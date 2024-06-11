import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { action, ActionType } from "@/api/game";
import { useAtomValue } from "jotai/index";
import {gameConfigAtom, walletAtom} from "@/lib/states";

interface FoldButtonProps {
	gameTableId: string;
}

export const FoldButton = ({ gameTableId }: FoldButtonProps) => {
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
				ActionType.FOLD,
				0,
				gameCfg,
			);

			if (response?.effects?.status?.status === "failure") {
				alert("Failed to fold");
			}

			console.log("fold response: ", response);
		} catch (error) {
			console.error("Failed to fold:", error);
		}
	};

	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={"FOLD"}
			color="red"
		/>
	);
};
