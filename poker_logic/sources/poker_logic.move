/// Module: poker_logic
module poker_logic::poker_logic {
  use shallwemove::random::{Self};
  use shallwemove::utils::{Self};
  use sui::random::{Random};
  use std::debug;
  use std::string::{Self};
  

  entry fun test(r: &Random, ctx: &mut TxContext) {
    // random::random_test(r, ctx);
    let array = utils::get_52_numbers_array();
  }

  #[test]
  fun test_test() {
    let array = utils::get_52_numbers_array();
    debug::print(&array);


  }



  

}
