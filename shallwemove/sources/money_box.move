module shallwemove::money_box {
  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::player_seat::{Self, PlayerSeat};
  use shallwemove::player_info::{Self, PlayerInfo};
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
  
  public fun money(money_box : &MoneyBox) : &vector<Coin<SUI>> {
    &money_box.money
  }
  
  public fun money_mut(money_box : &mut MoneyBox) : &mut vector<Coin<SUI>> {
    &mut money_box.money
  }

  public fun add_money(money_box : &mut MoneyBox, money : Coin<SUI>) {
    vector::push_back(&mut money_box.money, money);
  }

  public fun send_all_money(money_box : &mut MoneyBox, player_seat : &mut PlayerSeat, player_info : &mut PlayerInfo) {
    let mut i = money_box.money.length();
    while (i > 0) {
      let money = money_box.money.pop_back();
      // MoneyBoxInfo의 total bet amount 도 감소시켜 줘야지...ㅜ
      player_seat.add_money(player_info, money);
      i = i - 1;
    };


  }

}