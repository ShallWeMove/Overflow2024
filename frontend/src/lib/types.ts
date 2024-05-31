export type Casino = {
	fields: {
		id: string;
		admin: string;
		publicKey: string[];
	};
};

export type Lounge = {
	fields: {
		id: string;
		casinoId: string;
		maxRound: number;
		gameTables: string[];
	};
};

export type GameTable = {
	fields: {
		id: string;
		loungeId: string;
		gameStatus: GameStatus;
		moneyBox: MoneyBox;
		cardDeck: CardDeck | null;
		usedCardDecks: string[];
		playerSeats: PlayerSeat[];
	};
};

export type GameStatus = {
	fields: {
		gameInfo: GameInfo;
		moneyBoxInfo: MoneyBoxInfo;
		cardInfo: CardInfo;
		playerInfos: PlayerInfo[];
	};
};

export type MoneyBox = {
	fields: {
		id: number;
		money: Coin[];
	};
};

export type CardDeck = {
	fields: {
		id: string;
		availCards: Card[];
		usedCards: Card[];
	};
};

export type PlayerSeat = {
	fields: {
		id: string;
		index: number;
		playerAddress?: string;
		publicKey: Uint8Array;
		cards: Card[];
		deposit: Coin[];
	};
};

export type Card = {
	fields: {
		id: string;
		index: number;
		cardNumber: number;
		cardNumberForUser : number;
	};
};

export type GameInfo = {
	fields: {
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
};

export type MoneyBoxInfo = {
	fields: {
		totalBetAmount: bigint;
	};
};

export type CardInfo = {
	fields: {
		numberOfAvailCards: number;
		numberOfUsedCards: number;
	};
};

export type PlayerInfo = {
	fields: {
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
};

export type Coin = {
	fields: {
		balance: string;
		id: {
			id: string;
		};
	};
};
