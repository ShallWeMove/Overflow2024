module shallwemove::player_seat {

  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::card_deck::{Self, Card};
  use sui::dynamic_object_field;
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;

  // ============================================
  // ============== STRUCTS =====================

  public struct PlayerSeat has key, store {
    id : UID,
    index : u8,
    player : Option<address>,
    public_key : vector<u8>,
    cards : vector<Card>,
    deposit : vector<ID>
  }

  // ============================================
  // ============== FUNCTIONS ===================

  public fun new(index : u8, ctx : &mut TxContext) : PlayerSeat {
    PlayerSeat {
      id : object::new(ctx),
      index : index,
      player : option::none(),
      public_key : vector<u8>[],
      cards : vector<Card>[],
      deposit : vector<ID>[]
    }
  }

  // ===================== Methods ===============================

  fun id(player_seat : &PlayerSeat) : ID {object::id(player_seat)}

  public fun player(player_seat : &PlayerSeat) : Option<address> {player_seat.player}

  fun public_key(player_seat : &PlayerSeat) : vector<u8> {player_seat.public_key}

  fun money_ids(player_seat : &PlayerSeat) : vector<ID> {player_seat.deposit}

  public fun set_player(player_seat : &mut PlayerSeat, ctx : &TxContext) {
    player_seat.player = option::some(tx_context::sender(ctx));
  }

  public fun remove_player(player_seat : &mut PlayerSeat, ctx : &mut TxContext){
    // let player_address = tx_context::sender(ctx);
    player_seat.player = option::none();
    player_seat.public_key = vector<u8>[];

    player_seat.remove_money(ctx);
  }

  public fun set_public_key(player_seat : &mut PlayerSeat, public_key : vector<u8>) {
    player_seat.public_key = public_key;
  }

  public fun add_money(player_seat : &mut PlayerSeat, money : Coin<SUI>) {
    // player_seat.money.push_back(object::id(&money));
    player_seat.deposit.push_back(object::id(&money));
    dynamic_object_field::add<ID, Coin<SUI>>(&mut player_seat.id, object::id(&money), money);
  }

  public fun remove_money(player_seat : &mut PlayerSeat, ctx : &mut TxContext) {
    let player_address = tx_context::sender(ctx);
     let mut i = 0;
      // while(i < player_seat.money.length()) {
      while(i < player_seat.deposit.length()) {
        // let money_id = player_seat.money.pop_back();
        let money_id = player_seat.deposit.pop_back();
        let money = dynamic_object_field::remove<ID, Coin<SUI>>(&mut player_seat.id, money_id);
        transfer::public_transfer(money, player_address);

        i = i + 1;
      }
  }

  // ============================================
  // ================ TEST ======================

}