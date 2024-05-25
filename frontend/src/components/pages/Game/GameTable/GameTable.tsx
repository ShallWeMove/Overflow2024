
import {Box, styled} from "@mui/material";
import {GameInfo, Player} from "@/components/pages/Game/Game";
import {tableAtom} from "@/lib/states";
import {useAtom} from "jotai";
import {Table} from "@/components/pages/Game/GameTable/Table";
import {TotalAmount} from "@/components/pages/Game/GameTable/TotalAmount";

interface GameTableProps {
	players: Player[];
	gameInfo: null | GameInfo;
}

export const GameTable = ({ players, gameInfo }: GameTableProps) => {
	const [gameTable] = useAtom(tableAtom);
	return (
		<Container>
			<Table />
			<TotalAmount
				players={players}
				gameInfo={gameInfo}
				totalBetAmount={gameTable?.totalBetAmount}
				callAmount={gameTable?.callAmount}
			/>
		</Container>
	);
};

const Container = styled(Box)({
	display: "flex",
	flexDirection: "column",
	gap: 16,
});
