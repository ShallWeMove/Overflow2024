import NodeRSA from "node-rsa";

export const generateAndStoreRSAKeyPair = () => {
    const key = new NodeRSA({ b: 512 });

    localStorage.setItem("privateKey", key.exportKey("private"));
    localStorage.setItem("publicKey", key.exportKey("public"));
}

export const encrypt = (data: string): string => {
    const key = new NodeRSA({ b: 512 });
    key.importKey(localStorage.getItem("publicKey") as string, "public");
    return key.encrypt(data, "base64");
}

export const decrypt = (data: string): string => {
    const key = new NodeRSA({ b: 512 });
    key.importKey(localStorage.getItem("privateKey") as string, "private");
    return key.decrypt(data, "utf8");
}