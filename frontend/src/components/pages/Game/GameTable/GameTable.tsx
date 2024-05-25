import { Box, styled } from "@mui/material";
import { Table } from "./Table";
import { TotalAmount } from "./TotalAmount";
import { tableAtom } from "@/lib/states";
import { useAtom } from "jotai";

export const GameTable = () => {
	const [gameTable] = useAtom(tableAtom);
	return (
		<Container>
			<Table />
			<TotalAmount
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
