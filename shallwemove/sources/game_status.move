module shallwemove::game_status {

  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::player_info::{Self, PlayerInfo};
  use std::vector::{Self};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use std::string::{Self, String};
  use std::debug;

  // ============================================
  // ============== CONSTANTS ===================

  // ==================== Game Statuses ==========================

  const PRE_GAME : u8 = 0;
  const IN_GAME : u8 = 1;
  const GAME_FINISHED : u8 = 2;

  // ============================================
  // ============== STRUCTS =====================

  public struct GameStatus has store {
    game_info : GameInfo,
    money_box_info : MoneyBoxInfo,
    card_info : CardInfo,
    player_infos : vector<PlayerInfo>
  }

  public struct GameInfo has store {
    game_playing_status : u8,
    manager_player : Option<address>,
    max_round : u8,
    current_round : u8,
    current_turn_index : u8,
    previous_turn_index : u8,
    winner_player : Option<address>,
    ante_amount : u64,
    bet_unit : u64,
    game_seats : u8,
    avail_game_seats : u8
  }

  public struct MoneyBoxInfo has store {
    total_bet_amount : u64
  }

  public struct CardInfo has store {
    number_of_avail_cards : u8,
    number_of_used_cards : u8
  }

  // ============================================
  // ============== FUNCTIONS ===================

  public fun new(max_round : u8, ante_amount : u64, bet_unit : u64, game_seats : u8) : GameStatus {
    let game_info = new_game_info(max_round, ante_amount, bet_unit, game_seats);

    let money_box_info = MoneyBoxInfo {
      total_bet_amount : 0
    };

    let card_info = CardInfo {
      number_of_avail_cards : 0,
      number_of_used_cards : 0
    };

    let game_status = GameStatus {
      game_info : game_info,
      money_box_info : money_box_info,
      card_info : card_info,
      player_infos : vector[]
    };

    game_status
  }

  fun new_game_info(max_round : u8, ante_amount : u64, bet_unit : u64, game_seats : u8) : GameInfo {
    assert!(game_seats >= 2 && game_seats <= 5, 201);

    GameInfo {
      game_playing_status : 0,
      manager_player : option::none(),
      max_round : max_round,
      current_round : 0,
      current_turn_index : 0,
      previous_turn_index : 0,
      winner_player : option::none(),
      ante_amount : ante_amount,
      bet_unit : bet_unit,
      game_seats : game_seats,
      avail_game_seats : game_seats
    }
  }

  public fun CONST_PRE_GAME() : u8 {
    return PRE_GAME
  }
  public fun CONST_IN_GAME() : u8 {
    return IN_GAME
  }
  public fun CONST_GAME_FINISHED() : u8 {
    return GAME_FINISHED
  }

  // ===================== Methods ===============================
  // --------- GameInfo ---------

  public fun game_playing_status(game_status : &GameStatus) : u8 {game_status.game_info.game_playing_status}

  public fun manager_player(game_status : &GameStatus) : Option<address>{game_status.game_info.manager_player}

  public fun current_turn_index(game_status : &GameStatus) : u8 {game_status.game_info.current_turn_index}

  public fun previous_turn_index(game_status : &GameStatus) : u8 {game_status.game_info.previous_turn_index}

  public fun max_round(game_status : &GameStatus) : u8 {game_status.game_info.max_round}

  public fun current_round(game_status : &GameStatus) : u8 {game_status.game_info.current_round}

  public fun next_round(game_status : &mut GameStatus) {
    game_status.game_info.current_round = game_status.game_info.current_round + 1; 
  }

  public fun winner_player(game_status : &GameStatus) : Option<address> {game_status.game_info.winner_player}

  public fun set_winner_player(game_status : &mut GameStatus, player_address : Option<address>) {
    game_status.game_info.winner_player = player_address;
  }
  
  public fun ante_amount(game_status : &GameStatus) : u64 {game_status.game_info.ante_amount}

  public fun bet_unit(game_status : &GameStatus) : u64 {game_status.game_info.bet_unit}

  public fun game_seats(game_status : &GameStatus) : u8 {game_status.game_info.game_seats}

  public fun avail_game_seats(game_status : &GameStatus) : u8 {game_status.game_info.avail_game_seats}

  public fun is_manager_player(game_status: &GameStatus, ctx : &mut TxContext) : bool {
    return game_status.manager_player() == option::some(tx_context::sender(ctx))
  }

  public fun is_current_turn(game_status : &GameStatus, ctx : &mut TxContext) : bool {
    game_status.current_turn_player() == option::some(tx_context::sender(ctx))
  }

  fun current_turn_player(game_status : &GameStatus) : Option<address> {
    let current_turn_player_info = game_status.player_infos.borrow(game_status.current_turn_index() as u64);
    return current_turn_player_info.player_address()
  }

  public fun set_current_turn(game_status : &mut GameStatus, index : u8) {
    game_status.game_info.current_turn_index = index;
  }

  public fun set_previous_turn(game_status : &mut GameStatus, index : u8) {
    game_status.game_info.previous_turn_index = index;
  }

  public fun set_game_playing_status(game_status : &mut GameStatus, game_playing_status : u8){
    game_status.game_info.game_playing_status = game_playing_status
  }

  public fun set_manager_player(game_status: &mut GameStatus, manager_player_address : Option<address>) {
    game_status.game_info.manager_player = manager_player_address;
  }

  public fun increment_avail_seat(game_status : &mut GameStatus) {
    game_status.game_info.avail_game_seats = game_status.game_info.avail_game_seats + 1; 
  }

  public fun decrease_avail_seat(game_status : &mut GameStatus) {
    game_status.game_info.avail_game_seats = game_status.game_info.avail_game_seats - 1; 
  }

  public fun reset_game_info(game_status : &mut GameStatus) {
    game_status.game_info.game_playing_status = PRE_GAME;
    game_status.game_info.manager_player = option::none();
    game_status.game_info.current_round = 0;
    game_status.game_info.current_turn_index = 0;
    game_status.game_info.previous_turn_index = 0;
    game_status.game_info.winner_player = option::none();
  }

  // --------- MoneyBoxInfo ---------
  public fun money_box_info(game_status : &mut GameStatus) : &mut MoneyBoxInfo {
    &mut game_status.money_box_info
  }
  fun total_bet_amount(game_status : &GameStatus) : u64 {game_status.money_box_info.total_bet_amount}

  public fun add_bet_amount(game_status : &mut GameStatus, bet_amount : u64) {
    game_status.money_box_info.total_bet_amount = game_status.money_box_info.total_bet_amount + bet_amount;
  }

  public fun discard_money(game_status : &mut GameStatus, money_amount : u64) {
    game_status.money_box_info.total_bet_amount = game_status.money_box_info.total_bet_amount - money_amount;
  }
  

  // --------- CardInfo ---------

  fun number_of_avail_cards(game_status : &GameStatus) : u8 {game_status.card_info.number_of_avail_cards}

  fun number_of_used_cards(game_status : &GameStatus) : u8 {game_status.card_info.number_of_used_cards}

  public fun add_card(game_status : &mut GameStatus) {
    game_status.card_info.number_of_avail_cards = game_status.card_info.number_of_avail_cards + 1;
  }

  public fun draw_card(game_status : &mut GameStatus) {
    game_status.card_info.number_of_avail_cards = game_status.card_info.number_of_avail_cards - 1;
    game_status.card_info.number_of_used_cards = game_status.card_info.number_of_used_cards + 1;
  }

  // public fun player_receive_card(game_status : &mut GameStatus, index : u64) {
  //   let player_info = game_status.player_infos.borrow_mut(index);
  //   player_info.receive_card();
  //   game_status.draw_card();
  // }
  // --------- PlayerInfo ---------

  public fun player_infos(game_status : &GameStatus) : &vector<PlayerInfo> {&game_status.player_infos}

  public fun player_infos_mut(game_status : &mut GameStatus) : &mut vector<PlayerInfo> {&mut game_status.player_infos}

  public fun add_player_info(game_status : &mut GameStatus, player_info : PlayerInfo) {game_status.player_infos.push_back(player_info);}

  // ============================================
  // ================ TEST ======================
}