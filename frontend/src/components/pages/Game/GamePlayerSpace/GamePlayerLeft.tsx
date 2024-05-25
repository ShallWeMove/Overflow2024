import { CardPlaceHolder } from "@/components/UI/CardPlaceHolder";
import { ReactNode } from "react";

interface GamePlayerLeftProps {
	cards?: ReactNode[];
}

export const GamePlayerLeft = ({ cards }: GamePlayerLeftProps) => {
	return <CardPlaceHolder position="left" value={1000} cards={cards} />;
};
