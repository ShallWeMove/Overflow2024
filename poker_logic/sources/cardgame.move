module poker_logic::cardgame {
  use shallwemove::cardgame::{Self};
  use shallwemove::casino::{Self, Casino};
  use shallwemove::lounge::{Self, Lounge};
  use shallwemove::game_table::{Self, GameTable};
  use shallwemove::game_status::{Self, GameStatus};
  use poker_logic::poker_logic::{Self};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use std::debug;
  use sui::random::{Self, Random};
  use std::string::{Self};

  // Enter game
  entry fun enter(
  casino : &Casino, 
  lounge : &mut Lounge, 
  public_key : vector<u8>,
  deposit : Coin<SUI>,
  ctx : &mut TxContext) : ID {
    cardgame::enter(casino, lounge, public_key, deposit, ctx)
  }

  // Exit game
  entry fun exit(
    casino: &Casino, 
    lounge: &mut Lounge, // It's necessary to access from parent
    game_table_id: ID, 
    ctx: &mut TxContext
  ) {

    let finish_case = cardgame::exit(casino, lounge, game_table_id, ctx);
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    if (finish_case == game_table::CONST_FINISH_GAME_CASE()) {
      poker_logic::finish_game(game_table, ctx);
    };
  }

  // Money you pay at the start of the game.
  // transition status to game ready
  entry fun ante(
    casino: &Casino,
    lounge: &mut Lounge,
    game_table_id: ID,
    ctx: &mut TxContext,
  ) : ID {
    cardgame::ante(casino, lounge, game_table_id, ctx)
  }

  // Start game
  entry fun start(
    casino: &Casino, 
    lounge: &mut Lounge,
    game_table_id: ID,
    ctx: &mut TxContext,
  ) : ID {
    cardgame::start(casino, lounge, game_table_id, ctx)
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
  ) {
    let finish_case = cardgame::action(casino, lounge, game_table_id, action_type, chip_count, ctx);
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    if (finish_case == game_table::CONST_FINISH_GAME_CASE()) {
      poker_logic::finish_game(game_table, ctx);
    };
  }

  // Get a settlement (The winner must call the transaction at the end of the game)
  entry public fun settle_up(
    casino: &Casino, 
    lounge: &mut Lounge,
    game_table_id: ID,
    r : &Random,
    ctx: &mut TxContext,
  ) : ID {
    cardgame::settle_up(casino, lounge, game_table_id, r, ctx)
  }
}