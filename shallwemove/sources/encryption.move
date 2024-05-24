module shallwemove::encrypt {

    // public struct PublicKey has key, store {
    //     id: UID,
    //     n: u256, // mod
    //     e: u256, // exponent
    // }
    use sui::test_utils::{Self};
    use std::debug;

    public fun encrypt_vector(n: u256, e: u256, message: vector<u8>) : vector<u256>{

        let mut cipher = vector::empty<u256>(); // 최적화 필요시 메모리 미리 할당할 것. 근데 할당 함수가 없는듯.
        let length = vector::length(&message);
        let mut char : u8;

        let mut i = 0;
        while (i < length){
            char = *vector::borrow(&message, i);
            vector::push_back(&mut cipher, encrypt_256(n, e, char)); 

            i = i + 1
        };


        cipher

    }

    public fun decrypt_vector(n: u256, d: u256, cipher: vector<u256>) : vector<u8>{
        let mut message = vector::empty<u8>();
        let length = vector::length(&cipher);
        let mut char : u256;

        let mut i = 0;
        while (i < length){
            char = *vector::borrow(&cipher, i);
            vector::push_back(&mut message, decrypt_256(n, d, char));
            i = i + 1
        };

        message

    }
    public fun encrypt_256(n: u256, e: u256, char: u8): u256{ 
        modular_exponent(char as u256, e, n)
    }
    public fun decrypt_256(n: u256, d: u256, char: u256): u8{
        modular_exponent(char, d, n) as u8
    }

    public fun modular_exponent(mut base : u256, mut exp : u256, mod : u256) : u256 {
        let mut result = 1u256;
        base = base % mod;

        while (exp > 0){
            if ((exp % 2) == 1){
                result = (result * base) % mod
            };
            exp = exp >> 1;
            base = (base * base) % mod;
        };
        result
    }
    #[test]
    fun test_modular_exponent(){
        let n_1024 : u256 = modular_exponent(2, 10, 100000);
        debug::print(&n_1024);
        assert!(n_1024 == 1024);


    }

    #[test]
    fun test01() {
        let exp = 65537;
        let pub_key = 66633827065583729588053549370837238547u256;
        let priv_key = 37650750721968217797070706451775625801u256;
        let message = b"hello";

        let cipher = encrypt_vector(pub_key, exp, message);
        let d_message = decrypt_vector(pub_key, priv_key, cipher);

        test_utils::print(d_message);
        assert!(d_message == b"hello");
    }


}



