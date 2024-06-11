/// Module: poker_logic
module three_cards_poker::three_cards_poker {
  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::random::{Self};
  use shallwemove::utils::{Self};
  use shallwemove::game_table::{Self, GameTable};
  use shallwemove::encrypt::{Self};
  use sui::random::{Random};
  use std::debug;
  use std::string::{Self};
  use sui::math;
  
  // ============================================
  // ============== CONSTANTS ===================
  
  const TRIPLE : u64 = 400_000_000;
  const STRAIGHT : u64 = 300_000_000;
  const FLUSH : u64 = 200_000_000;
  const PAIR : u64 = 100_000_000;
  const NUMBER_SCORE_BASE : u64 = 4;

  entry fun test(r: &Random, ctx: &mut TxContext) {
    // random::random_test(r, ctx);
    let array = utils::get_52_numbers_array();
  }

  public fun finish_game(game_table : &mut GameTable, ctx : &mut TxContext) {
    let finish_case = game_table::finish_game(game_table, ctx);
    if (finish_case == game_table::CONST_FINISH_CASE_1()) {
      game_table::finish_game_case_1(game_table, ctx);
    } else if (finish_case == game_table::CONST_FINISH_CASE_2()) {
      game_table::finish_game_case_2(game_table, ctx);
    } else if (finish_case == game_table::CONST_FINISH_CASE_3()) {
      let winner_player_index = find_winner_index(game_table);
      let winner_player_player_address = game_table.game_status().player_infos().borrow(winner_player_index).player_address();
      game_table.game_status_mut().set_winner_player(winner_player_player_address);
      game_table.after_finish_game_case(ctx);

    }
  }

  fun find_winner_index(game_table : &mut GameTable) : u64 {
    let mut i = 0;
    let mut highest_score = 0;
    let mut highest_score_player_index = 0;
    while (i < game_table.player_seats().length()) {
      let player_seat = game_table.player_seats_mut().borrow_mut(i);
      if (player_seat.player_address() == option::none()) {
        i = i + 1;
        continue
      };

      let card1 = player_seat.cards().borrow(0);
      let card2 = player_seat.cards().borrow(1);
      let card3 = player_seat.cards().borrow(2);

      let casino_n = encrypt::convert_vec_u8_to_u256(game_table.casino_public_key());
      let decrypted_card_number1 = encrypt::decrypt_256(casino_n, card1.card_number());
      let decrypted_card_number2 = encrypt::decrypt_256(casino_n, card2.card_number());
      let decrypted_card_number3 = encrypt::decrypt_256(casino_n, card3.card_number());

      if (highest_score == 0) {
        highest_score = get_card_combination_score(decrypted_card_number1, decrypted_card_number2, decrypted_card_number3);
      };

      if (highest_score < get_card_combination_score(decrypted_card_number1, decrypted_card_number2, decrypted_card_number3)) {
        highest_score = get_card_combination_score(decrypted_card_number1, decrypted_card_number2, decrypted_card_number3);
        highest_score_player_index = i;
      };

      i = i + 1;
    };

    return highest_score_player_index
  }

    fun get_card_combination_score(card_number1 : u256, card_number2 : u256, card_number3 : u256 ) : u64 {
    assert!(card_number1 < 52 && card_number2 < 52 && card_number3 < 52, 500);
    assert!(card_number1 != card_number2 , 501);
    assert!(card_number2 != card_number3 , 501);
    assert!(card_number3 != card_number1 , 501);
    let mut combination_score : u64 = 0;
    let mut number_score : u64 = 0;
    let mut shape_score : u64 = 0;
    let mut has_combination = false;
    
    // TRIPLE
    if (card_number1 % 13 == card_number2 % 13 && card_number2 % 13 == card_number3 % 13) {
      // combination score
      combination_score = combination_score + TRIPLE;
      has_combination = true;
      // number score
      number_score = number_score + math::pow(NUMBER_SCORE_BASE ,(card_number1 % 13 + 1) as u8);
    } 
    // PAIR
    else if (card_number1 % 13 == card_number2 % 13 || card_number2 % 13 == card_number3 % 13 || card_number1 % 13 == card_number3 % 13) {
      // combination score
      combination_score = combination_score + PAIR;
      has_combination = true;
      // number score
      number_score = number_score + math::pow(NUMBER_SCORE_BASE ,(card_number1 % 13 + 1) as u8);
    };

    // STRAIGHT
    if (card_number1 % 13 > card_number2 % 13  ) {
      if (card_number1 % 13 - card_number2 % 13 == 1 || card_number1 % 13 - card_number2 % 13 == 12) {
        // combination score
        combination_score = combination_score + STRAIGHT;
        has_combination = true;
        // number score
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number1 % 13 + 1) as u8);
      };
    } else if (card_number2 % 13  > card_number1 % 13){
      if (card_number2 % 13 - card_number1 % 13 == 1 || card_number2 % 13 - card_number1 % 13 == 12) {
        // combination score
        combination_score = combination_score + STRAIGHT;
        has_combination = true;
        // number score
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number2 % 13 + 1) as u8);
      };
    };

    // FLUSH
    if (card_number1 / 13 == card_number2 / 13 && card_number2 / 13 == card_number3 / 13) {
      // combination score
      combination_score = combination_score + FLUSH;
      has_combination = true;
      // number score
      if (card_number1 % 13 > card_number2 % 13 && card_number1 % 13 > card_number3 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number1 % 13 + 1) as u8);
      } else if (card_number2 % 13 > card_number1 % 13 && card_number2 % 13 > card_number3 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number2 % 13 + 1) as u8);
      } else if (card_number3 % 13 > card_number1 % 13 && card_number3 % 13 > card_number2 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number3 % 13 + 1) as u8);
      };
    };

    if (!has_combination) {
      // number score
      if (card_number1 % 13 >= card_number2 % 13 && card_number1 % 13 >= card_number3 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number1 % 13 + 1) as u8);
      } else if (card_number2 % 13 >= card_number1 % 13 && card_number2 % 13 >= card_number3 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number2 % 13 + 1) as u8);
      } else if (card_number3 % 13 >= card_number1 % 13 && card_number3 % 13 >= card_number2 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number3 % 13 + 1) as u8);
      };
    };

    // shape score
    if (card_number1 / 13 >= card_number2 / 13 && card_number1 / 13 >= card_number3 / 13) {
      shape_score = shape_score + (card_number1 as u64) / 13 ;
    } else if (card_number2 / 13 >= card_number1 / 13 && card_number2 / 13 >= card_number3 / 13) {
      shape_score = shape_score + (card_number2 as u64) / 13;
    } else if (card_number3 / 13 >= card_number1 / 13 && card_number3 / 13 >= card_number2 / 13) {
      shape_score = shape_score + (card_number3 as u64) / 13;
    };

    let total_score = combination_score + number_score + shape_score;

    total_score as u64
  }



  #[test]
  fun test_test() {
    let array = utils::get_52_numbers_array();
    debug::print(&array);


  }



  

}
