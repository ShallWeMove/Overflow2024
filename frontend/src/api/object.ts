import {
	SuiClient,
	GetObjectParams,
	MultiGetObjectsParams,
} from "@mysten/sui.js/client";

const TESTNET_ENDPOINT = "https://sui-testnet.nodeinfra.com";
export const client = new SuiClient({ url: TESTNET_ENDPOINT });

export const getObject = async (objectId: string): Promise<any> => {
	try {
		const input: GetObjectParams = {
			id: objectId,
		};
		const res = await client.getObject(input);
		return res.data;
	} catch (e) {
		console.error("getObject failed", e);
	}
};

export const multiGetObjects = async (objectIds: string[]): Promise<any> => {
	try {
		const input: MultiGetObjectsParams = {
			ids: objectIds,
		};
		const res = await client.multiGetObjects(input);
		return res.map((r) => r.data);
	} catch (e) {
		console.error("batchGetObjects failed", e);
	}
};
