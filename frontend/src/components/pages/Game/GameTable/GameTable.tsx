import { Box, styled } from "@mui/material";
import { tableAtom } from "@/lib/states";
import { useAtom } from "jotai";
import { TotalAmount } from "@/components/pages/Game/GameTable/TotalAmount";

export const GameTable = () => {
	const [tableInfo] = useAtom(tableAtom);
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
		</Container>
	);
};

const Container = styled(Box)({
	display: "flex",
	flexDirection: "column",
	gap: 16,
});
