module shallwemove::casino {

  // ============================================
  // ============= IMPORTS ======================

  // ============================================
  // ============== STRUCTS =====================

  // game object which can create game table
   public struct Casino has key {
    id: UID,
    admin: address,
    public_key: vector<u8>
  }

  // ============================================
  // ============== FUNCTIONS ===================

  public fun create(public_key : vector<u8>, ctx: &mut TxContext) {
    transfer::freeze_object(
      Casino {
      id : object::new(ctx),
      admin: tx_context::sender(ctx),
      public_key : public_key
      });
  }

  // ===================== Methods ===============================

  public fun id(casino : &Casino) : ID {object::id(casino)}

  public fun admin(casino : &Casino) : address {casino.admin}

  public fun public_key(casino : &Casino) : vector<u8> {casino.public_key}

  // ============================================
  // ================ TEST ======================
}