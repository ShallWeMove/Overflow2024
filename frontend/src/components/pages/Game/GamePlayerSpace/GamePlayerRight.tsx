import { CardPlaceHolder } from "@/components/UI/CardPlaceHolder";
import { ReactNode } from "react";
import { PlayerSeat } from "@/lib/types";

interface GamePlayerRightProps {
	cards?: ReactNode[];
	playerData?: PlayerSeat;
}

export const GamePlayerRight = ({
	cards,
	playerData,
}: GamePlayerRightProps) => {
	return <CardPlaceHolder value={1000} cards={cards} />;
};
