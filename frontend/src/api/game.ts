import { TransactionBlock } from "@mysten/sui.js/transactions";
import { WalletContextState } from "@suiet/wallet-kit";
import { RSA } from "@/lib/rsa";


const ORIGINAL_CARDGAME_PACKAGE_ID =
	"0xd10b25e4b34a013949d22666cf115cd01c2b0714585cd260122cb3e627893b63";
const LATEST_CARDGAME_PACKAGE_ID =
	"0x40ac31cb39dfb38ca7953f62bdd430c3d1a2e671047de0b91fbaafe32275eb17";
const CASINO_ID =
	"0x6a7880707b5edcda161d695e98ded49ac18596d9e22d50e8cbc62583cd54d452";
const LOUNGE_ID =
	"0xba94f4539a865d578076d1e9800bf49219beda80e1d67e570ec016f08a6d3a90";
const GAME_LOGIC_PACKAGE_ID =
	"0x4fe20afdac0b60838296679d777f7418348d6d99f9a8c38c318eb480c9df7508";

const MODULE = "cardgame";

export const LOCAL_STORAGE_ONGOING_GAME_KEY = 'ongoingGameId';

export const GAME_TABLE_TYPE = `${ORIGINAL_CARDGAME_PACKAGE_ID}::game_table::GameTable`;

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
		target: `${GAME_LOGIC_PACKAGE_ID}::${MODULE}::enter`,
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
			},
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
		target: `${GAME_LOGIC_PACKAGE_ID}::${MODULE}::exit`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(LOUNGE_ID), // lounge
			txb.pure(gameTableId), // game table
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
			},
		});
		console.log("exit transaction result: ", res);
		return res;
	} catch (e) {
		console.error("'exit' transaction failed", e);
	}
};

// ante - called when the player antes.
// 	After all players have anted, manager player can start the game.
export const ante = async (wallet: WalletContextState, gameTableId: string) => {
	const txb = new TransactionBlock();

	txb.setGasBudget(gasBudgetInMist);

	txb.moveCall({
		target: `${GAME_LOGIC_PACKAGE_ID}::${MODULE}::ante`,
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
			},
		});
		console.log("'ante' transaction result: ", res);
		return res;
	} catch (e) {
		console.error("'ante' transaction failed", e);
	}
};

// start - called when the game starts
export const start = async (
	wallet: WalletContextState,
	gameTableId: string
) => {
	const txb = new TransactionBlock();

	txb.setGasBudget(gasBudgetInMist);

	txb.moveCall({
		target: `${GAME_LOGIC_PACKAGE_ID}::${MODULE}::start`,
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
			},
		});
		console.log("'start' transaction result: ", res);
		return res;
	} catch (e) {
		console.error("'start' transaction failed", e);
	}
};

// action - called when the player makes an action
//  one of [BET, RAISE, CALL, CHECK]
export const action = async (
	wallet: WalletContextState,
	gameTableId: string,
	actionType: ActionType,
	withNewCard: boolean,
	chipCount: number
) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${GAME_LOGIC_PACKAGE_ID}::${MODULE}::action`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(LOUNGE_ID), // lounge
			txb.pure(gameTableId), // game table id
			txb.pure(convertActionTypeToInt(actionType)), // action type
			// txb.pure(withNewCard), // with new card
			txb.pure(chipCount), // chip count
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
			},
		});
		console.log("action transaction result: ", res);
		return res;
	} catch (e) {
		console.error("'action' transaction failed", e);
	}
};

// settleUp - called after the game ends to calculate the winnings
export const settleUp = async (
	wallet: WalletContextState,
	gameTableId: string
) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${GAME_LOGIC_PACKAGE_ID}::${MODULE}::settle_up`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(LOUNGE_ID), // lounge
			txb.pure(gameTableId), // game table
			txb.object("0x0000000000000000000000000000000000000000000000000000000000000008") // random object
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
			},
		});
		console.log("settle_up transaction result: ", res);
		return res;
	} catch (e) {
		console.error("'settle_up' transaction failed", e);
	}
};

export enum GameStatusType {
	PRE_GAME = "PRE GAME",
	IN_GAME = "IN GAME",
	GAME_FINISHED = "GAME_FINISHED",
}

export enum PlayingStatusType {
	EMPTY = "EMPTY",
	ENTER = "ENTER",
	READY = "READY",
	PLAYING = "PLAYING",
	GAME_END = "GAME_END",
}

export enum ActionType {
	NONE = "NONE",
	BET = "BET",
	CHECK = "CHECK",
	CALL = "CALL",
	RAISE = "RAISE",
	FOLD = "FOLD",
	EXIT = "EXIT",
}

export const convertIntToGameStatusType = (
	gameStatusTypeNumber: number
): GameStatusType => {
	switch (gameStatusTypeNumber) {
		case 0:
			return GameStatusType.PRE_GAME;
		case 1:
			return GameStatusType.IN_GAME;
		case 2:
			return GameStatusType.GAME_FINISHED;
		default:
			throw new Error("Invalid game status type number");
	}
};

export const convertGameStatusTypeToInt = (
	gameStatusType: GameStatusType
): number => {
	switch (gameStatusType) {
		case GameStatusType.PRE_GAME:
			return 0;
		case GameStatusType.IN_GAME:
			return 1;
		case GameStatusType.GAME_FINISHED:
			return 2;
		default:
			throw new Error("Invalid game status type");
	}
};

export const convertPlayingStatusTypeToInt = (
	playingStatusType: PlayingStatusType
): number => {
	switch (playingStatusType) {
		case PlayingStatusType.EMPTY:
			return 10;
		case PlayingStatusType.ENTER:
			return 11;
		case PlayingStatusType.READY:
			return 12;
		case PlayingStatusType.PLAYING:
			return 13;
		case PlayingStatusType.GAME_END:
			return 14;
		default:
			throw new Error("Invalid playing status type");
	}
};

export const convertIntToPlayingStatusType = (
	playingStatusTypeNumber: number
): PlayingStatusType => {
	switch (playingStatusTypeNumber) {
		case 10:
			return PlayingStatusType.EMPTY;
		case 11:
			return PlayingStatusType.ENTER;
		case 12:
			return PlayingStatusType.READY;
		case 13:
			return PlayingStatusType.PLAYING;
		case 14:
			return PlayingStatusType.GAME_END;
		default:
			throw new Error("Invalid playing status type number");
	}
};

const convertActionTypeToInt = (actionType: ActionType): number => {
	switch (actionType) {
		case ActionType.NONE:
			return 20;
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
		case ActionType.EXIT:
			return 26;
		default:
			throw new Error("Invalid action type");
	}
};

export const convertIntToActionType = (
	actionTypeNumber: number
): ActionType => {
	switch (actionTypeNumber) {
		case 20:
			return ActionType.NONE;
		case 21:
			return ActionType.BET;
		case 22:
			return ActionType.CHECK;
		case 23:
			return ActionType.CALL;
		case 24:
			return ActionType.RAISE;
		case 25:
			return ActionType.FOLD;
		case 26:
			return ActionType.EXIT;
		default:
			throw new Error("Invalid action type number");
	}
};

