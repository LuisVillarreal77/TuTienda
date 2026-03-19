class Shop {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int productCount;

  Shop({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.productCount,
  });

  factory Shop.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Shop(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      productCount: data['productCount'] ?? 0,
    );
  }
}