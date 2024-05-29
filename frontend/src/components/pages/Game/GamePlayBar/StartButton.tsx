import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { start } from "@/api/game";
import { useAtomValue } from "jotai/index";
import { walletAtom } from "@/lib/states";

interface StartButtonProps {
	gameTableId: string;
}

export const StartButton = ({ gameTableId }: StartButtonProps) => {
	const disabled = false;
	const wallet = useAtomValue(walletAtom);

	const handleClick = async () => {
		try {
			const response = await start(wallet, gameTableId);

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
