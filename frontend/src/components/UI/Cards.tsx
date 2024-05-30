import Image from "next/image";

export const convertCardNumberToCardImage = (
	cardNumber: number
) : JSX.Element => {
	let cardImageNumber : number = 0;
	if (cardNumber > 52) {
		cardImageNumber = 100;
	} else {
		// 여기에 decrypt function이 쓰일 예정
		cardImageNumber = Number(cardNumber);
	};

	switch (cardImageNumber) {
		case 0:
			return FlippedCard();
		case 0:
			return Club2();
    case 1:
			return Club3();
    case 2:
			return Club4();
    case 3:
			return Club5();
    case 4:
			return Club6();
    case 5:
			return Club7();
    case 6:
			return Club8();
    case 7:
			return Club9();
    case 8:
			return Club10();
    case 9:
			return ClubJ();
    case 10:
			return ClubQ();
    case 11:
			return ClubK();
    case 12:
			return ClubA();
		case 13:
			return Heart2();
    case 14:
			return Heart3();
    case 15:
			return Heart4();
    case 16:
			return Heart5();
    case 17:
			return Heart6();
    case 18:
			return Heart7();
    case 19:
			return Heart8();
    case 20:
			return Heart9();
    case 21:
			return Heart10();
    case 22:
			return HeartJ();
    case 23:
			return HeartQ();
    case 24:
			return HeartK();
    case 25:
			return HeartA();
		case 26:
			return Diamond2();
    case 27:
			return Diamond3();
    case 28:
			return Diamond4();
    case 29:
			return Diamond5();
    case 30:
			return Diamond6();
    case 31:
			return Diamond7();
    case 32:
			return Diamond8();
    case 33:
			return Diamond9();
    case 34:
			return Diamond10();
    case 35:
			return DiamondJ();
    case 36:
			return DiamondQ();
    case 37:
			return DiamondK();
    case 38:
			return DiamondA();
		case 39:
			return Spade2();
    case 40:
			return Spade3();
    case 41:
			return Spade4();
    case 42:
			return Spade5();
    case 43:
			return Spade6();
    case 44:
			return Spade7();
    case 45:
			return Spade8();
    case 46:
			return Spade9();
    case 47:
			return Spade10();
    case 48:
			return SpadeJ();
    case 49:
			return SpadeQ();
    case 50:
			return SpadeK();
    case 51:
			return SpadeA();
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
