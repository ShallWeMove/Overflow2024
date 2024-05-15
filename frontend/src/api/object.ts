import axios from "axios";

const TESTNET_ENDPOINT = "https://sui-testnet.nodeinfra.com"

export const getObject = async(objectId: string): Promise<any> => {
    const out = await axios.post(TESTNET_ENDPOINT, {
        jsonrpc: "2.0",
        id: 1,
        method: "sui_getObject",
        params: [
            objectId,
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

    return out.data;
}