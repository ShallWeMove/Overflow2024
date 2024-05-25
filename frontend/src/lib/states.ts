import { atom } from "jotai";
import { Casino, Lounge, GameTable } from "./types";

export const walletAtom = atom<any>(null);

export const casinoAtom = atom<Casino | null>(null);

export const loungeAtom = atom<Lounge | null>(null);

export const gameTableAtom = atom<GameTable | null>(null);

// 내 index 가져오기
export const myIndexAtom = atom((get) => {
	const gameTable = get(gameTableAtom);
	const userWalletAddress = get(walletAtom).address;

	const playerInfo = gameTable?.gameStatus.playerInfos.find(
		(playerInfo) => playerInfo.playerAddress === userWalletAddress
	);

	return playerInfo?.index ?? 0;
});

// 게임 플레이에 필요한 정보 가져오기
export const gamePlayBarAtom = atom((get) => {
	const gameTable = get(gameTableAtom);

	return gameTable?.gameStatus.gameInfo;
});

// 내 게임 정보 가져오기
export const userSpaceAtom = atom((get) => {
	const gameTable = get(gameTableAtom);
	const myIndex = get(myIndexAtom);
	const userInfo = gameTable?.gameStatus.playerInfos[myIndex];

	return userInfo;
});

// 테이블에 보여줄 정보 (총 배팅 금액, 콜 금액) 보여주기
export const tableAtom = atom((get) => {
	const gameTable = get(gameTableAtom);

	if (!gameTable) {
		return {
			totalBetAmount: 0,
			callAmount: 0,
		};
	}

	const currentTurnIndex =
		gameTable?.gameStatus?.gameInfo?.currentTurnIndex ?? 0;
	const playerInfo = gameTable?.gameStatus?.playerInfos[currentTurnIndex];
	const totalBetAmount =
		Number(gameTable?.gameStatus?.moneyBoxInfo?.totalBetAmount) ?? 0;
	const callAmount = Number(playerInfo?.previousBetAmount) ?? 0;

	return { totalBetAmount, callAmount };
});
