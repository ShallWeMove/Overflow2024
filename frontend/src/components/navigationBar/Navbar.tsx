import AppBar from "@mui/material/AppBar";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";
import WalletButton from "./WalletButton";
import InfoIcon from '@mui/icons-material/Info';
import {useState} from "react";
import GameRulesPopup from "./GameRulesPopUp";

const Navbar = () => {
	const [showRules, setShowRules] = useState(false);

	return (
		<AppBar
			position="static"
			sx={{
				backgroundColor: "rgba(255, 255, 255, 0)",
				height: "7.36569rem",
				display: "flex",
				justifyContent: "center",
				position: "fixed",
				boxShadow: "none",
				zIndex: 1000,
			}}
		>
			<Toolbar>
				<Typography
					variant="h3"
					component="div"
					sx={{ flexGrow: 1, color: "#0054E7" }}
				></Typography>
				<InfoIcon
					sx={{
						color: "primary",
						fontSize: "2.5rem",
						marginRight: "20px",
						cursor: "pointer",
						":hover": {
							color: "#4cceac",
						},
					}}
					onClick={() => setShowRules(true)}
				/>
				<GameRulesPopup onClose={() => setShowRules(false)} showRules={showRules}	/>

				<WalletButton />
			</Toolbar>
		</AppBar>
	);
};

export default Navbar;
