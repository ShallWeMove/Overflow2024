import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { action, ActionType } from "@/api/game";
import { useAtomValue } from "jotai/index";
import {gameConfigAtom, walletAtom} from "@/lib/states";

interface RaiseButtonProps {
	value?: number;
	gameTableId: string;
}

export const RaiseButton = ({ value, gameTableId }: RaiseButtonProps) => {
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
				ActionType.RAISE,
				1,
				gameCfg,
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
