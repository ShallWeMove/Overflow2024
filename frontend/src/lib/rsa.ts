import NodeRSA from "node-rsa";

const EXPIRATION_DAYS = 7;
export const LOCAL_STORAGE_PUBLIC_KEY = 'publicKey';
export const LOCAL_STORAGE_PRIVATE_KEY = 'privateKey';
export const LOCAL_STORAGE_KEY_EXPIRATION = 'keyExpiration';

const getExpirationDate = (): number => {
    const date = new Date();
    date.setDate(date.getDate() + EXPIRATION_DAYS);
    return date.getTime();
};

const clearExpiredKeys = (): void => {
    localStorage.removeItem(LOCAL_STORAGE_PUBLIC_KEY);
    localStorage.removeItem(LOCAL_STORAGE_PRIVATE_KEY);
    localStorage.removeItem(LOCAL_STORAGE_KEY_EXPIRATION);
};

export const generateAndStoreRSAKeyPair = (): void => {
    const existingExpiration = localStorage.getItem(LOCAL_STORAGE_KEY_EXPIRATION);
    const now = new Date().getTime();

    if (existingExpiration && now < parseInt(existingExpiration, 10)) {
        return; // 유효기간이 남아있으면 새로운 키를 생성하지 않음
    }

    // 유효기간이 지났으면 기존 키 제거
    clearExpiredKeys();

    const key = new NodeRSA({ b: 512 });

    localStorage.setItem(LOCAL_STORAGE_PRIVATE_KEY, key.exportKey('private'));
    localStorage.setItem(LOCAL_STORAGE_PUBLIC_KEY, key.exportKey('public'));
    localStorage.setItem(LOCAL_STORAGE_KEY_EXPIRATION, getExpirationDate().toString());
};

export const encrypt = (data: string): string => {
    const publicKey = localStorage.getItem(LOCAL_STORAGE_PUBLIC_KEY);
    if (!publicKey) {
        throw new Error('Public key not found in localStorage');
    }

    const key = new NodeRSA({ b: 512 });
    key.importKey(publicKey, 'public');
    return key.encrypt(data, 'base64');
};

export const decrypt = (data: string): string => {
    const privateKey = localStorage.getItem('privateKey');
    if (!privateKey) {
        throw new Error('Private key not found in localStorage');
    }

    const key = new NodeRSA({ b: 512 });
    key.importKey(privateKey, 'private');
    return key.decrypt(data, 'utf8');
};
