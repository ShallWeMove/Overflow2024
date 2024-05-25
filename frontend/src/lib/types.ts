export type Casino = {
	id: string;
	admin: string;
	publicKey: string[];
};

export type Lounge = {
	id: string;
	casinoId: string;
	maxRound: number;
	gameTables: string[];
};

export type GameTable = {
	id: string;
	loungeId: string;
	gameStatus: GameStatus;
	moneyBox: MoneyBox;
	cardDeck: CardDeck | null;
	usedCardDecks: string[];
	playerSeats: PlayerSeat[];
};

export type GameStatus = {
	gameInfo: GameInfo;
	moneyBoxInfo: MoneyBoxInfo;
	cardInfo: CardInfo;
	playerInfos: PlayerInfo[];
};

export type MoneyBox = {
	id: number;
	money: any[];
};

export type CardDeck = {
	id: string;
	availCards: Card[];
	usedCards: Card[];
};

export type PlayerSeat = {
	id: string;
	index: number;
	playerAddress?: string;
	publicKey: Uint8Array;
	cards: Card[];
	deposit: any[];
};

export type Card = {
	id: string;
	index: number;
	cardNumber: number;
};

export type GameInfo = {
	gamePlayingStatus: number;
	managerPlayer?: string;
	maxRound: number;
	currentRound: number;
	currentTurnIndex: number;
	previousTurnIndex: number;
	winnerPlayer?: string;
	anteAmount: bigint;
	betUnit: bigint;
	gameSeats: number;
	availGameSeats: number;
};

export type MoneyBoxInfo = {
	totalBetAmount: bigint;
};

export type CardInfo = {
	numberOfAvailCards: number;
	numberOfUsedCards: number;
};

export type PlayerInfo = {
	index: number;
	playerAddress?: string;
	publicKey: Uint8Array;
	deposit: bigint;
	playingStatus: number;
	playingAction: number;
	numberOfHoldingCards: number;
	previousBetAmount: bigint;
	totalBetAmount: bigint;
};
