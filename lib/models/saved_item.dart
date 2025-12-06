enum SavedItemType { flight, hotel }

class SavedItem {
  final String id; // Unique identifier
  final SavedItemType type;
  final DateTime savedAt;

  // Common fields
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final String price;
  final String currency;

  // Flight-specific fields
  final String? airline;
  final String? flightNumber;
  final String? travelClass;
  final int? passengers;

  // Hotel-specific fields
  final String? hotelName;
  final int? nights;
  final int? rooms;
  final int? guests;

  SavedItem({
    required this.id,
    required this.type,
    required this.savedAt,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.price,
    required this.currency,
    this.airline,
    this.flightNumber,
    this.travelClass,
    this.passengers,
    this.hotelName,
    this.nights,
    this.rooms,
    this.guests,
  });

  // Create from flight offer
  factory SavedItem.fromFlight({
    required String id,
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? returnDate,
    required String price,
    required String currency,
    required String airline,
    required String flightNumber,
    required String travelClass,
    required int passengers,
  }) {
    return SavedItem(
      id: id,
      type: SavedItemType.flight,
      savedAt: DateTime.now(),
      origin: origin,
      destination: destination,
      departureDate: departureDate,
      returnDate: returnDate,
      price: price,
      currency: currency,
      airline: airline,
      flightNumber: flightNumber,
      travelClass: travelClass,
      passengers: passengers,
    );
  }

  // Create from hotel offer
  factory SavedItem.fromHotel({
    required String id,
    required String origin,
    required String destination,
    required DateTime departureDate,
    required DateTime returnDate,
    required String price,
    required String currency,
    required String hotelName,
    required int nights,
    required int rooms,
    required int guests,
  }) {
    return SavedItem(
      id: id,
      type: SavedItemType.hotel,
      savedAt: DateTime.now(),
      origin: origin,
      destination: destination,
      departureDate: departureDate,
      returnDate: returnDate,
      price: price,
      currency: currency,
      hotelName: hotelName,
      nights: nights,
      rooms: rooms,
      guests: guests,
    );
  }

  // Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'savedAt': savedAt.toIso8601String(),
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'price': price,
      'currency': currency,
      'airline': airline,
      'flightNumber': flightNumber,
      'travelClass': travelClass,
      'passengers': passengers,
      'hotelName': hotelName,
      'nights': nights,
      'rooms': rooms,
      'guests': guests,
    };
  }

  // Create from JSON
  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'],
      type: json['type'] == SavedItemType.flight.toString()
          ? SavedItemType.flight
          : SavedItemType.hotel,
      savedAt: DateTime.parse(json['savedAt']),
      origin: json['origin'],
      destination: json['destination'],
      departureDate: DateTime.parse(json['departureDate']),
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'])
          : null,
      price: json['price'],
      currency: json['currency'],
      airline: json['airline'],
      flightNumber: json['flightNumber'],
      travelClass: json['travelClass'],
      passengers: json['passengers'],
      hotelName: json['hotelName'],
      nights: json['nights'],
      rooms: json['rooms'],
      guests: json['guests'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
