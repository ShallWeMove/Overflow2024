module shallwemove::cardgame {
  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::casino::{Self, Casino};
  use shallwemove::lounge::{Self, Lounge};
  use shallwemove::game_table::{Self, GameTable};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use std::debug;
  use std::string::{Self};

  // ======================= Errors ==============================

  const ERROR1 : u8 = 100; // example of error codex

  // ============================================
  // ============== FUNCTIONS ===================

  fun init(ctx: &mut TxContext) {
  }

  // ====================== Entry Functions ======================

  // --------- For Game Owner ---------

  // This function will be executed in the Backend
  // game owner or anyone who wanna be a game owner can create new game
  // Casino object is essential to play game
  entry fun create_casino(public_key : vector<u8>, ctx: &mut TxContext) {
    casino::create(public_key, ctx);
  }

  entry fun create_lounge(casino : &Casino, ctx: &mut TxContext) {
    lounge::create(casino, ctx);
  }

  entry fun add_game_table(
    casino : &Casino, 
    lounge : &mut Lounge, 
    ante_amount : u64, 
    bet_unit : u64, 
    game_seats : u8, 
    ctx : &mut TxContext) {
    assert!(casino.admin() == tx_context::sender(ctx), 403);

    let game_table = game_table::new(lounge.id(), casino.public_key(), ante_amount, bet_unit, game_seats, ctx);

    lounge.add_game_table(game_table);
  }

  #[test_only]
  public fun add_game_table_test(
    casino : &Casino, 
    lounge : &mut Lounge, 
    ante_amount : u64, 
    bet_unit : u64, 
    game_seats : u8, 
    ctx : &mut TxContext) {
      add_game_table(casino, lounge, ante_amount, bet_unit, game_seats, ctx);
    }

  // --------- For Player ---------

  // 게임 입장
  entry fun enter(
    casino : &Casino, 
    lounge : &mut Lounge, 
    public_key : vector<u8>,
    deposit : Coin<SUI>,
    ctx : &mut TxContext) : ID {
      //casino id 와 lounge의 casino id가 같은지 체크
      assert!(casino.id() == lounge.casino_id(), 403);

      // deposit은 일정량 이상으로 -> game_table의 bet_unit의 20배..? -> 일단 테스트를 위해서 보류

      // available한 GameTable 가져온다
      let mut available_game_table_id = lounge.available_game_table_id();
      assert!(available_game_table_id != option::none());

      // player를 GameTable에 참여 시킨다.
      let avail_game_table = lounge.borrow_mut_game_table(option::extract(&mut available_game_table_id));
      avail_game_table.enter_player(public_key, deposit, ctx);

      debug::print(&string::utf8(b"=========================== ENTER =========================="));
      debug::print(avail_game_table);
      return avail_game_table.id()
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

  // 게임 퇴장
  entry fun exit(
    casino: &Casino, 
    lounge: &mut Lounge, // 필요 없을 수도 => 무조건 필요함... parent에서 접근해야 함
    game_table: &GameTable, 
    ctx: &mut TxContext
  ) {
    assert!(casino.id() == lounge.casino_id(), 403);
    assert!(lounge.id() == game_table.lounge_id(), 403);

    let game_table = lounge.borrow_mut_game_table(game_table.id());
    
    game_table.exit_player(ctx);
  }

  #[test_only]
  public fun exit_test(
    casino: &Casino, 
    lounge: &mut Lounge, // 필요 없을 수도 => 무조건 필요함... parent에서 접근해야 함
    game_table_id: ID, 
    ctx: &mut TxContext
  ) {
    assert!(casino.id() == lounge.casino_id(), 403);
  
    let lounge_id = lounge.id();
    let game_table = lounge.borrow_mut_game_table(game_table_id);
    assert!(lounge_id == game_table.lounge_id(), 403);
    
    game_table.exit_player(ctx);
    debug::print(&string::utf8(b"=========================== EXIT =========================="));
    debug::print(game_table);
  }


  // 최초 게임 시작 시 내는 돈. 게임 준비 상태 전환.
  entry fun ante(
    casino: &Casino,
    lounge: &mut Lounge,
    game_table: &mut GameTable,
    ctx: &mut TxContext,
  ) : ID {
    assert!(casino.id() == lounge.casino_id(), 403);
    assert!(lounge.id() == game_table.lounge_id(), 403);

    let game_table = lounge.borrow_mut_game_table(game_table.id());

    game_table.ante(ctx);
    
    return game_table.id()
  }

  // 게임 시작
  entry fun start(
    casino: &Casino, 
    lounge: &mut Lounge,
    game_table: &GameTable, 
    ctx: &mut TxContext,
  ) : ID {
    assert!(casino.id() == lounge.casino_id(), 403);
    assert!(lounge.id() == game_table.lounge_id(), 403);
    
    let game_table = lounge.borrow_mut_game_table(game_table.id());

    assert!(game_table.game_status().manager_player() != option::none(), 403);
    assert!(game_table.game_status().is_manager_player(ctx), 403);
    // assert!(tx_context::sender(ctx) == option::extract(&mut game_table.game_status().manager_player()), 403);
    
    game_table.start();

    return game_table.id()
  }


  // 플레이어 콜 => 마지막 턴의 액션이면 Move에서 알아서 게임 종료해줌
  entry fun action(
    casino: &Casino, 
    game_table: &mut GameTable,
    // action_type: ActionType, // ante(요건 없애야 할 듯), check, bet, call, raise
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

}