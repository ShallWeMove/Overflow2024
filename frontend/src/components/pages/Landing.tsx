import React from "react";
import { Box, Button, Typography, styled } from "@mui/material";
import { useRouter } from "next/router";
import { enter, GAME_TABLE_TYPE } from "@/api/game";
import { useAtomValue } from "jotai/index";
import { walletAtom } from "@/lib/states";

const Landing = () => {
	const router = useRouter();
	const wallet = useAtomValue(walletAtom);

	const enterGame = async () => {
		try {
			const response = await enter(wallet);

			if (response?.objectChanges) {
				for (let i = 0; i < response.objectChanges?.length; i++) {
					const objectChange = response.objectChanges[i];
					if (
						objectChange.type === "mutated" &&
						objectChange.objectType === GAME_TABLE_TYPE
					) {
						const gameTableId = objectChange.objectId;
						await router.push(`/game/${gameTableId}`);
					}
				}
			}
		} catch (error) {
			console.error("Failed to enter the game:", error);
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
			<Container>
				<Box sx={{ display: "flex", flexDirection: "column" }}>
					<Typography color="black" fontWeight={700} fontSize={32}>
						Welcome to Shall We Move,
					</Typography>
					<Typography color="black" fontWeight={700} fontSize={20}>
						a fully on-chain multiplayer Blackjack game implemented on the Sui
						blockchain.
					</Typography>
					<Typography color="black" fontWeight={700} fontSize={20}>
						This demo leverages the unique features of the Sui blockchain to
						provide secure,
					</Typography>
					<Typography color="black" fontWeight={700} fontSize={20}>
						transparent, and decentralized gameplay experience.
					</Typography>
				</Box>
				<ButtonWrapper>
					<Button
						onClick={enterGame}
						variant="contained"
						color="secondary"
						sx={{
							padding: "16px 20px",
							fontSize: "1rem",
							borderRadius: "40px",
							fontWeight: 700,
							boxShadow: "none",
						}}
					>
						Enter Game
					</Button>
					<Button
						onClick={() => router.push("https://sui.io")}
						sx={{
							padding: "16px 20px",
							fontSize: "1rem",
							color: "white",
							fontWeight: 700,
							borderRadius: "40px",
							backgroundColor: "#0272E6",
						}}
					>
						Learn about SUI
					</Button>
				</ButtonWrapper>
			</Container>
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
	gap: 20,
});
