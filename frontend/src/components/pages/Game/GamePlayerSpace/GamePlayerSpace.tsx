import { Box, styled } from "@mui/material";
import { GamePlayerLeft } from "./GamePlayerLeft";
import { GamePlayerRight } from "./GamePlayerRight";
import {
	SpadeA,
	HeartQ,
	DiamondK,
	ClubJ,
	FlippedCard,
} from "@/components/UI/Cards";
import { playersDataAtom, myIndexAtom } from "@/lib/states";
import { useAtom } from "jotai";
interface GamePlayerSpaceProps {
	position: "left" | "right";
}

export const GamePlayerSpace = ({ position }: GamePlayerSpaceProps) => {
	const [playersData] = useAtom(playersDataAtom);
	const [myIndex] = useAtom(myIndexAtom);

	const otherPlayersData = playersData?.filter((_, index) => index !== myIndex);

	return (
		<Container>
			{position === "left" && (
				<Wrapper>
					{otherPlayersData && otherPlayersData.length > 0 && (
						<GamePlayerLeft
							cards={[
								<SpadeA key="spadeA" />,
								<FlippedCard key="flippedCard" />,
							]}
							playerData={otherPlayersData[0]}
						/>
					)}
					{otherPlayersData && otherPlayersData.length > 1 && (
						<GamePlayerLeft
							cards={[
								<HeartQ key="spadeA" />,
								<FlippedCard key="flippedCard" />,
							]}
							playerData={otherPlayersData[1]}
						/>
					)}
				</Wrapper>
			)}
			{position === "right" && (
				<Wrapper>
					{otherPlayersData && otherPlayersData.length > 2 && (
						<GamePlayerRight
							cards={[
								<DiamondK key="spadeA" />,
								<FlippedCard key="flippedCard" />,
							]}
							playerData={otherPlayersData[2]}
						/>
					)}
					{otherPlayersData && otherPlayersData.length > 3 && (
						<GamePlayerRight
							cards={[
								<ClubJ key="spadeA" />,
								<FlippedCard key="flippedCard" />,
							]}
							playerData={otherPlayersData[3]}
						/>
					)}
				</Wrapper>
			)}
		</Container>
	);
};

const Container = styled(Box)({
	backgroundColor: "transparent",
	padding: 8,
});

const Wrapper = styled(Box)({
	display: "flex",
	flexDirection: "column",
	gap: 16,
});
