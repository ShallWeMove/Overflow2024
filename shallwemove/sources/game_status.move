module shallwemove::game_status {

  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::player_info::{Self, PlayerInfo};

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
    assert!(game_seats >= 2 && game_seats <= 6, 403);

    GameInfo {
      manager_player : option::none(),
      game_playing_status : 0,
      current_turn_player : option::none(),
      winner_player : option::none(),
      ante_amount : ante_amount,
      bet_unit : bet_unit,
      game_seats : game_seats,
      avail_seats : game_seats
    }
  }

  // ===================== Methods ===============================
  // --------- GameStatus ---------

  public fun game_info(game_status : &GameStatus) : &GameInfo {
    &game_status.game_info
  }

  public fun manager_player(game_status : &GameStatus) : Option<address>{game_status.game_info.manager_player}

  public fun set_manager_player(game_status: &mut GameStatus, player : address) {
    game_status.game_info.manager_player = option::some(player);
  }

  fun is_manager_player(game_status: &GameStatus, ctx : &mut TxContext) : bool {
    return game_status.manager_player() == option::some(tx_context::sender(ctx))
  }

  fun game_playing_status(game_status : &GameStatus) : u8 {game_status.game_info.game_playing_status}

  fun current_turn_player(game_status : &GameStatus) : Option<address> {game_status.game_info.current_turn_player}

  fun winner_player(game_status : &GameStatus) : Option<address> {game_status.game_info.winner_player}

  fun ante_amount(game_status : &GameStatus) : u64 {game_status.game_info.ante_amount}

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

  fun game_status_number_of_avail_cards(game_status : &GameStatus) : u8 {game_status.card_info.number_of_avail_cards}

  fun number_of_used_cards(game_status : &GameStatus) : u8 {game_status.card_info.number_of_used_cards}

  public fun player_infos(game_status : &GameStatus) : vector<PlayerInfo> {game_status.player_infos}

  public fun add_player_info(game_status : &mut GameStatus, player_info : PlayerInfo) {game_status.player_infos.push_back(player_info);}

  public fun enter_player(game_status : &mut GameStatus, ctx : &mut TxContext) {
    // player가 해당 게임의 첫 번째 유저면 manager_player로 등록

    // avail_seat 하나 감소
    game_status.decrement_avail_seat();
  }

  public fun remove_player(game_status : &mut GameStatus, ctx : &mut TxContext) {

    // player가 해당 게임의 manager_player이면 다음으로 넘겨주거나 마지막 유저면 null

    // player가 현재 턴 유저면 넘겨주는 로직

    // avail_seat 하나 추가
    game_status.increment_avail_seat();
  }

  
  // ============================================
  // ================ TEST ======================
}