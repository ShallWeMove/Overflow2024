import { Box, Button, Typography, styled } from "@mui/material";

interface GamePlayButtonProps {
	onClick: () => void;
	disabled: boolean;
	title: string;
	value?: number;
	color: string;
}

export const GamePlayButton = ({
	onClick,
	disabled,
	value,
	title,
	color,
}: GamePlayButtonProps) => {
	return (
		<Container color={color}>
			<Button onClick={onClick} disabled={disabled} sx={{ width: "100%" }}>
				<Typography color={color} fontWeight={700}>
					{title}
				</Typography>
			</Button>
			{value && (
				<AmountWrapper>
					<Amount>
						<Typography color="white" fontWeight={700}>
							{value} SUI
						</Typography>
					</Amount>
				</AmountWrapper>
			)}
		</Container>
	);
};

const Container = styled(Box)<{ color: string }>(({ color }) => ({
	position: "relative",
	border: `2px solid ${color}`,
	borderRadius: 4,
	backgroundColor: "transparent",
	flexGrow: 1,
	fontSize: 24,
	fontWeight: "bold",
	textAlign: "center",
}));

const AmountWrapper = styled(Box)({
	width: "100%",
	position: "absolute",
	bottom: 30,
	display: "flex",
	justifyContent: "center",
});

const Amount = styled(Box)({
	backgroundColor: "black",
	padding: "2px 12px",
	borderRadius: "15px",
});
