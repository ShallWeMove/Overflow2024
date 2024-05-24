module shallwemove::lounge {

  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::casino::{Self, Casino};
  use shallwemove::game_table::{Self, GameTable};
  use sui::dynamic_object_field;
  use std::string::{Self, String};
  use std::debug;
  use std::option::{Self, Option};

  // ============================================
  // ============== STRUCTS =====================

  // public struct Lounge has key {
  public struct Lounge has key, store { //for test
    id: UID,
    casino_id : ID,
    game_tables : vector<ID>
  }

  // ============================================
  // ============== FUNCTIONS ===================

  public fun create(casino : &Casino, ctx: &mut TxContext) {
    assert!(casino.admin() == tx_context::sender(ctx), 403);

    transfer::share_object(Lounge{
      id : object::new(ctx),
      // casino_id : object::id(casino),
      casino_id : casino.id(),
      game_tables : vector[]
    });
  }

  public fun new(casino : &Casino, ctx : &mut TxContext) : Lounge {
    Lounge{
      id : object::new(ctx),
      casino_id : casino.id(),
      game_tables : vector[]
    }
  }

  // ===================== Methods ===============================
  public fun delete(lounge : Lounge) {
    let Lounge {id : lounge_id, casino_id : _, game_tables : _} = lounge;
    object::delete(lounge_id);
  }
  
  public fun id(lounge : &Lounge) : ID {object::id(lounge)}

  public fun casino_id(lounge : &Lounge) : ID {lounge.casino_id}

  public fun borrow_game_table(lounge: &Lounge, game_table_id : ID) : &GameTable {
    dynamic_object_field::borrow<ID, GameTable> (&lounge.id, game_table_id)
  }

  public fun borrow_mut_game_table(lounge: &mut Lounge, game_table_id : ID) : &mut GameTable {
    dynamic_object_field::borrow_mut<ID, GameTable> (&mut lounge.id, game_table_id)
  }

  public fun add_game_table(lounge : &mut Lounge, game_table : GameTable) {
    lounge.game_tables.push_back(game_table.id());
    dynamic_object_field::add<ID, GameTable>(&mut lounge.id, game_table.id(), game_table);
  }

  public fun available_game_table_id(lounge : &Lounge) : Option<ID> {
    let mut game_tables = lounge.game_tables;

    while (!game_tables.is_empty()) {
      let game_table_id = game_tables.pop_back();
      let game_table = dynamic_object_field::borrow<ID, GameTable> (&lounge.id, game_table_id);
      if (game_table.game_status().avail_game_seats() > 0) {
        debug::print(&string::utf8(b"게임을 찾았다!"));
        return option::some(game_table_id)
      };
    };

    return option::none()
  }

  // ============================================
  // ================ TEST ======================
}