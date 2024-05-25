import { Box, Typography, styled } from "@mui/material";
import { useSpring, animated } from "react-spring";

interface TotalAmountProps {
	totalBetAmount: number | undefined;
	callAmount: number | undefined;
}

export const TotalAmount = ({
	totalBetAmount,
	callAmount,
}: TotalAmountProps) => {
	return (
		<Container>
			<Wrapper>
				<Typography color="#C1CCDC" fontWeight={700}>
					Total
				</Typography>
				<Typography
					color="#C1CCDC"
					fontWeight={700}
					sx={{ display: "flex", gap: 0.5 }}
				>
					<AnimatedSUI n={totalBetAmount?.toString() ?? "0"} />
					SUI
				</Typography>
			</Wrapper>
			<Box sx={{ height: 2, width: "100%", border: "1px solid #C1CCDC" }} />
			<Wrapper>
				<Typography color="#C1CCDC" fontWeight={700}>
					Call
				</Typography>
				<Typography
					color="#C1CCDC"
					fontWeight={700}
					sx={{ display: "flex", gap: 0.5 }}
				>
					<AnimatedSUI n={callAmount?.toString() ?? "0"} />
					SUI
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
