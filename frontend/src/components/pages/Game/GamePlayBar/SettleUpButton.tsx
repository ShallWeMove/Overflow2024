import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { settleUp } from "@/api/game";
import { useAtomValue } from "jotai/index";
import {gameConfigAtom, walletAtom} from "@/lib/states";

interface FoldButtonProps {
	gameTableId: string;
}

export const SettleUpButton = ({ gameTableId }: FoldButtonProps) => {
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

			const response = await settleUp(
				wallet,
				gameTableId,
				gameCfg,
			);

			if (response?.effects?.status?.status === "failure") {
				alert("Failed to settle up");
			}

			console.log("settle up response: ", response);
		} catch (error) {
			console.error("Failed to settle up:", error);
		}
	};

	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={"SettleUp"}
			color="green"
		/>
	);
};
