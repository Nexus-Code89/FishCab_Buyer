class ShoppingCart {
  List<CartItem> items = [];

  void addItem(CartItem item) {
    // Check if an item with the same name already exists in the cart
    int existingIndex = items.indexWhere((existingItem) => existingItem.name == item.name);

    if (existingIndex != -1) {
      // If the item already exists, update the quantity
      items[existingIndex].quantity += item.quantity;
    } else {
      // If the item doesn't exist, add it to the cart
      items.add(item);
    }
  }

  void removeItem(CartItem item) {
    items.remove(item);
  }

  double getTotalPrice() {
    return items.fold(0, (total, item) => total + (item.price * item.quantity));
  }
}

class CartItem {
  String name;
  num price;
  double quantity; // New property to track the quantity

  CartItem({required this.name, required this.price, this.quantity = 1});
}
