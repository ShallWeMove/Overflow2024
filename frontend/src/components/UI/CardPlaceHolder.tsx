import React, { useState } from "react";
import { Box, Button, Typography, styled } from "@mui/material";
import { Fragment, ReactNode } from "react";
import { PlayerInfo, PlayerSeat } from "@/lib/types";
import { PlayerInfoPopover } from "./PlayerInfoPopover";
import { StatusBadge } from "../pages/Game/GamePlayerSpace/StatusBadge";
import { convertIntToActionType } from "@/api/game";
import { convertIntToPlayingStatusType } from "@/api/game";

interface CardPlaceHolderProps {
	value: number;
	position: "left" | "right";
	isUser?: boolean;
	isTurn?: boolean;
	cards?: ReactNode[];
	playerData?: PlayerSeat;
	playerInfo?: PlayerInfo;
}

export const CardPlaceHolder = ({
	value,
	position,
	cards = [],
	isUser = false,
	isTurn = false,
	playerData,
	playerInfo
}: CardPlaceHolderProps) => {
	const [anchorEl, setAnchorEl] = useState<HTMLButtonElement | null>(null);

	const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
		if (playerData) {
			setAnchorEl(event.currentTarget);
		}
	};

	const handleClose = () => {
		setAnchorEl(null);
	};

	//TODO playerData 오류 해결

	return (
		<Container>
			{position === "left" && (
				<Fragment>
					<UserProfileWrapper>
						<StatusBadge value={playerInfo?.fields.playingStatus && convertIntToPlayingStatusType(playerInfo?.fields.playingStatus)}></StatusBadge>
						<StatusBadge value={playerInfo?.fields.playingAction && convertIntToActionType(playerInfo?.fields.playingAction)}></StatusBadge>
						<UserProfile isTurn={isTurn} />
					</UserProfileWrapper>
					<PlaceHolder isTurn={isTurn} onClick={handleClick}>
						<CardWrapper>
							{cards[0] ?? ""}
							{cards[1] ?? ""}
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
					<PlaceHolder isTurn={isTurn}>
						<CardWrapper>
							{cards[0] ?? ""}
							{cards[1] ?? ""}
						</CardWrapper>
						<TotalBetAmount>
							<Typography color="white" fontSize="16px" fontWeight={700}>
								{value} SUI
							</Typography>
						</TotalBetAmount>
					</PlaceHolder>
					<UserProfile isTurn={isTurn} />
				</Fragment>
			)}
			<PlayerInfoPopover
				open={Boolean(anchorEl)}
				anchorEl={anchorEl}
				onClose={handleClose}
				playerData={playerData}
			/>
		</Container>
	);
};

const Container = styled(Box)({
	display: "flex",
	gap: 16,
	alignItems: "flex-start",
});

interface PlaceHolderProps {
	isTurn: boolean;
}

const UserProfile = styled(Box)<PlaceHolderProps>(({ isTurn }) => ({
	width: 90,
	height: 80,
	border: isTurn ? "3px solid #E9DDAE" : "none",
	backgroundImage: "url('/default-profile.jpg')",
	backgroundSize: "cover",
	borderRadius: 8,
}));

const PlaceHolder = styled(Button)<PlaceHolderProps>(({ isTurn }) => ({
	position: "relative",
	backgroundColor: "#273648",
	border: isTurn ? "3px solid #E9DDAE" : "none",
	borderRadius: 8,
	width: 375,
	height: 200,
}));

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
	marginTop: -36,
});

const UserProfileWrapper = styled(Box)({
	display: "flex",
	flexDirection: "column"
})