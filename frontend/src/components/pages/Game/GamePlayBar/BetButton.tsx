import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { ActionType } from "@/api/game";
import { action } from "@/api/game";
import { useAtomValue } from "jotai/index";
import {gameConfigAtom, walletAtom} from "@/lib/states";

interface BetButtonProps {
	value?: number;
	gameTableId: string;
}

export const BetButton = ({ value, gameTableId }: BetButtonProps) => {
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
				ActionType.BET,
				0,
				gameCfg,
			);

			if (response?.effects?.status?.status === "failure") {
				alert("Failed to bet");
			}

			console.log("bet response: ", response);
		} catch (error) {
			console.error("Failed to bet:", error);
		}
	};
	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={ActionType.BET}
			value={value}
			color="#ffd200"
		/>
	);
};
