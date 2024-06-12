import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { action, ActionType } from "@/api/game";
import { useAtomValue } from "jotai/index";
import {gameConfigAtom, walletAtom} from "@/lib/states";

interface CallButtonProps {
	value?: number;
	gameTableId: string;
}

export const CallButton = ({ value, gameTableId }: CallButtonProps) => {
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
				ActionType.CALL,
				0,
				gameCfg
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
