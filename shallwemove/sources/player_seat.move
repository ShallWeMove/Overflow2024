module shallwemove::player_seat {

  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::card_deck::{Self, CardDeck, Card};
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
    // deposit : vector<ID>
    deposit : vector<Coin<SUI>>
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
      // deposit : vector<ID>[]
      deposit : vector<Coin<SUI>>[]
    }
  }

  // ===================== Methods ===============================

  fun id(player_seat : &PlayerSeat) : ID {object::id(player_seat)}

  public fun player(player_seat : &PlayerSeat) : Option<address> {player_seat.player}

  fun public_key(player_seat : &PlayerSeat) : vector<u8> {player_seat.public_key}

  // public fun deposit(player_seat : &PlayerSeat) : vector<ID> {player_seat.deposit}
  // public fun deposit(player_seat : &PlayerSeat) : vector<Coin<SUI>> {player_seat.deposit}

  // public fun remove_money

  public fun set_player(player_seat : &mut PlayerSeat, ctx : &TxContext) {
    player_seat.player = option::some(tx_context::sender(ctx));
  }

  public fun remove_player(player_seat : &mut PlayerSeat, card_deck : &mut CardDeck, ctx : &mut TxContext){
    // let player_address = tx_context::sender(ctx);
    player_seat.player = option::none();
    player_seat.public_key = vector<u8>[];

    // 카드도 정리해야지??
    player_seat.remove_cards(card_deck);

    player_seat.remove_deposit(ctx);
  }

  public fun set_public_key(player_seat : &mut PlayerSeat, public_key : vector<u8>) {
    player_seat.public_key = public_key;
  }

  public fun add_money(player_seat : &mut PlayerSeat, money : Coin<SUI>) {
    // player_seat.money.push_back(object::id(&money));
    // player_seat.deposit.push_back(object::id(&money));
    player_seat.deposit.push_back(money);
    // dynamic_object_field::add<ID, Coin<SUI>>(&mut player_seat.id, object::id(&money), money);
  }

  public fun remove_deposit(player_seat : &mut PlayerSeat, ctx : &mut TxContext) {
    let player_address = tx_context::sender(ctx);
     let mut i = 0;
     let mut money_container = coin::zero<SUI>(ctx);
      // while(i < player_seat.money.length()) {
      while(i < player_seat.deposit.length()) {
        // let money_id = player_seat.money.pop_back();
        let money = player_seat.deposit.pop_back();
        // let money_id = player_seat.deposit.pop_back();
        // let money = dynamic_object_field::remove<ID, Coin<SUI>>(&mut player_seat.id, money_id);
        coin::join<SUI>(&mut money_container, money);
        // transfer::public_transfer(money, player_address);

        i = i + 1;
      };
      transfer::public_transfer(money_container, player_address);
  }

  public fun split_money(player_seat : &mut PlayerSeat, amount : u64, ctx : &mut TxContext) : Coin<SUI> {
    let mut i = 0;
    let mut money_container = coin::zero<SUI>(ctx);
    while (i < player_seat.deposit.length()) {
      let money = player_seat.deposit.pop_back();
      // let money_id = vector::remove(&mut player_seat.deposit(),i);
      // let money = dynamic_object_field::remove<ID, Coin<SUI>>(&mut player_seat.id, money_id);
      coin::join<SUI>(&mut money_container, money);

      i = i + 1;
    };

    let money = coin::split<SUI>(&mut money_container, amount, ctx);
    vector::push_back(&mut player_seat.deposit, money_container);
    return money
  }

  fun remove_cards(player_seat : &mut PlayerSeat, card_deck : &mut CardDeck) {
    let mut i = 0;
    while (i < player_seat.cards.length()) {
      let card = player_seat.cards.pop_back();
      card_deck.add_used_card(card);

      i = i + 1;
    };
  }

  // ============================================
  // ================ TEST ======================

}