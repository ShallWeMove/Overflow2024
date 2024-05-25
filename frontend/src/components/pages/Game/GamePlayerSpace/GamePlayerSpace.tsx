import { Box, styled } from "@mui/material";
import { GamePlayerLeft } from "./GamePlayerLeft";
import { GamePlayerRight } from "./GamePlayerRight";
interface GamePlayerSpaceProps {
	position: "left" | "right";
}

export const GamePlayerSpace = ({ position }: GamePlayerSpaceProps) => {
	return (
		<Container>
			{position === "left" && (
				<Wrapper>
					<GamePlayerLeft />
					<GamePlayerLeft />
				</Wrapper>
			)}
			{position === "right" && (
				<Wrapper>
					<GamePlayerRight />
					<GamePlayerRight />
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
