import { TransactionBlock } from "@mysten/sui.js/transactions";
import { WalletContextState } from "@suiet/wallet-kit";

const PACKAGE_ID= "0x29361f0cd734d9374decb131affea826682f801c37021dfe39c6832db839a513"
const CASINO_ID = "0x334708a551a301c25e866acd0434dd4b2c95dd491d1a528923146b10bbaadb77"
const LOUNGE_ID = "0x0bff035610796da88e3820d847a6cfc541a2916b981e0c34e29940bb2f2b5c38"
const MODULE = "cardgame"

// enter - called when the player enters the game table
export const enter = async(
    wallet: WalletContextState,
) => {
    const txb = new TransactionBlock();
    txb.moveCall({
        target: `${PACKAGE_ID}::${MODULE}::enter`,
        arguments: [
            txb.object(CASINO_ID), // casino
            txb.object(LOUNGE_ID), // lounge
        ],
    });

    try {
        const res = wallet.signAndExecuteTransactionBlock({
            transactionBlock: txb,
        })
        console.log("enter transaction result: ", res)
    } catch (e) {
        console.error("'enter' transaction failed", e)
    }
}

// exit - called when the player exits the game table
export const exit = async(
    wallet: WalletContextState,
    gameTableId: string,
) => {
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
        })
        console.log("exit transaction result: ", res)
    } catch (e) {
        console.error("'exit' transaction failed", e)
    }
}

// start - called when the game starts
export const start = async(
    wallet: WalletContextState,
    gameTableId: string,
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
        })
        console.log("start transaction result: ", res)
    } catch (e) {
        console.error("'start' transaction failed", e)
    }
}

// action - called when the player makes an action
//  one of [ANTE, BET, RAISE, CALL, CHECK]
export const action = async(
    wallet: WalletContextState,
    gameTableId: string,
    actionType: ActionType,
    withNewCard: boolean,
    chipCount: number,
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
        })
        console.log("action transaction result: ", res)
    } catch (e) {
        console.error("'action' transaction failed", e)
    }

    return "gameTableId";
}
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
}

// fold - called when the player folds
export const fold = async(
    wallet: WalletContextState,
    gameTableId: string,
) => {
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
        })
        console.log("fold transaction result: ", res)
    } catch (e) {
        console.error("'fold' transaction failed", e)
    }
}

// settleUp - called after the game ends to calculate the winnings
export const settleUp = async(
    wallet: WalletContextState,
    gameTableId: string,
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
        })
        console.log("settle_up transaction result: ", res)
    } catch (e) {
        console.error("'settle_up' transaction failed", e)
    }
}
