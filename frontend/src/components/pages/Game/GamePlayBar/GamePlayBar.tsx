import { Box, styled } from "@mui/material";
import { RaiseButton } from "./RaiseButton";
import { BetButton } from "./BetButton";
import { CallButton } from "./CallButton";
import { CheckButton } from "./CheckButton";
import { FoldButton } from "./FoldButton";
import { AnteButton } from "./AnteButton";

interface GamePlayBarProps {
	gameTableId: string;
}

export const GamePlayBar = ({gameTableId}: GamePlayBarProps) => {
	return (
		<Container>
			<AnteButton gameTableId={gameTableId} />
			<FoldButton />
			<BetButton />
			<CheckButton />
			<CallButton />
			<RaiseButton />
		</Container>
	);
};

const Container = styled(Box)({
	position: "absolute",
	padding: 12,
	bottom: 0,
	width: "80%",
	height: 100,
	display: "flex",
	flexDirection: "row",
	justifyContent: "center",
	alignItems: "center",
	gap: 24,
});
