import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { ActionType } from "@/api/game";
// import { action } from "@/api/game";

interface CallButtonProps {
	value: number;
}

export const CallButton = ({ value }: CallButtonProps) => {
	const disabled = false;
	function handleClick() {
		// action;
	}
	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={ActionType.CALL}
			value={value}
			color="green"
		/>
	);
};
