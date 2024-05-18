import { Box, Typography } from "@mui/material";
import { useRouter } from "next/router";
import { useAtomValue } from "jotai";
import { walletAtom } from "@/lib/states";
// import { enter } from "@/api/game";

interface GameRoomProps {
	objectId: string;
	minBetAmount: number;
}

export const GameRoom = ({ objectId, minBetAmount }: GameRoomProps) => {
	const wallet = useAtomValue(walletAtom);
	const router = useRouter();

	const onClick = () => {
		// gameTableId = enter(wallet)
	};

	// 짜고 치는 것 방지
	// /game/1 /game/isafjioe3211234

	// 브라우저 접속. 지갑 로그인. 얘가 실제로 게임 참여자 맞아? validation

	return (
		<Box
			onClick={() => router.push(`/game/${objectId}`)}
			sx={{
				width: "200px",
				height: "200px",
				borderRadius: "50%",
				backgroundColor: "red",
				backgroundImage: "url('/gameRoom-background.png')",
				backgroundSize: "cover",
				display: "flex",
				justifyContent: "center",
				alignItems: "center",
			}}
		>
			<Typography variant="h5" color="white">
				{minBetAmount} SUI
			</Typography>
		</Box>
	);
};
