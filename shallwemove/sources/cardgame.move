module shallwemove::cardgame {
  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::casino::{Self, Casino};
  use shallwemove::lounge::{Self, Lounge};
  use shallwemove::game_table::{Self, GameTable};
  use shallwemove::game_status::{Self, GameStatus};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use std::debug;
  use sui::random::{Self, Random};
  use std::string::{Self};

  // ======================= Errors ==============================

  const ERROR1 : u8 = 100; // example of error code

  // ============================================
  // ============== FUNCTIONS ===================

  fun init(ctx: &mut TxContext) {
  }

  // ====================== Entry Functions ======================

  // --------- For Game Owner ---------

  // This function will be executed in the Sui client, Sui RPC or Backend.
  // game owner or anyone who wanna be a game owner can create new game
  // Casino object is essential to play game
  entry fun create_casino(public_key : vector<u8>, ctx: &mut TxContext) {
    casino::create(public_key, ctx);
  }

  entry fun create_lounge(casino : &Casino, max_round : u8, ctx: &mut TxContext) {
    lounge::create(casino,max_round, ctx);
  }

  entry fun add_game_table(
    casino : &Casino, 
    lounge : &mut Lounge, 
    ante_amount : u64, 
    bet_unit : u64, 
    game_seats : u8, 
    r : &Random,
    ctx : &mut TxContext) {
    assert!(casino.admin() == tx_context::sender(ctx), 1);

    let game_table = game_table::new(lounge.id(), casino.public_key(), lounge.max_round(), ante_amount, bet_unit, game_seats, r, ctx);

    lounge.add_game_table(game_table);
  }

  // --------- For Player ---------

  // Enter game
  entry fun enter(
    casino : &Casino, 
    lounge : &mut Lounge, 
    public_key : vector<u8>,
    deposit : Coin<SUI>,
    ctx : &mut TxContext) : ID {
      // Check that casino id is the same as the casino id of the round
      assert!(casino.id() == lounge.casino_id(), 2);

      // Deposit is a certain amount -> 100 times the bet_unit of game_table
      // Get an available game table
      let mut available_game_table_id = lounge.find_available_game_table_id();
      assert!(available_game_table_id != option::none(), 3);

      let avail_game_table = lounge.borrow_mut_game_table(available_game_table_id.extract());

      // Only possible when current game status is PRE_GAME
      assert!(avail_game_table.game_status().game_playing_status() == game_status::CONST_PRE_GAME(), 4);

      // Join the player in the GameTable
      avail_game_table.enter(public_key, deposit, ctx);
      debug::print(avail_game_table);

      // debug::print(avail_game_table);
      return avail_game_table.id()
  }


  // Exit game
  entry fun exit(
    casino: &Casino, 
    lounge: &mut Lounge, // It's necessary to access from parent
    game_table_id: ID, 
    ctx: &mut TxContext
  ) {
    assert!(casino.id() == lounge.casino_id(), 5);

    let lounge_id = lounge.id();
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    assert!(lounge_id == game_table.lounge_id(), 6);
    
    game_table.exit(ctx);
  }

  // Money you pay at the start of the game.
  // transition status to game ready
  entry fun ante(
    casino: &Casino,
    lounge: &mut Lounge,
    game_table_id: ID,
    ctx: &mut TxContext,
  ) : ID {
    assert!(casino.id() == lounge.casino_id(), 7);

    let lounge_id = lounge.id();
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    assert!(lounge_id == game_table.lounge_id(), 8);


    // Only possible when the current game status is PRE_GAME
    assert!(game_table.game_status().game_playing_status() == game_status::CONST_PRE_GAME(), 9);

    game_table.ante(ctx);
    
    return game_table.id()
  }

  // Start game
  entry fun start(
    casino: &Casino, 
    lounge: &mut Lounge,
    game_table_id: ID,
    ctx: &mut TxContext,
  ) : ID {
    assert!(casino.id() == lounge.casino_id(), 10);
    let lounge_id = lounge.id();
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    assert!(lounge_id == game_table.lounge_id(), 11);

    
    // Only possible when the current game status is PRE_GAME
    assert!(game_table.game_status().game_playing_status() == game_status::CONST_PRE_GAME(), 12);

    // Cannot execute start() if not the manager player
    assert!(game_table.game_status().is_manager_player(ctx), 13);
    
    game_table.start(ctx);

    return game_table.id()
  }

  // Called by a player.
  // If it's the last turn's action, the game would be automatically ended by the Smart contract.
  entry fun action(
    casino: &Casino, 
    lounge: &mut Lounge,
    game_table_id: ID,
    action_type: u8, // ante, check, bet, call, raise
    chip_count: u64, // How many chips to bet (how many SUIs a chip will be depends on GameTable's bet_unit)
    ctx: &mut TxContext,
  ) : ID {
    assert!(casino.id() == lounge.casino_id(), 14);
    let lounge_id = lounge.id();
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    assert!(lounge_id == game_table.lounge_id(), 15);

    //Only possible when current game status is IN_GAME
    assert!(game_table.game_status().game_playing_status() == game_status::CONST_IN_GAME(), 16);

    game_table.action(action_type, chip_count, ctx);
      
    return game_table.id()
  }

  // Get a settlement (The winner must call the transaction at the end of the game)
  entry fun settle_up(
    casino: &Casino, 
    lounge: &mut Lounge,
    game_table_id: ID,
    r : &Random,
    ctx: &mut TxContext,
  ) : ID {
    assert!(casino.id() == lounge.casino_id(), 17);
    let lounge_id = lounge.id();
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    assert!(lounge_id == game_table.lounge_id(), 18);

    // Only possible when the current game status is GAME_FINISHED
    assert!(game_table.game_status().game_playing_status() == game_status::CONST_GAME_FINISHED(), 19);

    game_table.settle_up(r, ctx);
    
    return game_table.id()
  }

  // ============================================
  // ================ TEST ======================

  #[test_only]
  public fun add_game_table_test(
    casino : &Casino, 
    lounge : &mut Lounge, 
    ante_amount : u64, 
    bet_unit : u64, 
    game_seats : u8, 
    r: &Random,
    ctx : &mut TxContext) {
      add_game_table(casino, lounge, ante_amount, bet_unit, game_seats, r, ctx);
    }

  #[test_only]
  public fun enter_test(
    casino : &Casino, 
    lounge : &mut Lounge, 
    public_key : vector<u8>,
    deposit : Coin<SUI>,
    ctx : &mut TxContext) : ID {
      enter(casino, lounge, public_key, deposit, ctx)
  }

  #[test_only]
  public fun exit_test(
    casino: &Casino, 
    lounge: &mut Lounge,
    game_table_id: ID, 
    ctx: &mut TxContext
  ) {
    exit(casino, lounge, game_table_id, ctx);
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    debug::print(game_table);
  }

  #[test_only]
  public fun ante_test(
    casino: &Casino,
    lounge: &mut Lounge,
    game_table_id: ID,
    ctx: &mut TxContext,
  ) : ID {
    ante(casino, lounge, game_table_id, ctx);
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    debug::print(game_table);
    
    return game_table.id()
  }

  #[test_only]
  public fun start_test(
    casino: &Casino, 
    lounge: &mut Lounge,
    game_table_id: ID, 
    ctx: &mut TxContext,
  ) : ID {
    start(casino, lounge, game_table_id, ctx);
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    debug::print(game_table);

    return game_table.id()
  }

  #[test_only]
  public fun action_test(
    casino: &Casino, 
    lounge: &mut Lounge,
    game_table_id: ID,
    action_type: u8, // ante, check, bet, call, raise
    chip_count: u64,
    ctx: &mut TxContext,
  ) : ID {
    action(casino, lounge, game_table_id, action_type, chip_count, ctx);
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    debug::print(game_table);
      
    return game_table.id()
  }
}