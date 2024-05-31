import {
    RSA,
    LOCAL_STORAGE_PUBLIC_KEY,
    LOCAL_STORAGE_PRIVATE_KEY,
    LOCAL_STORAGE_KEY_EXPIRATION,
    EXPIRATION_DAYS,
} from './rsa';
import exp from "node:constants";

// Mock localStorage for Jest environment
const localStorageMock = (() => {
    let store: { [key: string]: string } = {};

    return {
        getItem(key: string) {
            return store[key] || null;
        },
        setItem(key: string, value: string) {
            store[key] = value.toString();
        },
        removeItem(key: string) {
            delete store[key];
        },
        clear() {
            store = {};
        },
    };
})();

Object.defineProperty(window, 'localStorage', {
    value: localStorageMock,
});

describe('RSA', () => {
    beforeEach(() => {
        localStorage.clear();
    });

    test('should generate keys and store them in localStorage', () => {
        const rsa = new RSA();
        const publicKey = localStorage.getItem(LOCAL_STORAGE_PUBLIC_KEY);
        const privateKey = localStorage.getItem(LOCAL_STORAGE_PRIVATE_KEY);
        const expiration = localStorage.getItem(LOCAL_STORAGE_KEY_EXPIRATION);

        expect(publicKey).not.toBeNull();
        expect(privateKey).not.toBeNull();
        expect(expiration).not.toBeNull();

        console.log("@@@ RSA generate keys @@@")
        console.log("Public key:\n", publicKey);
        console.log("Private key:\n", privateKey);
        console.log("Expiration date:\n", expiration);

        if(publicKey && privateKey && expiration) {
            const parsedPublicKey = JSON.parse(publicKey);
            const parsedPrivateKey = JSON.parse(privateKey);
            expect(parsedPublicKey['e']).toEqual(65537);
            expect(parsedPublicKey['n']).toEqual(rsa['n']);
            expect(parsedPrivateKey['d']).toEqual(rsa['privateKey']);
        }
    });

    test('should load keys from localStorage if they exist and are not expired', () => {
        const rsa1 = new RSA();
        const rsa2 = new RSA();

        expect(rsa2['exp']).toEqual(65537);
        expect(rsa2['privateKey']).toEqual(rsa1['privateKey']);
        expect(rsa2['n']).toEqual(rsa1['n']);
    });

    test('should encode and decode a message correctly', () => {
        const rsa = new RSA(12017, 5633);
        const message = 'Hello';
        const expectedEncoded = [10686, 8328, 74, 74, 11823];

        const encoded = rsa.encode(message);
        const decoded = rsa.decode(encoded);

        console.log("@@@ RSA encode/decode @@@")
        console.log("Initial message:\n", message);
        console.log("The encoded message (encrypted by public key):\n", encoded);
        console.log("The decoded message (decrypted by private key):\n", decoded);

        expect(encoded).toEqual(expectedEncoded);
        expect(decoded).toEqual(message);
    });

    test('should regenerate keys if expired', () => {
        const rsa1 = new RSA();
        const pastDate = new Date();
        pastDate.setDate(pastDate.getDate() - (EXPIRATION_DAYS + 1));
        localStorage.setItem(LOCAL_STORAGE_KEY_EXPIRATION, pastDate.toISOString());

        const rsa2 = new RSA();
        const expirationDateStr = localStorage.getItem(LOCAL_STORAGE_KEY_EXPIRATION);
        expect(expirationDateStr).not.toBeNull();
        if (expirationDateStr) {
            const expirationDate = new Date(expirationDateStr);
            expect(expirationDate > pastDate).toBe(true);
            expect(expirationDate > new Date()).toBe(true);
        }
    });
});
