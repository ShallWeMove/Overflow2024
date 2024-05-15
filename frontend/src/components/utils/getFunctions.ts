import axios from "axios";

export async function getObject(object_id: string) {
	const url = process.env.TESTNET_ENDPOINT ?? "";
	const response = await axios.post(url, {
		jsonrpc: "2.0",
		id: 1,
		method: "sui_getObject",
		params: [
			object_id,
			{
				showType: true,
				showOwner: true,
				showPreviousTransaction: false,
				showDisplay: false,
				showContent: true,
				showBcs: false,
				showStorageRebate: false,
			},
		],
	});
	// console.log(response);
	return response;
}
