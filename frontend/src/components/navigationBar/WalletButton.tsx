import { useEffect } from "react";
import { useWallet } from "@suiet/wallet-kit";
import { ConnectButton } from "@suiet/wallet-kit";
import "@suiet/wallet-kit/style.css";
import { useRouter } from "next/router";
import { walletAtom } from "@/lib/states";
import { useSetAtom } from "jotai";

function WalletButton() {
	const router = useRouter();
	const wallet = useWallet();
	const setWallet = useSetAtom(walletAtom);

	useEffect(() => {
		if (wallet.status === "connected") {
			setWallet(wallet);
			router.push("/lounge");
		} else {
			setWallet(null);
			router.push("/");
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [router]);

	return (
		<ConnectButton
		// The BaseError instance has properties like {code, message, details}
		// for developers to further customize their error handling.
		// onConnectError={(err) => {
		//     if (err.code === ErrorCode.WALLET__CONNECT_ERROR__USER_REJECTED) {
		//         console.warn('user rejected the connection to ' + err.details?.wallet);
		//     } else {
		//         console.warn('unknown connect error: ', err);
		//     }
		// }}
		>
			Connect Your Wallet
		</ConnectButton>
	);
}

export default WalletButton;
