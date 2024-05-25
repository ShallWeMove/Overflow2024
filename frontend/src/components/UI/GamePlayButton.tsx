import { Box, Button, Typography, styled } from "@mui/material";

interface GamePlayButtonProps {
	onClick: () => void;
	disabled: boolean;
	title: string;
	value: number;
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
		</Container>
	);
};

const Container = styled(Box)<{ color: string }>(({ color }) => ({
	border: `2px solid ${color}`,
	borderRadius: 4,
	backgroundColor: "transparent",
	flexGrow: 1,
	fontSize: 24,
	fontWeight: "bold",
	textAlign: "center",
}));
