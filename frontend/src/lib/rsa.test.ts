import {
    RSA,
    LOCAL_STORAGE_PUBLIC_KEY,
    LOCAL_STORAGE_PRIVATE_KEY,
    LOCAL_STORAGE_KEY_EXPIRATION,
    EXPIRATION_DAYS,
} from './rsa';

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

        console.log("@@@ LocalStorage @@@")
        console.log("Public key:\n", publicKey);
        console.log("Private key:\n", privateKey);
        console.log("Expiration date:\n", expiration);

        expect(publicKey).not.toBeNull();
        expect(privateKey).not.toBeNull();
        expect(expiration).not.toBeNull();
    });

    test('should load keys from localStorage if they exist and are not expired', () => {
        const rsa1 = new RSA();
        const rsa2 = new RSA();

        expect(rsa2['publicKey']).toEqual(rsa1['publicKey']);
        expect(rsa2['privateKey']).toEqual(rsa1['privateKey']);
        expect(rsa2['n']).toEqual(rsa1['n']);
    });

    test('should encode and decode a message correctly', () => {
        const rsa = new RSA();
        const message = 'Test Message 테스트 메시지';
        const encoded = rsa.encode(message);
        const decoded = rsa.decode(encoded);

        console.log("@@@ RSA encode/decode @@@")
        console.log("Initial message:\n", message);
        console.log("The encoded message (encrypted by public key):\n", encoded);
        console.log("The decoded message (decrypted by private key):\n", decoded);

        expect(decoded).toEqual(message);
    });

    test('should regenerate keys if expired', () => {
        const rsa1 = new RSA();

        // Set an expiration date in the past
        const pastDate = new Date();
        pastDate.setDate(pastDate.getDate() - (EXPIRATION_DAYS + 1));
        localStorage.setItem(LOCAL_STORAGE_KEY_EXPIRATION, pastDate.toISOString());

        const rsa2 = new RSA();

        expect(rsa2['publicKey']).not.toEqual(rsa1['publicKey']);
        expect(rsa2['privateKey']).not.toEqual(rsa1['privateKey']);
        expect(rsa2['n']).not.toEqual(rsa1['n']);
    });
});
