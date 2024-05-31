module shallwemove::game_table {

  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::game_status::{Self, GameStatus, GameInfo, MoneyBoxInfo, CardInfo};
  use shallwemove::player_info::{Self, PlayerInfo};
  use shallwemove::player_seat::{Self, PlayerSeat};
  use shallwemove::money_box::{Self, MoneyBox};
  use shallwemove::card_deck::{Self, CardDeck, Card};
  use shallwemove::mini_poker_logic::{Self};
  use shallwemove::encrypt;
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use std::string::{Self, String};
  use std::debug;
  use std::vector::{Self};
  use sui::dynamic_object_field;
  use sui::random::{Self, Random};


  // ============================================
  // ============== CONSTANTS ===================
  
  const GAME_TABLE_FULL : u64 = 100;
  const PLAYER_NOT_FOUND : u64 = 101;
  const NEXT_PLAYER_NOT_FOUND : u64 = 102;

  // ============================================
  // ============== STRUCTS =====================

  public struct GameTable has key, store {
    id : UID,
    lounge_id : ID,
    casino_public_key : vector<u8>,
    game_status : GameStatus,
    money_box : MoneyBox,
    card_deck : Option<CardDeck>,
    used_card_decks : vector<ID>,
    player_seats : vector<PlayerSeat>
  }
  
  // ============================================
  // ============== FUNCTIONS ===================

  public fun new(
    lounge_id : ID,
    casino_public_key : vector<u8>,
    max_round : u8,
    ante_amount : u64, 
    bet_unit : u64, 
    game_seats : u8, 
    r: &Random,
    ctx : &mut TxContext) : GameTable {

    let mut game_status = game_status::new(max_round, ante_amount, bet_unit, game_seats);
    let money_box = money_box::new(ctx);
    let mut card_deck = card_deck::new(casino_public_key, ctx);

    card_deck.fill_cards(&mut game_status, casino_public_key, r, ctx);

    let mut game_table = GameTable {
      id : object::new(ctx),
      lounge_id : lounge_id,
      casino_public_key : casino_public_key,
      game_status : game_status,
      money_box : money_box,
      card_deck : option::some(card_deck),
      used_card_decks : vector[],
      player_seats : vector[]
    };

    game_table.create_player_seats(ctx);

    game_table
  }


  // =============================================================
  // ===================== Methods ===============================

  // Create Methods ===============================
  fun create_player_seats(game_table : &mut GameTable, ctx: &mut TxContext) {
    let mut i = 0 as u8;
    while (i < game_table.game_status.game_seats()) {

      let player_seat = player_seat::new(i, ctx);
      let player_info = player_info::new(i);

      game_table.player_seats.push_back(player_seat);
      game_table.game_status.add_player_info(player_info);
      i = i + 1;
    };
  }

  // Public Methods ===============================
  public fun enter(game_table : &mut GameTable, public_key : vector<u8>, deposit : Coin<SUI>, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    assert!(player_seat_index == PLAYER_NOT_FOUND, 103);

    let empty_seat_index = game_table.find_empty_seat_index();
    if (empty_seat_index == GAME_TABLE_FULL) {
      // game table이 꽉 찼으면 deposit은 다시 user address로 되돌려보낸다.
      transfer::public_transfer(deposit, tx_context::sender(ctx));
    } else {
      // game table에 참여할 수 있으면 참여 시킨다.
      game_table.enter_player(empty_seat_index, public_key, deposit, ctx);
    };
  }

  public fun exit(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    assert!(player_seat_index != PLAYER_NOT_FOUND, 104);

    game_table.game_status.player_infos_mut().borrow_mut(player_seat_index).set_playing_action(player_info::CONST_EXIT());

    // player가 해당 게임의 manager_player이면 다음으로 넘겨주거나 마지막 유저면 option::none()
    let next_player_seat_index = game_table.find_next_player_seat_index(ctx);
    if (next_player_seat_index == NEXT_PLAYER_NOT_FOUND) {
      game_table.game_status.set_manager_player(option::none());
      game_table.game_status.set_current_turn(0);
    } else {
      game_table.game_status.set_manager_player(game_table.player_seats.borrow_mut(next_player_seat_index).player_address());
      game_table.game_status.set_current_turn(next_player_seat_index as u8);
    };
    
    if (game_table.game_status.game_playing_status() == game_status::CONST_IN_GAME() 
    && game_table.game_status.is_current_turn(ctx)) {
      game_table.next_turn(ctx);
    };

    // 만약 게임 중이고 남은 플레이어가 exit player 포함 2명이라 게임이 불가하면 -> 게임 종료
    if (game_table.game_status.game_playing_status() == game_status::CONST_IN_GAME() 
    && game_table.number_of_players() == 2) {
      game_table.finish_game(ctx);
    };

    // player 정보 제거
    game_table.exit_player(player_seat_index, ctx);
  }

  public fun ante(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    assert!(player_seat_index != PLAYER_NOT_FOUND, 105);

    let ante_amount = game_table.game_status.ante_amount();
    game_table.bet_money(player_seat_index, ante_amount, ctx);

    // READY 상태로 전환
    game_table.game_status.player_infos_mut().borrow_mut(player_seat_index).set_playing_status(player_info::CONST_READY());
  }

  public fun start(game_table : &mut GameTable, ctx : &mut TxContext) {
    assert!(game_table.game_status.is_manager_player(ctx), 106);
    assert!(game_table.number_of_players() >= 2, 106);
    assert!(game_table.is_all_player_ready(), 107);

    game_table.draw_card_to_all_player();

    // GameStatus 및 모든 플레이이어의 playing_status 업데이트
    game_table.set_all_player_playing_status(player_info::CONST_PLAYING());
    game_table.game_status.set_game_playing_status(game_status::CONST_IN_GAME());
  }

  public fun action(game_table : &mut GameTable, action_type : u8, raise_chip_count : u64, ctx : &mut TxContext) {
    assert!(game_table.game_status().is_current_turn(ctx), 113);

    // 첫 베팅인가? (current turn index 랑 previous turn index 랑 같은가?)
    if (game_table.game_status.current_turn_index() == game_table.game_status.previous_turn_index()){
      // 한 라운드의 최초의 턴일 경우 CHECK or BET or FOLD 할 수 있음 -> CALL, RAISE 불가
      assert!(action_type != player_info::CONST_CALL(), 114);
      assert!(action_type != player_info::CONST_RAISE(), 115);
    };

    // previous turn index의 베팅이 CHECK인가? 
    if (game_table.game_status.player_infos().borrow(game_table.game_status.previous_turn_index() as u64).playing_action() == player_info::CONST_CHECK()) {
      // CHECK 다음에는 CHECK or BET or FOLD 할 수 있음 -> CALL, RAISE 불가
      assert!(action_type != player_info::CONST_CALL(), 116);
      assert!(action_type != player_info::CONST_RAISE(), 117);
    };

    // previous turn index의 베팅이 BET인가? 
    if (game_table.game_status.player_infos().borrow(game_table.game_status.previous_turn_index() as u64).playing_action() == player_info::CONST_BET()) {
      // BET 다음 부터는 CALL or RAISE or FOLD 할 수 있음 -> CHECK, BET 불가
      assert!(action_type != player_info::CONST_CHECK(), 118);
      assert!(action_type != player_info::CONST_BET(), 119);
    };

    // previous turn index의 베팅이 CALL인가? 
    if (game_table.game_status.player_infos().borrow(game_table.game_status.previous_turn_index() as u64).playing_action() == player_info::CONST_CALL()) {
      // CALL 다음 부터는 CALL or RAISE or FOLD 할 수 있음 -> CHECK, BET 불가
      assert!(action_type != player_info::CONST_CHECK(), 120);
      assert!(action_type != player_info::CONST_BET(), 121);
    };

    // 모든 검토 과정이 끝나고 결국 실제 action을 여기서 진행
    if (action_type == player_info::CONST_CHECK()) {
      game_table.check(ctx);
      return
    };

    if (action_type == player_info::CONST_BET()) {
      game_table.bet(ctx);
      return
    };

    if (action_type == player_info::CONST_CALL()) {
      game_table.call(ctx);
      return
    };

    if (action_type == player_info::CONST_RAISE()) {
      game_table.raise(raise_chip_count, ctx);
      return
    };

    if (action_type == player_info::CONST_FOLD()) {
      game_table.fold(ctx);
      return
    };
  }

  public fun settle_up(game_table : &mut GameTable, r : &Random, ctx : &mut TxContext) {
    assert!(game_table.game_status.game_playing_status() == game_status::CONST_GAME_FINISHED(), 122);
    assert!(game_table.game_status.is_winner_player(ctx), 122);

    // 못 찾는다면 잘못된 game_table이라는 것. 
    let winner_player_seat_index = game_table.find_player_seat_index(ctx);
    
    // 먼저 모든 player seat 에서 카드를 card deck으로 수거한다.
    let mut i = 0 ;
    while (i < game_table.game_status.game_seats() as u64) {
      let player_seat = game_table.player_seats.borrow_mut(i);
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(i);
      if (player_seat.player_address() == option::none()) {
        i = i + 1;
        continue
      };

      player_seat.remove_cards(player_info, game_table.card_deck.borrow_mut());
      i = i + 1;
    };

    // card deck은 used_card_decks 로 옮긴다.
    let used_card_deck = game_table.card_deck.extract();
    game_table.used_card_decks.push_back(used_card_deck.id());
    dynamic_object_field::add<ID, CardDeck>(&mut game_table.id, used_card_deck.id(), used_card_deck);

    // 새로운 card deck을 생성해서 game table로 보낸다. 여기서 r 사용
    let mut card_deck = card_deck::new(game_table.casino_public_key, ctx);
    card_deck.fill_cards(&mut game_table.game_status, game_table.casino_public_key, r, ctx);
    option::fill(&mut game_table.card_deck, card_deck);

    // Money box에 있는 돈을 모두 merge해서 winner player에게 준다.
    let winner_player_seat = game_table.player_seats.borrow_mut(winner_player_seat_index);
    game_table.money_box.send_all_money(winner_player_seat, &mut game_table.game_status, ctx);

    // game info 초기화 한다.
      // winner player를 manager player로 설정한다.
    game_table.game_status.reset_game_info();
    game_table.game_status.set_manager_player(winner_player_seat.player_address());
    game_table.game_status.set_current_turn(winner_player_seat_index as u8);

    // player info 초기화 한다.
    let mut i = 0 ;
    while (i < game_table.game_status.game_seats() as u64) {
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(i);
      if (player_info.player_address() == option::none()) {
        i = i + 1;
        continue
      };

      player_info.reset_player_info();
      i = i + 1;
    };
  }

  // Game Play Methods ===============================
  fun enter_player(game_table : &mut GameTable, empty_seat_index : u64, public_key : vector<u8>, deposit : Coin<SUI>, ctx : &mut TxContext) {
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(empty_seat_index);
    let player_seat = game_table.player_seats.borrow_mut(empty_seat_index);

    player_seat.set_player_address(player_info, ctx);
    player_seat.set_public_key(player_info, public_key);
    player_seat.add_money(player_info, deposit);

    player_info.set_playing_status(player_info::CONST_ENTER());

    // player가 해당 게임에 manage_player가 없으면 manager_player로 등록
    if (game_table.game_status.manager_player() == option::none<address>()) {
      game_table.game_status.set_manager_player(option::some(tx_context::sender(ctx)));
      game_table.game_status.set_current_turn(0);
    };

    // avail_seat 하나 감소
    game_table.game_status.decrease_avail_seat();
  }

  fun exit_player(game_table : &mut GameTable, player_seat_index : u64, ctx : &mut TxContext) {
    let player_seat = game_table.player_seats.borrow_mut(player_seat_index);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);
    
    // tx sender가 해당 player_seat 자리 주인이 아니면 assert!
    assert!(option::some(tx_context::sender(ctx)) == player_seat.player_address(), 101);

    player_seat.remove_deposit(player_info, ctx);
    player_seat.remove_cards(player_info, game_table.card_deck.borrow_mut());
    player_seat.remove_player_info(player_info);

    game_table.game_status.increment_avail_seat();
  }

  fun check(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    player_info.set_playing_action(player_info::CONST_CHECK());

    // CHECK 후 PLAYING 중인 모든 player가 CHECK를 했는가? -> 아니라면 다음 턴
    if (!game_table.is_all_player_check()) {
      game_table.next_turn(ctx);
      return
    };

    // round가 끝나서 게임을 더 진행할 수 없는가? -> 게임을 끝낸다
    if (game_table.is_round_over()){
      game_table.finish_game(ctx);
      return
    };

    // round가 아직 남아서 게임을 더 진행할 수 있는가? -> 다음 라운드
    game_table.next_round(ctx);
  }

  fun bet(game_table : &mut GameTable, ctx : &mut TxContext) {
    // bet_unit 만큼의 금액을 베팅한다.
    let player_seat_index = game_table.find_player_seat_index(ctx);
    let bet_unit = game_table.game_status.bet_unit();
    game_table.bet_money(player_seat_index, bet_unit , ctx);

    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    // player action 은 BET
    player_info.set_playing_action(player_info::CONST_BET());

    // 그리고 다음 턴
    game_table.next_turn(ctx);
  }


  fun call(game_table : &mut GameTable, ctx : &mut TxContext) {
    let previous_player_seat_index = game_table.game_status.previous_turn_index() as u64;
    let previous_player_total_bet_amount = game_table.game_status.player_infos().borrow(previous_player_seat_index).total_bet_amount();

    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    // player action 은 CALL
    player_info.set_playing_action(player_info::CONST_CALL());

    // 현재 플레이어의 총 베팅 금액을 직전 플레이어의 총 베팅 금액과 동일하게 맞춘다.
    let bet_amount = previous_player_total_bet_amount - player_info.total_bet_amount();
    game_table.bet_money(player_seat_index, bet_amount, ctx);

    // CALL을 하고 PLAYING 중인 모든 플레이어의 베팅 총액이 동일해 졌는가? ->아니라면 다음 턴
    if (!game_table.is_all_player_bet_amount_same()) {
      game_table.next_turn(ctx);
      return
    };

    // round가 끝나서 게임을 더 진행할 수 없는가? -> 게임을 끝낸다
    if (game_table.is_round_over()){
      game_table.finish_game(ctx);
      return
    };

    // round가 아직 남아서 게임을 더 진행할 수 있는가? -> 다음 라운드
    game_table.next_round(ctx);
  }
  
  fun raise(game_table : &mut GameTable, raise_chip_count : u64, ctx : &mut TxContext) {
    let previous_player_seat_index = game_table.game_status.previous_turn_index() as u64;
    let previous_player_total_bet_amount = game_table.game_status.player_infos().borrow(previous_player_seat_index).total_bet_amount();

    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    // player action 은 RAISE
    player_info.set_playing_action(player_info::CONST_RAISE());

    // FOLD를 제외한 현재 플레이어의 총 베팅 금액을 직전 플레이어의 총 베팅 금액과 동일하게 맞춘다.
    // 추가로 chip_count X bet_unit 만큼 추가 베팅을 한다.
    let call_bet_amount = previous_player_total_bet_amount - player_info.total_bet_amount();
    let raise_bet_amount = raise_chip_count * game_table.game_status.bet_unit();
    let bet_amount = call_bet_amount + raise_bet_amount;
    game_table.bet_money(player_seat_index, bet_amount, ctx);

    // 그리고 다음 턴
    game_table.next_turn(ctx);

  }

  fun fold(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    // player action 은 FOLD
    player_info.set_playing_action(player_info::CONST_FOLD());

    // fold 안 한 player가 2명 미만이면 진행 불가
    if (game_table.number_of_players_not_folding() < 2) {
      game_table.finish_game(ctx);
      return
    };

    // FOLD 후 게임 진행 가능 & PLAYING 중인 모든 player가 CHECK를 했고, round가 끝났나? -> 게임을 끝낸다.
    if (game_table.is_all_player_check() && game_table.is_round_over()) {
      game_table.finish_game(ctx);
      return
    };

    // FOLD 후 게임 진행 가능 & PLAYING 중인 모든 player가 CHECK를 했고, round가 남았나? -> 다음 라운드
    if (game_table.is_all_player_check() && !game_table.is_round_over()) {
      game_table.next_round(ctx);
      return
    };

    // FOLD를 후 게임 진행 가능 & 남은 PLAYING 중인 모든 플레이어의 베팅 총액이 동일해 졌고, round가 끝났나? -> 게임을 끝낸다.
    if (game_table.is_all_player_action_not_none() && game_table.is_all_player_bet_amount_same() && game_table.is_round_over()) {
      game_table.finish_game(ctx);
      return
    };

    // FOLD를 후 게임 진행 가능 & 남은 PLAYING 중인 모든 플레이어의 베팅 총액이 동일해 졌고, round가 남았나? -> 다음 라운드
    if (game_table.is_all_player_action_not_none() && game_table.is_all_player_bet_amount_same() && !game_table.is_round_over()) {
      game_table.next_round(ctx);
      return
    };

    // 모두 해당 안 된다면 그냥 다음 턴
    game_table.next_turn(ctx);
  }

  fun finish_game(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_info = game_table.game_status.player_infos().borrow(player_seat_index);

    // winner player 결정하기 -> 이후 돈 보내는 것은 settle up에서 합시다
    // 남은 플레이어가 exit player 포함 2명이라 게임이 불가하면 -> 남은 사람이 winner
    if (player_info.playing_action() == player_info::CONST_EXIT() && game_table.number_of_players() == 2) {
      let next_player_seat_index = game_table.find_next_player_seat_index(ctx);
      let next_player_seat = game_table.player_seats.borrow(next_player_seat_index);
      game_table.game_status.set_winner_player(next_player_seat.player_address());
    } 
    // fold를 제외한 남은 player가 1명인가? -> 남은 사람이 winner
    else if (game_table.number_of_players_not_folding() < 2) {
      let next_player_seat_index = game_table.find_next_player_seat_index(ctx);
      let next_player_seat = game_table.player_seats.borrow(next_player_seat_index);
      game_table.game_status.set_winner_player(next_player_seat.player_address());
    } 
    // 위 두 케이스가 아닌 경우에는 게임 로직에 winner 결정
    else {
      let winner_player_index = game_table.check_winner_index();
      let winner_player_info = game_table.game_status.player_infos().borrow(winner_player_index);
      game_table.game_status.set_winner_player(winner_player_info.player_address());
    }; 

    // 모든 플레이어 카드 오픈
    game_table.open_all_player_card();
    
    // GAME FINISHED
    game_table.set_all_player_playing_status(player_info::CONST_GAME_END());
    game_table.game_status.set_game_playing_status(game_status::CONST_GAME_FINISHED());
  }

  // Get Methods ===============================
  public fun id(game_table : &GameTable) : ID {object::id(game_table)}

  public fun lounge_id(game_table : &GameTable) : ID {game_table.lounge_id}

  fun used_card_decks(game_table : &GameTable) : vector<ID> {game_table.used_card_decks}

  public fun game_status(game_table : &GameTable) : &GameStatus {
    &game_table.game_status
  }

  fun number_of_players(game_table : &GameTable) : u64 {
    (game_table.game_status.game_seats() - game_table.game_status.avail_game_seats()) as u64
  }

  fun number_of_players_not_folding(game_table : &GameTable) : u64 {
    let mut i = 0;
    let mut number_of_not_fold_players = 0;
    while (i < game_table.game_status.player_infos().length()) {
      let player_info = game_table.game_status.player_infos().borrow(i);
      if (player_info.player_address() == option::none<address>()) {
        i = i + 1;
        continue
      };
      if (player_info.playing_action() != player_info::CONST_FOLD()) {
        number_of_not_fold_players = number_of_not_fold_players + 1;
      };
      i = i + 1;
    };
    number_of_not_fold_players
  }

  // Find Methods ===============================
  fun find_empty_seat_index(game_table : &GameTable) : u64 {
    let mut index = 0;
    while (index < game_table.game_status.game_seats() as u64) {
      let player_seat = game_table.player_seats.borrow(index);

      if (player_seat.player_address() == option::none<address>()) {
        break
      };
      index = index + 1;
    };

    if (index == game_table.game_status.game_seats() as u64) {
      index = GAME_TABLE_FULL;
    };

    index
  }

  fun find_player_seat_index(game_table : &GameTable, ctx : &mut TxContext) : u64 {
    let mut index = 0;
    while (index < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow(index);
      if (player_seat.player_address() == option::none<address>()) {
        index = index + 1;
        continue
      };

      if (game_table.player_seats.borrow(index).player_address() == option::some(tx_context::sender(ctx))) {
        return index
      };

      index = index + 1;
    };

    PLAYER_NOT_FOUND
  }

  fun find_next_player_seat_index(game_table : &GameTable, ctx : &mut TxContext) : u64 {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    assert!(player_seat_index != PLAYER_NOT_FOUND, 130);
    let mut next_player_seat_index = player_seat_index + 1;
    loop {
      if (next_player_seat_index == game_table.player_seats.length()) {
        next_player_seat_index = 0;
      };

      let player_info = game_table.game_status.player_infos().borrow(next_player_seat_index);
      if (player_info.player_address() == option::none<address>()) {
        next_player_seat_index = next_player_seat_index + 1;
        continue
      };
      if (player_info.playing_action() == player_info::CONST_FOLD()) {
        next_player_seat_index = next_player_seat_index + 1;
        continue
      };

      if (player_info.player_address() != option::none<address>()) {
        break
      };

      // 만약 아무도 없어서 다시 돌아오면 break 즉, next turn 못하고 다시 제자리로
      if (next_player_seat_index == player_seat_index) {
        return NEXT_PLAYER_NOT_FOUND
      };

      next_player_seat_index = next_player_seat_index + 1;
    };
    next_player_seat_index
  }

  // Check Methods ===============================
  fun is_all_player_ready(game_table : &GameTable) : bool {
    let mut i = 0;
    while (i < game_table.player_seats.length()) {
      let player_info = game_table.game_status.player_infos().borrow(i);
      if (player_info.player_address() == option::none<address>()) {
        i = i + 1;
        continue
      };
      if (player_info.playing_status() != player_info::CONST_READY()) {
        return false
      };
      i = i + 1;
    };
    return true
  }

  fun is_all_player_check(game_table : &GameTable) : bool {
    let mut i = 0;
    while(i < game_table.player_seats.length()){
      if (game_table.game_status.player_infos().borrow(i).player_address() == option::none()) {
        i = i + 1;
        continue
      };
      if (game_table.game_status.player_infos().borrow(i).playing_action() == player_info::CONST_FOLD()) {
        i = i + 1;
        continue
      };
      if (game_table.game_status.player_infos().borrow(i).playing_action() != player_info::CONST_CHECK()) {
        return false
      };

      i = i + 1;
    };

    return true
  }

  fun is_all_player_bet_amount_same(game_table : &GameTable) : bool {
    let mut i = 0;
    let mut first_total_bet_amount = 0;
    while(i < game_table.player_seats.length()){
      if (game_table.game_status.player_infos().borrow(i).player_address() == option::none()) {
        i = i + 1;
        continue
      };
      if (game_table.game_status.player_infos().borrow(i).playing_action() == player_info::CONST_FOLD()) {
        i = i + 1;
        continue
      };

      if (first_total_bet_amount == 0) {
        first_total_bet_amount = game_table.game_status.player_infos().borrow(i).total_bet_amount();
      };

      if (first_total_bet_amount > 0 && first_total_bet_amount != game_table.game_status.player_infos().borrow(i).total_bet_amount()) {
        return false
      };

      i = i + 1;
    };

    return true
  }

  fun is_all_player_action_not_none(game_table : &GameTable) : bool {
    let mut i = 0;
    while(i < game_table.player_seats.length()){
      if (game_table.game_status.player_infos().borrow(i).player_address() == option::none()) {
        i = i + 1;
        continue
      };
      if (game_table.game_status.player_infos().borrow(i).playing_action() == player_info::CONST_FOLD()) {
        i = i + 1;
        continue
      };
      if (game_table.game_status.player_infos().borrow(i).playing_action() == player_info::CONST_NONE()) {
        return false
      };

      i = i + 1;
    };

    return true
  }

  fun is_round_over(game_table : &GameTable) : bool {
    game_table.game_status.max_round() <= game_table.game_status.current_round()
  }

  // Utils Methods ===============================
  fun next_round(game_table : &mut GameTable, ctx : &mut TxContext) {
    game_table.draw_card_to_all_player(); // 남아있는 사람들은 카드를 더 받는다
    game_table.game_status.next_round(); // 그리고 다음 라운드, 다음 턴
    game_table.next_turn(ctx);
    game_table.set_all_player_playing_action(player_info::CONST_NONE()); // 모든 player의 playing action은 NONE으로 초기화
    let current_turn_index = game_table.game_status.current_turn_index();
    game_table.game_status.set_previous_turn(current_turn_index); // 그리고 previous turn은 current turn과 동일하게 초기화
  }
  
  public fun next_turn(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_playing_action = game_table.game_status.player_infos().borrow(player_seat_index).playing_action();
    let next_player_seat_index = game_table.find_next_player_seat_index(ctx);

    // (action이 Exit이고) current turn이 아니라면 안 넘겨줘도 됨
    if (player_playing_action == player_info::CONST_EXIT() && !game_table.game_status.is_current_turn(ctx)) {
      return
    };

    // 여기선 웬만하면 player index == current turn index (Exit을 제외한 모든 action은 current turn일 때만 실행 가능) 
    // 만약 fold 이고 첫 턴이다? -> current turn, previoust turn 둘 다 넘김
    if (player_playing_action == player_info::CONST_FOLD() 
    && game_table.game_status.current_turn_index() == game_table.game_status.previous_turn_index()) {
      game_table.game_status.set_previous_turn(next_player_seat_index as u8); 
      game_table.game_status.set_current_turn(next_player_seat_index as u8);
      return
    };

    // 만약 fold 이고 첫 턴이 아니다? -> current turn 만 넘김
    if (player_playing_action == player_info::CONST_FOLD() 
    && game_table.game_status.current_turn_index() != game_table.game_status.previous_turn_index()) {
      game_table.game_status.set_current_turn(next_player_seat_index as u8);
      return
    }; 

    // fold도 아니고 exit도 아니라면 현재 턴이 previous turn이 되어야 함
    if (player_playing_action != player_info::CONST_FOLD() && player_playing_action != player_info::CONST_EXIT()) {
      game_table.game_status.set_previous_turn(player_seat_index as u8); 
      game_table.game_status.set_current_turn(next_player_seat_index as u8);
      return
    };
  }

  fun bet_money(game_table : &mut GameTable, player_seat_index : u64, money_amont : u64, ctx : &mut TxContext) {
    {
      let player_seat = game_table.player_seats.borrow_mut(player_seat_index);
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

      // tx sender가 해당 player_seat 자리 주인이 아니면 assert!
      assert!(option::some(tx_context::sender(ctx)) == player_seat.player_address(), 102);

      //PlayerSeat의 deposit에서 money_amount 만큼 꺼내서 MoneyBox로 보내기
      let money_to_bet = player_seat.withdraw_money(player_info, money_amont, ctx);
      game_table.money_box.bet_money(player_info, money_to_bet);
    };
    game_table.game_status.add_bet_amount(money_amont);
  }

  fun draw_card(game_table : &mut GameTable, player_seat_index : u64) {
    {
      let player_seat = game_table.player_seats.borrow_mut(player_seat_index);
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);
      // 자리 없으면 건너 뜀
      if (player_seat.player_address() == option::none<address>() || player_info.player_address() == option::none<address>()){
        return
      };
      player_seat.receive_card(player_info, game_table.card_deck.borrow_mut().draw_card(game_table.casino_public_key));
    };
    game_table.game_status.draw_card();
  }

  fun draw_card_to_all_player(game_table : &mut GameTable) {
    let mut player_seat_index = 0;
    while (player_seat_index < game_table.player_seats.length()) {
      game_table.draw_card(player_seat_index);

      player_seat_index = player_seat_index + 1;
    };
  }

  fun open_all_player_card(game_table : &mut GameTable) {

  }

  fun set_all_player_playing_status(game_table : &mut GameTable, playing_status : u8) {
    assert!(playing_status >= player_info::CONST_EMPTY() && playing_status <= player_info::CONST_GAME_END(), 403);
    let mut i = 0;
    while (i < game_table.game_status.player_infos().length()) {
      if (game_table.game_status.player_infos_mut().borrow_mut(i).player_address() == option::none()) {
        i = i + 1;
        continue
      };

      game_table.game_status.player_infos_mut().borrow_mut(i).set_playing_status(playing_status);
      i = i + 1;
    };
  }

  fun set_all_player_playing_action(game_table : &mut GameTable, playing_action : u8) {
    assert!(playing_action >= player_info::CONST_NONE() && playing_action <= player_info::CONST_EXIT(), 403);
    let mut i = 0;
    while (i < game_table.game_status.player_infos().length()) {
      if (game_table.game_status.player_infos_mut().borrow_mut(i).player_address() == option::none()) {
        i = i + 1;
        continue
      };
      if (game_table.game_status.player_infos().borrow(i).playing_action() == player_info::CONST_FOLD()) {
        i = i + 1;
        continue
      };

      game_table.game_status.player_infos_mut().borrow_mut(i).set_playing_action(playing_action);
      i = i + 1;
    };
  }

  fun check_winner_index(game_table : &mut GameTable) : u64 {
    let mut i = 0;
    let mut player_score = vector<u64>[];
    while (i < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow_mut(i);
      if (player_seat.player_address() == option::none()) {
        player_score.push_back(0);
        i = i + 1;
        continue
      };

      let card1 = player_seat.cards().borrow(0);
      let card2 = player_seat.cards().borrow(1);

      let casino_n = encrypt::convert_vec_u8_to_u256(game_table.casino_public_key);
      let decrypted_card_number1 = encrypt::decrypt_256(casino_n, card1.card_number());
      let decrypted_card_number2 = encrypt::decrypt_256(casino_n, card2.card_number());

      player_score.push_back(mini_poker_logic::convert_card_combination_to_score(decrypted_card_number1, decrypted_card_number2));

      i = i + 1;
    };

    let mut highest_score = player_score[0];
    let mut highest_score_player_index = 0;
    let mut j = 0;
    while (j < player_score.length()) {
      if (highest_score < *player_score.borrow(j)) {
        highest_score = *player_score.borrow(j);
        highest_score_player_index = j;
      };
      j = j + 1;
    };

    return highest_score_player_index
  }




  // ============================================
  // ================ TEST ======================



  #[test]
  fun test_enter() {

  }

}