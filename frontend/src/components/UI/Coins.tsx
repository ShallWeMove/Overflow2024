import { Box, styled } from "@mui/material";
import Image from "next/image";
import betCoinTemp1 from "../../../public/coins/bet-coin-temp1.png";
import betCoinTemp2 from "../../../public/coins/bet-coin-temp2.png";
import betCoinTemp3 from "../../../public/coins/bet-coin-temp3.png";

export const Coins = () => {
	const select = Math.random();

	return select < 0.33 ? (
		<BetCoinTemp1 />
	) : select < 0.66 ? (
		<BetCoinTemp2 />
	) : (
		<BetCoinTemp3 />
	);
};

const Container = styled(Box)({
	backgroundColor: "transparent",
});

const BetCoinTemp1 = () => {
	return (
		<Container>
			<Image src={betCoinTemp1} alt="coin" width={315} height={190} />
		</Container>
	);
};

const BetCoinTemp2 = () => {
	return (
		<Container>
			<Image src={betCoinTemp2} alt="coin" width={315} height={190} />
		</Container>
	);
};

const BetCoinTemp3 = () => {
	return (
		<Container>
			<Image src={betCoinTemp3} alt="coin" width={375} height={170} />
		</Container>
	);
};
