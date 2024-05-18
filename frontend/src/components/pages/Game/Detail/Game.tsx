import { useRouter } from "next/router";
import { useState, useEffect } from "react";
import { Box } from "@mui/material";
import background from "../../../../public/background.jpg";
import { Loading } from "@/components/UI/Loading";
import { getObject } from "@/api/object";

const Game = () => {
	const router = useRouter();
	const { objectId } = router.query;
	const [loading, setLoading] = useState(true);

	useEffect(() => {
		const interval = setInterval(async () => {
			const data = await getObject(objectId?.toString() ?? "");
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
				backgroundImage: `url(${background})`,
				backgroundSize: "cover",
				backgroundPosition: "center",
			}}
		>
			<div>this is game page</div>
			{loading && <Loading />}
		</Box>
	);
};

export default Game;
