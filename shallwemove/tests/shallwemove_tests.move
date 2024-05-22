#[test_only]
module shallwemove::shallwemove_tests {
    // uncomment this line to import the module
    use shallwemove::cardgame;

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

  // #[test_only] 
  // fun create_game() : (Casino, Lounge) {
  //   let mut ts = test_scenario::begin(@0xA);
  //   let ctx = test_scenario::ctx(&mut ts);

  //   let public_key = vector<u8>[11,2,3,1,12,31,3,12,1];
  //   let casino = Casino {
  //     id : object::new(ctx),
  //     admin: tx_context::sender(ctx),
  //     public_key : public_key
  //   };
  //   let mut lounge = Lounge {
  //     id : object::new(ctx),
  //     casino_id : casino.id(),
  //     game_tables : vector[]

  //   };

  //   create_and_add_game_table(&casino, &mut lounge, 5, 5, 5, ctx);

  //   test_scenario::end(ts);

  //   (casino, lounge)
  // }

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

  // #[test_only] 
  // fun remove_game(casino : Casino, lounge : Lounge, ctx : &mut TxContext) {
  //   let Casino {id : casino_id, admin : _, public_key : _} = casino;
  //   object::delete(casino_id);

  //   let sender = tx_context::sender(ctx);
  //   transfer::public_transfer(lounge, sender);

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