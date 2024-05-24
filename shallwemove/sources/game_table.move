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

  // 

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

  public fun is_player_entered(game_table : &GameTable, ctx : &mut TxContext) : bool {
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


  public fun enter_player(game_table : &mut GameTable, public_key : vector<u8>, deposit : Coin<SUI>, ctx : &mut TxContext) {
    assert!(!game_table.is_player_entered(ctx));

    let mut i = 0;
    let is_game_table_full = false;
    
    while (i < (game_table.game_status.game_seats() ) as u64) {
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(i);
      let player_seat = game_table.player_seats.borrow_mut(i);

      if (player_info.player_address() == option::none<address>() && player_seat.player_address() == option::none<address>()) {
        break
      };
      i = i + 1;
    };

    if (i == (game_table.game_status.avail_game_seats() ) as u64) {
      is_game_table_full == true;
    };

    if (is_game_table_full) {
      transfer::public_transfer(deposit, tx_context::sender(ctx));
    } else {
      
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(i);
      let player_seat = game_table.player_seats.borrow_mut(i);

      player_seat.set_player(ctx);
      player_seat.set_public_key(public_key);
      player_seat.add_money(deposit);

      player_info.set_player(ctx);
      player_info.set_public_key(public_key);
      player_info.set_playing_status(player_info::CONST_ENTER());

      game_table.game_status.enter_player(ctx);
    };
  }


  public fun exit_player(game_table : &mut GameTable, ctx : &mut TxContext) {
    let mut i = 0; // 여기는 I
    let mut is_player_found = false;
    let player_address = tx_context::sender(ctx);

    // player가 속한 player_seat index 찾아내기
    while (i < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow_mut(i);
      if (player_seat.player_address() == option::none<address>()) {
        i = i + 1;
        continue
      };

      let player_address_of_seat = game_table.player_seats[i].player_address().borrow();
      if (player_address == player_address_of_seat) {
        is_player_found = true;
        break
      };

      i = i + 1;
    };

    debug::print(&i);

    // 못 찾는다면 잘못된 game_table이라는 것. 
    assert!(is_player_found, 403);

    // 일단 game_table에 있는 player_seats 한 바퀴 돈 상황
      // player_seats에서 찾았음

    // 게임 중인가?? 그리고 지금 exit 하는 유저가 current turn인가?? -> next turn
    if (game_table.game_status().game_playing_status() == game_status::CONST_IN_GAME() 
    && game_table.game_status().is_current_turn(ctx)) {
      game_table.game_status_mut().next_turn();
    } else {

    };

    // player 정보 제거, PlayerSeat에서도 제거
    let player_seat = game_table.player_seats.borrow_mut(i);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(i);

    player_seat.remove_player(game_table.card_deck.borrow_mut(), ctx);
    player_info.remove_player(ctx);
    game_table.game_status.remove_player(ctx);

    // 만약 남은 플레이어가 1명 이하이다 -> Money box에 있는 거 남은 사람에게 주고 게임 강제 종료

    // player가 해당 게임의 manager_player이면 다음으로 넘겨주거나 마지막 유저면 null
    // 해당 유저가 manager player인가?? -> 남은 사람 중 다음 순서로 manager player 넘기기
      // 다음 순서 사람 찾기
      // 근데 플레이어 4명 중 3번째 유저가 manager player고 exit을 한대. 
      // 근데 4번째 순서는 없고 1,2번째에 유저가 있어. 그럼 1번째 유저한테 manager player를 줘야 해.
      // 단순 while문이면 안 되고 순환해야 해
      // 근데 혼자 들어갔다가 혼자 나가면 모든 플레이어가 none()이라 무한 루프
    let mut j = i + 1; // 여기는 J
    let mut is_nobody_here = false;
    loop {
      if (j == game_table.player_seats.length()) {
        j = 0;
      };

      if (j == i) {
        is_nobody_here = true;
        break
      };

      let player_seat = game_table.player_seats.borrow_mut(j);
      if (player_seat.player_address() == option::none<address>()) {
        j = j + 1;
        continue
      };

      if (player_seat.player_address() != option::none<address>()) {
        game_table.game_status.set_manager_player(player_seat.player_address());
        break
      };

      j = j + 1;
    };

    if (is_nobody_here) {
      game_table.game_status.set_manager_player(option::none());
    };
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
    // game_playing_status가 PRE_GAME 상태인가?
    assert!(game_table.game_status.game_playing_status() == game_status::CONST_PRE_GAME(), 403);

    // 모든 참여 플레이어가 READY 상태인가??
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

    debug::print(&player_playing_status_vector);

    let mut j = player_playing_status_vector.length();
    let mut is_all_player_ante = true;
    while (j > 0 ) {
      if (player_playing_status_vector.pop_back() != player_info::CONST_READY()) {
        is_all_player_ante = false;
        break
      };
      j = j - 1;
    };
    assert!(is_all_player_ante);

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