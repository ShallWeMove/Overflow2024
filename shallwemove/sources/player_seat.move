module shallwemove::player_seat {

  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::card_deck::{Self, CardDeck, Card};
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


  public fun set_player(player_seat : &mut PlayerSeat, ctx : &TxContext) {
    player_seat.player_address = option::some(tx_context::sender(ctx));
  }

  public fun set_public_key(player_seat : &mut PlayerSeat, public_key : vector<u8>) {
    player_seat.public_key = public_key;
  }

  public fun add_money(player_seat : &mut PlayerSeat, money : Coin<SUI>) {
    player_seat.deposit.push_back(money);
  }

  public fun receive_card(player_seat : &mut PlayerSeat, card : Card) {
    player_seat.cards.push_back(card);
  }

  public fun remove_player(player_seat : &mut PlayerSeat, card_deck : &mut CardDeck, ctx : &mut TxContext){
    player_seat.player_address = option::none();
    player_seat.public_key = vector<u8>[];

    // 카드도 정리해야지??
    player_seat.remove_cards(card_deck);
    // PlayerSeat에 있는 deposit도 다시 user 지갑으로 보내기
    player_seat.remove_deposit(ctx);
  }

  public fun remove_deposit(player_seat : &mut PlayerSeat, ctx : &mut TxContext) {
    let player_address = tx_context::sender(ctx);
     let mut i = player_seat.deposit.length();
     let mut money_container = coin::zero<SUI>(ctx);
      while(i > 0) {
        let money = player_seat.deposit.pop_back();
        coin::join<SUI>(&mut money_container, money);

        i = i - 1;
      };
      transfer::public_transfer(money_container, player_address);
  }

  fun remove_cards(player_seat : &mut PlayerSeat, card_deck : &mut CardDeck) {
    debug::print(&string::utf8(b"remove cards"));
    let mut i = player_seat.cards.length();
    while (i > 0) {
      let card = player_seat.cards.pop_back();
      card_deck.add_used_card(card);

      i = i - 1;
    };
  }

  public fun split_money(player_seat : &mut PlayerSeat, amount : u64, ctx : &mut TxContext) : Coin<SUI> {
    let mut i = player_seat.deposit.length();
    let mut money_container = coin::zero<SUI>(ctx);
    while (i > 0) {
      let money = player_seat.deposit.pop_back();
      coin::join<SUI>(&mut money_container, money);

      i = i - 1;
    };

    let money = coin::split<SUI>(&mut money_container, amount, ctx);
    vector::push_back(&mut player_seat.deposit, money_container);
    return money
  }



  // ============================================
  // ================ TEST ======================

}