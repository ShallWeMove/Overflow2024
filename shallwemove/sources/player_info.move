module shallwemove::player_info {

  // ============================================
  // ============= IMPORTS ======================
  
  use std::string::{Self, String};
  use std::debug;
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;

  // ============================================
  // ============== CONSTANTS ===================

  // ==================== Playing Statuses ==========================

  const EMPTY : u8 = 10; 
  const ENTER : u8 = 11;
  const READY : u8 = 12;
  const PLAYING : u8 = 13;
  const GAME_END : u8 = 14;
  // const WRONG_PLAYING_STATUS : u8 = 19;

  // ==================== Playing Actions ==========================

  const NONE : u8 = 20;
  const ANTE : u8 = 21;
  const BET : u8 = 22;
  const CHECK : u8 = 23;
  const CALL : u8 = 24;
  const RAISE : u8 = 25;
  const FOLD : u8 = 26;

  // ============================================
  // ============== STRUCTS =====================

  // public struct PlayerInfo has copy, store, drop {
  public struct PlayerInfo has store, drop {
    index : u8,
    player_address : Option<address>,
    public_key : vector<u8>,
    playing_status : u8,
    playing_action : u8,
    number_of_holding_cards : u8,
    previous_bet_amount : u64,
    total_bet_amount : u64
  }

  // ============================================
  // ============== FUNCTIONS ===================

  // public fun get_playing_status(playing_status : String) : u8 {
  //   if (playing_status == string::utf8(b"EMPTY")) {
  //     return EMPTY
  //   } else if (playing_status == string::utf8(b"ENTER")) {
  //     return ENTER
  //   } else if (playing_status == string::utf8(b"READY")) {
  //     return READY
  //   } else if (playing_status == string::utf8(b"PLAYING")) {
  //     return PLAYING
  //   } else if (playing_status == string::utf8(b"GAME_END")) {
  //     return GAME_END
  //   };

  //   return WRONG_PLAYING_STATUS
  // }

  public fun new(index : u8) : PlayerInfo {
    PlayerInfo {
      index : index,
      player_address : option::none(),
      public_key : vector<u8>[],
      playing_status : EMPTY,
      playing_action : NONE,
      number_of_holding_cards : 0,
      previous_bet_amount : 0,
      total_bet_amount : 0
    }
  }

  public fun CONST_EMPTY() : u8 {
    EMPTY
  }
  public fun CONST_ENTER() : u8 {
    ENTER
  }
  public fun CONST_READY() : u8 {
    READY
  }
  public fun CONST_PLAYING() : u8 {
    PLAYING
  }
  public fun CONST_GAME_END() : u8 {
    GAME_END
  }

  // ===================== Methods ===============================

  public fun player_address(player_info : &PlayerInfo) : Option<address> {player_info.player_address}

  fun public_key(player_info : &PlayerInfo) : vector<u8> {player_info.public_key}

  public fun playing_status(player_info : &PlayerInfo) : u8 {player_info.playing_status}

  public fun set_playing_status(player_info : &mut PlayerInfo, playing_status : u8) {
    player_info.playing_status = playing_status;
  }

  fun number_of_holding_cards(player_info : &PlayerInfo) : u8 {player_info.number_of_holding_cards}

  fun previous_bet_amount(player_info : &PlayerInfo) : u64 {player_info.previous_bet_amount}

  fun total_bet_amount(player_info : &PlayerInfo) : u64 {player_info.total_bet_amount}

  public fun add_bet_amount(player_info : &mut PlayerInfo, bet_amount : u64) {
    player_info.previous_bet_amount = bet_amount;
    player_info.total_bet_amount = player_info.total_bet_amount + bet_amount;
  }

  public fun set_player(player_info : &mut PlayerInfo, ctx : &mut TxContext) {
    player_info.player_address = option::some(tx_context::sender(ctx));
  }

  public fun remove_player(player_info : &mut PlayerInfo, ctx : &mut TxContext) {
    assert!(tx_context::sender(ctx) == player_info.player_address().extract(), 403);
    player_info.player_address = option::none();
    player_info.playing_status = EMPTY;
    player_info.playing_action = NONE;

    player_info.previous_bet_amount = 0;
    player_info.total_bet_amount = 0;
    player_info.number_of_holding_cards = 0;
  }

  public fun set_public_key(player_info : &mut PlayerInfo, public_key : vector<u8>) {
    player_info.public_key = public_key;
  }


  // public fun is_participated(player_info : &mut PlayerInfo, ctx : &mut TxContext) : bool {
  //   if (player_info.player_address() == option::none()) {
  //     false
  //   } else {
  //     option::extract(&mut player_info.player_address()) == tx_context::sender(ctx)
  //   }
  // }
  
  // ============================================
  // ================ TEST ======================
}