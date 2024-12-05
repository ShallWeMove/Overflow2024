import { Box, styled } from "@mui/material";
import { RaiseButton } from "./RaiseButton";
import { BetButton } from "./BetButton";
import { CallButton } from "./CallButton";
import { CheckButton } from "./CheckButton";
import { FoldButton } from "./FoldButton";
import { ExitButton } from "./ExitButton";
import { AnteButton } from "./AnteButton";
import { StartButton } from "@/components/pages/Game/GamePlayBar/StartButton";
import { SettleUpButton } from "./SettleUpButton";
import { playersInfoDataAtom, tableAtom, userSpaceAtom } from "@/lib/states";
import { useAtom } from "jotai";
import { GameStatusType, PlayingStatusType, convertGameStatusTypeToInt, convertPlayingStatusTypeToInt } from "@/api/game";

interface GamePlayBarProps {
	gameTableId: string;
}

export const GamePlayBar = ({ gameTableId }: GamePlayBarProps) => {
	const [tableInfo] = useAtom(tableAtom);
	const [playerInfo] = useAtom(userSpaceAtom);
	const [playerInfos] = useAtom(playersInfoDataAtom);

	return (
		<Container>
			{
				tableInfo.gamePlayingStatus == convertGameStatusTypeToInt(GameStatusType.PRE_GAME) &&
				playerInfo?.fields.playingStatus == convertPlayingStatusTypeToInt(PlayingStatusType.ENTER) &&
				<AnteButton gameTableId={gameTableId} />
			}
			{
				tableInfo.gamePlayingStatus == convertGameStatusTypeToInt(GameStatusType.PRE_GAME) &&
				tableInfo.managerPlayerAddress == playerInfo?.fields.playerAddress &&
				<StartButton gameTableId={gameTableId} />
			}
			{
				tableInfo.gamePlayingStatus == convertGameStatusTypeToInt(GameStatusType.IN_GAME) &&
				<BetButton gameTableId={gameTableId} />
			}
			{
				tableInfo.gamePlayingStatus == convertGameStatusTypeToInt(GameStatusType.IN_GAME) &&
				<CheckButton gameTableId={gameTableId} />
			}
			{
				tableInfo.gamePlayingStatus == convertGameStatusTypeToInt(GameStatusType.IN_GAME) &&
				<CallButton gameTableId={gameTableId} />
			}
			{
				tableInfo.gamePlayingStatus == convertGameStatusTypeToInt(GameStatusType.IN_GAME) &&
				<RaiseButton gameTableId={gameTableId} />
			}
			{
				tableInfo.gamePlayingStatus == convertGameStatusTypeToInt(GameStatusType.IN_GAME) &&
				<FoldButton gameTableId={gameTableId} />
			}
			<ExitButton gameTableId={gameTableId} />
			{
				tableInfo.gamePlayingStatus == convertGameStatusTypeToInt(GameStatusType.GAME_FINISHED) &&
				tableInfo.winnerPlayer == playerInfo?.fields.playerAddress &&
				<SettleUpButton gameTableId={gameTableId} />
			}
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
