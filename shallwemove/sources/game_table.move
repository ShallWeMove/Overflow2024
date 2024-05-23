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

    let game_status = game_status::new(ante_amount, bet_unit, game_seats);
    let money_box = money_box::new(ctx);
    let card_deck = card_deck::new(public_key, ctx);

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

  public fun id(game_table : &GameTable) : ID {object::id(game_table)}

  public fun lounge_id(game_table : &GameTable) : ID {game_table.lounge_id}

  fun used_card_decks(game_table : &GameTable) : vector<ID> {game_table.used_card_decks}

  public fun game_status(game_table : &GameTable) : &GameStatus {
    &game_table.game_status
  }

  public fun game_status_mut(game_table : &mut GameTable) : &mut GameStatus {
    &mut game_table.game_status
  }

  fun add_player_seat(game_table : &mut GameTable, player_seat : PlayerSeat) {
    game_table.player_seats.push_back(player_seat);
  }

  fun create_player_seats(game_table : &mut GameTable, ctx: &mut TxContext) {
    let mut i = 0 as u8;
    while (i < game_table.game_status.avail_seats()) {

      let player_seat = player_seat::new(i, ctx);
      let player_info = player_info::new(i);

      game_table.add_player_seat(player_seat);
      game_table.game_status.add_player_info(player_info);
      i = i + 1;
    };
  }


  public fun enter_player(game_table : &mut GameTable, public_key : vector<u8>, deposit : Coin<SUI>, ctx : &mut TxContext) {
    assert!(!game_table.is_player_entered(ctx));

    let mut i = 0;
    let is_game_table_full = false;
    
    while (i < (game_table.game_status.game_seats() ) as u64) {
      let player_info = game_table.game_status.player_infos_mut().borrow_mut(i);
      let player_seat = game_table.player_seats.borrow_mut(i);

      if (player_info.player_address() == option::none<address>() && player_seat.player() == option::none<address>()) {
        break
      };
      i = i + 1;
    };

    if (i == (game_table.game_status.avail_seats() ) as u64) {
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
      player_info.set_playing_status(player_info::CONST_EMTER());

      game_table.game_status.enter_player(ctx);
    };
  }

  public fun is_player_entered(game_table : &GameTable, ctx : &mut TxContext) : bool {
    let mut i = 0;
    while (i < game_table.game_status.player_infos().length()) {
      let player_info = game_table.game_status.player_infos().borrow(i);
      if (option::is_some(&player_info.player_address()) 
      && option::extract(&mut player_info.player_address()) == tx_context::sender(ctx) ) {
        return true
      };
      i = i + 1;
    };

    return false
  }

  public fun exit_player(game_table : &mut GameTable, ctx : &mut TxContext) {
    let mut i = 0;
    let mut is_player_found = false;
    let player_address = tx_context::sender(ctx);

    // player가 속한 player_seat index 찾아내기
    while (i < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow_mut(i);
      if (player_seat.player() == option::none()) {
        i = i + 1;
        continue
      };

      let player_address_of_seat = option::extract(&mut game_table.player_seats[i].player());
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
    
    // 해당 유저가 manager player인가?? -> 남은 사람 중 다음 순서로 manager player 넘기기
      // 다음 순서 사람 찾기
      // 근데 플레이어 4명 중 3번째 유저가 manager player고 exit을 한대. 
      // 근데 4번째 순서는 없고 1,2번째에 유저가 있어. 그럼 1번째 유저한테 manager player를 줘야 해.
      // 단순 while문이면 안 되고 순환해야 해
    i = i + 1;
    loop {
      if (i == game_table.player_seats.length()) {
        i = 0;
      };

      let player_seat = game_table.player_seats.borrow_mut(i);
      if (player_seat.player() == option::none()) {
        i = i + 1;
        continue
      };

      if (player_seat.player() != option::none()) {
        game_table.game_status.set_manager_player(player_seat.player().extract());
        break
      };

      i = i + 1;
    };


    // 게임 중인가?? 그리고 지금 exit 하는 유저가 current turn인가?? -> next turn
    if (game_table.game_status().game_playing_status() == game_status::CONST_PRE_GAME() 
    && game_table.game_status().is_current_turn(ctx)) {
      game_table.game_status_mut().next_turn();
    } else {

    };


    // player 정보 제거, PlayerSeat에서도 제거
    let player_seat = game_table.player_seats.borrow_mut(i);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(i);

    player_seat.remove_player(ctx);
    player_info.remove_player(ctx);
    game_table.game_status.remove_player(ctx);

  }

  public fun ante(game_table : &mut GameTable, ctx : &mut TxContext) {
    assert!(game_table.is_player_entered(ctx));
    assert!(game_table.game_status.game_playing_status() == game_status::CONST_PRE_GAME());
    let mut i = 0;
    while (i < game_table.game_status.player_infos().length()) {
      let player_info = game_table.game_status.player_infos().borrow(i);
      if (player_info.player_address() == option::some(tx_context::sender(ctx))){
        assert!(player_info.playing_status() == player_info::CONST_EMTER());
        break
      };

      i = i + 1;
    };

    // 이제 진짜 로직
    //각 PlayerSeat의 deposit에서 ante 만큼 꺼내기
    let player_seat = vector::borrow_mut(&mut game_table.player_seats, i);
    let money_to_send = player_seat.split_money(game_table.game_status.ante_amount(), ctx);
    //MoneyBox total 금액 업데이트 및 MoneyBox로 전송
    game_table.game_status.add_money(&money_to_send);
    game_table.money_box.add_money(money_to_send);

  }

  public fun start(game_table : &mut GameTable) {
    
  }

  // ============================================
  // ================ TEST ======================



  #[test]
  fun test_enter() {

  }

}