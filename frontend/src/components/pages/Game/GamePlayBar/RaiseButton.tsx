import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { ActionType } from "@/api/game";
// import { action } from "@/api/game";

interface RaiseButtonProps {
	value: number;
}

export const RaiseButton = ({ value }: RaiseButtonProps) => {
	const disabled = false;
	function handleClick() {
		// action;
	}
	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={ActionType.Raise}
			value={value}
			color="orange"
		/>
	);
};
