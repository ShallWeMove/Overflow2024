import { atom } from "jotai";
import { Casino, Lounge, GameTable } from "./types";

export const walletAtom = atom<any>(null);

export const casinoAtom = atom<Casino | null>(null);

export const loungeAtom = atom<Lounge | null>(null);

export const gameTableAtom = atom<GameTable | null>(null);

// 내 index 가져오기
export const myIndexAtom = atom((get) => {
	const gameTable = get(gameTableAtom);
	const userWalletAddress = get(walletAtom) != null ? get(walletAtom).address : null;


	const playerInfo = gameTable?.fields.gameStatus.fields.playerInfos.find(
		(playerInfo) => playerInfo.fields.playerAddress === userWalletAddress
	);

	return playerInfo?.fields.index ?? 0;
});

// 게임 플레이에 필요한 정보 가져오기
export const gamePlayBarAtom = atom((get) => {
	const gameTable = get(gameTableAtom);

	return gameTable?.fields.gameStatus.fields.gameInfo;
});

// 내 게임 정보 가져오기
export const userSpaceAtom = atom((get) => {
	const gameTable = get(gameTableAtom);
	const myIndex = get(myIndexAtom);
	const userInfo = gameTable?.fields.gameStatus.fields.playerInfos[myIndex];

	return userInfo;
});

// 테이블에 보여줄 정보 가져오기
export const tableAtom = atom((get) => {
	const gameTable = get(gameTableAtom);

	if (!gameTable) {
		return {
			totalBetAmount: 0,
			callAmount: 0,
		};
	}

	let numberOfPlayers = 0;
	let numberOfPlayerSeats = gameTable?.fields.playerSeats?.length ?? 0;
	for (let i = 0 ; i < numberOfPlayerSeats ; i++) {
		if (gameTable?.fields.playerSeats[i]?.fields.playerAddress != null) {
			numberOfPlayers++
		}
	}

	const currentTurnIndex =
		gameTable?.fields.gameStatus?.fields.gameInfo?.fields.currentTurnIndex ?? 0;
	const playerInfo =
		gameTable?.fields.gameStatus?.fields.playerInfos[currentTurnIndex];
	const totalBetAmount =
		Number(
			gameTable?.fields.gameStatus?.fields.moneyBoxInfo?.fields.totalBetAmount
		) ?? 0;
	const callAmount = Number(playerInfo?.fields.previousBetAmount) ?? 0;
	// const players = gameTable?.fields.playerSeats?.length ?? 0;
	const players = numberOfPlayers;
	const gamePlayingStatus =
		gameTable?.fields.gameStatus?.fields.gameInfo.fields.gamePlayingStatus;
	const currentPlayerAddress =
		gameTable?.fields.gameStatus?.fields.playerInfos[currentTurnIndex].fields
			.playerAddress;
	const managerPlayerAddress =
		gameTable?.fields.gameStatus?.fields.gameInfo.fields.managerPlayer;
	const betUnit = gameTable?.fields.gameStatus.fields.gameInfo.fields.betUnit
	const anteAmount = gameTable?.fields.gameStatus.fields.gameInfo.fields.anteAmount
	const winnerPlayer = gameTable?.fields.gameStatus.fields.gameInfo.fields.winnerPlayer

	return {
		totalBetAmount,
		callAmount,
		players,
		gamePlayingStatus,
		currentPlayerAddress,
		managerPlayerAddress,
		betUnit,
		anteAmount,
		winnerPlayer
	};
});

// 유저 정보 가져오기
export const playersDataAtom = atom((get) => {
	const gameTable = get(gameTableAtom);

	return gameTable?.fields.playerSeats;
});

export const playersInfoDataAtom = atom((get) => {
	const gameTable = get(gameTableAtom);

	return gameTable?.fields.gameStatus.fields.playerInfos;
});