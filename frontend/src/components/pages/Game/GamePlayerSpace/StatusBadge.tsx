import { Box, Typography, styled } from "@mui/material";
import {ActionType, PlayingStatusType} from "@/api/game";

function getBadgeColor(value: string) {
	switch (value) {
		case PlayingStatusType.ENTER:
		case ActionType.CALL:
			return "green";
			case PlayingStatusType.EMPTY:
		case ActionType.NONE:
		case ActionType.CHECK:
			return "grey";
		case PlayingStatusType.GAME_END:
		case ActionType.FOLD:
			return "red";
		case ActionType.RAISE:
			return "orange";
			case PlayingStatusType.READY:
		case ActionType.BET:
			return "#ffd200";
		default:
			return "white";
	}
}

export const StatusBadge = ({ value, left = false, manager = false }: any) => {
	return (
		<Container color={"white"} left={left} manager={manager}>
			<AmountWrapper value={value}>
				<Typography color={getBadgeColor(value)} fontWeight={700}>
					{value}
				</Typography>
			</AmountWrapper>
		</Container>
	);
};
const Container = styled(Box)<{ left: boolean, manager: boolean }>(({ left, manager }) => ({
	position: "absolute",
	borderRadius: 4,
	top: manager ? 50 :-25,
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
