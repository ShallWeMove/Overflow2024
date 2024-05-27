import { Box, styled } from "@mui/material";
import { RaiseButton } from "./RaiseButton";
import { BetButton } from "./BetButton";
import { CallButton } from "./CallButton";
import { CheckButton } from "./CheckButton";
import { FoldButton } from "./FoldButton";
import { ExitButton } from "./ExitButton";
import { AnteButton } from "./AnteButton";
import {StartButton} from "@/components/pages/Game/GamePlayBar/StartButton";

interface GamePlayBarProps {
	gameTableId: string;
}

export const GamePlayBar = ({gameTableId}: GamePlayBarProps) => {
	return (
		<Container>
			<StartButton gameTableId={gameTableId} />
			<AnteButton gameTableId={gameTableId} />
			<FoldButton gameTableId={gameTableId} value={1000} />
			<BetButton gameTableId={gameTableId} value={1000} />
			<CheckButton gameTableId={gameTableId} value={1000} />
			<CallButton gameTableId={gameTableId} value={1000} />
			<RaiseButton gameTableId={gameTableId} value={1000} />
			<ExitButton gameTableId={gameTableId} />
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
