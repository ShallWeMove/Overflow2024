import React, { useState, useEffect } from "react";
import { CircularProgress } from "@mui/material";
import { Box } from "@mui/material";
// import BlackJack from "../components/BlackJack.tsx";
// import BettingAmount from "../components/BettingAmount";
import bg_landing from "../../../../public/bg_landing.jpg";
import { Loading } from "@/components/UI/Loading";
// import {
// 	fetchGameTableObject,
// 	fetchAllGameTables,
// } from "../components/GetFunctions";
// import GameTableList from "../components/GameTableList";
// import bgSound from "../images/bg_sound.mp3";
// import buttonSound from "../images/button_sound.mp3";
// import useSound from "use-sound";

import { useWallet } from "@suiet/wallet-kit";
// import { JsonRpcProvider, Connection } from "@mysten/sui.js";

const Game = () => {
	// const [playButtonSound] = useSound(buttonSound);
	// const [playBgSound] = useSound(bgSound, { volume: 1, loop: true });

	const [gameTableObjectId, setGameTableObjectId] = useState("");
	const [gameTableConfirmed, setGameTableConfirmed] = useState(false);
	const [bettingAmount, setBettingAmount] = useState("0.0001");
	const [balance, setBalance] = useState(0);
	const [bettingConfirmed, setBettingConfirmed] = useState(false);
	const [error, setError] = useState(false);

	const [isPlaying, setIsPlaying] = useState(0);
	const [winner, setWinner] = useState(0);
	const [setGameTableData] = useState({});
	const [cardDeckData, setCardDeckData] = useState({});
	const [dealerHandData, setDealerHandData] = useState({});
	const [playerHandData, setPlayerHandData] = useState({});
	const [allGameTables, setAllGameTables] = useState([]);

	const [loading, setLoading] = useState(false);
	const wallet = useWallet();

	useEffect(() => {
		console.log("gameTableConfirmed: ", gameTableConfirmed);
		console.log("Gametable Object Id: ", gameTableObjectId);
	}, [gameTableConfirmed, gameTableObjectId]);

	// useEffect(() => {
	// 	// fetchAllGameTables(setAllGameTables);

	// 	// Construct your connection:
	// 	const connection = new Connection({
	// 		fullnode: "https://sui-testnet.nodeinfra.com",
	// 	});
	// 	// connect to a custom RPC server
	// 	const provider = new JsonRpcProvider(connection);

	// 	async function getAllCoins() {
	// 		const allCoins = await provider.getAllCoins({
	// 			owner: wallet.account?.address,
	// 		});

	// 		// console.log("sdk: ", allCoins);
	// 		setBalance(allCoins.data[0].balance);
	// 	}

	// 	getAllCoins().catch(console.error);
	// }, [gameTableObjectId, gameTableConfirmed, wallet.account?.address]);

	return (
		<Box
			sx={{
				display: "flex",
				flexDirection: "row",
				justifyContent: "center",
				alignItems: "center",
				height: "100vh",
				backgroundImage: `url(${bg_landing})`,
				backgroundSize: "cover",
				backgroundPosition: "center",
			}}
		>
			{loading && <Loading />}
		</Box>
	);
};

export default Game;
