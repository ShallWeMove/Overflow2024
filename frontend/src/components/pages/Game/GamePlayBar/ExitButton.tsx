import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { exit, LOCAL_STORAGE_ONGOING_GAME_KEY} from "@/api/game";
import { useAtomValue } from "jotai/index";
import { walletAtom, gameConfigAtom } from "@/lib/states";
import { useRouter } from "next/router";

interface FoldButtonProps {
	gameTableId: string;
}

export const ExitButton = ({ gameTableId }: FoldButtonProps) => {
	const router = useRouter();
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

			const response = await exit(wallet, gameTableId, gameCfg);

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
