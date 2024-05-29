import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { action, ActionType } from "@/api/game";
import { useAtomValue } from "jotai/index";
import { walletAtom } from "@/lib/states";
// import { action } from "@/api/game";

interface RaiseButtonProps {
	value?: number;
	gameTableId: string;
}

export const RaiseButton = ({ value, gameTableId }: RaiseButtonProps) => {
	const disabled = false;
	const wallet = useAtomValue(walletAtom);

	const handleClick = async () => {
		// action;
		try {
			const response = await action(
				wallet,
				gameTableId,
				ActionType.RAISE,
				false,
				1
			);

			if (response?.effects?.status?.status === "failure") {
				alert("Failed to raise");
			}

			console.log("raise response: ", response);
		} catch (error) {
			console.error("Failed to raise:", error);
		}
	};
	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={ActionType.RAISE}
			value={value}
			color="orange"
		/>
	);
};
