class SellerSeacrhSingleton {
  // Private constructor
  SellerSeacrhSingleton._privateConstructor();

  // Singleton instance
  static final SellerSeacrhSingleton _instance = SellerSeacrhSingleton._privateConstructor();

  // Getter to access the instance
  static SellerSeacrhSingleton get instance => _instance;

  // Seller ID property
  String _userId = '';

  // Getter for seller ID
  String get userId => _userId;

  // Setter for seller ID
  set userId(String id) {
    _userId = id;
  }
}
