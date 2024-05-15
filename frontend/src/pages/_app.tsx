import "@/styles/globals.css";
import type { AppProps } from "next/app";
import { ThemeProvider } from "@mui/material/styles";
import { ColorModeContext, useMode } from "./theme";
import { CssBaseline, Box } from "@mui/material";
import { WalletProvider } from "@suiet/wallet-kit";
import Navbar from "@/components/navigationBar/Navbar";

export default function App({ Component, pageProps }: AppProps) {
	const [theme, colorMode] = useMode();
	return (
		<ThemeProvider theme={theme}>
			<ColorModeContext.Provider value={colorMode}>
				<CssBaseline />
				<Box sx={{ flexGrow: 1 }}>
					<WalletProvider
						chains={[
							{
								id: "sui:testnet",
								name: "Sui Testnet",
								rpcUrl: "https://sui-testnet.nodeinfra.com",
							},
						]}
					>
						<Navbar />
						<Component {...pageProps} />;
					</WalletProvider>
				</Box>
			</ColorModeContext.Provider>
		</ThemeProvider>
	);
}
