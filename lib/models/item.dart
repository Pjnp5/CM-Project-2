class Item {
  String description;
  String tag;
  String imageUrl;

  Item({required this.description, required this.tag, required this.imageUrl});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'tag': tag,
      'imageUrl': imageUrl,
    };
  }
}
