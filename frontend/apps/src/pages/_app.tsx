import "@/styles/globals.css";
import type { AppProps } from "next/app";
import { WalletProvider } from "@suiet/wallet-kit";

export default function App({ Component, pageProps }: AppProps) {
	return (
		<WalletProvider
			chains={[
				{
					id: "sui:testnet",
					name: "Sui Testnet",
					rpcUrl: "https://sui-testnet.nodeinfra.com",
				},
			]}
		>
			<Component {...pageProps} />
		</WalletProvider>
	);
}
