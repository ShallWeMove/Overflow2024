import { useRouter } from "next/router";
import { useEffect } from "react";
import { Box, Grid, styled } from "@mui/material";
import { getObject } from "@/api/object";
import { GamePlayerSpace } from "./GamePlayerSpace/GamePlayerSpace";
import { UserSpace } from "./UserSpace/UserSpace";
import { GamePlayBar } from "./GamePlayBar/GamePlayBar";
import { GameTable } from "./GameTable/GameTable";
import { gameTableAtom } from "@/lib/states";
import { useAtom } from "jotai";
import { convertKeys } from "@/lib/formatting";
import {
	SpadeA,
	HeartQ,
	DiamondK,
	ClubJ,
	FlippedCard,
} from "@/components/UI/Cards";
import { CardPlaceHolder } from "@/components/UI/CardPlaceHolder";
import { playersDataAtom, myIndexAtom } from "@/lib/states";

export const Game = () => {
	const gameInfoRefreshIntervalMs = 1000;

	const router = useRouter();
	const value = router.query.objectId;
	const query = Array.isArray(value) ? value[0] : value;

	const [, setGameTable] = useAtom(gameTableAtom);

	const [playersData] = useAtom(playersDataAtom);
	const [myIndex] = useAtom(myIndexAtom);

	const playerIndex = (relativeIndex : number) => {
		if (playersData != null && relativeIndex > playersData.length - 1) {
			return relativeIndex - playersData.length;
		} else if (playersData != null && relativeIndex < 0) {
			return relativeIndex + playersData.length;
		}
		return relativeIndex;
	}

	let gameTableId = "";
	if (query) {
		gameTableId = query;
	}

	useEffect(() => {
		const interval = setInterval(async () => {
			const data = await getObject(gameTableId);
			if (!data) return;

			setGameTable(convertKeys(data.content));
		}, gameInfoRefreshIntervalMs);

		return () => clearInterval(interval);
	}, [gameTableId, setGameTable]);

	return (
		<Container>
			<Wrapper container>
				<Grid xs={4}>
					<GamePlayerWrapper>
						{playersData && playersData.length > 0 && (
							<CardPlaceHolder
								position="left"	
								value={1000}
								cards={[
									<SpadeA key="spadeA" />,
									<FlippedCard key="flippedCard" />,
								]}
								playerData={playersData[playerIndex(myIndex - 2)]}
							/>
						)}
						{playersData && playersData.length > 0 && (
							<CardPlaceHolder
								position="left"	
								value={1000}
								cards={[
									<SpadeA key="spadeA" />,
									<FlippedCard key="flippedCard" />,
								]}
								playerData={playersData[playerIndex(myIndex - 1)]}
							/>
						)}
					</GamePlayerWrapper>
				</Grid>
				<Grid
					xs={4}
					sx={{
						display: "flex",
						justifyContent: "center",
					}}
				>
					<GameTable />
				</Grid>
				<Grid xs={4}>
					<GamePlayerWrapper>
						{playersData && playersData.length > 0 && (
							<CardPlaceHolder
								position="left"	
								value={1000}
								cards={[
									<SpadeA key="spadeA" />,
									<FlippedCard key="flippedCard" />,
								]}
								playerData={playersData[playerIndex(myIndex + 2)]}
							/>
						)}
						{playersData && playersData.length > 0 && (
							<CardPlaceHolder
								position="left"	
								value={1000}
								cards={[
									<SpadeA key="spadeA" />,
									<FlippedCard key="flippedCard" />,
								]}
								playerData={playersData[playerIndex(myIndex + 1)]}
							/>
						)}
					</GamePlayerWrapper>
				</Grid>
			</Wrapper>
			{playersData && playersData.length > 0 && (
				<CardPlaceHolder
					position="left"	
					value={1000}
					cards={[
						<SpadeA key="spadeA" />,
						<FlippedCard key="flippedCard" />,
					]}
					playerData={playersData[myIndex]}
				/>
			)}
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
	backgroundImage: "url('/background.png')",
	backgroundSize: "cover",
	backgroundPosition: "center",
});

const Wrapper = styled(Grid)({
	width: "100%",
	display: "flex",
	justifyContent: "space-between",
});

const GamePlayerWrapper = styled(Box)({
	display: "flex",
	flexDirection: "column",
	gap: 16,
});