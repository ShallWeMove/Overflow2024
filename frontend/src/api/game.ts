import { TransactionBlock } from "@mysten/sui.js/transactions";
import { WalletContextState } from "@suiet/wallet-kit";
import { client } from "./object";
import { GetCoinsParams } from "@mysten/sui.js/client";

const PACKAGE_ID =
	"0x9aaf5ea1dcda8ec3f23d3e9a583bc770e5d22e59ecf4ffe0889918dd768e50fe";
const CASINO_ID =
	"0x100ca0103d9d06c76e29e2b114773e2ef23dfadca5b31d211965f432141059b7";
const LOUNGE_ID =
	"0xaad3c53cb7d9d28ac4ed7d9f5e656111295e0aeaa6d6d2c471a29ab1264426a3";
const MODULE = "cardgame";

// enter - called when the player enters the game table
export const enter = async (wallet: WalletContextState) => {
	const PUBLIC_KEY = localStorage.getItem("publicKey") ?? "";
	console.log("wallet: ", wallet);
	const getCoinsParams: GetCoinsParams = {
		owner: wallet?.address ?? "",
	};
	const MONEY = await client.getCoins(getCoinsParams);
	const coinIds = MONEY.data.map((coin) => coin.coinObjectId);
	console.log("public key: ", PUBLIC_KEY);
	console.log("money: ", MONEY);

	if (MONEY.data.length < 1) {
		return;
	}

	const txb = new TransactionBlock();
	const [money] = txb.mergeCoins(coinIds[0], coinIds.slice(1));

	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::enter`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(LOUNGE_ID), // lounge
			txb.object(PUBLIC_KEY), // public key
			money, // money
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
		});
		console.log("enter transaction result: ", res);
		return res;
	} catch (e) {
		console.error("'enter' transaction failed", e);
	}
};

// exit - called when the player exits the game table
export const exit = async (wallet: WalletContextState, gameTableId: string) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::exit`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(LOUNGE_ID), // lounge
			txb.object(gameTableId), // game table
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
		});
		console.log("exit transaction result: ", res);
	} catch (e) {
		console.error("'exit' transaction failed", e);
	}
};

// start - called when the game starts
export const start = async (
	wallet: WalletContextState,
	gameTableId: string
) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::start`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(LOUNGE_ID), // lounge
			txb.object(gameTableId), // game table
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
		});
		console.log("start transaction result: ", res);
	} catch (e) {
		console.error("'start' transaction failed", e);
	}
};

// action - called when the player makes an action
//  one of [ANTE, BET, RAISE, CALL, CHECK]
export const action = async (
	wallet: WalletContextState,
	gameTableId: string,
	actionType: ActionType,
	withNewCard: boolean,
	chipCount: number
): Promise<string> => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::action`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(gameTableId), // game table
			txb.pure(convertActionTypeToInt(actionType)), // action type
			txb.pure(withNewCard), // with new card
			txb.pure(chipCount), // chip count
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
		});
		console.log("action transaction result: ", res);
	} catch (e) {
		console.error("'action' transaction failed", e);
	}

	return "gameTableId";
};

export enum ActionType {
	Ante = "ANTE",
	Bet = "BET",
	Raise = "RAISE",
	Call = "CALL",
	Check = "CHECK",
}

const convertActionTypeToInt = (actionType: ActionType): number => {
	switch (actionType) {
		// TODO: sync each number with the contract
		case ActionType.Ante:
			return 0;
		case ActionType.Bet:
			return 1;
		case ActionType.Call:
			return 2;
		case ActionType.Raise:
			return 3;
		case ActionType.Check:
			return 4;
		default:
			throw new Error("Invalid action type");
	}
};

// fold - called when the player folds
export const fold = async (wallet: WalletContextState, gameTableId: string) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::fold`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(gameTableId), // game table
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
		});
		console.log("fold transaction result: ", res);
	} catch (e) {
		console.error("'fold' transaction failed", e);
	}
};

// settleUp - called after the game ends to calculate the winnings
export const settleUp = async (
	wallet: WalletContextState,
	gameTableId: string
) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::settle_up`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(gameTableId), // game table
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
		});
		console.log("settle_up transaction result: ", res);
	} catch (e) {
		console.error("'settle_up' transaction failed", e);
	}
};
