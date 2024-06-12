import {Box, Button, styled, Typography} from "@mui/material";
import {useRouter} from "next/router";
import {
	enter,
	GAME_TABLE_TYPE,
	LOCAL_STORAGE_ONGOING_GAME_CONFIG_KEY,
	LOCAL_STORAGE_ONGOING_GAME_KEY
} from "@/api/game";
import {useAtomValue} from "jotai/index";
import {gameConfigAtom, walletAtom} from "@/lib/states";
import {useEffect, useState} from "react";
import {Loading} from "@/components/UI/Loading";
import OngoingGamePopUp from "@/components/pages/OngoingGamePopUp";
import config, {GameConfig, GameType} from "../../../config/config";
import LoginIcon from '@mui/icons-material/Login';
import {useSetAtom} from "jotai";

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const Landing = () => {
	const router = useRouter();
	const wallet = useAtomValue(walletAtom);
	const setGameConfig = useSetAtom(gameConfigAtom);

	const [ongoingGameExists, setOngoingGameExists] = useState(false);
	const [loading, setLoading] = useState(false);

	useEffect(() => {
		const ongoingGameId = localStorage.getItem(LOCAL_STORAGE_ONGOING_GAME_KEY);
		if (ongoingGameId) {
			setOngoingGameExists(true);
		}
	}, []);

	const enterGame = async (gameType: GameType) => {
		try {
			setLoading(true);

			let gameCfg: GameConfig | null;

			switch (gameType) {
				case GameType.TwoCardsPoker:
					gameCfg = config.games.twoCardsPoker;
					break;
				case GameType.ThreeCardsPoker:
					gameCfg = config.games.threeCardsPoker;
					break;
				default:
					gameCfg = null;
			}

			if (!gameCfg) {
				setLoading(false);
				console.error("Failed to enter the game:", gameType);
				alert("Invalid game type");
				return;
			}

			const response = await enter(wallet, gameCfg);

			if (response?.objectChanges) {
				for (let i = 0; i < response.objectChanges?.length; i++) {
					const objectChange = response.objectChanges[i];
					if (
						objectChange.type === "mutated" &&
						objectChange.objectType === GAME_TABLE_TYPE
					) {
						const gameTableId = objectChange.objectId;
						setGameConfig(gameCfg);

						// if user enters new game successfully, save the ongoing game id to local storage
						localStorage.setItem(LOCAL_STORAGE_ONGOING_GAME_KEY, gameTableId);
						localStorage.setItem(LOCAL_STORAGE_ONGOING_GAME_CONFIG_KEY, JSON.stringify(gameCfg));
						await sleep(2000);
						setLoading(false);
						await router.push(`/game/${gameTableId}`);
					}
				}
			}
		} catch (error) {
			setLoading(false);
			console.error("Failed to enter the game:", error);
			alert("Failed to enter the game: " + error);
		}
	};

	return (
		<Box
			sx={{
				position: "relative",
				width: "100%",
				height: "100vh",
				backgroundImage: `url(/bg_landing.jpg)`,
				backgroundSize: "cover",
				display: "flex",
				justifyContent: "center",
				alignItems: "center",
			}}
		>
			{
				ongoingGameExists ? (
					<OngoingGamePopUp onClose={() => setOngoingGameExists(false)} />
				) : loading ? (
					<Loading />
				) : (
					<Container>
						<Box sx={{ display: "flex", flexDirection: "column" }}>
							<Typography color="black" fontWeight={700} fontSize={32}>
								Welcome to Shall We Move,
							</Typography>
							<Typography color="black" fontWeight={500} fontSize={20}
								sx={{
									lineHeight: "1.2",
									marginBottom: 1,
								}}
							>
								a fully on-chain multiplayer card game implemented on the Sui
								blockchain. <br />
								This project leverages the unique features of the Sui blockchain
								to provide secure, <br />
								transparent, and decentralized gameplay.
							</Typography>

							<Typography
								component="a"
								href="https://sui.io"
								color="blue"
								fontWeight={500}
								fontSize={15}
								sx={{ textDecoration: 'underline', marginBottom: 1, }}
								target="_blank"
								rel="noopener noreferrer"
							>
								Click here to learn more about SUI.
							</Typography>
						</Box>
						<Box>
							<Typography color="black" textAlign="center" fontWeight={700} fontSize={22}
								sx={{
									borderTop: "1px solid rgba(0, 0, 0, 0.5)",
									paddingTop: 3,
									marginBottom: 2,
								}}
							>
								Choose a game to play
							</Typography>
							<ButtonWrapper>

								<Button
									onClick={() => enterGame(GameType.TwoCardsPoker)}
									variant="contained"
									color="secondary"
									endIcon={<LoginIcon />}
									sx={{
										padding: "16px 20px",
										fontSize: "1rem",
										borderRadius: "40px",
										fontWeight: 700,
										boxShadow: "none",
									}}
								>
									2 Cards Poker
								</Button>
								<Button
									onClick={() => enterGame(GameType.ThreeCardsPoker)}
									variant="contained"
									color="info"
									endIcon={<LoginIcon />}
									sx={{
										padding: "16px 20px",
										fontSize: "1rem",
										color: "white",
										fontWeight: 700,
										borderRadius: "40px",
									}}
								>
									3 Cards Poker
								</Button>
							</ButtonWrapper>
						</Box>
					</Container>
				)
			}
		</Box>
	);
};

export default Landing;

const Container = styled(Box)({
	display: "flex",
	flexDirection: "column",
	padding: 20,
	borderRadius: 16,
	backdropFilter: "blur(10px)",
	gap: 40,
	backgroundColor: "rgba(255, 255, 255, 0.3)",
	border: "1px solid rgba(255, 255, 255, 0.5)",
});

const ButtonWrapper = styled(Box)({
	display: "flex",
	alignSelf: "flex-end",
	justifyContent: "center",
	alignItems: "center",
	gap: 40,
});
