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

  public fun game_status(game_table : &GameTable) : &GameStatus {&game_table.game_status}
  public fun game_status_mut(game_table : &mut GameTable) : &mut GameStatus {&mut game_table.game_status}

  public fun money_box(game_table : &GameTable) : &MoneyBox {&game_table.money_box}
  public fun money_box_mut(game_table : &mut GameTable) : &mut MoneyBox {&mut game_table.money_box}

  public fun card_deck(game_table : &GameTable) : &Option<CardDeck> {&game_table.card_deck}
  public fun card_deck_mut(game_table : &mut GameTable) : &mut Option<CardDeck> {&mut game_table.card_deck}

  public fun player_seats(game_table : &GameTable) : &vector<PlayerSeat> {&game_table.player_seats}
  public fun player_seats_mut(game_table : &mut GameTable) : &mut vector<PlayerSeat> {&mut game_table.player_seats}

  public fun casino_public_key(game_table : &GameTable) : vector<u8> {game_table.casino_public_key}

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
      // When the game table is full, deposit sends it back to the user address
      transfer::public_transfer(deposit, tx_context::sender(ctx));
    } else {
      // If there is any seats left, let the player join the game
      game_table.enter_player(empty_seat_index, public_key, deposit, ctx);
    };
  }

  public fun exit(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    assert!(player_seat_index != PLAYER_NOT_FOUND, 104);

    game_table.game_status.player_infos_mut().borrow_mut(player_seat_index).set_playing_action(player_info::CONST_EXIT());

    // If the player is the manager_player of the game, hand it over to the next, or return option::none() if the last user.
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

    // If current game status is IN_GAME and unable to play the game because there are 2 players left including exit player, -> finish game
    if (game_table.game_status.game_playing_status() == game_status::CONST_IN_GAME() 
    && game_table.number_of_players() == 2) {
      game_table.finish_game(ctx);
    };

    // Delete player info
    game_table.exit_player(player_seat_index, ctx);
  }

  public fun ante(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    assert!(player_seat_index != PLAYER_NOT_FOUND, 105);

    let ante_amount = game_table.game_status.ante_amount();
    game_table.bet_money(player_seat_index, ante_amount, ctx);

    // Switch to READY status
    game_table.game_status.player_infos_mut().borrow_mut(player_seat_index).set_playing_status(player_info::CONST_READY());
  }

  public fun start(game_table : &mut GameTable, ctx : &mut TxContext) {
    assert!(game_table.game_status.is_manager_player(ctx), 106);
    assert!(game_table.number_of_players() >= 2, 106);
    assert!(game_table.is_all_player_ready(), 107);

    game_table.draw_card_to_all_player();
    
    // Update GamesStatus and playing status of all players
    game_table.set_all_player_playing_status(player_info::CONST_PLAYING());
    game_table.game_status.set_game_playing_status(game_status::CONST_IN_GAME());
  }

  public fun action(game_table : &mut GameTable, action_type : u8, raise_chip_count : u64, ctx : &mut TxContext) {
    assert!(game_table.game_status().is_current_turn(ctx), 113);

    // Is it the first betting? (is current turn index the same as previous turn?)
    if (game_table.game_status.current_turn_index() == game_table.game_status.previous_turn_index()){
      // If it's the first turn of a round, you can do CHECK, BET or FOLD -> CALL, RAISE are unavailable
      assert!(action_type != player_info::CONST_CALL(), 114);
      assert!(action_type != player_info::CONST_RAISE(), 115);
    };

    // Is the action on the previous turn CHECK?
    if (game_table.game_status.player_infos().borrow(game_table.game_status.previous_turn_index() as u64).playing_action() == player_info::CONST_CHECK()) {
      // You can do CHECK, BET or FOLD after doing CHECK -> CALL, RAISE are unavailable
      assert!(action_type != player_info::CONST_CALL(), 116);
      assert!(action_type != player_info::CONST_RAISE(), 117);
    };

    // Is the action on previous turn BET?
    if (game_table.game_status.player_infos().borrow(game_table.game_status.previous_turn_index() as u64).playing_action() == player_info::CONST_BET()) {
      // You can do CALL, RAISE or FOLD after doing CHECK -> CALL, BET are unavailable
      assert!(action_type != player_info::CONST_CHECK(), 118);
      assert!(action_type != player_info::CONST_BET(), 119);
    };

    // Is the previous turn action CALL?
    if (game_table.game_status.player_infos().borrow(game_table.game_status.previous_turn_index() as u64).playing_action() == player_info::CONST_CALL()) {
      // You can do CALL, RAISE or FOLD after doing CHECK -> CALL, BET are unavailable
      assert!(action_type != player_info::CONST_CHECK(), 120);
      assert!(action_type != player_info::CONST_BET(), 121);
    };

    // Is the previous turn action RAISE?
    if (game_table.game_status.player_infos().borrow(game_table.game_status.previous_turn_index() as u64).playing_action() == player_info::CONST_RAISE()) {
      // You can do CALL, RAISE or FOLD after doing RAISE -> CALL, BET are unavailable
      assert!(action_type != player_info::CONST_CHECK(), 120);
      assert!(action_type != player_info::CONST_BET(), 121);
    };

    // After the review process is completed, the actual action is carried out here
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

    // If you can't find it, it's the wrong game_table.
    let winner_player_seat_index = game_table.find_player_seat_index(ctx);
    
    // First, collect cards from all player seats into the card deck.
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

    // Moves card deck to used_card_decks
    let used_card_deck = game_table.card_deck.extract();
    game_table.used_card_decks.push_back(used_card_deck.id());
    dynamic_object_field::add<ID, CardDeck>(&mut game_table.id, used_card_deck.id(), used_card_deck);

    // Create a new card deck and send it to the game table. Using Random here
    let mut card_deck = card_deck::new(game_table.casino_public_key, ctx);
    card_deck.fill_cards(&mut game_table.game_status, game_table.casino_public_key, r, ctx);
    option::fill(&mut game_table.card_deck, card_deck);

    // Merge all the money in the Money box and give it to the winner player.
    let winner_player_seat = game_table.player_seats.borrow_mut(winner_player_seat_index);
    game_table.money_box.send_all_money(winner_player_seat, &mut game_table.game_status, ctx);

    // Initialize game info.
    // Set winner player to manager player.
    game_table.game_status.reset_game_info();
    game_table.game_status.set_manager_player(winner_player_seat.player_address());
    game_table.game_status.set_current_turn(winner_player_seat_index as u8);

    // Initialize player info
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

    // Register player as manager_player if there is no manager_player in the game
    if (game_table.game_status.manager_player() == option::none<address>()) {
      game_table.game_status.set_manager_player(option::some(tx_context::sender(ctx)));
      game_table.game_status.set_current_turn(0);
    };

    // Decrease avail_seat by one
    game_table.game_status.decrease_avail_seat();
  }

  fun exit_player(game_table : &mut GameTable, player_seat_index : u64, ctx : &mut TxContext) {
    let player_seat = game_table.player_seats.borrow_mut(player_seat_index);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);
    
    // If tx sender is not the owner of the corresponding player_seat seat, assert!
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

    // After a CHECK, have all players who are PLAYING CHECKed? -> If not, next turn
    if (!game_table.is_all_player_check()) {
      game_table.next_turn(ctx);
      return
    };

    // Can't play more because the round is over? -> end game
    if (game_table.is_round_over()){
      game_table.finish_game(ctx);
      return
    };

    // Is there still a round left and can I play more? -> Next round
    game_table.next_round(ctx);
  }

  fun bet(game_table : &mut GameTable, ctx : &mut TxContext) {
    // Bet an amount equal to bet_unit.
    let player_seat_index = game_table.find_player_seat_index(ctx);
    let bet_unit = game_table.game_status.bet_unit();
    game_table.bet_money(player_seat_index, bet_unit , ctx);

    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    // Player's action is BET
    player_info.set_playing_action(player_info::CONST_BET());

    // Next turn
    game_table.next_turn(ctx);
  }


  fun call(game_table : &mut GameTable, ctx : &mut TxContext) {
    let previous_player_seat_index = game_table.game_status.previous_turn_index() as u64;
    let previous_player_total_bet_amount = game_table.game_status.player_infos().borrow(previous_player_seat_index).total_bet_amount();

    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    // player's action is CALL
    player_info.set_playing_action(player_info::CONST_CALL());

    // Match the current player's total bet amount equal to the previous player's total bet amount.
    let bet_amount = previous_player_total_bet_amount - player_info.total_bet_amount();
    game_table.bet_money(player_seat_index, bet_amount, ctx);

    // Have all players who are playing CALL and playing PLAYING got the same total amount of bets? -> Or next turn
    if (!game_table.is_all_player_bet_amount_same()) {
      game_table.next_turn(ctx);
      return
    };

    // Can't play more because round is over? -> End the game
    if (game_table.is_round_over()){
      game_table.finish_game(ctx);
      return
    };

    // Is the round still available to play further? -> Next round
    game_table.next_round(ctx);
  }
  
  fun raise(game_table : &mut GameTable, raise_chip_count : u64, ctx : &mut TxContext) {
    let previous_player_seat_index = game_table.game_status.previous_turn_index() as u64;
    let previous_player_total_bet_amount = game_table.game_status.player_infos().borrow(previous_player_seat_index).total_bet_amount();

    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    // player's action is RAISE
    player_info.set_playing_action(player_info::CONST_RAISE());

    // Match the current player's total bet amount excluding FOLD to the previous player's total bet amount.
    // Additionally, place an additional bet as much as chip_count * bet_unit.
    let call_bet_amount = previous_player_total_bet_amount - player_info.total_bet_amount();
    let raise_bet_amount = raise_chip_count * game_table.game_status.bet_unit();
    let bet_amount = call_bet_amount + raise_bet_amount;
    game_table.bet_money(player_seat_index, bet_amount, ctx);

    // Next turn
    game_table.next_turn(ctx);

  }

  fun fold(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    // player's action is FOLD
    player_info.set_playing_action(player_info::CONST_FOLD());

    // Cannot proceed if less than 2 players have not folded
    if (game_table.number_of_players_not_folding() < 2) {
      game_table.finish_game(ctx);
      return
    };

    // After FOLD, the game can be played & all players who are PLAYING have CHECKed, and the round is over -> End the game.
    if (game_table.is_all_player_check() && game_table.is_round_over()) {
      game_table.finish_game(ctx);
      return
    };

    // After FOLD, game can be played & all players who are PLAYING have CHECKed, is there a round left? -> Next round
    if (game_table.is_all_player_check() && !game_table.is_round_over()) {
      game_table.next_round(ctx);
      return
    };

    // After the FOLD, the game can proceed & all remaining PLAYING players have equalized their bet totals, and the round is over -> End the game.
    if (game_table.is_all_player_action_not_none() && game_table.is_all_player_bet_amount_same() && game_table.is_round_over()) {
      game_table.finish_game(ctx);
      return
    };

    // After FOLD, the game can proceed & all remaining PLAYING players have equalized their bet totals, is there a round left? -> Next round
    if (game_table.is_all_player_action_not_none() && game_table.is_all_player_bet_amount_same() && !game_table.is_round_over()) {
      game_table.next_round(ctx);
      return
    };

    // If none of these are true, just use the next turn
    game_table.next_turn(ctx);
  }

  fun finish_game(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_info = game_table.game_status.player_infos().borrow(player_seat_index);

    // Determining the winner player -> sending money afterwards is done in settle up
    // If the game is not possible because there are 2 players left including the exit player -> the remaining player becomes the winner
    if (player_info.playing_action() == player_info::CONST_EXIT() && game_table.number_of_players() == 2) {
      let next_player_seat_index = game_table.find_next_player_seat_index(ctx);
      let next_player_seat = game_table.player_seats.borrow(next_player_seat_index);
      game_table.game_status.set_winner_player(next_player_seat.player_address());
    } 
    // Is there 1 player left, excluding folds? -> the remaining player is the winner
    else if (game_table.number_of_players_not_folding() < 2) {
      let next_player_seat_index = game_table.find_next_player_seat_index(ctx);
      let next_player_seat = game_table.player_seats.borrow(next_player_seat_index);
      game_table.game_status.set_winner_player(next_player_seat.player_address());
    } 
    // Other than those two cases, let the game logic decide the winner.
    else {
      let winner_player_index = game_table.find_winner_index();
      let winner_player_info = game_table.game_status.player_infos().borrow(winner_player_index);
      game_table.game_status.set_winner_player(winner_player_info.player_address());
    }; 

    // Open all player cards
    game_table.open_all_player_card();
    
    // GAME FINISHED
    game_table.set_all_player_playing_status(player_info::CONST_GAME_END());
    game_table.game_status.set_game_playing_status(game_status::CONST_GAME_FINISHED());
  }

  // Get Methods ===============================
  public fun id(game_table : &GameTable) : ID {object::id(game_table)}

  public fun lounge_id(game_table : &GameTable) : ID {game_table.lounge_id}

  fun used_card_decks(game_table : &GameTable) : vector<ID> {game_table.used_card_decks}

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

      // If no one is there and you come back, break. This means that we can't take the next turn and return to our
      if (next_player_seat_index == player_seat_index) {
        return NEXT_PLAYER_NOT_FOUND
      };

      next_player_seat_index = next_player_seat_index + 1;
    };
    next_player_seat_index
  }

  fun find_winner_index(game_table : &mut GameTable) : u64 {
    let mut i = 0;
    let mut highest_score = 0;
    let mut highest_score_player_index = 0;
    while (i < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow_mut(i);
      if (player_seat.player_address() == option::none()) {
        i = i + 1;
        continue
      };

      let card1 = player_seat.cards().borrow(0);
      let card2 = player_seat.cards().borrow(1);

      let casino_n = encrypt::convert_vec_u8_to_u256(game_table.casino_public_key);
      let decrypted_card_number1 = encrypt::decrypt_256(casino_n, card1.card_number());
      let decrypted_card_number2 = encrypt::decrypt_256(casino_n, card2.card_number());

      if (highest_score == 0) {
        highest_score = mini_poker_logic::get_card_combination_score(decrypted_card_number1, decrypted_card_number2);
      };

      if (highest_score < mini_poker_logic::get_card_combination_score(decrypted_card_number1, decrypted_card_number2)) {
        highest_score = mini_poker_logic::get_card_combination_score(decrypted_card_number1, decrypted_card_number2);
        highest_score_player_index = i;
      };

      i = i + 1;
    };

    return highest_score_player_index
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
    game_table.draw_card_to_all_player(); // Those who stay get more cards
    game_table.set_all_player_playing_action(player_info::CONST_NONE()); // Reset all players' playing actions to NONE
    game_table.game_status.next_round(); // And the next round, the next turn
    game_table.next_turn(ctx);
  }
  
  public fun next_turn(game_table : &mut GameTable, ctx : &mut TxContext) {
    let player_seat_index = game_table.find_player_seat_index(ctx);
    let player_playing_action = game_table.game_status.player_infos().borrow(player_seat_index).playing_action();
    let next_player_seat_index = game_table.find_next_player_seat_index(ctx);

    // (action is Exit,) need to pass if it's not the current turn
    if (player_playing_action == player_info::CONST_EXIT() && !game_table.game_status.is_current_turn(ctx)) {
      return
    };

    // player index == current turn index (all actions except Exit can only be executed when it's the current turn) 
    // If fold and this is the first turn? -> flip both current turn and previoust turn
    if (player_playing_action == player_info::CONST_FOLD() 
    && game_table.game_status.current_turn_index() == game_table.game_status.previous_turn_index()) {
      game_table.game_status.set_previous_turn(next_player_seat_index as u8); 
      game_table.game_status.set_current_turn(next_player_seat_index as u8);
      return
    };

    // If fold and it's not the first turn? -> only flip the current turn
    if (player_playing_action == player_info::CONST_FOLD() 
    && game_table.game_status.current_turn_index() != game_table.game_status.previous_turn_index()) {
      game_table.game_status.set_current_turn(next_player_seat_index as u8);
      return
    }; 

    // If neither fold nor exit, current turn should be previous turn
    if (player_playing_action != player_info::CONST_FOLD() && player_playing_action != player_info::CONST_EXIT()) {
      game_table.game_status.set_previous_turn(player_seat_index as u8); 
      game_table.game_status.set_current_turn(next_player_seat_index as u8);
      return
    };
  }

  fun bet_money(game_table : &mut GameTable, player_seat_index : u64, money_amont : u64, ctx : &mut TxContext) {
    let player_seat = game_table.player_seats.borrow_mut(player_seat_index);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    //Take money_amount from PlayerSeat's deposit and send it to MoneyBox
    let money_to_bet = player_seat.withdraw_money(player_info, money_amont, ctx);
    game_table.money_box.bet_money(player_info, money_to_bet);
    game_table.game_status.add_bet_amount(money_amont);
  }

  fun draw_card(game_table : &mut GameTable, player_seat_index : u64) {
    let player_seat = game_table.player_seats.borrow_mut(player_seat_index);
    let player_info = game_table.game_status.player_infos_mut().borrow_mut(player_seat_index);

    player_seat.receive_card(player_info, game_table.card_deck.borrow_mut().draw_card(game_table.casino_public_key));
    game_table.game_status.draw_card();
  }

  fun draw_card_to_all_player(game_table : &mut GameTable) {
    let mut player_seat_index = 0;
    while (player_seat_index < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow_mut(player_seat_index);
      if (player_seat.player_address() == option::none<address>()){
        player_seat_index = player_seat_index + 1;
        continue
      };
      game_table.draw_card(player_seat_index);

      player_seat_index = player_seat_index + 1;
    };
  }

  fun open_all_player_card(game_table : &mut GameTable) {
    let mut i = 0;
    while (i < game_table.player_seats.length()) {
      let player_seat = game_table.player_seats.borrow_mut(i);
      if (player_seat.player_address() == option::none<address>()) {
        i = i + 1;
        continue
      };
      player_seat.open_cards(game_table.casino_public_key);
      
      i = i + 1;
    };

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





  // ============================================
  // ================ TEST ======================



  #[test]
  fun test_enter() {

  }

}