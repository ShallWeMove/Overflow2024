import React from "react";
import {Box, Button} from "@mui/material";
import Image from "next/image";
import backgroundImage from "../../../public/bg_landing.jpg";
import {useRouter} from "next/router";
import {enter} from "@/api/game";
import {useAtomValue} from "jotai/index";
import {walletAtom} from "@/lib/states";

const Landing = () => {
	const router = useRouter();
	const wallet = useAtomValue(walletAtom);

	const enterGame = async () => {
		try {
			const response = await enter(wallet);
			console.log("response: ", response);
			// TODO(Jarry): response 에서 gameTableId를 받아와야 함
			// await router.push(`/game/${gameId}`);
		} catch (error) {
			console.error('Failed to enter the game:', error);
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
