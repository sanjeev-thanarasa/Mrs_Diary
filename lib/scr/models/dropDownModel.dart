class DropListModel {
  DropListModel(this.listOptionItems);

  final List<OptionItem> listOptionItems;
}

class OptionItem {
  final String name;

  OptionItem({required this.name});
}

DropListModel dishDropListModel = DropListModel([
  // Dish types are loaded from Firestore.
]);

OptionItem optionDishSelected = OptionItem(name: "Select Dish Type");

DropListModel villageDropListModel = DropListModel([
  //OptionItem(name: 'நிலாவெளி'),
]);
