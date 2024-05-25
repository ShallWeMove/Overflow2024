import {
	SuiClient,
	GetObjectParams,
	MultiGetObjectsParams,
} from "@mysten/sui.js/client";

const TESTNET_ENDPOINT = "https://sui-testnet.nodeinfra.com";
export const client = new SuiClient({ url: TESTNET_ENDPOINT });

export const getObject = async (objectId: string): Promise<any> => {
	if (!objectId) {
		return;
	}

	try {
		const input: GetObjectParams = {
			id: objectId,
			options: {
				showContent: true,
			}
		};
		const res = await client.getObject(input);

		return res.data;
	} catch (e) {
		console.log("getObject failed: ", e, "objectId: ", objectId);
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
