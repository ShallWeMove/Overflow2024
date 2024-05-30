import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { action, ActionType } from "@/api/game";
import { useAtomValue } from "jotai/index";
import { walletAtom } from "@/lib/states";

interface CallButtonProps {
	value?: number;
	gameTableId: string;
}

export const CallButton = ({ value, gameTableId }: CallButtonProps) => {
	const disabled = false;
	const wallet = useAtomValue(walletAtom);

	const handleClick = async () => {
		// action;
		try {
			const response = await action(
				wallet,
				gameTableId,
				ActionType.CALL,
				false,
				0
			);

			if (response?.effects?.status?.status === "failure") {
				alert("Failed to call");
			}

			console.log("call response: ", response);
		} catch (error) {
			console.error("Failed to call:", error);
		}
	};
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
