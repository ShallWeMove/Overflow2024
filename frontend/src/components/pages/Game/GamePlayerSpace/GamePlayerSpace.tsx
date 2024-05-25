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
interface GamePlayerSpaceProps {
	position: "left" | "right";
}

export const GamePlayerSpace = ({ position }: GamePlayerSpaceProps) => {
	return (
		<Container>
			{position === "left" && (
				<Wrapper>
					<GamePlayerLeft
						cards={[<SpadeA key="spadeA" />, <FlippedCard key="flippedCard" />]}
					/>
					<GamePlayerLeft
						cards={[<HeartQ key="spadeA" />, <FlippedCard key="flippedCard" />]}
					/>
				</Wrapper>
			)}
			{position === "right" && (
				<Wrapper>
					<GamePlayerRight
						cards={[
							<DiamondK key="spadeA" />,
							<FlippedCard key="flippedCard" />,
						]}
					/>
					<GamePlayerRight
						cards={[<ClubJ key="spadeA" />, <FlippedCard key="flippedCard" />]}
					/>
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
