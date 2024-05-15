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

  // ======================= Errors ==============================
  // =============================================================

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
    card_game_id : ID,
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
    player_address : address,
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

  public struct PlayerSeat has store {
    // casino_id : ID,
    player : Option<address>,
    public_key : vector<u8>,
    cards : vector<Card>,
    money : vector<Coin<SUI>>
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
  entry fun create_root_game(public_key : vector<u8>, ctx: &mut TxContext) {
    transfer::freeze_object(
      Casino {
      id : object::new(ctx),
      admin: tx_context::sender(ctx),
      public_key : public_key
      });
  }

  entry fun create_card_game(casino : &Casino, ctx: &mut TxContext) {
    assert!(casino.admin == tx_context::sender(ctx), 403);

    transfer::share_object(Lounge{
      id : object::new(ctx),
      casino_id : object::id(casino),
      game_tables : vector[]
    });
  }

  entry fun create_and_add_game_table(
    casino : &Casino, 
    card_game : &mut Lounge, 
    ante_amount : u64, 
    bet_unit : u64, 
    game_seats : u8, 
    ctx : &mut TxContext) {
    assert!(casino.admin == tx_context::sender(ctx), 403);

    let game_status = create_game_status(ante_amount, bet_unit, game_seats);
    let money_box = create_money_box(ctx);
    let card_deck = create_card_deck(casino, ctx);

    
    let mut game_table = GameTable {
      id : object::new(ctx),
      card_game_id : card_game.id(),
      game_status : game_status,
      money_box : money_box,
      card_deck : option::some(card_deck),
      used_card_decks : vector[],
      player_seats : vector[]
    };

    let mut i = 0 as u8;
    while (i < game_seats) {
      let player_seat = create_player_seat();
      game_table.player_seats.push_back(player_seat);
      i = i + 1;
    };

    card_game.game_tables.push_back(game_table.id());

    dynamic_object_field::add<ID, GameTable>(&mut card_game.id, game_table.id(), game_table);
  }

  // --------- For Player ---------

  // 1. player가 가지고 있는 hand 중에서 빈 핸드 하나 보내는 거가 가능? 가능하면 player_hand parameter 필요 없음.
  // 2. 굳이 player_hand를 보내야 하나? game_table에 이미 player_hand가 있어서 정보만 보내는 거지. 그래도 player가 차있다 이걸 표현 할 수 있음.
  entry fun enter(
    casino : &Casino, 
    card_game : &mut Lounge, 
    // player_hand : PlayerSeat, 
    ctx : &mut TxContext) : ID {
    assert!(casino.id() == card_game.casino_id(), 403);

    let mut avail_game_table_id = card_game.avail_game_table();
    let avail_game_table = dynamic_object_field::borrow_mut<ID, GameTable> (&mut card_game.id, option::extract(&mut avail_game_table_id));
    // avail_game_table.add_player_hand(player_hand);
    return option::extract(&mut avail_game_table_id)

  }

  // entry fun get_player_hand(casino : &Casino, public_key : vector<u8>, ctx : &mut TxContext) {
  //   let sender = tx_context::sender(ctx);

  //   let player_hand = create_player_seat(casino, public_key, ctx);
  //   transfer::public_transfer(player_hand, sender);
  // }

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

  fun create_game_status(ante_amount : u64, bet_unit : u64, game_seats : u8) : GameStatus {
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

    GameStatus {
      game_info : game_info,
      money_box_info : money_box_info,
      card_info : card_info,
      player_infos : vector[]
    }
  }

  fun create_money_box(ctx : &mut TxContext) : MoneyBox {
    MoneyBox {
      id : object::new(ctx),
      money : vector[]
    }
  }

  fun create_card_deck(casino : &Casino, ctx : &mut TxContext) : CardDeck {
    let mut card_deck = CardDeck {
      id : object::new(ctx),
      avail_cards : vector[],
      used_cards : vector[],
    };

    card_deck.fill_card(casino.public_key(), ctx);

    card_deck
  }

  fun create_player_seat() : PlayerSeat {
    PlayerSeat {
      // id : object::new(ctx),
      // casino_id : object::id(casino),
      player : option::none(),
      public_key : vector<u8>[],
      cards : vector<Card>[],
      money : vector<Coin<SUI>>[]
    }
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

  use fun root_game_admin as Casino.admin;
  fun root_game_admin(casino : &Casino) : address {casino.admin}

  use fun root_game_public_key as Casino.public_key;
  fun root_game_public_key(casino : &Casino) : vector<u8> {casino.public_key}

  // --------- Lounge ---------

  use fun card_game_id as Lounge.id;
  fun card_game_id(card_game : &Lounge) : ID {object::id(card_game)}

  use fun card_game_root_game_id as Lounge.casino_id;
  fun card_game_root_game_id(card_game : &Lounge) : ID {card_game.casino_id}

  use fun card_game_game_tables as Lounge.game_tables;
  fun card_game_game_tables(card_game : &Lounge) : vector<ID> {card_game.game_tables}

  use fun get_available_game_table_id as Lounge.avail_game_table;
  fun get_available_game_table_id(card_game : &Lounge) : Option<ID> {
    let mut game_tables = card_game.game_tables();
    debug::print(&string::utf8(b"game tables : "));
    debug::print(&game_tables);

    while (!game_tables.is_empty()) {
      let game_table_id = game_tables.pop_back();
      let game_table = dynamic_object_field::borrow<ID, GameTable> (&card_game.id, game_table_id);
      if (game_table.game_status.avail_seats() > 0) {
        debug::print(&string::utf8(b"게임을 찾았다!"));
        return option::some(game_table_id)
      };
    };

    return option::none()
  }

  // --------- GameTable ---------

  use fun game_table_id as GameTable.id;
  fun game_table_id(game_table : &GameTable) : ID {object::id(game_table)}

  use fun game_table_card_game_id as GameTable.card_game_id;
  fun game_table_card_game_id(game_table : &GameTable) : ID {game_table.card_game_id}

  use fun game_table_used_card_decks as GameTable.used_card_decks;
  fun game_table_used_card_decks(game_table : &GameTable) : vector<ID> {game_table.used_card_decks}

  use fun game_table_add_player_hand as GameTable.add_player_hand;
  fun game_table_add_player_hand(game_table : &mut GameTable, player_hand : PlayerSeat) {
    game_table.player_seats.push_back(player_hand);
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

  // --------- PlayerInfo ---------

  use fun player_info_player_address as PlayerInfo.player_address;
  fun player_info_player_address(player_info : &PlayerInfo) : address {player_info.player_address}

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

  use fun player_hand_public_key as PlayerSeat.public_key;
  fun player_hand_public_key(player_hand : &PlayerSeat) : vector<u8> {player_hand.public_key}

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
    let mut card_game = Lounge {
      id : object::new(ctx),
      casino_id : casino.id(),
      game_tables : vector[]

    };

    create_and_add_game_table(&casino, &mut card_game, 5, 5, 5, ctx);

    test_scenario::end(ts);

    (casino, card_game)
  }

  #[test_only] 
  fun remove_game(casino : Casino, card_game : Lounge, ctx : &mut TxContext) {
    let Casino {id : casino_id, admin : _, public_key : _} = casino;
    object::delete(casino_id);

    let sender = tx_context::sender(ctx);
    transfer::public_transfer(card_game, sender);

  }

  #[test]
  fun test_get_available_game_table() {
    let mut ts = test_scenario::begin(@0xA);
    let ctx = test_scenario::ctx(&mut ts);

    let (casino, mut card_game) = create_game();

    create_and_add_game_table(&casino, &mut card_game, 5,5,5, ctx);
    create_and_add_game_table(&casino, &mut card_game, 5,5,5, ctx);

    let game_table_id = card_game.avail_game_table();
    debug::print(&game_table_id);


    remove_game(casino, card_game, ctx);
    test_scenario::end(ts);
  }

  #[test]
  fun test_card_number() {
    let mut ts = test_scenario::begin(@0xA);
    let ctx = test_scenario::ctx(&mut ts);

    let card = Card {
      id : object::new(ctx),
      index : 1,
      card_number : 10
    };

    let card_number = card.number();
    debug::print(&card_number);

    let Card {id, index : _, card_number: _} = card;
    object::delete(id);

    test_scenario::end(ts);
  }

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