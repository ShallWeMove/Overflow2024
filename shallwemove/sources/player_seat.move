module shallwemove::player_seat {

  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::card_deck::{Self, CardDeck, Card};
  use shallwemove::player_info::{Self, PlayerInfo};
  use shallwemove::game_status::{Self, GameStatus};
  use sui::dynamic_object_field;
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use std::string::{Self, String};
  use std::debug;

  // ============================================
  // ============== STRUCTS =====================

  public struct PlayerSeat has key, store {
    id : UID,
    index : u8,
    player_address : Option<address>,
    public_key : vector<u8>,
    cards : vector<Card>,
    deposit : vector<Coin<SUI>>
  }

  // ============================================
  // ============== FUNCTIONS ===================

  public fun new(index : u8, ctx : &mut TxContext) : PlayerSeat {
    PlayerSeat {
      id : object::new(ctx),
      index : index,
      player_address : option::none(),
      public_key : vector<u8>[],
      cards : vector<Card>[],
      deposit : vector<Coin<SUI>>[]
    }
  }

  // ===================== Methods ===============================

  fun id(player_seat : &PlayerSeat) : ID {object::id(player_seat)}

  public fun player_address(player_seat : &PlayerSeat) : Option<address> {player_seat.player_address}

  fun public_key(player_seat : &PlayerSeat) : vector<u8> {player_seat.public_key}

  public fun cards(player_seat : &PlayerSeat) : &vector<Card> {&player_seat.cards}


  public fun set_player_address(player_seat : &mut PlayerSeat, player_info : &mut PlayerInfo, ctx : &mut TxContext) {
    player_seat.player_address = option::some(tx_context::sender(ctx));
    player_info.set_player_address(ctx);
  }

  // public fun set_player_address_empty(player_seat : &mut PlayerSeat) {
  //   player_seat.player_address = option::none();
  // }

  public fun set_public_key(player_seat : &mut PlayerSeat, player_info : &mut PlayerInfo, public_key : vector<u8>) {
    player_seat.public_key = public_key;
    player_info.set_public_key(public_key);
  }

  public fun add_money(player_seat : &mut PlayerSeat, player_info : &mut PlayerInfo, money : Coin<SUI>) {
    let money_value = money.value();
    player_seat.deposit.push_back(money);
    player_info.add_deposit(money_value);
  }

  public fun draw_card(player_seat : &mut PlayerSeat, player_info : &mut PlayerInfo, card : Card) {
    player_seat.cards.push_back(card);
    player_info.receive_card();
  }

  public fun remove_player_info(player_seat : &mut PlayerSeat, player_info : &mut PlayerInfo){
    player_seat.player_address = option::none();
    player_seat.public_key = vector<u8>[];

    player_info.remove_player_info();
  }

  public fun remove_deposit(player_seat : &mut PlayerSeat, player_info : &mut PlayerInfo, ctx : &mut TxContext) {
    let player_address = tx_context::sender(ctx);
     let mut i = player_seat.deposit.length();
     let mut money_container = coin::zero<SUI>(ctx);
      while(i > 0) {
        let money = player_seat.deposit.pop_back();
        player_info.discard_deposit(money.value());
        // debug::print(&player_info.deposit());

        coin::join<SUI>(&mut money_container, money);

        i = i - 1;
      };
      transfer::public_transfer(money_container, player_address);
  }

  public fun remove_cards(player_seat : &mut PlayerSeat,player_info : &mut PlayerInfo, card_deck : &mut CardDeck) {
    let mut i = player_seat.cards.length();
    while (i > 0) {
      let used_card = player_seat.cards.pop_back();
      player_info.discard_card();

      card_deck.add_used_card(used_card);

      i = i - 1;
    };
  }

  public fun withdraw_money(player_seat : &mut PlayerSeat, player_info : &mut PlayerInfo, amount : u64, ctx : &mut TxContext) : Coin<SUI> {
    let mut i = player_seat.deposit.length();
    let mut money_container = coin::zero<SUI>(ctx);
    while (i > 0) {
      let money = player_seat.deposit.pop_back();
      coin::join<SUI>(&mut money_container, money);

      i = i - 1;
    };

    let money = coin::split<SUI>(&mut money_container, amount, ctx);
    let money_value = money.value();
    vector::push_back(&mut player_seat.deposit, money_container);
    player_info.discard_deposit(money_value);
    return money
  }



  // ============================================
  // ================ TEST ======================

}