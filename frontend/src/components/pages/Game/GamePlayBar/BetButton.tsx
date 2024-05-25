import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { ActionType } from "@/api/game";
// import { action } from "@/api/game";

export const BetButton = () => {
	const disabled = false;
	function handleClick() {
		// action;
	}
	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={ActionType.Bet}
			value={1000}
			color="#ffd200"
		/>
	);
};
