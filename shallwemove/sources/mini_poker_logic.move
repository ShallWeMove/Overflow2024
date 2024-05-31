module shallwemove::mini_poker_logic {

  // ============================================
  // ============= IMPORTS ======================

  use std::string::{Self, String};
  use std::debug;
  use sui::math;

  // ============================================
  // ============== CONSTANTS ===================
  
  const PAIR : u64 = 400_000_000;
  const STRAIGHT : u64 = 300_000_000;
  const FLUSH : u64 = 200_000_000;
  const NUMBER_SCORE_BASE : u64 = 4;


  public fun convert_card_combination_to_score(card_number1 : u256, card_number2 : u256 ) : u64 {
    assert!(card_number1 < 52 && card_number2 < 52, 500);
    assert!(card_number1 != card_number2 , 501);
    let mut combination_score : u64 = 0;
    let mut number_score : u64 = 0;
    let mut shape_score : u64 = 0;
    let mut has_combination = false;
    
    // PAIR
    if (card_number1 % 13 == card_number2 % 13) {
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
    if (card_number1 / 13 == card_number2 / 13) {
      // combination score
      combination_score = combination_score + FLUSH;
      has_combination = true;
      // number score
      if (card_number1 % 13 > card_number2 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number1 % 13 + 1) as u8);
      } else if (card_number2 % 13 > card_number1 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number2 % 13 + 1) as u8);
      };
    };

    if (!has_combination) {
      // number score
      if (card_number1 % 13 > card_number2 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number1 % 13 + 1) as u8);
      } else if (card_number2 % 13 > card_number1 % 13) {
        number_score = number_score + math::pow(NUMBER_SCORE_BASE, (card_number2 % 13 + 1) as u8);
      };
    };

    // shape score
    if (card_number1 / 13 > card_number2 / 13) {
      shape_score = shape_score + (card_number1 as u64) / 13 ;
    } else if (card_number2 / 13 > card_number1 / 13) {
      shape_score = shape_score + (card_number2 as u64) / 13;
    };

    let total_score = combination_score + number_score + shape_score;

    total_score as u64
  }

  // ============================================
  // ================ TEST ======================

  #[test]
  fun test_mini_poker_logic() {
    debug::print(&string::utf8(b"===================================================== POCKER LOGIC TEST ===================================================="));
    // 0~12 : spade / 13~25 : diamond / 26~38 : heart / 39~51 : clover
    // card_number % 13 = 
      // 0 -> 2
      // 1 -> 3
      // ...
      // 11 -> K
      // 12 -> A
    let card_number1 = 0;
    let card_number2 = 51;
    let score = convert_card_combination_to_score(card_number1, card_number2);

    let card_number3 = 37;
    let card_number4 = 25;
    let score = convert_card_combination_to_score(card_number3, card_number4);
  }
  
}