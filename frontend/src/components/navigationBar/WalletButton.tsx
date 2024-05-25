import { useEffect } from "react";
import { useWallet } from "@suiet/wallet-kit";
import { ConnectButton, ErrorCode } from "@suiet/wallet-kit";
import "@suiet/wallet-kit/style.css";
import { walletAtom } from "@/lib/states";
import { useSetAtom } from "jotai";

function WalletButton() {
	const wallet = useWallet();
	const setWallet = useSetAtom(walletAtom);

	useEffect(() => {
		if (wallet.connected) {
			console.log("wallet connected")
			console.log("current wallet: ", wallet);
			setWallet(wallet);
		} else {
			console.log("wallet disconnected")
			// setWallet(null);
			// router.push("/lounge");
		}

	}, [wallet]);

	return (
		<ConnectButton
		// The BaseError instance has properties like {code, message, details}
		// for developers to further customize their error handling.
		onConnectError={(err) => {
		    if (err.code === ErrorCode.WALLET__CONNECT_ERROR__USER_REJECTED) {
		        console.warn('user rejected the connection to ' + err.details?.wallet);
		    } else {
		        console.warn('unknown connect error: ', err);
		    }
		}}
		onConnectSuccess={(walletName) => {
			console.log('[Connection Success]: ', walletName);
		}}
		>
			Connect Your Wallet
		</ConnectButton>
	);
}

export default WalletButton;
