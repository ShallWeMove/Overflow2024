import { Box, Typography, styled } from "@mui/material";

function getBadgeColor(value: string) {
	switch (value) {
		case "ENTER":
		case "CALL":
			return "green";
		case "NONE":
		case "CHECK":
		case "EMPTY":
			return "grey";
		case "GAME_END":
		case "FOLD":
			return "red";
		case "RAISE":
			return "orange";
		case "BET":
		case "READY":
			return "#ffd200";
		default:
			return "white";
	}
}

export const StatusBadge = ({ value, left = false }: any) => {
	return (
		<Container color={"white"} left={left}>
			<AmountWrapper value={value}>
				<Typography color={getBadgeColor(value)} fontWeight={700}>
					{value}
				</Typography>
			</AmountWrapper>
		</Container>
	);
};
const Container = styled(Box)<{ left: boolean }>(({ left }) => ({
	position: "absolute",
	borderRadius: 4,
	top: -25,
	left: left ? -25 : 65,
	flexGrow: 1,
	fontSize: 24,
	fontWeight: "bold",
	textAlign: "center",
}));

const AmountWrapper = styled(Box)<{ value: any }>(({ value }) => ({
	width: 50,
	height: 50,
	display: "flex",
	justifyContent: "center",
	padding: 16,
	borderRadius: "50%",
	backgroundColor: "#18222D",
	border: `1px solid ${getBadgeColor(value)}`,
}));
