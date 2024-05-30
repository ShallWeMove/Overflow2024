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

	return (
		<Popover id={id} open={open} anchorEl={anchorEl} onClose={onClose}>
			<Container>
				<Typography color="white" fontSize="14px" fontWeight={700}>
					address: {playerData?.fields.deposit[0]?.fields.id.id ?? ""}
				</Typography>
				<Typography color="white" fontSize="14px" fontWeight={700}>
					public key: {playerData?.fields.publicKey}
				</Typography>
				<Typography color="white" fontSize="14px" fontWeight={700}>
					playing action: {playerData?.fields.publicKey}
				</Typography>
				<Typography color="white" fontSize="14px" fontWeight={700}>
					deposit: {playerData?.fields.deposit[0]?.fields.balance ?? 0}
				</Typography>
			</Container>
		</Popover>
	);
};

const Container = styled(Box)({
	padding: 16,
	display: "flex",
	flexDirection: "column",
	backgroundColor: "#273648",
});
