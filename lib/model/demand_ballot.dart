class DemandStorage {
  List<DemandItem> demandItems = [];

  void addDemand(DemandItem item) {
    // Check if an item with the same name already exists in the cart
    int existingIndex = demandItems.indexWhere((existingItem) => existingItem.fishName == item.fishName);

    if (existingIndex != -1) {
      // no operation
    } else {
      // If the item doesn't exist, add it to the cart
      demandItems.add(item);
    }
  }

  void removeItem(index) {
    if(index >= 0 && index < demandItems.length) {
      demandItems.removeAt(index);
    }
  }
}

class DemandItem {
  String fishName;

  DemandItem({
    required this.fishName,
  });
}
