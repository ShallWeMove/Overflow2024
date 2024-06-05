#[test_only]
module shallwemove::shallwemove_tests {
  // uncomment this line to import the module
  use shallwemove::cardgame;
  use shallwemove::casino::{Self, Casino};
  use shallwemove::lounge::{Self, Lounge};
  use shallwemove::player_info::{Self, PlayerInfo};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;
  use std::debug;
  use std::string::{Self};
  use sui::random::{Self, Random};

  const ENotImplemented: u64 = 0;

    // #[test]
    // fun test_shallwemove() {
    //     // pass
    // }

    // #[test, expected_failure(abort_code = shallwemove::shallwemove_tests::ENotImplemented)]
    // fun test_shallwemove_fail() {
    //     abort ENotImplemented
    // }
  // ============================================
  // ================ TEST ======================
  // ============================================
  #[test_only] 
  use sui::test_scenario;

  #[test_only] 
  fun create_game() : (Casino, Lounge) {
    let mut ts = test_scenario::begin(@0xA);
    let ctx = test_scenario::ctx(&mut ts);

    let public_key = vector<u8>[48,55,53,51,52,49];
    let casino = casino::new(public_key, ctx);
    let mut lounge = lounge::new(&casino, 3, ctx);

    cardgame::add_game_table_test(&casino, &mut lounge, 5, 5, 3, ctx);

    test_scenario::end(ts);
    (casino, lounge)
  }

  #[test_only] 
  fun remove_game(casino : Casino, lounge : Lounge) {
    casino.delete();
    lounge.delete();
  }

  #[test]
  fun test_enter_exit() {
    let mut ts1 = test_scenario::begin(@0xA);
    let mut ts2 = test_scenario::begin(@0xB);
    let mut ts3 = test_scenario::begin(@0xC);
    let ctx1 = test_scenario::ctx(&mut ts1);
    let ctx2 = test_scenario::ctx(&mut ts2);
    let ctx3 = test_scenario::ctx(&mut ts3);
    let deposit1 = coin::mint_for_testing<SUI>(50000, ctx1);
    let deposit2 = coin::mint_for_testing<SUI>(50000, ctx2);
    let deposit3 = coin::mint_for_testing<SUI>(50000, ctx3);

    debug::print(&string::utf8(b"===================================================== CREATE GAME ===================================================="));
    let (casino, mut lounge) = create_game();
    
    let user_public_key = vector<u8>[23,124,1,23,53,63,22];

    debug::print(&string::utf8(b"===================================================== 1 ENTER ===================================================="));
    let game_table_id = cardgame::enter_test(&casino, &mut lounge, user_public_key, deposit1, ctx1);
    debug::print(&string::utf8(b"===================================================== 2 ENTER ===================================================="));
    let game_table_id = cardgame::enter_test(&casino, &mut lounge, user_public_key, deposit2, ctx2);
    debug::print(&string::utf8(b"===================================================== 3 ENTER ===================================================="));
    let game_table_id = cardgame::enter_test(&casino, &mut lounge, user_public_key, deposit3, ctx3);

    // debug::print(&string::utf8(b"===================================================== 1 ANTE ===================================================="));
    // cardgame::ante_test(&casino, &mut lounge, game_table_id, ctx1);
    // debug::print(&string::utf8(b"===================================================== 2 ANTE ===================================================="));
    // cardgame::ante_test(&casino, &mut lounge, game_table_id, ctx2);
    // debug::print(&string::utf8(b"===================================================== 3 ANTE ===================================================="));
    // cardgame::ante_test(&casino, &mut lounge, game_table_id, ctx3);

    // debug::print(&string::utf8(b"===================================================== START ===================================================="));
    // cardgame::start_test(&casino, &mut lounge, game_table_id, ctx1);
    // // // cardgame::start_test(&casino, &mut lounge, game_table_id, ctx2);

    // debug::print(&string::utf8(b"===================================================== 1-1 BET ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_BET(), 0, ctx1);
    // debug::print(&string::utf8(b"===================================================== 1-2 CALL ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_CALL(), 0, ctx2);
    // debug::print(&string::utf8(b"===================================================== 1-3 CALL ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_CALL(), 0, ctx3);

    // debug::print(&string::utf8(b"===================================================== 2-1 CHECK ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_CHECK(), 0, ctx1);
    // debug::print(&string::utf8(b"===================================================== 2-2 CHECK ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_CHECK(), 0, ctx2);
    // debug::print(&string::utf8(b"===================================================== 2-3 BET ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_BET(), 0, ctx3);
    // debug::print(&string::utf8(b"===================================================== 2-1 CALL ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_CALL(), 0, ctx1);
    // debug::print(&string::utf8(b"===================================================== 2-2 CALL ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_CALL(), 0, ctx2);

    // debug::print(&string::utf8(b"===================================================== 3-3 BET ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_BET(), 0, ctx3);
    // debug::print(&string::utf8(b"===================================================== 3-1 FOLD ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_FOLD(), 0, ctx1);
    // debug::print(&string::utf8(b"===================================================== 3-2 RAISE ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_RAISE(), 1, ctx2);
    // debug::print(&string::utf8(b"===================================================== 3-3 RAISE ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_RAISE(), 2, ctx3);
    // debug::print(&string::utf8(b"===================================================== 3-2 RAISE ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_RAISE(), 3, ctx2);
    // debug::print(&string::utf8(b"===================================================== 3-3 CALL ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_CALL(), 0, ctx3);
    
    // debug::print(&string::utf8(b"===================================================== 4-2 BET ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_BET(), 0, ctx2);
    // debug::print(&string::utf8(b"===================================================== 4-3 RAISE ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_RAISE(), 1, ctx3);
    // debug::print(&string::utf8(b"===================================================== 4-1 EXIT ===================================================="));
    // cardgame::exit_test(&casino, &mut lounge, game_table_id, ctx1);
    // debug::print(&string::utf8(b"===================================================== 4-2 RAISE ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_RAISE(), 2, ctx2);
    // debug::print(&string::utf8(b"===================================================== 4-3 FOLD ===================================================="));
    // cardgame::action_test(&casino, &mut lounge, game_table_id, player_info::CONST_FOLD(), 0, ctx3);

    debug::print(&string::utf8(b"===================================================== 1 EXIT ===================================================="));
    cardgame::exit_test(&casino, &mut lounge, game_table_id, ctx1);
    debug::print(&string::utf8(b"===================================================== 2 EXIT ===================================================="));
    cardgame::exit_test(&casino, &mut lounge, game_table_id, ctx2);
    debug::print(&string::utf8(b"===================================================== 3 EXIT ===================================================="));
    cardgame::exit_test(&casino, &mut lounge, game_table_id, ctx3);

    remove_game(casino, lounge);
    test_scenario::end(ts1);
    test_scenario::end(ts2);
    test_scenario::end(ts3);
  }

  // #[test]
  // fun test_game_table() {
  //     let mut ts = test_scenario::begin(@0xA);
  //   let ctx = test_scenario::ctx(&mut ts);
  //   let coin = coin::mint_for_testing<SUI>(50000, ctx);

  //   let (casino, mut lounge) = create_game();

  //   create_and_add_game_table(&casino, &mut lounge, 5,5,5, ctx);
  //   // create_and_add_game_table(&casino, &mut lounge, 5,5,6, ctx);


  //   let mut game_tables = lounge.game_tables();
  //   // debug::print(&string::utf8(b"game tables : "));
  //   // debug::print(&game_tables);

  //   let game_table_id = game_tables.pop_back();
  //   let game_table = dynamic_object_field::borrow_mut<ID, GameTable> (&mut lounge.id, game_table_id);

  //   game_table.enter_player(vector<u8>[2,3,31,31,42,33], coin, ctx);

  //   // debug::print(&game_table.game_status.player_infos);
  //   // debug::print(&game_table.player_seats);

  //   // let mut i = 1;
  //   // while (i < game_tables.length() + 1) {
  //   //   let game_table_id = game_tables.pop_back();
  //   //   let game_table = dynamic_object_field::borrow_mut<ID, GameTable> (&mut lounge.id, game_table_id);


  //   //   // game_table.enter_player(vector<u8>[2,3,31,31,42,33], coin, ctx);
      
  //   //   debug::print(&game_table.game_status.player_infos);
  //   //   debug::print(&game_table.player_seats);

  //   //   i = i + 1;
  //   // };



  //   remove_game(casino, lounge, ctx);
  //   test_scenario::end(ts);

  // }

  // #[test]
  // fun test_exit() {
  //   let mut ts = test_scenario::begin(@0xA);
  //   let ctx = test_scenario::ctx(&mut ts);

  //   let (casino, mut lounge) = create_game();

  //   create_and_add_game_table(&casino, &mut lounge, 5,5,5, ctx);

  //   let coin = coin::mint_for_testing<SUI>(50000, ctx);


  //   enter(&casino, &mut lounge, vector<u8>[67,58], coin, ctx);


  //   let mut game_tables = lounge.game_tables();
  //   // debug::print(&string::utf8(b"game tables : "));
  //   // debug::print(&game_tables);

  //   let game_table_id = game_tables.pop_back();
  //   // let game_table = dynamic_object_field::borrow<ID, GameTable> (&lounge.id, game_table_id);

  //   // exit(&casino, &mut lounge, game_table, ctx);

  //   debug::print(&string::utf8(b"exit!"));

  //   // let game_table_id = lounge.avail_game_table();
  //   // debug::print(&game_table_id);


  //   remove_game(casino, lounge, ctx);
  //   test_scenario::end(ts);

  // }


  // #[test]
  // fun test_vector() {
  //   let mut u64_vector = vector<u64> [0, 1, 2, 3];
  //   let element = u64_vector.remove(0);
  //   debug::print(&element);
  //   debug::print(&u64_vector.remove(0));
  // }


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
}