module shallwemove::card_deck {
  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::utils;
  use shallwemove::game_status::{Self, GameStatus};
  use sui::random::{Self, Random};
  
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
    card_number : u256
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

  fun id(card_deck : &CardDeck) : ID {object::id(card_deck)}

  public fun fill_cards(card_deck : &mut CardDeck, game_status : &mut GameStatus, public_key : vector<u8>, r: &Random, ctx : &mut TxContext) {
    // 여기에 encrypt 하고 shuffle 하는 로직이 들어가야 함
    let fifty_two_numbers_array = utils::get_fifty_two_numbers_array();
    let mut encrypted = utils::encrypt(fifty_two_numbers_array, public_key);
    let shuffled_encrypted = utils::shuffle(&mut encrypted, r, ctx);
    let immutable_shuffled_encrypted = &*shuffled_encrypted; // immutable object로 변경하기 위함. mutable 그대로 쓰면 에러 발생.

    let mut i = shuffled_encrypted.length();
    while (i > 0) {
      let card = Card {
        id : object::new(ctx),
        index : (i as u8),
        card_number : *immutable_shuffled_encrypted.borrow(i)
      };

      card_deck.avail_cards.push_back(card);
      game_status.add_card();

      i = i - 1;
    };
  }

  public fun add_used_card(card_deck : &mut CardDeck, card : Card) {
    card_deck.used_cards.push_back(card);
  }

  public fun draw_card(card_deck : &mut CardDeck) : Card {
    card_deck.avail_cards.pop_back()
  }

  // --------- Card ---------

  fun card_id(card : &Card) : ID {object::id(card)}

  fun card_index(card : &Card) : u8 {card.index}

  public fun card_number(card : &Card) : u256 {card.card_number}

  // ============================================
  // ================ TEST ======================

}