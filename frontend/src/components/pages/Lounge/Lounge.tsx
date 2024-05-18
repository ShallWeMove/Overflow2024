import { useState, useEffect } from "react";
import { Box } from "@mui/material";
import bg_landing from "../../../../public/bg_landing.jpg";
import { Loading } from "@/components/UI/Loading";
import { getObject } from "@/api/object";
import { GameRoom } from "./GameRoom";

const Lounge = () => {
	const [loading, setLoading] = useState(true);

	useEffect(() => {
		const interval = setInterval(async () => {
			const data = await getObject(
				"0x29361f0cd734d9374decb131affea826682f801c37021dfe39c6832db839a513"
			);
			console.log("data: ", data);
		}, 1000);
		return () => clearInterval(interval);
	}, []);

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
			<GameRoom
				objectId="0x29361f0cd734d9374decb131affea826682f801c37021dfe39c6832db839a513"
				minBetAmount={1000}
			/>
			{loading && <Loading />}
		</Box>
	);
};

export default Lounge;
