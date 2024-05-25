import { useEffect } from "react";
import { useWallet } from "@suiet/wallet-kit";
import { ConnectButton } from "@suiet/wallet-kit";
import "@suiet/wallet-kit/style.css";
import { walletAtom } from "@/lib/states";
import { useSetAtom } from "jotai";

function WalletButton() {
	const wallet = useWallet();
	const setWallet = useSetAtom(walletAtom);

	useEffect(() => {
		if (wallet.status === "connected") {
			setWallet(wallet);
		}
	}, [wallet, setWallet]);

	return <ConnectButton>Connect Your Wallet</ConnectButton>;
}

export default WalletButton;
