module shallwemove::game_table {

  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::game_status::{Self, GameStatus, GameInfo, MoneyBoxInfo, CardInfo};
  use shallwemove::player_info::{Self, PlayerInfo};
  use shallwemove::player_seat::{Self, PlayerSeat};
  use shallwemove::money_box::{Self, MoneyBox};
  use shallwemove::card_deck::{Self, CardDeck, Card};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use std::string::{Self, String};
  use std::debug;
  use std::vector::{Self};
  use sui::dynamic_object_field;


  // ============================================
  // ============== CONSTANTS ===================
  
  const GAME_TABLE_FULL : u64 = 100;
  const PLAYER_NOT_FOUND : u64 = 100;

  // ============================================
  // ============== STRUCTS =====================

  public struct GameTable has key, store {
    id : UID,
    lounge_id : ID,
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
    public_key : vector<u8>,
    ante_amount : u64, 
    bet_unit : u64, 
    game_seats : u8, 
    ctx : &mut TxContext) : GameTable {

    let mut game_status = game_status::new(ante_amount, bet_unit, game_seats);
    let money_box = money_box::new(ctx);
    let mut card_deck = card_deck::new(public_key, ctx);

    card_deck.fill_cards(&mut game_status, public_key, ctx);

    let mut game_table = GameTable {
      id : object::new(ctx),
      lounge_id : lounge_id,
      game_status : game_status,
      money_box : money_box,
      card_deck : option::some(card_deck),
      used_card_decks : vector[],
      player_seats : vector[]
    };

    game_table.create_player_seats(ctx);

    game_table
  }


  // ===================== Methods ===============================

  // get methods
  public fun id(game_table : &GameTable) : ID {object::id(game_table)}

  public fun lounge_id(game_table : &GameTable) : ID {game_table.lounge_id}

  fun used_card_decks(game_table : &GameTable) : vector<ID> {game_table.used_card_decks}


  public fun game_status(game_table : &GameTable) : &GameStatus {
    &game_table.game_status
  }

  public fun game_status_mut(game_table : &mut GameTable) : &mut GameStatus {
    &mut game_table.game_status
  }

  fun set_player_address(game_table : &mut GameTable, index : u64, ctx : &mut TxContext) {
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(index);
      let player_seat = game_table.player_seats.borrow_mut(index);
      player_seat.set_player_address(ctx);
      player_info.set_player_address(ctx);
  }

  fun set_player_public_key(game_table : &mut GameTable, index : u64, public_key : vector<u8>) {
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(index);
      let player_seat = game_table.player_seats.borrow_mut(index);
      player_seat.set_public_key(public_key);
      player_info.set_public_key(public_key);
  }

  fun set_player_deposit(game_table : &mut GameTable, index : u64, deposit : Coin<SUI>) {
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(index);
      let player_seat = game_table.player_seats.borrow_mut(index);
      player_info.add_money(deposit.value());
      player_seat.add_money(deposit);
      player_info.set_playing_status(player_info::CONST_ENTER());
  }


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

  fun is_player_entered(game_table : &GameTable, ctx : &mut TxContext) : bool {
    let mut i = 0;
    while (i < game_table.game_status.player_infos().length()) {
      let player_info = game_table.game_status.player_infos().borrow(i);
      if (player_info.player_address().is_some() 
      && player_info.player_address().borrow() == tx_context::sender(ctx) ) {
        return true
      };
      i = i + 1;
    };

    return false
  }

  fun find_empty_seat_index(game_table : &GameTable) : u64 {
    let is_game_table_full = false;
    let mut index = 0;
    while (index < game_table.game_status.game_seats() as u64) {
      let player_info = game_table.game_status.player_infos().borrow(index);
      let player_seat = game_table.player_seats.borrow(index);

      if (player_info.player_address() == option::none<address>() && player_seat.player_address() == option::none<address>()) {
        break
      };
      index = index + 1;
    };

    if (index == game_table.game_status.avail_game_seats() as u64) {
      is_game_table_full == true;
      index = GAME_TABLE_FULL; // 완전 PlayerSeat index 범위를 벗어나는 숫자
    };

    index
  }

  fun find_player_seat_index(game_table : &mut GameTable, ctx : &mut TxContext) : u64 {
    let mut index = 0; // 여기는 I
    let player_address = tx_context::sender(ctx);

    // player가 속한 player_seat index 찾아내기
    while (index < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow_mut(index);
      if (player_seat.player_address() == option::none<address>()) {
        index = index + 1;
        continue
      };

      let player_address_of_seat = game_table.player_seats.borrow(index).player_address().borrow();
      if (player_address == player_address_of_seat) {
        return index
      };

      index = index + 1;
    };

    PLAYER_NOT_FOUND
  }


  fun set_player(game_table : &mut GameTable, empty_seat_index : u64, public_key : vector<u8>, deposit : Coin<SUI>, ctx : &mut TxContext) {
      game_table.set_player_address(empty_seat_index, ctx);
      game_table.set_player_public_key(empty_seat_index, public_key);
      game_table.set_player_deposit(empty_seat_index, deposit);

      game_table.game_status.enter_player(ctx);
  }

  fun remove_player(game_table : &mut GameTable, player_seat_index : u64, ctx : &mut TxContext) {
    let player_seat = game_table.player_seats.borrow_mut(player_seat_index);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    player_seat.remove_player(game_table.card_deck.borrow_mut(), ctx);
    player_info.remove_player(ctx);

    game_table.game_status_mut().increment_avail_seat();
  }

  fun update_manager_player(game_table : &mut GameTable, player_seat_index : u64) {
    let mut i = player_seat_index + 1;
    let mut is_nobody_here = false;
    loop {
      if (i == game_table.player_seats.length()) {
        i = 0;
      };

      if (i == player_seat_index) {
        is_nobody_here = true;
        break
      };

      if (game_table.player_seats.borrow_mut(i).player_address() == option::none<address>()) {
        i = i + 1;
        continue
      };

      if (game_table.player_seats.borrow_mut(i).player_address() != option::none<address>()) {
        game_table.game_status.set_manager_player(game_table.player_seats.borrow_mut(i).player_address());
        break
      };

      i = i + 1;
    };

    if (is_nobody_here) {
      game_table.game_status.set_manager_player(option::none());
    };
  }

  fun get_number_of_players(game_table : &GameTable) : u64 {
    let mut i = 0;
    let mut number_of_players = 0;
    while (i < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow(i);
      if (player_seat.player_address() != option::none()) {
        number_of_players = number_of_players + 1;
      };
      i = i + 1;
    };
    return number_of_players
  }

  fun exit_player(game_table : &mut GameTable, player_seat_index : u64, ctx : &mut TxContext) {
    // player 정보 초기화
    game_table.remove_player(player_seat_index, ctx);

    // 게임 중인가?? 그리고 지금 exit 하는 유저가 current turn인가?? -> next turn
    if (game_table.game_status().game_playing_status() == game_status::CONST_IN_GAME() && game_table.game_status().is_current_turn(ctx)) {
      game_table.game_status_mut().next_turn();
    };

    // player가 해당 게임의 manager_player이면 다음으로 넘겨주거나 마지막 유저면 option::none()
    game_table.update_manager_player(player_seat_index);

    // 만약 남은 플레이어가 1명이다
    if (game_table.get_number_of_players() == 1) {
      // Money box에 있는 거 남은 player의 PlayerSeat에게 주고
      let mut i = 0;
      while (i < game_table.player_seats.length()) {
        if (game_table.player_seats.borrow(i).player_address() != option::none()) {
          break
        };
        i = i + 1;
      };
      let player_seat = game_table.player_seats.borrow_mut(i);
      game_table.money_box.send_all_money(player_seat);

      // 게임 종료 (추후 개발)
      // game_table.finish_game();
    };
    
  }

  public fun enter(game_table : &mut GameTable, public_key : vector<u8>, deposit : Coin<SUI>, ctx : &mut TxContext) {
    // player 가 이미 enter 했는데 또 하는 건 아닌지 체크한다.
    assert!(!game_table.is_player_entered(ctx));

    // game_table이 다 차서 enter를 못 하는 상황인지 체크한다.
    let empty_seat_index = game_table.find_empty_seat_index();

    // game table이 꽉 찼으면 deposit은 다시 user address로 되돌려보낸다.
    if (empty_seat_index == GAME_TABLE_FULL) {
      transfer::public_transfer(deposit, tx_context::sender(ctx));
    } else {
      // game table에 참여할 수 있으면 참여 시킨다.
      game_table.set_player(empty_seat_index, public_key, deposit, ctx);
    };
  }


  public fun exit(game_table : &mut GameTable, ctx : &mut TxContext) {
    // // player가 속한 player_seat index 찾아내기
    let player_seat_index = game_table.find_player_seat_index(ctx);

    // 못 찾는다면 잘못된 game_table이라는 것. 
    assert!(player_seat_index != PLAYER_NOT_FOUND, 403);

    game_table.exit_player(player_seat_index, ctx);
  }

  public fun ante(game_table : &mut GameTable, ctx : &mut TxContext) {
    assert!(game_table.is_player_entered(ctx));
    assert!(game_table.game_status.game_playing_status() == game_status::CONST_PRE_GAME());
    let mut i = 0;
    while (i < game_table.game_status.player_infos().length()) {
      let player_info = game_table.game_status.player_infos().borrow(i);
      if (player_info.player_address() == option::some(tx_context::sender(ctx))){
        assert!(player_info.playing_status() == player_info::CONST_ENTER());
        break
      };

      i = i + 1;
    };

    // 이제 진짜 로직
    //각 PlayerSeat의 deposit에서 ante 만큼 꺼내기
    let player_seat = vector::borrow_mut(&mut game_table.player_seats, i);
    let money_to_send = player_seat.split_money(game_table.game_status.ante_amount(), ctx);
    // PlayerInfo bet amount 업데이트 & READY 상태
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(i);
    player_info.add_bet_amount(money_to_send.value());
    player_info.set_playing_status(player_info::CONST_READY());
    //MoneyBox total 금액 업데이트 및 MoneyBox로 전송
    game_table.game_status.add_money(&money_to_send);
    game_table.money_box.add_money(money_to_send);

  }

  public fun start(game_table : &mut GameTable) {
    // 이제 여기를 채워야 할 시간!!!!

    // 플레이어 수가 2명 이상이고 모든 참여 플레이어가 READY 상태인가??
    let mut i = 0;
    let mut player_playing_status_vector = vector<u8>[];
    while (i < game_table.game_status.player_infos().length()) {
      let player_info = game_table.game_status.player_infos().borrow(i);
      if (player_info.player_address() == option::none<address>()) {
        i = i + 1;
        continue
      };
      player_playing_status_vector.push_back(player_info.playing_status());
      i = i + 1;
    };

    assert!(player_playing_status_vector.length() >= 2, 403);

    let mut j = player_playing_status_vector.length();
    let mut is_all_player_ready = true;
    while (j > 0 ) {
      if (player_playing_status_vector.pop_back() != player_info::CONST_READY()) {
        is_all_player_ready = false;
        break
      };
      j = j - 1;
    };

    assert!(is_all_player_ready);

    // 모든 참여 PlayerSeat에 카드 2장씩 분배하기
    let mut k = 0;
    while (k < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow_mut(k);
      // let player_info = game_table.game_status.player_infos_mut().borrow_mut(k);
      if (player_seat.player_address() == option::none<address>()){
        k = k + 1;
        continue
      };

      // player 2장 주고 -> 다음 player 2장 주는 방식인데
      // 1장 -> 1장 -> 1장 -> 1장 ..해서 한 바퀴씩 도는 방식으로 변경하자 나중에
      player_seat.receive_card(game_table.card_deck.borrow_mut().draw_card());
      game_table.game_status.player_receive_card(k); // GameStatus 업데이트 -> PlayerInfo CardInfo

      player_seat.receive_card(game_table.card_deck.borrow_mut().draw_card());
      game_table.game_status.player_receive_card(k);

      k = k + 1;
    };

    // GameStatus 업데이트 -> GameInfo
    game_table.game_status.set_game_playing_status(game_status::CONST_IN_GAME());
  }

  public fun action(game_table : &mut GameTable, action_type : u8, chip_count : u64, ctx : &mut TxContext) {
    // 한 라운드의 최초의 턴일 경우 CHECK or BET or FOLD 할 수 있음

    // CHECK 다음에는 CHECK or FOLD(이건 action에서 커버 치는게 아님) 할 수 있음

    // BET 다음 부터는 CALL or RAISE or FOLD 할 수 있음
      // RAISE는 CALL 만큼 베팅 금액에 추가 베팅을 하는 거임

    // 모든 플레이어의 총 베팅 금액이 동일해진다면 다음 라운드로 돌아감
    // 매 action 마다 체크해주면 좋을 것 같다.

  }

  // ============================================
  // ================ TEST ======================



  #[test]
  fun test_enter() {

  }

}