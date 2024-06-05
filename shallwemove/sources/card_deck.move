module shallwemove::card_deck {
  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::utils;
  use shallwemove::encrypt;
  use shallwemove::game_status::{Self, GameStatus};
  use sui::random::{Self, Random};
  use std::string::{Self, String};
  use std::debug;
  
  // ============================================
  // ============== STRUCTS =====================
  
  public struct CardDeck has key, store {
    id : UID,
    avail_cards : vector<Card>,
    used_cards : vector<Card>
  }

  public struct Card has key, store {
    id : UID,
    index : u8,
    card_number : u256,
    card_number_for_user : u256
  }

  // ============================================
  // ============== FUNCTIONS ===================

  public fun new(public_key : vector<u8>, ctx : &mut TxContext) : CardDeck {
    CardDeck {
      id : object::new(ctx),
      avail_cards : vector[],
      used_cards : vector[],
    }
  }

  // ===================== Methods ===============================
  // --------- CardDeck ---------

  public fun id(card_deck : &CardDeck) : ID {object::id(card_deck)}

  public fun fill_cards(card_deck : &mut CardDeck, game_status : &mut GameStatus, casino_public_key : vector<u8>, r: &Random, ctx : &mut TxContext) {
    let mut card_numbers_array : vector<u256> = utils::get_52_numbers_array();
    // 한 번 섞기
    utils::shuffle(&mut card_numbers_array, r, ctx);

    // encrypted 된 숫자로 card 생성
    let casino_n = encrypt::convert_vec_u8_to_u256(casino_public_key);
    let mut i = 0;
    while (i < card_numbers_array.length()) {
      let card = Card {
        id : object::new(ctx),
        index : (i as u8),
        card_number : encrypt::encrypt_256(casino_n, card_numbers_array[i]),
        card_number_for_user : encrypt::encrypt_256(casino_n, card_numbers_array[i])
      };

      card_deck.avail_cards.push_back(card);
      game_status.add_card();

      i = i + 1;
    };
  }

  public fun add_used_card(card_deck : &mut CardDeck, card : Card) {
    card_deck.used_cards.push_back(card);
  }

  public fun draw_card(card_deck : &mut CardDeck, casino_public_key : vector<u8>) : Card {
    let mut card = card_deck.avail_cards.pop_back();
    decrypt_card_number_for_user(&mut card, casino_public_key);
    card
  }

  // --------- Card ---------

  fun card_id(card : &Card) : ID {object::id(card)}

  fun card_index(card : &Card) : u8 {card.index}

  public fun card_number(card : &Card) : u256 {card.card_number}

  fun card_number_for_user(card : &Card) : u256 {card.card_number_for_user}

  public fun encrypt_card_number_for_user(card : &mut Card, user_public_key : vector<u8>) {
    let user_n = encrypt::convert_vec_u8_to_u256(user_public_key);
    card.card_number_for_user = encrypt::encrypt_256(user_n, card.card_number_for_user);
  }

  public fun decrypt_card_number(card : &mut Card, casino_public_key : vector<u8>) {
    let casino_n = encrypt::convert_vec_u8_to_u256(casino_public_key);
    card.card_number = encrypt::decrypt_256(casino_n, card.card_number);
  }

  public fun decrypt_card_number_for_user(card : &mut Card, casino_public_key : vector<u8>) {
    let casino_n = encrypt::convert_vec_u8_to_u256(casino_public_key);
    card.card_number_for_user = encrypt::decrypt_256(casino_n, card.card_number_for_user);
  }

  // ============================================
  // ================ TEST ======================
  #[test_only]
  public fun fill_cards_for_testing(card_deck : &mut CardDeck, game_status : &mut GameStatus, casino_public_key : vector<u8>, ctx : &mut TxContext) {
    let mut card_numbers_array : vector<u256> = utils::get_52_numbers_array();
    // 한 번 섞기
    utils::shuffle_for_testing(&mut card_numbers_array, ctx);

    // encrypted 된 숫자로 card 생성
    let casino_n = encrypt::convert_vec_u8_to_u256(casino_public_key);
    let mut i = 0;
    while (i < card_numbers_array.length()) {
      let card = Card {
        id : object::new(ctx),
        index : (i as u8),
        card_number : encrypt::encrypt_256(casino_n, card_numbers_array[i]),
        card_number_for_user : encrypt::encrypt_256(casino_n, card_numbers_array[i])
      };

      card_deck.avail_cards.push_back(card);
      game_status.add_card();

      i = i + 1;
    };
  }


}