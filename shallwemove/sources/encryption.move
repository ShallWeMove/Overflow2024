module shallwemove::encrypt {
  #[test_only]
  use sui::test_utils::{Self};
  
  #[test_only]
  use std::debug;

  const EXPONENT : u256 = 65537;

  public struct TestResult has key, store {
    id: UID,
    public_key: vector<u8>,
    public_key_int: u256,
    original_num: u8,
    encrypted_num: u256
  }

  entry fun test_string_public_key(
    public_key: vector<u8>,
    original_num: u8,
    ctx: &mut TxContext
  ) {
    let public_key_int = vecu8_to_int(public_key);
    let encrypted_num = encrypt_256(public_key_int as u256, EXPONENT, original_num as u256);

    let test_result = TestResult{
        id: object::new(ctx),
        public_key: public_key,
        public_key_int: public_key_int,
        original_num: original_num,
        encrypted_num: encrypted_num
        
    };
    transfer::transfer(test_result, ctx.sender());
  }

  public fun encrypt_vector(n: u256, e: u256, message: vector<u256>) : vector<u256>{

    let mut cipher = vector::empty<u256>(); // 최적화 필요시 메모리 미리 할당할 것. 근데 할당 함수가 없는듯.
    let length = vector::length(&message);
    let mut char : u256;

    let mut i = 0;
    while (i < length){
        char = *vector::borrow(&message, i);
        vector::push_back(&mut cipher, encrypt_256(n, e, char)); 

        i = i + 1
    };


    cipher

  }

  public fun decrypt_vector(n: u256, d: u256, cipher: vector<u256>) : vector<u256>{
    let mut message = vector::empty<u256>();
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
  public fun encrypt_256(n: u256, e: u256, char: u256): u256{ 
    modular_exponent(char as u256, e, n)
  }
  public fun decrypt_256(n: u256, d: u256, char: u256): u256{
    modular_exponent(char, d, n) as u256
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

  public fun vecu8_to_int(string: vector<u8>): u256{
    let length = string.length();
    let mut i = 0;
    let mut char: u8;
    let mut result = 0u256;

    while (i < length) {
        char = *vector::borrow(&string, i);
        assert!(char >= 48 && char <= 57, 1);

        result = result * 10 + ((char-48) as u256);
        i = i + 1;
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
    let message = vector<u256>[12u256, 33u256];

    let cipher = encrypt_vector(pub_key, exp, message);
    let d_message = decrypt_vector(pub_key, priv_key, cipher);

    debug::print(&d_message);
    assert!(d_message == vector<u256>[12u256, 33u256]);
  }

//     #[test]
//     fun test_vector_to_int(){
//         let mut string_int = b"54235423";
//         string_int.reverse();

//         let length = string_int.length();

//         let mut i = 0;
//         let mut char: u8;
//         let mut result = 0;

//         while (i < length) {
//             char = string_int.pop_back();
//             i = i + 1;
//             if (char <48 || char > 57){
//                 test_utils::print(b"number string only");
//             };

//             result = result * 10 + ((char-48) as u64);
//         };
//         debug::print(&result);
//     }

  #[test]
  fun test_vtoi(){
      let result = vecu8_to_int(b"25556");
      debug::print(&result);
      assert!(result == 25556, 1);
  }
}



