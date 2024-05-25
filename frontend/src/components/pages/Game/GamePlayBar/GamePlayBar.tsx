import { Box, styled } from "@mui/material";
import { RaiseButton } from "./RaiseButton";
import { BetButton } from "./BetButton";
import { CallButton } from "./CallButton";
import { CheckButton } from "./CheckButton";
import { FoldButton } from "./FoldButton";
import { gamePlayBarAtom } from "@/lib/states";
import { useAtom } from "jotai";

// 배팅 금액 정보 가져오기

export const GamePlayBar = () => {
	const [gameTable] = useAtom(gamePlayBarAtom);
	return (
		<Container>
			<FoldButton />
			<BetButton value={1000} />
			<CheckButton />
			<CallButton value={1000} />
			<RaiseButton value={1000} />
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
