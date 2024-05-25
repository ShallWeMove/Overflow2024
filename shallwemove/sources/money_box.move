module shallwemove::money_box {
  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::player_seat::{Self, PlayerSeat};
  use sui::coin::{Self, Coin};
  use sui::sui::SUI;

  // ============================================
  // ============== STRUCTS =====================

  public struct MoneyBox has key, store {
    id : UID,
    money : vector<Coin<SUI>>
  }
  // ============================================
  // ============== FUNCTIONS ===================

  public fun new(ctx : &mut TxContext) : MoneyBox {
    MoneyBox {
      id : object::new(ctx),
      money : vector[]
    }
  }

  // ===================== Methods ===============================

  fun id(money_box : &MoneyBox) : ID {object::id(money_box)}

  public fun add_money(money_box : &mut MoneyBox, money : Coin<SUI>) {
    vector::push_back(&mut money_box.money, money);
  }

  public fun send_all_money(money_box : &mut MoneyBox, player_seat : &mut PlayerSeat) {
    let mut i = money_box.money.length();
    while (i > 0) {
      let money = money_box.money.pop_back();
      player_seat.add_money(money);
      i = i - 1;
    };


  }

}