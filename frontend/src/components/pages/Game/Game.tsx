import { useState } from "react";
import { Box } from "@mui/material";
import bg_landing from "../../../../public/bg_landing.jpg";
import { Loading } from "@/components/UI/Loading";
import { getObject } from "@/api/object";

const Game = () => {
	const [loading, setLoading] = useState(true);

	const interval = setInterval(async () => {
		setLoading(true);
		try {
			const obj = await getObject(
				"0x29361f0cd734d9374decb131affea826682f801c37021dfe39c6832db839a513"
			);
			console.log("obj: ", obj);
		} catch (error) {
			console.error("error: ", error);
		}
		setLoading(false);
	}, 10000);

	console.log("interval: ", interval);

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
