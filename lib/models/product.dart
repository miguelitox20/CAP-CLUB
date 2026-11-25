class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.imageUrl = '',
  });

  // Lo que se guarda en Firestore (el id es el nombre del documento).
  Map<String, dynamic> toMap() => {
        'name': name,
        'brand': brand,
        'price': price,
        'imageUrl': imageUrl,
      };

  // Lee un documento de Firestore.
  factory Product.fromMap(String id, Map<String, dynamic> map) => Product(
        id: id,
        name: '${map['name'] ?? ''}',
        brand: '${map['brand'] ?? ''}',
        price: double.tryParse('${map['price']}') ?? 0,
        imageUrl: '${map['imageUrl'] ?? ''}',
      );
}
