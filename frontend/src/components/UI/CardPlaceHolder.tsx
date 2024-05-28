import React, { useState } from "react";
import { Box, Button, Typography, styled, Grid } from "@mui/material";
import { PlayerInfo, PlayerSeat } from "@/lib/types";
import { PlayerInfoPopover } from "./PlayerInfoPopover";
import { StatusBadge } from "../pages/Game/GamePlayerSpace/StatusBadge";
import { convertIntToActionType } from "@/api/game";
import { convertIntToPlayingStatusType } from "@/api/game";
import { useEffect } from "react";
import { tableAtom } from "@/lib/states";
import { useAtom } from "jotai";
import { convertCardNumberToCardImage } from "@/components/UI/Cards";

interface CardPlaceHolderProps {
	isUser?: boolean;
	playerData?: PlayerSeat;
	playerInfo?: PlayerInfo;
}

export const CardPlaceHolder = ({
	isUser = false,
	playerData,
	playerInfo,
}: CardPlaceHolderProps) => {
	const [tableInfo] = useAtom(tableAtom);
	const [anchorEl, setAnchorEl] = useState<HTMLButtonElement | null>(null);
	const [isTurn, setIsTurn] = useState(false);

	const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
		if (playerData) {
			setAnchorEl(event.currentTarget);
		}
	};

	const handleClose = () => {
		setAnchorEl(null);
	};

	useEffect(()=>{
		setIsTurn(tableInfo.currentPlayerAddress == playerData?.fields.playerAddress);
	},[playerData])


	return (
		<Container>
			<UserProfileWrapper>
				<UserProfile isTurn={isTurn} />
				<StatusBadge
					value={
						playerInfo?.fields.playingStatus &&
						convertIntToPlayingStatusType(playerInfo?.fields.playingStatus)
					}
					left={true}
				></StatusBadge>
				<StatusBadge
					value={
						playerInfo?.fields.playingAction &&
						convertIntToActionType(playerInfo?.fields.playingAction)
					}
				></StatusBadge>
				<Typography>
					{playerData && playerData.fields.playerAddress?.slice(0, 5)}
					{playerData?.fields.playerAddress && "..."}
					{playerData && playerData.fields.playerAddress?.slice(-6, -1)}
				</Typography>
			</UserProfileWrapper>
			<PlaceHolder isTurn={isTurn} onClick={handleClick}>
				<CardWrapper>
					{playerData && playerData.fields.cards && playerData.fields.cards.map((card, index)=>{
						return (
							<Grid item xs={2} key={index}>
								{convertCardNumberToCardImage(card.fields.cardNumber)}
							</Grid> 
							?? "");
					})}
				</CardWrapper>
				<TotalBetAmount>
					<Typography color="white" fontSize="16px" fontWeight={700}>
						{playerInfo?.fields.deposit} MIST
					</Typography>
				</TotalBetAmount>
			</PlaceHolder>
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
	width: 350,
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
	position: "relative",
	display: "flex",
	flexDirection: "column",
});
