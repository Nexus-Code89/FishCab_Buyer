class SellerSingleton {
  // Private constructor
  SellerSingleton._privateConstructor();

  // Singleton instance
  static final SellerSingleton _instance = SellerSingleton._privateConstructor();

  // Getter to access the instance
  static SellerSingleton get instance => _instance;

  // Seller ID property
  String _userId = '';

  // Getter for seller ID
  String get userId => _userId;

  // Setter for seller ID
  set userId(String id) {
    _userId = id;
  }
}
