
/// Module: shallwemove
module shallwemove::shallwemove {
  use sui::object::{Self, ID, UID};
  use std::string::{Self, String};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;

  // game object which can create game table
  struct RootGame has key {
    id: UID,
    admin: address,
    publicKey: vector<u8>
  }

  fun init(ctx: &mut TxContext) {
  }

  // This function will be executed in the Backend
  // dealer or anyone who wanna be a dealer can create new game
  // GameInfo object is essential to play game
  entry fun create_game(publicKey : vector<u8>, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    let id = object::new(ctx);

    // create_game_table(&game, ctx);

    transfer::freeze_object(
      RootGame {
      id,
      admin: sender,
      publicKey : publicKey
      });
  }

}