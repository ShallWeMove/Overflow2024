import { useState, useEffect } from "react";
import { Box } from "@mui/material";
import bg_landing from "../../../../public/bg_landing.jpg";
import { Loading } from "@/components/UI/Loading";
import { getObjectById } from "@/api/object";

const SearchGame = () => {
	const [loading, setLoading] = useState(true);

	useEffect(() => {
		const interval = setInterval(async () => {
			const data = await getObjectById(
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
			<div>this is game searching page</div>
			{loading && <Loading />}
		</Box>
	);
};

export default SearchGame;
