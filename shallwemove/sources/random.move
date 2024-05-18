module shallwemove::random {
  use sui::random::{Self, Random};
  public struct Test has key {
      id : UID,
      number : u8
  }

  entry fun random_test(r: &Random, ctx: &mut TxContext)  {
    // let ran = random::create(ctx);
    let mut generator = random::new_generator(r, ctx); // generator is a PRG
    let number = random::generate_u8_in_range(&mut generator, 1, 6);
    
    transfer::share_object(
    Test {
    id : object::new(ctx),
    number : number
    });

  }

}