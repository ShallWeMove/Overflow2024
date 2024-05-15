import React from "react";
import { Box } from "@mui/material";
import Image from "next/image";
import backgroundImage from "../../../public/bg_landing.jpg";

const Landing = () => {
	return (
		<Box
			sx={{
				position: "relative",
				width: "100%",
				height: "100vh",
			}}
		>
			<Image
				src={backgroundImage}
				alt="background-image"
				quality="100"
				layout="fill"
			/>
		</Box>
	);
};

export default Landing;
