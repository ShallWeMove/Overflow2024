import { GamePlayButton } from "@/components/UI/GamePlayButton";
import {ante, ActionType} from "@/api/game";
import {useAtomValue} from "jotai/index";
import {walletAtom} from "@/lib/states";

interface AnteButtonProps {
    gameTableId: string;
}

export const AnteButton = ({gameTableId}: AnteButtonProps) => {
    const disabled = false;
    const wallet = useAtomValue(walletAtom);

    const handleClick = async () => {
        try {
            const response = await ante(
                wallet,
                gameTableId,
            )

            if (response?.effects?.status?.status === "failure") {
                alert("Failed to ante")
            }

            console.log("ante response: ", response)
        }   catch (error) {
            console.error('Failed to ante:', error);
        }
    }
    return (
        <GamePlayButton
            onClick={handleClick}
            disabled={disabled}
            title={"ANTE"}
            value={1000}
            color="blue"
        />
    );
};
