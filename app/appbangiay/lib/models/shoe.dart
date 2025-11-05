class Shoe {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final List<String> sizes; // 👈 thêm thuộc tính size

  Shoe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.sizes,
  });

  factory Shoe.fromJson(Map<String, dynamic> json, String id) {
    return Shoe(
      id: id,
      name: json['name'],
      imageUrl: json['image'],
      price: (json['price'] as num).toDouble(),
      description: json['desc'],
      sizes:
          json['sizes'] != null ? List<String>.from(json['sizes']) : <String>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': imageUrl,
        'price': price,
        'desc': description,
        'sizes': sizes,
      };
}
