import { useRouter } from "next/router";
import { useState, useEffect } from "react";
import { Box, styled } from "@mui/material";
import { getObject } from "@/api/object";
import { Dealer } from "./Dealer/Dealer";
import { GamePlayerSpace } from "./GamePlayerSpace/GamePlayerSpace";
import { UserSpace } from "./UserSpace/UserSpace";
import { GamePlayBar } from "./GamePlayBar/GamePlayBar";
import { GameTable } from "./GameTable/GameTable";

export interface Player {
	address: string;
}
export interface GameInfo {
	anteAmount: string;
	availGameSeats: number;
	betUnit: string;
	currentRound: number;
	currentTurnIndex: number;
	gamePlayingStatus: GameStatus;
	gameSeats: number;
	managerPlayer: null | string;
	maxRound: number;
	previousTurnIndex: number;
	winnerPlayer: null | string;
}

export enum GameStatus {
	PRE_GAME = 0,
	IN_GAME = 1,
	GAME_FINISHED = 2
}

const convertGameStatus = (status: number): GameStatus => {
	switch (status) {
		case 0:
			return GameStatus.PRE_GAME;
		case 1:
			return GameStatus.IN_GAME;
		case 2:
			return GameStatus.GAME_FINISHED;
		default:
			return GameStatus.PRE_GAME;

	}
}

export const Game = () => {
	const gameInfoRefreshIntervalMs = 1000;

	const router = useRouter();
	const value = router.query.objectId;
	const query = Array.isArray(value) ? value[0] : value;

	let gameTableId = "";
	if (query) {
		gameTableId = query;
	}

	const [players, setPlayers] = useState<Player[]>([]);
	const [gameInfo, setGameInfo] = useState<GameInfo | null>(null);

	// const [loading, setLoading] = useState(false);

	useEffect(() => {
		const interval = setInterval(async () => {
			const data = await getObject(gameTableId);
			if(!data) return;

			if(data.content?.fields?.player_seats) {
				const playerSeats = data.content.fields.player_seats;
				let newPlayers: Player[] = [];

				for (let i = 0; i < playerSeats.length; i++) {
					if (playerSeats[i]?.fields?.player_address) {
						const newPlayer: Player = {
							address: playerSeats[i].fields.player_address,
						}
						newPlayers.push(newPlayer);
					}
				}

				if (players.length !== newPlayers.length) {
					setPlayers(newPlayers);
				}
			}

			if(data.content?.fields?.game_status?.fields?.game_info) {
				const newGameInfo: GameInfo = {
					anteAmount: data.content.fields.game_status.fields.game_info.fields.ante_amount,
					availGameSeats: data.content.fields.game_status.fields.game_info.fields.avail_game_seats,
					betUnit: data.content.fields.game_status.fields.game_info.fields.bet_unit,
					currentRound: data.content.fields.game_status.fields.game_info.fields.current_round,
					currentTurnIndex: data.content.fields.game_status.fields.game_info.fields.current_turn_index,
					gamePlayingStatus: convertGameStatus(data.content.fields.game_status.fields.game_info.fields.game_playing_status),
					gameSeats: data.content.fields.game_status.fields.game_info.fields.game_seats,
					managerPlayer: data.content.fields.game_status.fields.game_info.fields.manager_player,
					maxRound: data.content.fields.game_status.fields.game_info.fields.max_round,
					previousTurnIndex: data.content.fields.game_status.fields.game_info.fields.previous_turn_index,
					winnerPlayer: data.content.fields.game_status.fields.game_info.fields.winner_player,
				};

				if ((gameInfo === null) || (gameInfo.currentTurnIndex !== newGameInfo.currentTurnIndex)) {
					console.log("gameInfo:", newGameInfo)
					setGameInfo(newGameInfo);
				}
			}
		}, gameInfoRefreshIntervalMs);
		return () => clearInterval(interval);
	}, [gameTableId]);

	return (
		<Container>
			<Wrapper>
				<GamePlayerSpace position="left" />
				<GameTable
					players={players}
					gameInfo={gameInfo}
				/>
				<GamePlayerSpace position="right" />
			</Wrapper>
			<UserSpace value={1000} />
			<GamePlayBar gameTableId={gameTableId} />
		</Container>
	);
};

const Container = styled(Box)({
	position: "relative",
	display: "flex",
	flexDirection: "column",
	justifyContent: "center",
	alignItems: "center",
	height: "100vh",
	overflow: "hidden",
	backgroundImage: "url('/background.jpg')",
	backgroundSize: "cover",
	backgroundPosition: "center",
});

const Wrapper = styled(Box)({
	width: "100%",
	display: "flex",
	justifyContent: "space-between",
});
