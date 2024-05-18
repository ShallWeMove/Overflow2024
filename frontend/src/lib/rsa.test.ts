import { generateAndStoreRSAKeyPair, encrypt, decrypt } from './rsa';

describe('encrypt and decrypt with RSA keypair at local storage', () => {
    beforeEach(() => {
        // 로컬 스토리지를 클리어합니다.
        localStorage.clear();
    });

    it('should generate and store RSA key pair in local storage', () => {
        generateAndStoreRSAKeyPair();

        const privateKey = localStorage.getItem('privateKey');
        const publicKey = localStorage.getItem('publicKey');

        expect(privateKey).not.toBeNull();
        expect(publicKey).not.toBeNull();

        console.log('privateKey:', privateKey);
        console.log('publicKey:', publicKey);
    });

    it('should generate valid RSA keys', () => {
        generateAndStoreRSAKeyPair();

        const testData = 'Hello, World!';

        const encryptedData = encrypt(testData);
        const decryptedData = decrypt(encryptedData);

        console.log('encryptedData:', encryptedData);
        console.log('decryptedData:', decryptedData);

        expect(decryptedData).toBe(testData);
    });
});
