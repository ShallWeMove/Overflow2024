import { Popover, Box, Typography, styled } from "@mui/material";
import { PlayerSeat } from "@/lib/types";

interface PlayerInfoPopoverProps {
	open: boolean;
	anchorEl: null | HTMLElement;
	onClose: () => void;
	playerData: PlayerSeat | undefined;
}

export const PlayerInfoPopover = ({
	open,
	anchorEl,
	onClose,
	playerData,
}: PlayerInfoPopoverProps) => {
	const id = open ? "player-info-popover" : undefined;

	//TODO popover 안보임 해결

	if (open) {
		console.log("playerData: ", playerData);
	}
	return (
		<Popover id={id} open={open} anchorEl={anchorEl} onClose={onClose}>
			<Box>
				<Typography color="white" fontSize="14px" fontWeight={700}>
					balance: {playerData?.fields.deposit[0]?.fields.balance ?? 0}
				</Typography>
				<Typography color="white" fontSize="14px" fontWeight={700}>
					public key: {playerData?.fields.publicKey}
				</Typography>
			</Box>
		</Popover>
	);
};
