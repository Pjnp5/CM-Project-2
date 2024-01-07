class Item {
  String description;
  String tag;
  String imageUrl;
  DateTime dateAdded;
  String dep_stored;
  bool is_retrieved;

  Item({
    required this.description,
    required this.tag,
    required this.imageUrl,
    required this.dateAdded,
    required this.dep_stored,
    required this.is_retrieved,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'tag': tag,
      'image_url': imageUrl,
      'dateAdded': dateAdded,
      'dep_stored': dep_stored,
      'isRetrieved': is_retrieved,
    };
  }
}
