module shallwemove::cardgame {
  // ------ Contents ----------
  // IMPORTS
  // CONSTANTS
    // GAME STATUSES
    // ERRORS
  // EVENTS
  // STRUCTS
  // FUNCTIONS
    // Entry Functions
    // None Entry Functions
    // Methods
  // TEST
  // --------------------------

  // ============================================
  // ============= IMPORTS ======================
  // ============================================

  use sui::object::{Self, ID, UID};
  use std::string::{Self, String};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;
  use std::option::{Self, Option};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use sui::dynamic_object_field;
  use std::debug;

  // ============================================
  // ============== CONSTANTS ===================
  // ============================================

  // ==================== Game Statuses ==========================
  // =============================================================

  const PRE_GAME : u8 = 0;
  const IN_GAME : u8 = 1;
  const GAME_FINISHED : u8 = 2;

  // ==================== Playing Statuses ==========================
  // =============================================================

  const EMPTY : u8 = 10;
  const ENTER : u8 = 11;
  const READY : u8 = 12;
  const PLAYING : u8 = 13;
  const GAME_END : u8 = 14;

  // ==================== Playing Actions ==========================
  // =============================================================

  const ANTE : u8 = 20;
  const CHECK : u8 = 21;
  const BET : u8 = 22;
  const CALL : u8 = 23;
  const RAISE : u8 = 24;
  const FOLD : u8 = 25;

  // ======================= Errors ==============================
  // =============================================================

  const ERROR1 : u8 = 100; // example of error code

  // ============================================
  // ============== EVENTS ======================
  // ============================================

  // ============================================
  // ============== STRUCTS =====================
  // ============================================

  // game object which can create game table
  public struct Casino has key {
    id: UID,
    admin: address,
    public_key: vector<u8>
  }

  // public struct Lounge has key {
  public struct Lounge has key, store { //for test
    id: UID,
    casino_id : ID,
    game_tables : vector<ID>
  }

  public struct GameTable has key, store {
    id : UID,
    lounge_id : ID,
    game_status : GameStatus,
    money_box : MoneyBox,
    card_deck : Option<CardDeck>,
    used_card_decks : vector<ID>,
    player_seats : vector<PlayerSeat>
  }

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

  public struct PlayerInfo has store {
    index : u8,
    player_address : Option<address>,
    public_key : vector<u8>,
    playing_status : u8,
    number_of_holding_cards : u8,
    previous_bet_amount : u64,
    total_bet_amount : u64
  }

  public struct MoneyBox has key, store {
    id : UID,
    money : vector<Coin<SUI>>
  }

  public struct CardDeck has key, store {
    id : UID,
    avail_cards : vector<Card>,
    used_cards : vector<Card>
  }

  public struct Card has key, store {
    id : UID,
    index : u8,
    card_number : u8
  }

  public struct PlayerSeat has key, store {
    // casino_id : ID,
    id : UID,
    index : u8,
    player : Option<address>,
    public_key : vector<u8>,
    cards : vector<Card>,
    // money : vector<Coin<SUI>>
    money : vector<ID>
  }

  // ============================================
  // ============== FUNCTIONS ===================
  // ============================================

  fun init(ctx: &mut TxContext) {
  }

  // ====================== Entry Functions ======================
  // =============================================================

  // --------- For Game Owner ---------

  // This function will be executed in the Backend
  // game owner or anyone who wanna be a game owner can create new game
  // Casino object is essential to play game
  entry fun create_casino(public_key : vector<u8>, ctx: &mut TxContext) {
    transfer::freeze_object(
      Casino {
      id : object::new(ctx),
      admin: tx_context::sender(ctx),
      public_key : public_key
      });
  }

  entry fun create_lounge(casino : &Casino, ctx: &mut TxContext) {
    assert!(casino.admin == tx_context::sender(ctx), 403);

    transfer::share_object(Lounge{
      id : object::new(ctx),
      casino_id : object::id(casino),
      game_tables : vector[]
    });
  }

  entry fun create_and_add_game_table(
    casino : &Casino, 
    lounge : &mut Lounge, 
    ante_amount : u64, 
    bet_unit : u64, 
    game_seats : u8, 
    ctx : &mut TxContext) {
    assert!(casino.admin == tx_context::sender(ctx), 403);

    let game_status = new_game_status(ante_amount, bet_unit, game_seats);
    let money_box = new_money_box(ctx);
    let card_deck = new_card_deck(casino, ctx);

    
    let mut game_table = GameTable {
      id : object::new(ctx),
      lounge_id : lounge.id(),
      game_status : game_status,
      money_box : money_box,
      card_deck : option::some(card_deck),
      used_card_decks : vector[],
      player_seats : vector[]
    };

    game_table.create_player_seats(ctx);

    lounge.add_game_table(game_table);
  }

  // --------- For Player ---------

  // 1. player가 가지고 있는 hand 중에서 빈 핸드 하나 보내는 거가 가능? 가능하면 player_hand parameter 필요 없음.
  // 2. 굳이 player_hand를 보내야 하나? game_table에 이미 player_hand가 있어서 정보만 보내는 거지. 그래도 player가 차있다 이걸 표현 할 수 있음.
  entry fun enter(
    casino : &Casino, 
    lounge : &mut Lounge, 
    public_key : vector<u8>,
    money : Coin<SUI>,
    ctx : &mut TxContext) : ID {
    assert!(casino.id() == lounge.casino_id(), 403);

    let mut avail_game_table_id = lounge.avail_game_table_id();
    let avail_game_table = dynamic_object_field::borrow_mut<ID, GameTable> (&mut lounge.id, option::extract(&mut avail_game_table_id));

    avail_game_table.enter_player(public_key, money, ctx);

    return avail_game_table.id()
  }

  

  fun get_available_player_seat() {

  }


  //   // 게임 입장
  // entry fun enter(
  //   casino: &Casino, 
  //   lounge: &mut Lounge,  
  //   ctx: &mut TxContext,
  // ) : ID {

  // }

  // 게임 퇴장
  entry fun exit(
    casino: &Casino, 
    lounge: &mut Lounge, // 필요 없을 수도
    game_table: &mut GameTable, 
    ctx: &mut TxContext
  ) {

  }

  // 게임 시작
  entry fun start(
    casino: &Casino, 
    lounge: &mut Lounge, // 필요 없을 수도
    game_table: &mut GameTable, 
    ctx: &mut TxContext,
  ) : ID {
    return game_table.id()
  }

  // 플레이어 콜 => 마지막 턴의 액션이면 Move에서 알아서 게임 종료해줌
  entry fun action(
    casino: &Casino, 
    game_table: &mut GameTable,
    // action_type: ActionType, // ante, check, bet, call, raise
    action_type: u8, // ante, check, bet, call, raise
    with_new_card: bool, // 새 카드를 받을지 
    chip_count: u64, // 몇 개의 칩을 베팅할지 (칩 하나가 ? SUI일지는 GameTable마다 다르다)
    ctx: &mut TxContext,
  ) : ID {
    return game_table.id()
  }

  // 중도 포기(기권)
  entry fun fold(
    casino: &Casino, 
    game_table: &mut GameTable,
    ctx: &mut TxContext,
  ) : ID {
    return game_table.id()
  }

  // 정산 받기 (승자가 트랜잭션 콜 해야 함)
  entry fun settle_up(
    casino: &Casino, 
    game_table: &mut GameTable,
    ctx: &mut TxContext,
  ) : ID {
    return game_table.id()
  }

  // =================== None Entry Functions ====================
  // =============================================================

  // --------- Create Functions ---------

  fun new_game_status(ante_amount : u64, bet_unit : u64, game_seats : u8) : GameStatus {
    assert!(game_seats >= 3 && game_seats <= 6, 403);

    let game_info = GameInfo {
      manager_player : option::none(),
      game_playing_status : 0,
      current_turn_player : option::none(),
      winner_player : option::none(),
      ante_amount : ante_amount,
      bet_unit : bet_unit,
      game_seats : game_seats,
      avail_seats : game_seats
    };

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

  fun new_money_box(ctx : &mut TxContext) : MoneyBox {
    MoneyBox {
      id : object::new(ctx),
      money : vector[]
    }
  }

  fun new_card_deck(casino : &Casino, ctx : &mut TxContext) : CardDeck {
    let mut card_deck = CardDeck {
      id : object::new(ctx),
      avail_cards : vector[],
      used_cards : vector[],
    };

    card_deck.fill_card(casino.public_key(), ctx);

    card_deck
  }

  // --------- Utility Functions ---------

  fun get_fifty_two_numbers_array() : vector<u8> {
    let mut fifty_two_numbers_array = vector<u8>[];
    let mut i = 52;
    while (i > 0) {
      fifty_two_numbers_array.push_back(i);
      i = i - 1;
    };
    fifty_two_numbers_array
  }

  fun shuffle(number_array : vector<u8>) : vector<u8> {
    // 임시 하드코딩
    vector<u8>[34, 9, 15, 3, 43, 10, 19, 36, 20, 22, 40, 28, 50, 26, 47, 42, 17, 48, 37, 33, 51, 24, 8, 23, 21, 5, 4, 1, 12, 6, 31, 14, 35, 41, 11, 32, 7, 29, 46, 30, 13, 16, 18, 27, 49, 39, 44, 38, 2, 25, 45, 52]
  }

  fun encrypt(number_array : vector<u8>, public_key : vector<u8>) : vector<u8> {
    // 임시 하드코딩
    vector<u8>[34, 9, 15, 3, 43, 10, 19, 36, 20, 22, 40, 28, 50, 26, 47, 42, 17, 48, 37, 33, 51, 24, 8, 23, 21, 5, 4, 1, 12, 6, 31, 14, 35, 41, 11, 32, 7, 29, 46, 30, 13, 16, 18, 27, 49, 39, 44, 38, 2, 25, 45, 52]
  }



  // ===================== Methods ===============================
  // =============================================================

  // --------- Casino ---------

  use fun casino_id as Casino.id;
  fun casino_id(casino : &Casino) : ID {object::id(casino)}

  use fun casino_admin as Casino.admin;
  fun casino_admin(casino : &Casino) : address {casino.admin}

  use fun casino_public_key as Casino.public_key;
  fun casino_public_key(casino : &Casino) : vector<u8> {casino.public_key}

  // --------- Lounge ---------

  use fun lounge_id as Lounge.id;
  fun lounge_id(lounge : &Lounge) : ID {object::id(lounge)}

  use fun lounge_casino_id as Lounge.casino_id;
  fun lounge_casino_id(lounge : &Lounge) : ID {lounge.casino_id}

  use fun lounge_game_tables as Lounge.game_tables;
  fun lounge_game_tables(lounge : &Lounge) : vector<ID> {lounge.game_tables}

  use fun lounge_add_game_table as Lounge.add_game_table;
  fun lounge_add_game_table(lounge : &mut Lounge, game_table : GameTable) {
    lounge.game_tables.push_back(game_table.id());
    dynamic_object_field::add<ID, GameTable>(&mut lounge.id, game_table.id(), game_table);

  }

  use fun get_available_game_table_id as Lounge.avail_game_table_id;
  fun get_available_game_table_id(lounge : &Lounge) : Option<ID> {
  // fun get_available_game_table_id(lounge : &mut Lounge) : &mut Option<GameTable> {
    let mut game_tables = lounge.game_tables();
    // debug::print(&string::utf8(b"game tables : "));
    // debug::print(&game_tables);

    while (!game_tables.is_empty()) {
      let game_table_id = game_tables.pop_back();
      let game_table = dynamic_object_field::borrow<ID, GameTable> (&lounge.id, game_table_id);
      // let game_table = dynamic_object_field::borrow<ID, GameTable> (&mut lounge.id, game_table_id);
      if (game_table.game_status.avail_seats() > 0) {
        debug::print(&string::utf8(b"게임을 찾았다!"));
        return option::some(game_table_id)
        // return &mut option::some(game_table)
      };
    };

    return option::none()
  }

  // --------- GameTable ---------

  use fun game_table_id as GameTable.id;
  fun game_table_id(game_table : &GameTable) : ID {object::id(game_table)}

  use fun game_table_lounge_id as GameTable.lounge_id;
  fun game_table_lounge_id(game_table : &GameTable) : ID {game_table.lounge_id}

  use fun game_table_used_card_decks as GameTable.used_card_decks;
  fun game_table_used_card_decks(game_table : &GameTable) : vector<ID> {game_table.used_card_decks}

  use fun game_table_add_player_seat as GameTable.add_player_seat;
  fun game_table_add_player_seat(game_table : &mut GameTable, player_seat : PlayerSeat) {
    game_table.player_seats.push_back(player_seat);
  }

  use fun game_table_create_player_seats as GameTable.create_player_seats;
  fun game_table_create_player_seats(game_table : &mut GameTable, ctx: &mut TxContext) {
    let mut i = 1 as u8;
    while (i < game_table.game_status.game_info.avail_seats + 1) {
      let player_seat = PlayerSeat {
        id : object::new(ctx),
        index : i,
        player : option::none(),
        public_key : vector<u8>[],
        cards : vector<Card>[],
        // money : vector<Coin<SUI>>[]
        money : vector<ID>[]
      };
      let player_info = PlayerInfo {
        index : i,
        player_address : option::none(),
        public_key : vector<u8>[],
        playing_status : EMPTY,
        number_of_holding_cards : 0,
        previous_bet_amount : 0,
        total_bet_amount : 0
      };
      game_table.add_player_seat(player_seat);
      game_table.game_status.add_player_info(player_info);
      i = i + 1;
    };
  }

  use fun game_table_enter_player as GameTable.enter_player;
  fun game_table_enter_player(game_table : &mut GameTable, public_key : vector<u8>, money : Coin<SUI>, ctx : &mut TxContext) {
    // check if player already enter into same game table
    let mut i = 0;
    let is_full = false;
    
    while (i < (game_table.game_status.game_info.game_seats ) as u64) {
      let player_info = game_table.game_status.player_infos.borrow_mut(i);
      let player_seat = game_table.player_seats.borrow_mut(i);

      assert!(!player_info.is_participated(ctx) , 403);

      if (player_info.player_address() == option::none() && player_seat.player() == option::none()) {
        break
      };

      i = i + 1;
    };

    if (i == (game_table.game_status.game_info.avail_seats ) as u64) {
      is_full == true;
    };

    if (is_full) {
      transfer::public_transfer(money, tx_context::sender(ctx));
    } else {
      let player_info = game_table.game_status.player_infos.borrow_mut(i);
      let player_seat = game_table.player_seats.borrow_mut(i);

      player_seat.set_player(ctx);
      player_seat.set_public_key(public_key);
      player_seat.add_money(money);

      player_info.set_player(ctx);
      player_info.set_public_key(public_key);
      player_info.set_playing_status(ENTER);
    }
  }

  // --------- GameStatus ---------

  use fun game_status_manager_player as GameStatus.manager_player;
  fun game_status_manager_player(game_status : &GameStatus) : Option<address>{game_status.game_info.manager_player}

  use fun game_status_game_playing_status as GameStatus.game_playing_status;
  fun game_status_game_playing_status(game_status : &GameStatus) : u8 {game_status.game_info.game_playing_status}

  use fun game_status_current_turn_player as GameStatus.current_turn_player;
  fun game_status_current_turn_player(game_status : &GameStatus) : Option<address> {game_status.game_info.current_turn_player}

  use fun game_status_winner_player as GameStatus.winner_player;
  fun game_status_winner_player(game_status : &GameStatus) : Option<address> {game_status.game_info.winner_player}

  use fun game_status_ante_amount as GameStatus.ante_amount;
  fun game_status_ante_amount(game_status : &GameStatus) : u64 {game_status.game_info.ante_amount}

  use fun game_status_bet_unit as GameStatus.bet_unit;
  fun game_status_bet_unit(game_status : &GameStatus) : u64 {game_status.game_info.bet_unit}

  use fun game_status_game_seats as GameStatus.game_seats;
  fun game_status_game_seats(game_status : &GameStatus) : u8 {game_status.game_info.game_seats}

  use fun game_status_avail_seats as GameStatus.avail_seats;
  fun game_status_avail_seats(game_status : &GameStatus) : u8 {game_status.game_info.avail_seats}

  use fun game_status_total_bet_amount as GameStatus.total_bet_amount;
  fun game_status_total_bet_amount(game_status : &GameStatus) : u64 {game_status.money_box_info.total_bet_amount}

  use fun game_status_number_of_avail_cards as GameStatus.number_of_avail_cards;
  fun game_status_number_of_avail_cards(game_status : &GameStatus) : u8 {game_status.card_info.number_of_avail_cards}

  use fun game_status_number_of_used_cards as GameStatus.number_of_used_cards;
  fun game_status_number_of_used_cards(game_status : &GameStatus) : u8 {game_status.card_info.number_of_used_cards}

  use fun game_status_add_player_info as GameStatus.add_player_info;
  fun game_status_add_player_info(game_status : &mut GameStatus, player_info : PlayerInfo) {game_status.player_infos.push_back(player_info);}

  // --------- PlayerInfo ---------

  use fun player_info_player_address as PlayerInfo.player_address;
  fun player_info_player_address(player_info : &PlayerInfo) : Option<address> {player_info.player_address}

  use fun player_info_public_key as PlayerInfo.public_key;
  fun player_info_public_key(player_info : &PlayerInfo) : vector<u8> {player_info.public_key}

  use fun player_info_playing_status as PlayerInfo.playing_status;
  fun player_info_playing_status(player_info : &PlayerInfo) : u8 {player_info.playing_status}

  use fun player_info_number_of_holding_cards as PlayerInfo.number_of_holding_cards;
  fun player_info_number_of_holding_cards(player_info : &PlayerInfo) : u8 {player_info.number_of_holding_cards}

  use fun player_info_previous_bet_amount as PlayerInfo.previous_bet_amount;
  fun player_info_previous_bet_amount(player_info : &PlayerInfo) : u64 {player_info.previous_bet_amount}

  use fun player_info_total_bet_amount as PlayerInfo.total_bet_amount;
  fun player_info_total_bet_amount(player_info : &PlayerInfo) : u64 {player_info.total_bet_amount}

  use fun player_info_set_player as PlayerInfo.set_player;
  fun player_info_set_player(player_info : &mut PlayerInfo, ctx : &mut TxContext) {
    player_info.player_address = option::some(tx_context::sender(ctx));
  }

  use fun player_info_set_public_key as PlayerInfo.set_public_key;
  fun player_info_set_public_key(player_info : &mut PlayerInfo, public_key : vector<u8>) {
    player_info.public_key = public_key;
  }

  use fun player_info_set_playing_status as PlayerInfo.set_playing_status;
  fun player_info_set_playing_status(player_info : &mut PlayerInfo, playing_status : u8) {
    player_info.playing_status = playing_status;
  }

  use fun player_info_is_participated as PlayerInfo.is_participated;
  fun player_info_is_participated(player_info : &mut PlayerInfo, ctx : &mut TxContext) : bool {
    if (player_info.player_address() == option::none()) {
      false
    } else {
      option::extract(&mut player_info.player_address()) == tx_context::sender(ctx)
    }
  }


  // --------- MoneyBox ---------

  use fun money_box_id as MoneyBox.id;
  fun money_box_id(money_box : &MoneyBox) : ID {object::id(money_box)}

  // --------- CardDeck ---------
  use fun card_deck_id as CardDeck.id;
  fun card_deck_id(card_deck : &CardDeck) : ID {object::id(card_deck)}

  use fun fill_card_deck as CardDeck.fill_card;
  fun fill_card_deck(card_deck : &mut CardDeck, public_key : vector<u8>, ctx : &mut TxContext) {
    let fifty_two_numbers_array = get_fifty_two_numbers_array();
    let shuffled_fifty_two_numbers_array = shuffle(fifty_two_numbers_array);
    let mut encrypted_fifty_two_numbers_array = encrypt(shuffled_fifty_two_numbers_array, public_key);

    let mut i = encrypted_fifty_two_numbers_array.length();
    while (i > 0) {
      let card = Card {
        id : object::new(ctx),
        index : (i as u8),
        card_number : encrypted_fifty_two_numbers_array.pop_back()
      };

      card_deck.avail_cards.push_back(card);

      i = i - 1;
    };
  }

  // --------- Card ---------

  use fun card_id as Card.id;
  fun card_id(card : &Card) : ID {object::id(card)}

  use fun card_index as Card.index;
  fun card_index(card : &Card) : u8 {card.index}

  use fun card_number as Card.number;
  fun card_number(card : &Card) : u8 {card.card_number}

  // --------- PlayerSeat ---------

  // use fun player_seat_id as PlayerSeat.id;
  // fun player_seat_id(player_hand : &PlayerSeat) : ID {object::id(player_hand)}

  use fun player_seat_player as PlayerSeat.player;
  fun player_seat_player(player_seat : &PlayerSeat) : Option<address> {player_seat.player}

  use fun player_seat_public_key as PlayerSeat.public_key;
  fun player_seat_public_key(player_seat : &PlayerSeat) : vector<u8> {player_seat.public_key}

  use fun player_seat_set_player as PlayerSeat.set_player;
  fun player_seat_set_player(player_seat : &mut PlayerSeat, ctx : &TxContext) {
    player_seat.player = option::some(tx_context::sender(ctx));
  }

  use fun player_seat_set_public_key as PlayerSeat.set_public_key;
  fun player_seat_set_public_key(player_seat : &mut PlayerSeat, public_key : vector<u8>) {
    player_seat.public_key = public_key;
  }

  use fun player_seat_add_money as PlayerSeat.add_money;
  fun player_seat_add_money(player_seat : &mut PlayerSeat, money : Coin<SUI>) {
    player_seat.money.push_back(object::id(&money));
    dynamic_object_field::add<ID, Coin<SUI>>(&mut player_seat.id, object::id(&money), money);
  }

  // ============================================
  // ================ TEST ======================
  // ============================================
  #[test_only] 
  use sui::test_scenario;

  #[test_only] 
  fun create_game() : (Casino, Lounge) {
    let mut ts = test_scenario::begin(@0xA);
    let ctx = test_scenario::ctx(&mut ts);

    let public_key = vector<u8>[11,2,3,1,12,31,3,12,1];
    let casino = Casino {
      id : object::new(ctx),
      admin: tx_context::sender(ctx),
      public_key : public_key
    };
    let mut lounge = Lounge {
      id : object::new(ctx),
      casino_id : casino.id(),
      game_tables : vector[]

    };

    create_and_add_game_table(&casino, &mut lounge, 5, 5, 5, ctx);

    test_scenario::end(ts);

    (casino, lounge)
  }

  #[test]
  fun test_game_table() {
    let mut ts = test_scenario::begin(@0xA);
    let ctx = test_scenario::ctx(&mut ts);
    let coin = coin::mint_for_testing<SUI>(50000, ctx);

    let (casino, mut lounge) = create_game();

    create_and_add_game_table(&casino, &mut lounge, 5,5,5, ctx);
    // create_and_add_game_table(&casino, &mut lounge, 5,5,6, ctx);


    let mut game_tables = lounge.game_tables();
    debug::print(&string::utf8(b"game tables : "));
    debug::print(&game_tables);

    let game_table_id = game_tables.pop_back();
    let game_table = dynamic_object_field::borrow_mut<ID, GameTable> (&mut lounge.id, game_table_id);

    game_table.enter_player(vector<u8>[2,3,31,31,42,33], coin, ctx);

    debug::print(&game_table.game_status.player_infos);
    debug::print(&game_table.player_seats);

    // let mut i = 1;
    // while (i < game_tables.length() + 1) {
    //   let game_table_id = game_tables.pop_back();
    //   let game_table = dynamic_object_field::borrow_mut<ID, GameTable> (&mut lounge.id, game_table_id);


    //   // game_table.enter_player(vector<u8>[2,3,31,31,42,33], coin, ctx);
      
    //   debug::print(&game_table.game_status.player_infos);
    //   debug::print(&game_table.player_seats);

    //   i = i + 1;
    // };



    remove_game(casino, lounge, ctx);
    test_scenario::end(ts);

  }


  #[test]
  fun test_vector() {
    let mut u64_vector = vector<u64> [0, 1, 2, 3];
    let element = u64_vector.remove(0);
    debug::print(&element);
    debug::print(&u64_vector.remove(0));
  }

  #[test_only] 
  fun remove_game(casino : Casino, lounge : Lounge, ctx : &mut TxContext) {
    let Casino {id : casino_id, admin : _, public_key : _} = casino;
    object::delete(casino_id);

    let sender = tx_context::sender(ctx);
    transfer::public_transfer(lounge, sender);

  }

  // #[test]
  // fun test_get_available_game_table() {
  //   let mut ts = test_scenario::begin(@0xA);
  //   let ctx = test_scenario::ctx(&mut ts);

  //   let (casino, mut lounge) = create_game();

  //   create_and_add_game_table(&casino, &mut lounge, 5,5,5, ctx);
  //   create_and_add_game_table(&casino, &mut lounge, 5,5,5, ctx);

  //   let game_table_id = lounge.avail_game_table();
  //   debug::print(&game_table_id);


  //   remove_game(casino, lounge, ctx);
  //   test_scenario::end(ts);
  // }

  // #[test]
  // fun test_card_number() {
  //   let mut ts = test_scenario::begin(@0xA);
  //   let ctx = test_scenario::ctx(&mut ts);

  //   let card = Card {
  //     id : object::new(ctx),
  //     index : 1,
  //     card_number : 10
  //   };

  //   let card_number = card.number();
  //   debug::print(&card_number);

  //   let Card {id, index : _, card_number: _} = card;
  //   object::delete(id);

  //   test_scenario::end(ts);
  // }

  // #[test]
  // fun test_card_deck() {
  //   let mut ts = test_scenario::begin(@0xA);
  //   let ctx = test_scenario::ctx(&mut ts);
  //   let public_key = vector<u8>[11,2,3,1,12,31,3,12,1];
  //   let casino = Casino {
  //     id : object::new(ctx),
  //     admin: tx_context::sender(ctx),
  //     public_key : public_key
  //   };
  //   let card_deck = create_card_deck(&casino, ctx);
  //   debug::print(&card_deck);

  //   let CardDeck {id : id, avail_cards : mut avail_cards, used_cards : mut used_cards} = card_deck;
  //   object::delete(id);

  //   while (!avail_cards.is_empty()) {
  //     let card = avail_cards.pop_back();
  //     let Card {id : card_id, index: _, card_number: _} = card;
  //     object::delete(card_id);
  //   };

  //   avail_cards.destroy_empty();

  //   while (!used_cards.is_empty()) {
  //     let card = used_cards.pop_back();
  //     let Card {id : card_id, index: _, card_number: _} = card;
  //     object::delete(card_id);
  //   };
  //   used_cards.destroy_empty();

  //   let Casino {id : casino_id, admin : _, public_key : _} = casino;
  //   object::delete(casino_id);
    
  //   test_scenario::end(ts);
  // }

  // #[test]
  // fun test_numbers_array() {
  //   let fifty_two_numbers_array = get_fifty_two_numbers_array();
  //   let mut shuffled_fifty_two_numbers_array = shuffle(fifty_two_numbers_array);

  //   let mut i = shuffled_fifty_two_numbers_array.length();
  //   while (i > 0) {
  //     let number = shuffled_fifty_two_numbers_array.pop_back();
  //     debug::print(&number);
    
  //     i = i - 1;
  //   };
  // }

}