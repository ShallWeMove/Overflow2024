import AppBar from "@mui/material/AppBar";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";
import WalletButton from "./WalletButton";
import card from "../../../public/cards/card.png";
import Image from "next/image";

const Navbar = () => {
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
				<a href="/">
					<Image
						src={card}
						alt="card"
						style={{ height: "3.68284rem", width: "3.68284rem" }}
					/>
				</a>
				<Typography
					variant="h3"
					component="div"
					sx={{ flexGrow: 1, color: "#0054E7" }}
				></Typography>
				<WalletButton />
			</Toolbar>
		</AppBar>
	);
};

export default Navbar;
