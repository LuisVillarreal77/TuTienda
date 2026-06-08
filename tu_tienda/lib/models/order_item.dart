class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String image;
  final String shopId;
  final String shopName;
  final String sellerId;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.shopId,
    required this.shopName,
    required this.sellerId,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: data['quantity'] ?? 0,
      image: data['image'] ?? '',
      shopId: data['shopId'] ?? '',
      shopName: data['shopName'] ?? '',
      sellerId: data['sellerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
      'shopId': shopId,
      'shopName': shopName,
      'sellerId': sellerId,
    };
  }
}
