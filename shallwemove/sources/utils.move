module shallwemove::utils {
  use shallwemove::encrypt;
  use sui::random::{Self, Random};

  public fun get_52_numbers_array() : vector<u256> {
    let mut fifty_two_numbers_array = vector<u256>[];
    let mut i = 52;
    while (i > 0) {
      fifty_two_numbers_array.push_back(i);
      i = i - 1;
    };
    fifty_two_numbers_array
  }

  public fun shuffle(number_array : &mut vector<u256>, r: &Random, ctx: &mut TxContext){
    let mut generator = random::new_generator(r, ctx);
    random::shuffle(&mut generator, number_array);
  }
}
