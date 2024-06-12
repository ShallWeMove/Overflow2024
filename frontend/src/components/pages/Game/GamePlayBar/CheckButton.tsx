import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { action, ActionType } from "@/api/game";
import { useAtomValue } from "jotai/index";
import {gameConfigAtom, walletAtom} from "@/lib/states";
// import { action } from "@/api/game";

interface CheckButtonProps {
	value?: number;
	gameTableId: string;
}

export const CheckButton = ({ value, gameTableId }: CheckButtonProps) => {
	const disabled = false;
	const wallet = useAtomValue(walletAtom);
	const gameCfg = useAtomValue(gameConfigAtom);

	const handleClick = async () => {
		// action;
		try {
			if (!wallet || !gameCfg) {
				console.error("Wallet or game config is not available");
				return;
			}

			const response = await action(
				wallet,
				gameTableId,
				ActionType.CHECK,
				0,
				gameCfg,
			);

			if (response?.effects?.status?.status === "failure") {
				alert("Failed to check");
			}

			console.log("check response: ", response);
		} catch (error) {
			console.error("Failed to check:", error);
		}
	};
	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={ActionType.CHECK}
			color="grey"
		/>
	);
};
