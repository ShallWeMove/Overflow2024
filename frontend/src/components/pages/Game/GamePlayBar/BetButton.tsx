import { Box, styled } from "@mui/material";
import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { ActionType } from "@/api/game";
// import { action } from "@/api/game";

interface BetButtonProps {
	value: number;
}

export const BetButton = ({ value }: BetButtonProps) => {
	const disabled = false;
	function handleClick() {
		// action;
	}
	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={ActionType.Bet}
			value={value}
			color="#ffd200"
		/>
	);
};
