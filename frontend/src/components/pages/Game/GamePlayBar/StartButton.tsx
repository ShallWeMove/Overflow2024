import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { start } from "@/api/game";
import { useAtomValue } from "jotai/index";
import {gameConfigAtom, walletAtom} from "@/lib/states";

interface StartButtonProps {
	gameTableId: string;
}

export const StartButton = ({ gameTableId }: StartButtonProps) => {
	const disabled = false;
	const wallet = useAtomValue(walletAtom);
	const gameCfg = useAtomValue(gameConfigAtom);

	const handleClick = async () => {
		try {
			if (!wallet || !gameCfg) {
				console.error("Wallet or game config is not available");
				return;
			}

			const response = await start(wallet, gameTableId, gameCfg);

			if (response?.effects?.status?.status === "failure") {
				alert("Failed to start");
			}

			console.log("start response: ", response);
		} catch (error) {
			console.error("Failed to start:", error);
		}
	};
	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={"START"}
			color="white"
		/>
	);
};
