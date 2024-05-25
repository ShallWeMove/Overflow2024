import { Box, Typography, Button, styled } from "@mui/material";
import { useRouter } from "next/router";
import { useAtomValue } from "jotai";
import { walletAtom } from "@/lib/states";
import { enter } from "@/api/game";

export const EnterGameBox = () => {
	const wallet = useAtomValue(walletAtom);
	const router = useRouter();

	async function handleClick() {
		const gameTableId = await enter(wallet)
			.then((res) => {
				console.log("res: ", res);
				if (res) {
					router.push(`/game/${gameTableId}`);
				}
			})
			.catch((e) => console.log("error: ", e));
	}

	return (
		<Container>
			<Typography variant="h4" color="black" fontWeight="bold">
				Would you like to Enter a Game?
			</Typography>
			<EnterGameButton onClick={handleClick}>Enter Game</EnterGameButton>
		</Container>
	);
};

const Container = styled(Box)({
	width: 400,
	height: 400,
	backgroundColor: "white",
	borderRadius: 16,
	boxShadow: "0px 0px 16px rgba(0, 0, 0, 0.1)",
	display: "flex",
	flexDirection: "column",
	justifyContent: "center",
	alignItems: "center",
});

const EnterGameButton = styled(Button)({
	backgroundColor: "#FFD700",
});
