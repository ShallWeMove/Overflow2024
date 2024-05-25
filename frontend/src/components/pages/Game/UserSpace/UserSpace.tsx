import { CardPlaceHolder } from "@/components/UI/CardPlaceHolder";
import { SpadeA, SpadeK } from "@/components/UI/Cards";

interface UserSpaceProps {
	value: number;
}

export const UserSpace = ({ value }: UserSpaceProps) => {
	return (
		<CardPlaceHolder
			value={value}
			position="left"
			cards={[<SpadeA key="spadeA" />, <SpadeK key="king" />]}
		/>
	);
};
