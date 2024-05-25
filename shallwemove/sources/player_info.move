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
  const BET : u8 = 21;
  const CHECK : u8 = 22;
  const CALL : u8 = 23;
  const RAISE : u8 = 24;
  const FOLD : u8 = 25;

  // ============================================
  // ============== STRUCTS =====================

  // public struct PlayerInfo has copy, store, drop {
  public struct PlayerInfo has store, drop {
    index : u8,
    player_address : Option<address>,
    public_key : vector<u8>,
    deposit : u64,
    playing_status : u8,
    playing_action : u8,
    number_of_holding_cards : u8,
    previous_bet_amount : u64,
    total_bet_amount : u64
  }

  // ============================================
  // ============== FUNCTIONS ===================

  public fun new(index : u8) : PlayerInfo {
    PlayerInfo {
      index : index,
      player_address : option::none(),
      deposit : 0,
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

  public fun CONST_NONE() : u8 {
    NONE
  }
  public fun CONST_BET() : u8 {
    BET
  }
  public fun CONST_CHECK() : u8 {
    CHECK
  }
  public fun CONST_CALL() : u8 {
    CALL
  }
  public fun CONST_RAISE() : u8 {
    RAISE
  }
  public fun CONST_FOLD() : u8 {
    FOLD
  }

  // ===================== Methods ===============================

  public fun player_address(player_info : &PlayerInfo) : Option<address> {player_info.player_address}

  fun public_key(player_info : &PlayerInfo) : vector<u8> {player_info.public_key}

  public fun deposit(player_info : &PlayerInfo) : u64 {player_info.deposit}

  public fun playing_status(player_info : &PlayerInfo) : u8 {player_info.playing_status}

  public fun playing_action(player_info : &PlayerInfo) : u8 {player_info.playing_action}

  public fun set_playing_status(player_info : &mut PlayerInfo, playing_status : u8) {
    player_info.playing_status = playing_status;
  }

  fun number_of_holding_cards(player_info : &PlayerInfo) : u8 {player_info.number_of_holding_cards}

  fun previous_bet_amount(player_info : &PlayerInfo) : u64 {player_info.previous_bet_amount}

  public fun total_bet_amount(player_info : &PlayerInfo) : u64 {player_info.total_bet_amount}


  public fun add_bet_amount(player_info : &mut PlayerInfo, bet_amount : u64) {
    player_info.previous_bet_amount = bet_amount;
    player_info.total_bet_amount = player_info.total_bet_amount + bet_amount;
  }

  public fun set_player_address(player_info : &mut PlayerInfo, ctx : &mut TxContext) {
    player_info.player_address = option::some(tx_context::sender(ctx));
  }

  public fun remove_player_info(player_info : &mut PlayerInfo) {
    player_info.player_address = option::none();
    player_info.public_key = vector<u8>[];

    player_info.playing_status = EMPTY;
    player_info.playing_action = NONE;
  }


  public fun add_deposit(player_info : &mut PlayerInfo, deposit_amount : u64) {
    player_info.deposit = player_info.deposit + deposit_amount;
  }

  public fun discard_deposit(player_info : &mut PlayerInfo, deposit_amount : u64) {
    player_info.deposit = player_info.deposit - deposit_amount;
  }

  public fun set_public_key(player_info : &mut PlayerInfo, public_key : vector<u8>) {
    player_info.public_key = public_key;
  }

  public fun set_playing_action(player_info : &mut PlayerInfo, playing_action : u8) {
    player_info.playing_action = playing_action;
  }

  public fun receive_card(player_info : &mut PlayerInfo) {
    player_info.number_of_holding_cards = player_info.number_of_holding_cards + 1;
  }

  public fun discard_card(player_info : &mut PlayerInfo) {
    player_info.number_of_holding_cards = player_info.number_of_holding_cards - 1;
  }

  // ============================================
  // ================ TEST ======================
}