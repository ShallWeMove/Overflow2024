import { SuiClient, GetObjectParams } from "@mysten/sui.js/client";

const TESTNET_ENDPOINT = "https://sui-testnet.nodeinfra.com"
const client = new SuiClient({ url: TESTNET_ENDPOINT });

export const getObjectById = async(objectId: string): Promise<any> => {
    try {
        const input: GetObjectParams = {
            id: objectId,
        };
        const res = await client.getObject(input)
        return res.data
    }   catch (e) {
        console.error("getObject failed", e)
    }
}