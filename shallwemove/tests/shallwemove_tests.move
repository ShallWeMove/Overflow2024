#[test_only]
module shallwemove::shallwemove_tests {
  // uncomment this line to import the module
  use shallwemove::cardgame;
  use shallwemove::casino::{Self, Casino};
  use shallwemove::lounge::{Self, Lounge};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;

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

    let public_key = vector<u8>[11,2,3,1,12,31,3,12,1];
    let casino = casino::new(public_key, ctx);
    let mut lounge = lounge::new(&casino, ctx);

    cardgame::add_game_table_test(&casino, &mut lounge, 5, 5, 5, ctx);

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
    let ctx1 = test_scenario::ctx(&mut ts1);
    let ctx2 = test_scenario::ctx(&mut ts2);
    let deposit1 = coin::mint_for_testing<SUI>(50000, ctx1);
    let deposit2 = coin::mint_for_testing<SUI>(50000, ctx2);

    let (casino, mut lounge) = create_game();
    
    let user_public_key = vector<u8>[23,124,1,23,53,63,22];

    let game_table_id = cardgame::enter_test(&casino, &mut lounge, user_public_key, deposit1, ctx1);
    let game_table_id = cardgame::enter_test(&casino, &mut lounge, user_public_key, deposit2, ctx2);

    cardgame::exit_test(&casino, &mut lounge, game_table_id, ctx1);

    remove_game(casino, lounge);
    test_scenario::end(ts1);
    test_scenario::end(ts2);
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