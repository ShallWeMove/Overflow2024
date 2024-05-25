import { Box, styled } from "@mui/material";
import { Table } from "./Table";
import { TotalAmount } from "./TotalAmount";

export const GameTable = () => {
	return (
		<Container>
			<Table />
			<TotalAmount />
		</Container>
	);
};

const Container = styled(Box)({
	display: "flex",
	flexDirection: "column",
	gap: 16,
});
