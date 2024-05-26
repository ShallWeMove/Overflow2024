import { GamePlayButton } from "@/components/UI/GamePlayButton";
import {action, ActionType} from "@/api/game";
import {useAtomValue} from "jotai/index";
import {walletAtom} from "@/lib/states";

interface FoldButtonProps {
	value: number;
	gameTableId: string;
}

export const FoldButton = ({ value, gameTableId }: FoldButtonProps) => {
	const disabled = false;
	const wallet = useAtomValue(walletAtom);

	const handleClick = async () => {
		// action;
		try {
			const response = await action(
				wallet,
				gameTableId,
				ActionType.FOLD,
				false,
				0
			)

			if (response?.effects?.status?.status === "failure") {
				alert("Failed to fold")
			}

			console.log("fold response: ", response)

		}   catch (error) {
			console.error('Failed to fold:', error);
		}
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
