import { GamePlayButton } from "@/components/UI/GamePlayButton";
import {action, ActionType, exit, LOCAL_STORAGE_ONGOING_GAME_KEY} from "@/api/game";
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
				// if user exits successfully, remove the ongoing game id from local storage
				localStorage.removeItem(LOCAL_STORAGE_ONGOING_GAME_KEY);
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
