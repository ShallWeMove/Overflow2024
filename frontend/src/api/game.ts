import { TransactionBlock } from "@mysten/sui.js/transactions";
import { WalletContextState } from "@suiet/wallet-kit";
import { client } from "./object";
import { GetCoinsParams } from "@mysten/sui.js/client";
import { RSA } from "@/lib/rsa";

const PACKAGE_ID =
	"0x4053a7e19e497b9f6f3bfa9eff1dec36fec1a8d6f29fe613d9ce3b76976d0ca1";
const CASINO_ID =
	"0xb2c9a4652ed140b8592e252a14f9e1baf9e7add0d79a4eeb4c964ebb899f3866";
const LOUNGE_ID =
	"0x9386ebfa4b512b3b66f3845f2be7dc601f697207a1a6b4659c1351becd55bca6";
const MODULE = "cardgame";

// depositAmount - the amount of chips needed to enter the game
const depositAmountInMist = 1000000;
const gasBudgetInMist = 100000000;

// enter - called when the player enters the game table
export const enter = async (wallet: WalletContextState) => {
	const publicKey = new RSA().getPublicKey();
	const txb = new TransactionBlock();

	txb.setGasBudget(gasBudgetInMist);
	const [coin] = txb.splitCoins(txb.gas, [txb.pure(depositAmountInMist)]);

	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::enter`,
		arguments: [
			// casino
			txb.object(CASINO_ID),
			// lounge
			txb.object(LOUNGE_ID),
			// public key as a string
			txb.pure(publicKey.toString()),
			// deposit
			coin,
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
			options: {
				showInput: true,
				showEffects: true,
				showEvents: true,
			}
		});
		console.log("'enter' transaction result: ", res);
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

// ante - called when the player antes.
// 	After all players have anted, manager player can start the game.
export const ante = async (
	wallet: WalletContextState,
	gameTableId: string
) => {
	const txb = new TransactionBlock();

	txb.setGasBudget(gasBudgetInMist);

	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::ante`,
		arguments: [
			// casino
			txb.object(CASINO_ID),
			// lounge
			txb.object(LOUNGE_ID),
			// game table
			txb.object(gameTableId),
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
			options: {
				showInput: true,
				showEffects: true,
				showEvents: true,
			}
		});
		console.log("'ante' transaction result: ", res);
		return res;
	} catch (e) {
		console.error("'ante' transaction failed", e);
	}
}

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
