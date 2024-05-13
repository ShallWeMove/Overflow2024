
/// Module: shallwemove
module shallwemove::cardgame {
  use sui::object::{Self, ID, UID};
  use std::string::{Self, String};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;
  use std::option::{Self, Option};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;

  // game object which can create game table
  struct RootGame has key {
    id: UID,
    admin: address,
    public_key: vector<u8>
  }

  struct CardGame has key {
    id: UID,
    root_game_id : ID,
    game_tables : vector<GameTable>
  }

  struct GameTable has key, store {
    id : UID,
    // card_game_id : ID,
    game_status : GameStatus,
    money_box : MoneyBox,
    card_deck : CardDeck,
    used_card_decks : vector<Option<CardDeck>>,
    player_hands : vector<Option<PlayerHand>>
  }

  struct GameStatus has store {
    game_info : GameInfo,
    moneybox_info : MoneyBoxInfo,
    card_info : CardInfo,
    player_infos : vector<PlayerInfo>

  }

  struct GameInfo has store {
    manager_player : Option<address>,
    game_playing_status : u8,
    current_turn_player : Option<address>,
    winner_player : Option<address>,
    ante_amount : u64,
    bet_unit : u64,
    game_seats : u8,
    available_seats : u8
  }

  struct MoneyBoxInfo has store {
    total_bet_amount : u64

  }

  struct CardInfo has store {
    number_of_avail_cards : u8,
    number_of_used_cards : u8
  }

  struct PlayerInfo has store {
    player_address : address,
    public_key : vector<u8>,
    playing_status : u8,
    number_of_holding_cards : u8,
    previous_bet_amount : u64,
    total_bet_amount : u64
  }

  struct MoneyBox has store {
    money : Option<Coin<SUI>>
  }

  struct CardDeck has store, drop {
    avail_cards : vector<Option<Card>>,
    used_cards : vector<Option<Card>>
  }

  struct Card has store, drop {
    index : u8,
    card_number : u8
  }

  struct PlayerHand has key, store {
    id : UID,
    owner : address,
    public_key : vector<u8>,
    cards : vector<Option<Card>>,
    money : Option<Coin<SUI>>
  }

  fun init(ctx: &mut TxContext) {
  }

  // This function will be executed in the Backend
  // dealer or anyone who wanna be a dealer can create new game
  // RootGame object is essential to play game
  entry fun create_root_game(public_key : vector<u8>, ctx: &mut TxContext) {
    // create_game_table(&game, ctx);

    transfer::freeze_object(
      RootGame {
      id : object::new(ctx),
      admin: tx_context::sender(ctx),
      public_key : public_key
      });
  }

}