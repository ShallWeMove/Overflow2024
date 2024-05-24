import { Box, Typography, styled } from "@mui/material";

export const GameTable = () => {
	return (
		<Container>
			<Table />
			<TotalAmount>
				<Wrapper>
					<Typography color="#C1CCDC" fontWeight={700}>
						Total
					</Typography>
					<Typography color="#C1CCDC" fontWeight={700}>
						5000 SUI
					</Typography>
				</Wrapper>
				<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
				<Wrapper>
					<Typography color="#C1CCDC" fontWeight={700}>
						Call
					</Typography>
					<Typography color="#C1CCDC" fontWeight={700}>
						0 SUI
					</Typography>
				</Wrapper>
			</TotalAmount>
		</Container>
	);
};

const Container = styled(Box)({
	display: "flex",
	flexDirection: "column",
	gap: 16,
});

const Table = styled(Box)({});

const TotalAmount = styled(Box)({
	display: "flex",
	flexDirection: "column",
	border: "2px solid #C1CCDC",
	borderRadius: 8,
	width: 400,
	height: 80,
});

const Wrapper = styled(Box)({
	display: "flex",
	padding: 8,
	alignItems: "center",
	justifyContent: "space-between",
	flexGrow: 1,
});
