import Image from "next/image";

export const convertCardNumberToCardImage = (
	cardNumber: number
) : JSX.Element => {
	let cardImageNumber : number = 0;
	if (cardNumber > 52) {
		cardImageNumber = 100;
	} else {
		cardImageNumber = Number(cardNumber);
	};

	switch (cardImageNumber) {
		case 0:
			return FlippedCard();
		case 1:
			return SpadeA();
		case 2:
			return Spade2();
		case 3:
			return Spade3();
		case 4:
			return Spade4();
		case 5:
			return Spade5();
		case 6:
			return Spade6();
		case 7:
			return Spade7();
		case 8:
			return Spade8();
		case 9:
			return Spade9();
		case 10:
			return Spade10();
		case 11:
			return SpadeJ();
		case 12:
			return SpadeQ();
		case 13:
			return SpadeK();
		case 14:
			return ClubA();
		case 15:
			return Club2();
		case 16:
			return Club3();
		case 17:
			return Club4();
		case 18:
			return Club5();
		case 19:
			return Club6();
		case 20:
			return Club7();
		case 21:
			return Club8();
		case 22:
			return Club9();
		case 23:
			return Club10();
		case 24:
			return ClubJ();
		case 25:
			return ClubQ();
		case 26:
			return ClubK();
		case 27:
			return DiamondA();
		case 28:
			return Diamond2();
		case 29:
			return Diamond3();
		case 30:
			return Diamond4();
		case 31:
			return Diamond5();
		case 32:
			return Diamond6();
		case 33:
			return Diamond7();
		case 34:
			return Diamond8();
		case 35:
			return Diamond9();
		case 36:
			return Diamond10();
		case 37:
			return DiamondJ();
		case 38:
			return DiamondQ();
		case 39:
			return DiamondK();
		case 40:
			return HeartA();
		case 41:
			return Heart2();
		case 42:
			return Heart3();
		case 43:
			return Heart4();
		case 44:
			return Heart5();
		case 45:
			return Heart6();
		case 46:
			return Heart7();
		case 47:
			return Heart8();
		case 48:
			return Heart9();
		case 49:
			return Heart10();
		case 50:
			return HeartJ();
		case 51:
			return HeartQ();
		case 52:
			return HeartK();
		case 100:
			return FlippedCard();
		default:
			return FlippedCard();

			// throw new Error("Invalid card number");
	}
};

export const FlippedCard = () => {
	return <Image src="/cards/card.png" alt="card" width={108} height={146} />;
};

export const SpadeA = () => {
	return (
		<Image src="/cards/spade/ace.png" alt="card" width={110} height={150} />
	);
};

export const Spade2 = () => {
	return <Image src="/cards/spade/2.png" alt="card" width={110} height={150} />;
};

export const Spade3 = () => {
	return <Image src="/cards/spade/3.png" alt="card" width={110} height={150} />;
};

export const Spade4 = () => {
	return <Image src="/cards/spade/4.png" alt="card" width={110} height={150} />;
};

export const Spade5 = () => {
	return <Image src="/cards/spade/5.png" alt="card" width={110} height={150} />;
};

export const Spade6 = () => {
	return <Image src="/cards/spade/6.png" alt="card" width={110} height={150} />;
};

export const Spade7 = () => {
	return <Image src="/cards/spade/7.png" alt="card" width={110} height={150} />;
};

export const Spade8 = () => {
	return <Image src="/cards/spade/8.png" alt="card" width={110} height={150} />;
};

export const Spade9 = () => {
	return <Image src="/cards/spade/9.png" alt="card" width={110} height={150} />;
};

export const Spade10 = () => {
	return (
		<Image src="/cards/spade/10.png" alt="card" width={110} height={150} />
	);
};

export const SpadeJ = () => {
	return (
		<Image src="/cards/spade/jack.png" alt="card" width={110} height={150} />
	);
};

export const SpadeQ = () => {
	return (
		<Image src="/cards/spade/queen.png" alt="card" width={110} height={150} />
	);
};

export const SpadeK = () => {
	return (
		<Image src="/cards/spade/king.png" alt="card" width={110} height={150} />
	);
};

export const HeartA = () => {
	return (
		<Image src="/cards/heart/ace.png" alt="card" width={110} height={150} />
	);
};

export const Heart2 = () => {
	return <Image src="/cards/heart/2.png" alt="card" width={110} height={150} />;
};

export const Heart3 = () => {
	return <Image src="/cards/heart/3.png" alt="card" width={110} height={150} />;
};

export const Heart4 = () => {
	return <Image src="/cards/heart/4.png" alt="card" width={110} height={150} />;
};

export const Heart5 = () => {
	return <Image src="/cards/heart/5.png" alt="card" width={110} height={150} />;
};

export const Heart6 = () => {
	return <Image src="/cards/heart/6.png" alt="card" width={110} height={150} />;
};

export const Heart7 = () => {
	return <Image src="/cards/heart/7.png" alt="card" width={110} height={150} />;
};

export const Heart8 = () => {
	return <Image src="/cards/heart/8.png" alt="card" width={110} height={150} />;
};

export const Heart9 = () => {
	return <Image src="/cards/heart/9.png" alt="card" width={110} height={150} />;
};

export const Heart10 = () => {
	return (
		<Image src="/cards/heart/10.png" alt="card" width={110} height={150} />
	);
};

export const HeartJ = () => {
	return (
		<Image src="/cards/heart/jack.png" alt="card" width={110} height={150} />
	);
};

export const HeartQ = () => {
	return (
		<Image src="/cards/heart/queen.png" alt="card" width={110} height={150} />
	);
};

export const HeartK = () => {
	return (
		<Image src="/cards/heart/king.png" alt="card" width={110} height={150} />
	);
};

export const ClubA = () => {
	return (
		<Image src="/cards/club/ace.png" alt="card" width={110} height={150} />
	);
};

export const Club2 = () => {
	return <Image src="/cards/club/2.png" alt="card" width={110} height={150} />;
};

export const Club3 = () => {
	return <Image src="/cards/club/3.png" alt="card" width={110} height={150} />;
};

export const Club4 = () => {
	return <Image src="/cards/club/4.png" alt="card" width={110} height={150} />;
};

export const Club5 = () => {
	return <Image src="/cards/club/5.png" alt="card" width={110} height={150} />;
};

export const Club6 = () => {
	return <Image src="/cards/club/6.png" alt="card" width={110} height={150} />;
};

export const Club7 = () => {
	return <Image src="/cards/club/7.png" alt="card" width={110} height={150} />;
};

export const Club8 = () => {
	return <Image src="/cards/club/8.png" alt="card" width={110} height={150} />;
};

export const Club9 = () => {
	return <Image src="/cards/club/9.png" alt="card" width={110} height={150} />;
};

export const Club10 = () => {
	return <Image src="/cards/club/10.png" alt="card" width={110} height={150} />;
};

export const ClubJ = () => {
	return (
		<Image src="/cards/club/jack.png" alt="card" width={110} height={150} />
	);
};

export const ClubQ = () => {
	return (
		<Image src="/cards/club/queen.png" alt="card" width={110} height={150} />
	);
};

export const ClubK = () => {
	return (
		<Image src="/cards/club/king.png" alt="card" width={110} height={150} />
	);
};

export const DiamondA = () => {
	return (
		<Image src="/cards/diamond/ace.png" alt="card" width={110} height={150} />
	);
};

export const Diamond2 = () => {
	return (
		<Image src="/cards/diamond/2.png" alt="card" width={110} height={150} />
	);
};

export const Diamond3 = () => {
	return (
		<Image src="/cards/diamond/3.png" alt="card" width={110} height={150} />
	);
};

export const Diamond4 = () => {
	return (
		<Image src="/cards/diamond/4.png" alt="card" width={110} height={150} />
	);
};

export const Diamond5 = () => {
	return (
		<Image src="/cards/diamond/5.png" alt="card" width={110} height={150} />
	);
};

export const Diamond6 = () => {
	return (
		<Image src="/cards/diamond/6.png" alt="card" width={110} height={150} />
	);
};

export const Diamond7 = () => {
	return (
		<Image src="/cards/diamond/7.png" alt="card" width={110} height={150} />
	);
};

export const Diamond8 = () => {
	return (
		<Image src="/cards/diamond/8.png" alt="card" width={110} height={150} />
	);
};

export const Diamond9 = () => {
	return (
		<Image src="/cards/diamond/9.png" alt="card" width={110} height={150} />
	);
};

export const Diamond10 = () => {
	return (
		<Image src="/cards/diamond/10.png" alt="card" width={110} height={150} />
	);
};

export const DiamondJ = () => {
	return (
		<Image src="/cards/diamond/jack.png" alt="card" width={110} height={150} />
	);
};

export const DiamondQ = () => {
	return (
		<Image src="/cards/diamond/queen.png" alt="card" width={110} height={150} />
	);
};

export const DiamondK = () => {
	return (
		<Image src="/cards/diamond/king.png" alt="card" width={110} height={150} />
	);
};

export const HiddenCard = () => {
	return <Image src="/cards/card.png" alt="card" width={110} height={150} />;
};
