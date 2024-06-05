module shallwemove::utils {
  use shallwemove::encrypt;
  use sui::random::{Self, Random};

  public fun get_52_numbers_array() : vector<u256> {
    let mut numbers_array = vector<u256>[];
    let mut i = 0;
    while (i < 52) {
      numbers_array.push_back(i);
      i = i + 1;
    };
    numbers_array.reverse();
    numbers_array
  }

  public fun shuffle(number_array : &mut vector<u256>, r: &Random, ctx: &mut TxContext){
    let mut generator = random::new_generator(r, ctx);
    random::shuffle(&mut generator, number_array);
  }

  #[test_only]
  public fun shuffle_for_testing(number_array : &mut vector<u256>, ctx: &mut TxContext){

    // let mut generator = random::new_generator(r, ctx);
    let mut generator = random::new_generator_for_testing();
    random::shuffle(&mut generator, number_array);
  }
}
