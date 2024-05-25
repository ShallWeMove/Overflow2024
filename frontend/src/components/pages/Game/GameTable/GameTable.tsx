import {Box, styled, Typography} from "@mui/material";
import {GameInfo, GameStatus, Player} from "@/components/pages/Game/Game";
import {useState} from "react";

interface GameTableProps {
	players: Player[];
	gameInfo: null | GameInfo;
}

export const GameTable = ({ players, gameInfo }: GameTableProps) => {
	const [currentPlayer, setCurrentPlayer] = useState<Player | null>(null);
	if (gameInfo?.currentTurnIndex) {
		setCurrentPlayer(players[gameInfo.currentTurnIndex]);
	}

	return (
		<Container>
			<Table />
			<TotalAmount>
				<Wrapper>
					<Typography color="#C1CCDC" fontWeight={700}>
						Total
					</Typography>
					<Typography color="#C1CCDC" fontWeight={700}>
						5000 SUI
					</Typography>
				</Wrapper>
				<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
				<Wrapper>
					<Typography color="#C1CCDC" fontWeight={700}>
						Call
					</Typography>
					<Typography color="#C1CCDC" fontWeight={700}>
						0 SUI
					</Typography>
				</Wrapper>
				<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
				<Wrapper>
					<Typography color="#C1CCDC" fontWeight={700}>
						Players
					</Typography>
					<Typography color="#C1CCDC" fontWeight={700}>
						{players.length} Players
					</Typography>
				</Wrapper>
				<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
				<Wrapper>
					<Typography color="#C1CCDC" fontWeight={700}>
						Game Status
					</Typography>
					<Typography color="#C1CCDC" fontWeight={700}>
						{gameInfo?.gamePlayingStatus === GameStatus.PRE_GAME ? "Pre Game" : gameInfo?.gamePlayingStatus === GameStatus.IN_GAME ? "In Game" : "Game Finished"}
					</Typography>
				</Wrapper>
				<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
				<Wrapper>
					<Typography color="#C1CCDC" fontWeight={700}>
						Current Turn
					</Typography>
					<Typography color="#C1CCDC" fontWeight={700}>
						{currentPlayer?.address}
					</Typography>
				</Wrapper>
			</TotalAmount>
		</Container>
	);
};

const Container = styled(Box)({
	display: "flex",
	flexDirection: "column",
	gap: 16,
});

const Table = styled(Box)({});

const TotalAmount = styled(Box)({
	display: "flex",
	flexDirection: "column",
	border: "2px solid #C1CCDC",
	borderRadius: 8,
	width: 400,
	height: 80,
});

const Wrapper = styled(Box)({
	display: "flex",
	padding: 8,
	alignItems: "center",
	justifyContent: "space-between",
	flexGrow: 1,
});
