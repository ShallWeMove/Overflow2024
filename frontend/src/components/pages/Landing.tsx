import React from "react";
import { Box, Button } from "@mui/material";
import Image from "next/image";
import backgroundImage from "../../../public/bg_landing.jpg";
import { useRouter } from "next/router";
import { enter, GAME_TABLE_TYPE } from "@/api/game";
import { useAtomValue } from "jotai/index";
import { walletAtom } from "@/lib/states";

const Landing = () => {
	const router = useRouter();
	const wallet = useAtomValue(walletAtom);

	const enterGame = async () => {
		console.log("wallet: ", wallet);
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
			}}
		>
			<Image
				src={backgroundImage}
				alt="background-image"
				quality="100"
				layout="fill"
			/>
			<Button
				onClick={enterGame}
				variant="contained"
				color="secondary"
				sx={{
					position: "absolute",
					top: "50%",
					left: "50%",
					transform: "translate(-50%, -50%)",
					width: "300px",
					height: "60px",
					fontSize: "1rem",
					backgroundColor: "rgba(255, 255, 255, 0.3)",
					borderRadius: "10px",
				}}
			>
				Enter Game
			</Button>
		</Box>
	);
};

export default Landing;
