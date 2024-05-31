module shallwemove::money_box {
  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::player_seat::{Self, PlayerSeat};
  use shallwemove::player_info::{Self, PlayerInfo};
  use shallwemove::game_status::{Self, GameStatus};
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

  public fun bet_money(money_box : &mut MoneyBox, player_info : &mut PlayerInfo, money : Coin<SUI>) {
    let money_value = money.value();
    vector::push_back(&mut money_box.money, money);
    player_info.add_bet_amount(money_value);
  }

  public fun send_all_money(money_box : &mut MoneyBox, player_seat : &mut PlayerSeat, game_status : &mut GameStatus, ctx : &mut TxContext) {
    let mut i = money_box.money.length();
    let mut money_container = coin::zero<SUI>(ctx);
    while (i > 0) {
      let money = money_box.money.pop_back();
      game_status.discard_money(money.value());
      coin::join<SUI>(&mut money_container, money);
      
      i = i - 1;
    };
    let player_info = game_status.player_infos_mut().borrow_mut(player_seat.index() as u64);
    player_seat.add_money(player_info, money_container);


  }

}