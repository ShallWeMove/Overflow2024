import { TransactionBlock } from "@mysten/sui.js/transactions";
import { WalletContextState } from "@suiet/wallet-kit";
import { RSA } from "@/lib/rsa";
import config, { GameConfig } from "../../config/config";

const CASINO_ID =
	"0x02a394910e21ce11f32891d8f33232651c5d84b126ef5a7d606476afd07a1304";
const LOUNGE_ID =
	"0x4169e06afb311216ef5c001adfd6f5b185434896ed7ec9871dea20dc3ad97aea";
const GAME_LOGIC_PACKAGE_ID =
	// "0x4fe20afdac0b60838296679d777f7418348d6d99f9a8c38c318eb480c9df7508";
	"0x83375f7ddf8e848befd0febc4d05599faeef7c161e1b2c0b52fdbbf1a3d5d39c"; // three card poker

const MODULE = "cardgame";

export const LOCAL_STORAGE_ONGOING_GAME_KEY = 'ongoingGameId';
export const LOCAL_STORAGE_ONGOING_GAME_CONFIG_KEY = 'ongoingGameConfig';

export const GAME_TABLE_TYPE = `${config.core.packageId}::game_table::GameTable`;

// depositAmount - the amount of chips needed to enter the game
const depositAmountInMist = 1000000;
const gasBudgetInMist = 100000000;

// enter - called when the player enters the game table
export const enter = async (wallet: WalletContextState, gameConfig: GameConfig) => {
	const publicKey = new RSA().getPublicKey();
	const txb = new TransactionBlock();

	txb.setGasBudget(gasBudgetInMist);
	const [coin] = txb.splitCoins(txb.gas, [txb.pure(depositAmountInMist)]);

	txb.moveCall({
		target: `${gameConfig.packageId}::cardgame::enter`,
		arguments: [
			// casino
			txb.object(gameConfig.objects.casinoId),
			// lounge
			txb.object(gameConfig.objects.loungeId),
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
export const exit = async (wallet: WalletContextState, gameTableId: string, gameConfig: GameConfig) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${gameConfig.packageId}::cardgame::exit`,
		arguments: [
			txb.object(gameConfig.objects.casinoId), // casino
			txb.object(gameConfig.objects.loungeId), // lounge
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
export const ante = async (wallet: WalletContextState, gameTableId: string, gameConfig: GameConfig) => {
	const txb = new TransactionBlock();

	txb.setGasBudget(gasBudgetInMist);

	txb.moveCall({
		target: `${gameConfig.packageId}::cardgame::ante`,
		arguments: [
			// casino
			txb.object(gameConfig.objects.casinoId),
			// lounge
			txb.object(gameConfig.objects.loungeId),
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
	gameTableId: string,
	gameConfig: GameConfig
) => {
	const txb = new TransactionBlock();

	txb.setGasBudget(gasBudgetInMist);

	txb.moveCall({
		target: `${gameConfig.packageId}::cardgame::start`,
		arguments: [
			// casino
			txb.object(gameConfig.objects.casinoId),
			// lounge
			txb.object(gameConfig.objects.loungeId),
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
	chipCount: number,
	gameConfig: GameConfig
) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${gameConfig.packageId}::cardgame::action`,
		arguments: [
			txb.object(gameConfig.objects.casinoId), // casino
			txb.object(gameConfig.objects.loungeId), // lounge
			txb.pure(gameTableId), // game table id
			txb.pure(convertActionTypeToInt(actionType)), // action type
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
	gameTableId: string,
	gameConfig: GameConfig
) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${gameConfig.packageId}::cardgame::settle_up`,
		arguments: [
			txb.object(gameConfig.objects.casinoId), // casino
			txb.object(gameConfig.objects.loungeId), // lounge
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

