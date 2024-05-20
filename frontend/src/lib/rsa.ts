export const EXPIRATION_DAYS = 7;
export const LOCAL_STORAGE_PUBLIC_KEY = 'publicKey';
export const LOCAL_STORAGE_PRIVATE_KEY = 'privateKey';
export const LOCAL_STORAGE_KEY_EXPIRATION = 'keyExpiration';

export class RSA {
    private prime: Set<number> = new Set();
    private publicKey: number;
    private privateKey: number;
    private n: number;

    constructor() {
        this.publicKey = 0;
        this.privateKey = 0;
        this.n = 0;

        if (!this.loadKeys()) {
            this.primeFiller();
            this.generateKeys();
        }
    }

    private primeFiller(): void {
        const seive: boolean[] = new Array(250).fill(true);
        seive[0] = false;
        seive[1] = false;
        for (let i = 2; i < 250; i++) {
            for (let j = i * 2; j < 250; j += i) {
                seive[j] = false;
            }
        }
        for (let i = 0; i < seive.length; i++) {
            if (seive[i]) {
                this.prime.add(i);
            }
        }
    }

    private pickRandomPrime(): number {
        const primesArray = Array.from(this.prime);
        const k = Math.floor(Math.random() * primesArray.length);
        const ret = primesArray[k];
        this.prime.delete(ret);
        return ret;
    }

    private gcd(a: number, b: number): number {
        if (b === 0) return a;
        return this.gcd(b, a % b);
    }

    private generateKeys(): void {
        const prime1 = this.pickRandomPrime();
        const prime2 = this.pickRandomPrime();
        this.n = prime1 * prime2;
        const fi = (prime1 - 1) * (prime2 - 1);
        let e = 2;
        while (true) {
            if (this.gcd(e, fi) === 1) break;
            e++;
        }
        this.publicKey = e;
        let d = 2;
        while (true) {
            if ((d * e) % fi === 1) break;
            d++;
        }
        this.privateKey = d;

        const expirationDate = new Date();
        expirationDate.setDate(expirationDate.getDate() + EXPIRATION_DAYS);

        localStorage.setItem(LOCAL_STORAGE_PUBLIC_KEY, JSON.stringify({ e: this.publicKey, n: this.n }));
        localStorage.setItem(LOCAL_STORAGE_PRIVATE_KEY, JSON.stringify({ d: this.privateKey, n: this.n }));
        localStorage.setItem(LOCAL_STORAGE_KEY_EXPIRATION, expirationDate.toISOString());
    }

    private loadKeys(): boolean {
        const publicKey = localStorage.getItem(LOCAL_STORAGE_PUBLIC_KEY);
        const privateKey = localStorage.getItem(LOCAL_STORAGE_PRIVATE_KEY);
        const keyExpiration = localStorage.getItem(LOCAL_STORAGE_KEY_EXPIRATION);

        if (publicKey && privateKey && keyExpiration) {
            const expirationDate = new Date(keyExpiration);
            if (new Date() > expirationDate) {
                this.clearKeys();
                return false;
            }

            const parsedPublicKey = JSON.parse(publicKey);
            const parsedPrivateKey = JSON.parse(privateKey);
            this.publicKey = parsedPublicKey.e;
            this.n = parsedPublicKey.n;
            this.privateKey = parsedPrivateKey.d;
            return true;
        }

        return false;
    }

    private clearKeys(): void {
        localStorage.removeItem(LOCAL_STORAGE_PUBLIC_KEY);
        localStorage.removeItem(LOCAL_STORAGE_PRIVATE_KEY);
        localStorage.removeItem(LOCAL_STORAGE_KEY_EXPIRATION);
    }

    private encrypt(message: number): number {
        let e = this.publicKey;
        let encryptedText = 1;
        while (e--) {
            encryptedText *= message;
            encryptedText %= this.n;
        }
        return encryptedText;
    }

    private decrypt(encryptedText: number): number {
        let d = this.privateKey;
        let decrypted = 1;
        while (d--) {
            decrypted *= encryptedText;
            decrypted %= this.n;
        }
        return decrypted;
    }

    // encode message to encrypted number array
    public encode(message: string): number[] {
        const utf8Encoder = new TextEncoder();
        const bytes = utf8Encoder.encode(message);
        const form: number[] = [];
        for (let i = 0; i < bytes.length; i++) {
            form.push(this.encrypt(bytes[i]));
        }
        return form;
    }

    // decode encrypted number array to string
    public decode(encoded: number[]): string {
        const bytes: number[] = [];
        for (let i = 0; i < encoded.length; i++) {
            bytes.push(this.decrypt(encoded[i]));
        }
        const utf8Decoder = new TextDecoder();
        return utf8Decoder.decode(new Uint8Array(bytes));
    }
}
