
/// Module: shallwemove
module shallwemove::cardgame {
  use sui::object::{Self, ID, UID};
  use std::string::{Self, String};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;
  use std::option::{Self, Option};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use sui::dynamic_object_field;

  // game object which can create game table
  public struct RootGame has key {
    id: UID,
    admin: address,
    public_key: vector<u8>
  }

  public struct CardGame has key {
    id: UID,
    root_game_id : ID,
    game_tables : vector<Option<ID>>
  }

  public struct GameTable has key, store {
    id : UID,
    card_game_id : ID,
    game_status : GameStatus,
    money_box : MoneyBox,
    card_deck : Option<CardDeck>,
    used_card_decks : vector<Option<ID>>,
    player_hands : vector<Option<PlayerHand>>
  }

  public struct GameStatus has store {
    game_info : GameInfo,
    money_box_info : MoneyBoxInfo,
    card_info : CardInfo,
    player_infos : vector<Option<PlayerInfo>>

  }

  public struct GameInfo has store {
    manager_player : Option<address>,
    game_playing_status : u8,
    current_turn_player : Option<address>,
    winner_player : Option<address>,
    ante_amount : u64,
    bet_unit : u64,
    game_seats : u8,
    avail_seats : u8
  }

  public struct MoneyBoxInfo has store {
    total_bet_amount : u64

  }

  public struct CardInfo has store {
    number_of_avail_cards : u8,
    number_of_used_cards : u8
  }

  public struct PlayerInfo has store {
    player_address : address,
    public_key : vector<u8>,
    playing_status : u8,
    number_of_holding_cards : u8,
    previous_bet_amount : u64,
    total_bet_amount : u64
  }

  public struct MoneyBox has key, store {
    id : UID,
    money : vector<Option<Coin<SUI>>>
  }

  public struct CardDeck has key, store {
    id : UID,
    avail_cards : vector<Option<Card>>,
    // avail_cards : vector<Option<ID>>,
    used_cards : vector<Option<Card>>
    // used_cards : vector<Option<ID>>
  }

  public struct Card has key, store {
    id : UID,
    index : u8,
    card_number : u8
  }

  public struct PlayerHand has key, store {
    id : UID,
    owner : address,
    public_key : vector<u8>,
    cards : vector<Option<Card>>,
    // cards : vector<Option<ID>>,
    money : Option<Coin<SUI>>
  }

  fun init(ctx: &mut TxContext) {
  }

  // This function will be executed in the Backend
  // dealer or anyone who wanna be a dealer can create new game
  // RootGame object is essential to play game
  entry fun create_root_game(public_key : vector<u8>, ctx: &mut TxContext) {
    transfer::freeze_object(
      RootGame {
      id : object::new(ctx),
      admin: tx_context::sender(ctx),
      public_key : public_key
      });
  }
  
  entry fun create_card_game(root_game : &RootGame, ctx: &mut TxContext) {
    assert!(root_game.admin == tx_context::sender(ctx), 403);

    transfer::share_object(CardGame{
      id : object::new(ctx),
      root_game_id : object::id(root_game),
      game_tables : vector[option::none()]
    });
  }

  entry fun create_and_add_game_table(root_game : &RootGame, card_game : &mut CardGame, ante_amount : u64, bet_unit : u64, game_seats : u8, ctx : &mut TxContext) {
    assert!(root_game.admin == tx_context::sender(ctx), 403);

    let game_status = create_game_status(ante_amount, bet_unit, game_seats);
    let money_box = create_money_box(ctx);
    let empty_card_deck = create_card_deck(ctx);
    
    let game_table = GameTable {
      id : object::new(ctx),
      card_game_id : object::id(card_game),
      game_status : game_status,
      money_box : money_box,
      card_deck : option::some(empty_card_deck),
      used_card_decks : vector[option::none()],
      player_hands : vector[option::none()]
    };

    let object_field_key = card_game.game_tables.length() + 1;

    dynamic_object_field::add(&mut card_game.id, object_field_key, game_table);

  }

  fun create_game_status(ante_amount : u64, bet_unit : u64, game_seats : u8) : GameStatus {
    assert!(game_seats <= 6, 403);

    let game_info = GameInfo {
      manager_player : option::none(),
      game_playing_status : 0,
      current_turn_player : option::none(),
      winner_player : option::none(),
      ante_amount : ante_amount,
      bet_unit : bet_unit,
      game_seats : game_seats,
      avail_seats : game_seats
    };

    let money_box_info = MoneyBoxInfo {
      total_bet_amount : 0
    };

    let card_info = CardInfo {
      number_of_avail_cards : 0,
      number_of_used_cards : 0
    };

    GameStatus {
      game_info : game_info,
      money_box_info : money_box_info,
      card_info : card_info,
      player_infos : vector[option::none()]
    }
  }

  fun create_money_box(ctx : &mut TxContext) : MoneyBox {
    MoneyBox {
      id : object::new(ctx),
      money : vector[option::none()]
    }
  }

  fun create_card_deck(ctx : &mut TxContext) : CardDeck {
    CardDeck {
      id : object::new(ctx),
      avail_cards : vector[option::none()],
      used_cards : vector[option::none()],
    }

  }

  fun create_card() {

  }


}