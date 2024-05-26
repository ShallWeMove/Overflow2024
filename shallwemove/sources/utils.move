module shallwemove::utils {
  use shallwemove::encrypt;
  use sui::random::{Self, Random};

  public fun get_fifty_two_numbers_array() : vector<u256> {
    let mut fifty_two_numbers_array = vector<u256>[];
    let mut i = 52;
    while (i > 0) {
      fifty_two_numbers_array.push_back(i);
      i = i - 1;
    };
    fifty_two_numbers_array
  }

  public fun shuffle(number_array : &mut vector<u256>, r: &Random, ctx: &mut TxContext) : &mut vector<u256> {
    let mut generator = random::new_generator(r, ctx);
    random::shuffle(&mut generator, number_array);
    number_array
  }

  public fun encrypt(number_array : vector<u256>, public_key : vector<u8>) : vector<u256> {
    let public_key_int = encrypt::vecu8_to_int(public_key);
    let cipher = encrypt::encrypt_vector(public_key_int, 65537, number_array);
    cipher
  }
}
