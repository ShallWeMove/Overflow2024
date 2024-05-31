import {Box, styled} from "@mui/material";
import {tableAtom, userSpaceAtom} from "@/lib/states";
import {useAtom} from "jotai";
import {TotalAmount} from "@/components/pages/Game/GameTable/TotalAmount";
import {convertGameStatusTypeToInt, GameStatusType} from "@/api/game";
import {SettleUpButton} from "@/components/pages/Game/GamePlayBar/SettleUpButton";

interface GameTableProps {
	gameTableId: string;
}

export const GameTable = ({ gameTableId }: GameTableProps) => {
	const [tableInfo] = useAtom(tableAtom);
	const [playerInfo] = useAtom(userSpaceAtom);

	return (
		<Container>
			<TotalAmount
				totalBetAmount={tableInfo?.totalBetAmount}
				callAmount={tableInfo?.callAmount}
				players={tableInfo?.players ?? 0}
				gameStatus={tableInfo?.gamePlayingStatus ?? 0}
				currentPlayerAddress={tableInfo?.currentPlayerAddress ?? ""}
				betUnit={tableInfo?.betUnit}
				anteAmount={tableInfo?.anteAmount}
				winnerPlayer={tableInfo?.winnerPlayer}
			/>
			{
				tableInfo?.gamePlayingStatus == convertGameStatusTypeToInt(GameStatusType.GAME_FINISHED) &&
				tableInfo?.winnerPlayer == playerInfo?.fields.playerAddress ?
					<WinnerBadge gameTableId={gameTableId} /> :
					<LoserBadge />
			}
		</Container>
	);
};

interface WinnerBadgeProps {
	gameTableId: string;
}

const WinnerBadge = ({ gameTableId }: WinnerBadgeProps) => {
	return (
		<Container>
			<h1>Win!!</h1>
			<p>You are the winner! settle up the game to get your reward.</p>
			<SettleUpButton gameTableId={gameTableId} />
		</Container>
	);
}

const LoserBadge = () => {
	return (
		<Container>
			<h1>Lose</h1>
		</Container>
	);
}

const Container = styled(Box)({
	display: "flex",
	flexDirection: "column",
	gap: 16,
});
