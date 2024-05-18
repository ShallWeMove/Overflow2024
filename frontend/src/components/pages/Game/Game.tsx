import { useRouter } from "next/router";
import { useState, useEffect } from "react";
import { Box } from "@mui/material";
import { getObject } from "@/api/object";
import { Dealer } from "./Dealer/Dealer";
import { GamePlayerSpace } from "./GamePlayerSpace/GamePlayerSpace";
import { GamePlayBar } from "./GamePlayBar/GamePlayBar";

const Game = () => {
	const router = useRouter();
	const { objectId } = router.query;
	const [loading, setLoading] = useState(false);

	useEffect(() => {
		const interval = setInterval(async () => {
			const data = await getObject(objectId?.toString() ?? "");
			console.log("data: ", data);
		}, 1000);
		return () => clearInterval(interval);
	}, [objectId]);

	return (
		<Box
			sx={{
				position: "relative",
				display: "flex",
				flexDirection: "row",
				justifyContent: "center",
				alignItems: "center",
				height: "100vh",
				overflow: "hidden",
				backgroundImage: "url('/background.jpg')",
				backgroundSize: "cover",
				backgroundPosition: "center",
			}}
		>
			<Dealer />
			<GamePlayerSpace />
			<GamePlayBar />
		</Box>
	);
};

export default Game;
