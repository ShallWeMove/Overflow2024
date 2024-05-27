import { CardPlaceHolder } from "@/components/UI/CardPlaceHolder";
import { ReactNode } from "react";
import { PlayerSeat } from "@/lib/types";

interface GamePlayerLeftProps {
	cards?: ReactNode[];
	playerData?: PlayerSeat;
}

export const GamePlayerLeft = ({ cards, playerData }: GamePlayerLeftProps) => {
	return (
		<CardPlaceHolder
			value={1000}
			cards={cards}
			playerData={playerData}
		/>
	);
};
