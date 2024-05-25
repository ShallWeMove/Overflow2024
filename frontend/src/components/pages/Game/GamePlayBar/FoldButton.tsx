import { GamePlayButton } from "@/components/UI/GamePlayButton";
// import { action } from "@/api/game";

export const FoldButton = () => {
	const disabled = false;
	function handleClick() {
		// action;
	}
	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={"FOLD"}
			color="red"
		/>
	);
};
