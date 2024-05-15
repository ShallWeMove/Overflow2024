import { TransactionBlock } from "@mysten/sui.js/transactions";
import { SuiClient } from "@mysten/sui.js/client";

const TESTNET_ENDPOINT = "https://sui-testnet.nodeinfra.com";
const PACKAGE_ID =
	"0x29361f0cd734d9374decb131affea826682f801c37021dfe39c6832db839a513";
const CASINO_ID =
	"0x334708a551a301c25e866acd0434dd4b2c95dd491d1a528923146b10bbaadb77";
const LOUNGE_ID =
	"0x0bff035610796da88e3820d847a6cfc541a2916b981e0c34e29940bb2f2b5c38";
const MODULE = "cardgame";

const client = new SuiClient({ url: TESTNET_ENDPOINT });

// enter - called when the player enters the game table
export const enter = async (signer: any) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::enter`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(LOUNGE_ID), // lounge
		],
	});

	//TODO: signer setting
	client.signAndExecuteTransactionBlock({
		signer,
		transactionBlock: txb,
	});
};

// exit - called when the player exits the game table
export const exit = async (signer: any, gameTableId: string) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::exit`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(LOUNGE_ID), // lounge
			txb.object(gameTableId), // game table
		],
	});

	//TODO: signer setting
	client.signAndExecuteTransactionBlock({
		signer,
		transactionBlock: txb,
	});
};

// start - called when the game starts
export const start = async (signer: any, gameTableId: string) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::start`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(LOUNGE_ID), // lounge
			txb.object(gameTableId), // game table
		],
	});

	//TODO: signer setting
	client.signAndExecuteTransactionBlock({
		signer,
		transactionBlock: txb,
	});
};

// action - called when the player makes an action
//  one of [ANTE, BET, RAISE, CALL, CHECK]
export const action = async (
	signer: any,
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

	//TODO: signer setting
	client.signAndExecuteTransactionBlock({
		signer,
		transactionBlock: txb,
	});

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
export const fold = async (signer: any, gameTableId: string) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::fold`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(gameTableId), // game table
		],
	});

	//TODO: signer setting
	client.signAndExecuteTransactionBlock({
		signer,
		transactionBlock: txb,
	});
};

// settleUp - called after the game ends to calculate the winnings
export const settleUp = async (signer: any, gameTableId: string) => {
	const txb = new TransactionBlock();
	txb.moveCall({
		target: `${PACKAGE_ID}::${MODULE}::fold`,
		arguments: [
			txb.object(CASINO_ID), // casino
			txb.object(gameTableId), // game table
		],
	});

	//TODO: signer setting
	client.signAndExecuteTransactionBlock({
		signer,
		transactionBlock: txb,
	});
};
