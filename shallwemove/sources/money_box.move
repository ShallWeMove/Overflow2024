module shallwemove::money_box {
  // ============================================
  // ============= IMPORTS ======================

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

}