import { Box } from "@mui/material";
import { EnterGameBox } from "./EnterGameBox";

const Lounge = () => {
	return (
		<Box
			sx={{
				display: "flex",
				flexDirection: "row",
				justifyContent: "center",
				alignItems: "center",
				height: "100vh",
				backgroundImage: `url('/bg_landing.jpg')`,
				backgroundSize: "cover",
				backgroundPosition: "center",
			}}
		>
			<EnterGameBox />
		</Box>
	);
};

export default Lounge;
