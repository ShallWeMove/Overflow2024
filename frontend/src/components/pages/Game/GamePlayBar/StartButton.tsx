import { GamePlayButton } from "@/components/UI/GamePlayButton";
import {start} from "@/api/game";
import {useAtomValue} from "jotai/index";
import {walletAtom} from "@/lib/states";

interface StartButtonProps {
    gameTableId: string;
}

export const StartButton = ({gameTableId}: StartButtonProps) => {
    const disabled = false;
    const wallet = useAtomValue(walletAtom);

    const handleClick = async () => {
        try {
            const response = await start(
                wallet,
                gameTableId,
            )
            console.log("start response: ", response)
            // TODO: response.effects.status.status === "success" OR "failure"에 따라 성공/에러 처리하기
        }   catch (error) {
            console.error('Failed to ante:', error);
        }
    }
    return (
        <GamePlayButton
            onClick={handleClick}
            disabled={disabled}
            title={"START"}
            value={1000}
            color="white"
        />
    );
};
