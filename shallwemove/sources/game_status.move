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
    manager_player : Option<address>,
    game_playing_status : u8,
    current_turn : u8,
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

  // ============================================
  // ============== FUNCTIONS ===================

  public fun new(ante_amount : u64, bet_unit : u64, game_seats : u8) : GameStatus {
    let game_info = new_game_info(ante_amount, bet_unit, game_seats);

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

  fun new_game_info(ante_amount : u64, bet_unit : u64, game_seats : u8) : GameInfo {
    assert!(game_seats >= 2 && game_seats <= 5, 403);

    GameInfo {
      manager_player : option::none(),
      game_playing_status : 0,
      current_turn : 0,
      winner_player : option::none(),
      ante_amount : ante_amount,
      bet_unit : bet_unit,
      game_seats : game_seats,
      avail_seats : game_seats
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
  // --------- GameStatus ---------

  public fun game_info(game_status : &GameStatus) : &GameInfo {
    &game_status.game_info
  }

  public fun game_info_mut(game_status : &mut GameStatus) : &mut GameInfo {
    &mut game_status.game_info
  }

  public fun manager_player(game_status : &GameStatus) : Option<address>{game_status.game_info.manager_player}

  public fun set_manager_player(game_status: &mut GameStatus, player : address) {
    game_status.game_info_mut().manager_player = option::some(player);
  }

  public fun is_manager_player(game_status: &GameStatus, ctx : &mut TxContext) : bool {
    return game_status.manager_player() == option::some(tx_context::sender(ctx))
  }

  public fun game_playing_status(game_status : &GameStatus) : u8 {game_status.game_info.game_playing_status}

  fun current_turn(game_status : &GameStatus) : u8 {game_status.game_info.current_turn}

  fun current_turn_player(game_status : &GameStatus) : Option<address> {
    let current_turn_player_info = vector::borrow(&game_status.player_infos, game_status.current_turn() as u64);
    return current_turn_player_info.player_address()
  }

  public fun is_current_turn(game_status : &GameStatus, ctx : &mut TxContext) : bool {
    game_status.current_turn_player() == option::some(tx_context::sender(ctx))
  }

  // fun find_

  fun winner_player(game_status : &GameStatus) : Option<address> {game_status.game_info.winner_player}

  public fun ante_amount(game_status : &GameStatus) : u64 {game_status.game_info.ante_amount}

  fun bet_unit(game_status : &GameStatus) : u64 {game_status.game_info.bet_unit}

  public fun game_seats(game_status : &GameStatus) : u8 {game_status.game_info.game_seats}

  public fun avail_seats(game_status : &GameStatus) : u8 {game_status.game_info.avail_seats}

  fun increment_avail_seat(game_status : &mut GameStatus) {
    game_status.game_info.avail_seats = game_status.game_info.avail_seats + 1; 
  }

  fun decrement_avail_seat(game_status : &mut GameStatus) {
    game_status.game_info.avail_seats = game_status.game_info.avail_seats - 1; 
  }

  fun total_bet_amount(game_status : &GameStatus) : u64 {game_status.money_box_info.total_bet_amount}

  public fun add_money(game_status : &mut GameStatus, money : &Coin<SUI>) {
    game_status.money_box_info.total_bet_amount = game_status.money_box_info.total_bet_amount + money.value();
  }

  fun game_status_number_of_avail_cards(game_status : &GameStatus) : u8 {game_status.card_info.number_of_avail_cards}

  fun number_of_used_cards(game_status : &GameStatus) : u8 {game_status.card_info.number_of_used_cards}

  public fun player_infos(game_status : &GameStatus) : &vector<PlayerInfo> {&game_status.player_infos}
  public fun player_infos_mut(game_status : &mut GameStatus) : &mut vector<PlayerInfo> {&mut game_status.player_infos}

  // public fun player_info(game_status : &GameStatus, ctx : &mut TxContext) : &PlayerInfo {
  //   let mut i = 0;
  //   while (i < game_status.player_infos().length()) {
  //     let player_info = vector::borrow(&game_status.player_infos(), i);
  //     if (player_info.player_address() == option::some(tx_context::sender(ctx))){
  //       return player_info
  //     };

  //     i = i + 1;
  //   };
  //   // return 
  // }

  public fun add_player_info(game_status : &mut GameStatus, player_info : PlayerInfo) {game_status.player_infos.push_back(player_info);}

  public fun enter_player(game_status : &mut GameStatus, ctx : &mut TxContext) {
    // player가 해당 게임의 첫 번째 유저면 manager_player로 등록
    if (game_status.manager_player() == option::none<address>()) {
      game_status.set_manager_player(tx_context::sender(ctx));
    };

    // avail_seat 하나 감소
    game_status.decrement_avail_seat();
  }

  public fun remove_player(game_status : &mut GameStatus, ctx : &mut TxContext) {

    // player가 해당 게임의 manager_player이면 다음으로 넘겨주거나 마지막 유저면 null

    // player가 현재 턴 유저면 넘겨주는 로직

    // avail_seat 하나 추가
    game_status.increment_avail_seat();
  }

  public fun next_turn(game_status : &mut GameStatus) {
    // current turn을 다음 턴으로
    if ( (game_status.current_turn() + 1) as u64 == game_status.player_infos.length()) {
      game_status.game_info.current_turn = 0;
    } else {
      game_status.game_info.current_turn = game_status.game_info.current_turn + 1;
    };
  }

  
  // ============================================
  // ================ TEST ======================
}