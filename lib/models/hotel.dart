class HotelOffer {
  final String id;
  final String name;
  final String address;
  final String city;
  final String country;
  final String price;
  final String currency;
  final double rating;
  final int stars;
  final List<String> amenities;
  final String imageUrl;

  HotelOffer({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.price,
    required this.currency,
    required this.rating,
    required this.stars,
    required this.amenities,
    required this.imageUrl,
  });

  // create hotel offer from liteAPI json response
  factory HotelOffer.fromJson(Map<String, dynamic> json) {
    // find the minimum room price
    double minPrice = 0.0;

    if (json['rooms'] != null && json['rooms'] is List) {
      final rooms = json['rooms'] as List;
      for (var room in rooms) {
        final priceStr = room['price']?['total']?.toString();
        final price = double.tryParse(priceStr ?? '');
        if (price != null) {
          if (minPrice == 0 || price < minPrice) {
            minPrice = price;
          }
        }
      }
    }
    // return hotel offer
    return HotelOffer(
      id: json['hotelId']?.toString() ?? '',
      name: json['hotelName'] ?? 'Unknown Hotel',
      address: json['address'] ?? '',
      city: json['cityName'] ?? '',
      country: json['countryCode'] ?? '',
      price: minPrice.toStringAsFixed(2),
      currency: 'USD',
      rating: (json['rating'] ?? 0).toDouble(),
      stars: json['stars'] ?? 0,
      amenities: [],
      imageUrl: json['image'] ?? '',
    );
  }
}
