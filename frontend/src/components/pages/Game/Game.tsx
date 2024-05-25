import { useRouter } from "next/router";
import { useState, useEffect } from "react";
import { Box, styled } from "@mui/material";
import { getObject } from "@/api/object";
import { Dealer } from "./Dealer/Dealer";
import { GamePlayerSpace } from "./GamePlayerSpace/GamePlayerSpace";
import { UserSpace } from "./UserSpace/UserSpace";
import { GamePlayBar } from "./GamePlayBar/GamePlayBar";
import { GameTable } from "./GameTable/GameTable";

export const Game = () => {
	const router = useRouter();
	const { objectId } = router.query;
	// const [loading, setLoading] = useState(false);

	useEffect(() => {
		const interval = setInterval(async () => {
			const data = await getObject(objectId?.toString() ?? "");
			console.log("data: ", data);
		}, 1000);
		return () => clearInterval(interval);
	}, [objectId]);

	return (
		<Container>
			<Wrapper>
				<GamePlayerSpace position="left" />
				<GameTable />
				<GamePlayerSpace position="right" />
			</Wrapper>
			<UserSpace value={1000} />
			<GamePlayBar />
		</Container>
	);
};

const Container = styled(Box)({
	position: "relative",
	display: "flex",
	flexDirection: "column",
	justifyContent: "center",
	alignItems: "center",
	height: "100vh",
	overflow: "hidden",
	backgroundImage: "url('/background.jpg')",
	backgroundSize: "cover",
	backgroundPosition: "center",
});

const Wrapper = styled(Box)({
	width: "100%",
	display: "flex",
	justifyContent: "space-between",
});
