module shallwemove::utils {

  public fun get_fifty_two_numbers_array() : vector<u8> {
    let mut fifty_two_numbers_array = vector<u8>[];
    let mut i = 52;
    while (i > 0) {
      fifty_two_numbers_array.push_back(i);
      i = i - 1;
    };
    fifty_two_numbers_array
  }

  public fun shuffle(number_array : vector<u8>) : vector<u8> {
    // 임시 하드코딩
    vector<u8>[34, 9, 15, 3, 43, 10, 19, 36, 20, 22, 40, 28, 50, 26, 47, 42, 17, 48, 37, 33, 51, 24, 8, 23, 21, 5, 4, 1, 12, 6, 31, 14, 35, 41, 11, 32, 7, 29, 46, 30, 13, 16, 18, 27, 49, 39, 44, 38, 2, 25, 45, 52]
  }

  public fun encrypt(number_array : vector<u8>, public_key : vector<u8>) : vector<u8> {
    // 임시 하드코딩
    vector<u8>[34, 9, 15, 3, 43, 10, 19, 36, 20, 22, 40, 28, 50, 26, 47, 42, 17, 48, 37, 33, 51, 24, 8, 23, 21, 5, 4, 1, 12, 6, 31, 14, 35, 41, 11, 32, 7, 29, 46, 30, 13, 16, 18, 27, 49, 39, 44, 38, 2, 25, 45, 52]
  }
}