import {
    generateAndStoreRSAKeyPair,
    encrypt,
    decrypt,
    LOCAL_STORAGE_PUBLIC_KEY,
    LOCAL_STORAGE_PRIVATE_KEY,
    LOCAL_STORAGE_KEY_EXPIRATION } from './rsa';

describe('encrypt and decrypt with RSA keypair at local storage', () => {
    beforeEach(() => {
        // 로컬 스토리지를 클리어합니다.
        localStorage.clear();
    });

    it('should generate and store RSA key pair in localStorage if not already present', () => {
        generateAndStoreRSAKeyPair();

        const publicKey = localStorage.getItem(LOCAL_STORAGE_PUBLIC_KEY);
        const privateKey = localStorage.getItem(LOCAL_STORAGE_PRIVATE_KEY);
        const keyExpiration = localStorage.getItem(LOCAL_STORAGE_KEY_EXPIRATION);

        expect(privateKey).not.toBeNull();
        expect(publicKey).not.toBeNull();
        expect(keyExpiration).not.toBeNull();
    });

    it('should not generate new keys if valid keys already exist in localStorage', () => {
        generateAndStoreRSAKeyPair();

        const initialPublicKey = localStorage.getItem(LOCAL_STORAGE_PUBLIC_KEY);
        const initialPrivateKey = localStorage.getItem(LOCAL_STORAGE_PRIVATE_KEY);
        const initialKeyExpiration = localStorage.getItem(LOCAL_STORAGE_KEY_EXPIRATION);

        // 함수 다시 호출
        generateAndStoreRSAKeyPair();

        const publicKey = localStorage.getItem(LOCAL_STORAGE_PUBLIC_KEY);
        const privateKey = localStorage.getItem(LOCAL_STORAGE_PRIVATE_KEY);
        const keyExpiration = localStorage.getItem(LOCAL_STORAGE_KEY_EXPIRATION);

        // 키와 유효기간이 동일해야 함
        expect(publicKey).toBe(initialPublicKey);
        expect(privateKey).toBe(initialPrivateKey);
        expect(keyExpiration).toBe(initialKeyExpiration);
    });

    it('should generate new keys if keys have expired', () => {
        const pastExpirationDate = new Date().getTime() - (1000 * 60 * 60 * 24); // 하루 전
        localStorage.setItem(LOCAL_STORAGE_KEY_EXPIRATION, pastExpirationDate.toString());

        generateAndStoreRSAKeyPair();

        const publicKey = localStorage.getItem(LOCAL_STORAGE_PUBLIC_KEY);
        const privateKey = localStorage.getItem(LOCAL_STORAGE_PRIVATE_KEY);
        const keyExpiration = localStorage.getItem(LOCAL_STORAGE_KEY_EXPIRATION);

        expect(publicKey).not.toBeNull();
        expect(privateKey).not.toBeNull();
        expect(keyExpiration).not.toBeNull();
        if (keyExpiration) {
            expect(parseInt(keyExpiration, 10)).toBeGreaterThan(new Date().getTime());
        }
    });
});

describe('encrypt and decrypt', () => {
    beforeEach(() => {
        // 로컬 스토리지를 클리어하고 RSA 키를 생성합니다.
        localStorage.clear();
        generateAndStoreRSAKeyPair();
    });

    it('should encrypt and decrypt data correctly', () => {
        const testData = 'test data';
        const encryptedData = encrypt(testData);
        const decryptedData = decrypt(encryptedData);

        expect(decryptedData).toBe(testData);
    });

    it('should throw error if public key is not found during encryption', () => {
        localStorage.removeItem('publicKey');

        expect(() => encrypt('test data')).toThrow('Public key not found in localStorage');
    });

    it('should throw error if private key is not found during decryption', () => {
        const testData = 'test data';
        const encryptedData = encrypt(testData);
        localStorage.removeItem('privateKey');

        expect(() => decrypt(encryptedData)).toThrow('Private key not found in localStorage');
    });
});

