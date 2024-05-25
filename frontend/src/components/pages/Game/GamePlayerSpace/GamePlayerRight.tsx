import { CardPlaceHolder } from "@/components/UI/CardPlaceHolder";
import { ReactNode } from "react";

interface GamePlayerRightProps {
	cards?: ReactNode[];
}

export const GamePlayerRight = ({ cards }: GamePlayerRightProps) => {
	return <CardPlaceHolder position="right" value={1000} cards={cards} />;
};
