import { Box, styled, Typography } from "@mui/material";
import { animated, useSpring } from "react-spring";

interface TotalAmountProps {
	totalBetAmount: number | undefined;
	callAmount: number | undefined;
	players: number;
	gameStatus: number;
	currentPlayerAddress: string;
	betUnit: bigint | undefined;
	anteAmount: bigint | undefined;
	winnerPlayer: string | undefined;
}

export const TotalAmount = ({
	totalBetAmount,
	callAmount,
	players,
	gameStatus,
	currentPlayerAddress,
	betUnit,
	anteAmount,
	winnerPlayer
}: TotalAmountProps) => {
	return (
		<Container>
			<Wrapper>
				<Typography color="#C1CCDC" fontWeight={700}>
					Total
				</Typography>
				<Box sx={{ display: "flex", gap: 0.5 }}>
					<AnimatedSUI n={totalBetAmount?.toString() ?? "0"} />
					<Typography color="#C1CCDC" fontWeight={700}>
						SUI
					</Typography>
				</Box>
			</Wrapper>
			<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
			<Wrapper>
				<Typography color="#C1CCDC" fontWeight={700}>
					Call
				</Typography>
				<Box sx={{ display: "flex", gap: 0.5 }}>
					<AnimatedSUI n={callAmount?.toString() ?? "0"} />
					<Typography color="#C1CCDC" fontWeight={700}>
						SUI
					</Typography>
				</Box>
			</Wrapper>
			<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
			<Wrapper>
				<Typography color="#C1CCDC" fontWeight={700}>
					Players
				</Typography>
				<Typography
					color="#C1CCDC"
					fontWeight={700}
					sx={{ display: "flex", gap: 0.5 }}
				>
					{players} Players
				</Typography>
			</Wrapper>
			<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
			<Wrapper>
				<Typography color="#C1CCDC" fontWeight={700}>
					Game Status
				</Typography>
				<Typography
					color="#C1CCDC"
					fontWeight={700}
					sx={{ display: "flex", gap: 0.5 }}
				>
					{gameStatus === 0
						? "Pre Game"
						: gameStatus === 1
						? "In Game"
						: "Game Finished"}
				</Typography>
			</Wrapper>
			<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
			<Wrapper>
				<Typography color="#C1CCDC" fontWeight={700}>
					Current Turn
				</Typography>
				<Typography
					color="#C1CCDC"
					fontWeight={700}
					sx={{
						display: "flex",
						gap: 0.5,
						overflowWrap: "anywhere",
					}}
				>
					{currentPlayerAddress}
				</Typography>
			</Wrapper>
			<Wrapper>
				<Typography color="#C1CCDC" fontWeight={700}>
					Ante Amount
				</Typography>
				<Typography
					color="#C1CCDC"
					fontWeight={700}
				>
					{anteAmount}
				</Typography>
				<Typography color="#C1CCDC" fontWeight={700}>
					Betting Unit
				</Typography>
				<Typography
					color="#C1CCDC"
					fontWeight={700}
				>
					{betUnit}
				</Typography>
			</Wrapper>
			<Wrapper>
				<Typography color="#C1CCDC" fontWeight={700}>
					Winner Player
				</Typography>
				<Typography
					color="#C1CCDC"
					fontWeight={700}
					sx={{
						display: "flex",
						gap: 0.5,
						overflowWrap: "anywhere",
					}}
				>
					{winnerPlayer}
				</Typography>
			</Wrapper>
		</Container>
	);
};

const Container = styled(Box)({
	display: "flex",
	flexDirection: "column",
	border: "2px solid #C1CCDC",
	borderRadius: 8,
	width: 400,
	height: 80,
});

const Wrapper = styled(Box)({
	display: "flex",
	padding: 8,
	alignItems: "center",
	justifyContent: "space-between",
	flexGrow: 1,
});

interface AnimatedProps {
	n: string;
}

const AnimatedSUI = ({ n }: AnimatedProps) => {
	const cleanedNumber = n.replace(/,/g, "");
	const numberValue = parseFloat(cleanedNumber);

	const { number } = useSpring({
		from: { number: 0 },
		to: { number: isNaN(numberValue) ? 0 : numberValue },
		delay: 200,
		config: { mass: 1, tension: 20, friction: 10, duration: 1000 },
	});

	return (
		<animated.div
			style={{
				fontSize: "14px",
				fontWeight: 700,
				color: "#C1CCDC",
				marginTop: -1,
			}}
		>
			{number.to((value) => Math.floor(value).toLocaleString())}
		</animated.div>
	);
};
