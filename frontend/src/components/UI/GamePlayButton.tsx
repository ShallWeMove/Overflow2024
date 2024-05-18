import { Box, Button, Typography, styled } from "@mui/material";

interface GamePlayButtonProps {
	onClick: () => void;
	disabled: boolean;
	title: string;
}

export const GamePlayButton = ({
	onClick,
	disabled,
	title,
}: GamePlayButtonProps) => {
	return (
		<Container>
			<Button onClick={onClick} disabled={disabled}>
				<Typography color="#ffd200">{title}</Typography>
			</Button>
		</Container>
	);
};

const Container = styled(Box)({
	border: "1px solid #ffd200",
	borderRadius: 4,
	backgroundColor: "black",
	flexGrow: 1,
	fontSize: 24,
	fontWeight: "bold",
	textAlign: "center",
});
