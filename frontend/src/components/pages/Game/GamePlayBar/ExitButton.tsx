import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { action, ActionType, exit } from "@/api/game";
import { useAtomValue } from "jotai/index";
import { walletAtom } from "@/lib/states";
import { useRouter } from "next/router";

interface FoldButtonProps {
	gameTableId: string;
}

export const ExitButton = ({ gameTableId }: FoldButtonProps) => {
	const router = useRouter();
	const disabled = false;
	const wallet = useAtomValue(walletAtom);

	const handleClick = async () => {
		// action;
		try {
			const response = await exit(wallet, gameTableId);

			if (response?.effects?.status?.status === "failure") {
				alert("Failed to exit");
			}

			if (response?.effects?.status?.status === "success") {
				router.push(`/`);
			}

			console.log("exit response: ", response);
		} catch (error) {
			console.error("Failed to exit:", error);
		}
	};

	return (
		<GamePlayButton
			onClick={handleClick}
			disabled={disabled}
			title={"Exit"}
			color="red"
		/>
	);
};
