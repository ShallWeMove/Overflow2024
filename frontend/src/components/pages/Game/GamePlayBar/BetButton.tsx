import { Box, styled } from "@mui/material";
import { GamePlayButton } from "@/components/UI/GamePlayButton";
import { ActionType } from "@/api/game";
import { action } from "@/api/game";
import {useAtomValue} from "jotai/index";
import {walletAtom} from "@/lib/states";

interface BetButtonProps {
	value: number;
	gameTableId: string;
}

export const BetButton = ({ value, gameTableId }: BetButtonProps) => {
	const disabled = false;
	const wallet = useAtomValue(walletAtom);
			
	const handleClick = async () => {
		// action;
		try {
				const response = await action(
						wallet,
						gameTableId,
						ActionType.BET,
						false,
						0
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
			title={ActionType.BET}
			value={value}
			color="#ffd200"
		/>
	);
};
