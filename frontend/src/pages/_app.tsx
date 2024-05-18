import "@/styles/globals.css";
import type { AppProps } from "next/app";
import { ThemeProvider } from "@mui/material/styles";
import { useMode } from "./theme";
import { CssBaseline, Box } from "@mui/material";
import { WalletProvider } from "@suiet/wallet-kit";
import Navbar from "@/components/navigationBar/Navbar";
import { Provider as JotaiProvider } from "jotai";

export default function App({ Component, pageProps }: AppProps) {
	const [theme] = useMode();
	return (
		<JotaiProvider>
			<ThemeProvider theme={theme}>
				<CssBaseline />
				<Box sx={{ flexGrow: 1, height: "100vh", overflowY: "hidden" }}>
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
			</ThemeProvider>
		</JotaiProvider>
	);
}
