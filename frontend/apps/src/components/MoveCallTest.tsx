import { useWallet } from "@suiet/wallet-kit";

export const MoveCallTest = () => {
	const wallet = useWallet();
	console.log("wallet: ", wallet);
	return <div>movecall</div>;
};
