import { TransactionBlock } from "@mysten/sui.js/transactions";
import { WalletContextState } from "@suiet/wallet-kit";
import { client } from "./object";
import { GetCoinsParams } from "@mysten/sui.js/client";
import { RSA } from "@/lib/rsa";

const PACKAGE_ID =
	"0x94ccb3f97236f52229a8d09d270f12334780e2a3885b9593f4498a9f24e06ea2";
const CASINO_ID =
	"0x710b67fc7d0a20870d3c895e164a2170b3a67cf0658ff87b524b6b54440eb7b4";
const LOUNGE_ID =
	"0xffbc0faf2519428f315900d3b213c8b2cf10e109dee7323bb3497193233a685c";
const MODULE = "cardgame";

export const GAME_TABLE_TYPE = `${PACKAGE_ID}::game_table::GameTable`

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
				showObjectChanges: true,
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
			// game table id as a string
			txb.pure(gameTableId),
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
			options: {
				showInput: true,
				showEffects: true,
				showEvents: true,
				showObjectChanges: true,
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

	txb.setGasBudget(gasBudgetInMist);

	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::start`,
		arguments: [
			// casino
			txb.object(CASINO_ID),
			// lounge
			txb.object(LOUNGE_ID),
			// game table as a string
			txb.pure(gameTableId),
		],
	});

	try {
		const res = wallet.signAndExecuteTransactionBlock({
			transactionBlock: txb,
			options: {
				showInput: true,
				showEffects: true,
				showEvents: true,
				showObjectChanges: true,
			}
		});
		console.log("'start' transaction result: ", res);
		return res;
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
			txb.object(LOUNGE_ID), // lounge
			txb.pure(gameTableId), // game table id
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
	BET = "BET",
	CHECK = "CHECK",
	CALL = "CALL",
	RAISE = "RAISE",
	FOLD = "FOLD",
}

const convertActionTypeToInt = (actionType: ActionType): number => {
	switch (actionType) {
		// TODO: sync each number with the contract
		case ActionType.BET:
			return 21;
		case ActionType.CHECK:
			return 22;
		case ActionType.CALL:
			return 23;
		case ActionType.RAISE:
			return 24;
		case ActionType.FOLD:
			return 25;
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
