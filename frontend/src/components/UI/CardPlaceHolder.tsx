import { Box, Typography, styled } from "@mui/material";
import { Fragment, ReactNode } from "react";
import { HiddenCard } from "./HiddenCard";

interface CardPlaceHolderProps {
	value: number;
	position: "left" | "right";
	isUser?: boolean;
	cards?: ReactNode[];
}

export const CardPlaceHolder = ({
	value,
	position,
	cards = [],
	isUser = false,
}: CardPlaceHolderProps) => {
	return (
		<Container>
			{position === "left" && (
				<Fragment>
					<UserProfile />
					<PlaceHolder>
						<CardWrapper>
							{cards[0] ?? <HiddenCard />}
							{cards[1] ?? <HiddenCard />}
						</CardWrapper>
						<TotalBetAmount>
							<Typography color="white" fontSize="16px" fontWeight={700}>
								{value} SUI
							</Typography>
						</TotalBetAmount>
					</PlaceHolder>
				</Fragment>
			)}
			{position === "right" && (
				<Fragment>
					<PlaceHolder>
						<CardWrapper>
							{cards[0] ?? <HiddenCard />}
							{cards[1] ?? <HiddenCard />}
						</CardWrapper>
						<TotalBetAmount>
							<Typography color="white" fontSize="16px" fontWeight={700}>
								{value} SUI
							</Typography>
						</TotalBetAmount>
					</PlaceHolder>
					<UserProfile />
				</Fragment>
			)}
		</Container>
	);
};

const Container = styled(Box)({
	display: "flex",
	gap: 16,
	alignItems: "flex-start",
});

const UserProfile = styled(Box)({
	width: 110,
	height: 100,
	backgroundImage: "url('/default-profile.jpg')",
	backgroundSize: "cover",
	borderRadius: 8,
});

const PlaceHolder = styled(Box)({
	position: "relative",
	backgroundColor: "#273648",
	borderRadius: 8,
	width: 400,
	height: 200,
});

const TotalBetAmount = styled(Box)({
	position: "absolute",
	height: 40,
	width: "100%",
	bottom: 0,
	backgroundColor: "#18222D",
	borderRadius: "0px 0px 8px 8px",
	display: "flex",
	justifyContent: "center",
	alignItems: "center",
});

const CardWrapper = styled(Box)({
	width: "100%",
	display: "flex",
	justifyContent: "center",
	gap: 6,
	padding: 6,
});
