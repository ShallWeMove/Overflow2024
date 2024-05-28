import { Box, Typography, styled } from "@mui/material";

export const TotalBetAmountBadge = ({ value }: any) => {
	return (
		<Container color={"white"}>
			<AmountWrapper>
				<Typography fontWeight={700}>
					{value} MIST
				</Typography>
			</AmountWrapper>
		</Container>
	);
};
const Container = styled(Box)(() => ({
	position: "absolute",
	borderRadius: 4,
	top: 110,
	left: -4,
	flexGrow: 1,
	fontSize: 24,
	fontWeight: "bold",
	textAlign: "center",
}));

const AmountWrapper = styled(Box)(() => ({
	width: 100,
	height: 50,
	display: "flex",
	justifyContent: "center",
	padding: 16,
	borderRadius: 8,
	backgroundColor: "#18222D",
	border: `1px solid white`,
}));
