module shallwemove::card_deck {
  // ============================================
  // ============= IMPORTS ======================

  use shallwemove::utils;
  use shallwemove::game_status::{Self, GameStatus};
  
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
    card_number : u8
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

  public fun fill_cards(card_deck : &mut CardDeck, game_status : &mut GameStatus, public_key : vector<u8>, ctx : &mut TxContext) {
    let fifty_two_numbers_array = utils::get_fifty_two_numbers_array();
    let shuffled_fifty_two_numbers_array = utils::shuffle(fifty_two_numbers_array);
    let mut encrypted_fifty_two_numbers_array = utils::encrypt(shuffled_fifty_two_numbers_array, public_key);

    let mut i = encrypted_fifty_two_numbers_array.length();
    while (i > 0) {
      let card = Card {
        id : object::new(ctx),
        index : (i as u8),
        card_number : encrypted_fifty_two_numbers_array.pop_back()
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

  fun card_number(card : &Card) : u8 {card.card_number}

  // ============================================
  // ================ TEST ======================

}