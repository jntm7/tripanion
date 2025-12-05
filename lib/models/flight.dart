class FlightOffer {
  final String id;
  final String price;
  final String currency;
  final List<Itinerary> itineraries;
  final int numberOfBookableSeats;

  FlightOffer({
    required this.id,
    required this.price,
    required this.currency,
    required this.itineraries,
    required this.numberOfBookableSeats,
  });

  // create flight offer from json
  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    return FlightOffer(
      id: json['id'] ?? '',
      price: json['price']?['total'] ?? '0',
      currency: json['price']?['currency'] ?? 'USD',
      itineraries: (json['itineraries'] as List<dynamic>?)
              ?.map((i) => Itinerary.fromJson(i))
              .toList() ??
          [],
      numberOfBookableSeats: json['numberOfBookableSeats'] ?? 1,
    );
  }
}

class Itinerary {
  final String duration;
  final List<Segment> segments;

  Itinerary({
    required this.duration,
    required this.segments,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      duration: json['duration'] ?? '',
      segments: (json['segments'] as List<dynamic>?)
              ?.map((s) => Segment.fromJson(s))
              .toList() ??
          [],
    );
  }

  // calculate number of stops
  int get numberOfStops => segments.length - 1;

  // get first segment departure
  Segment get firstSegment => segments.first;

  // get last segment arrival
  Segment get lastSegment => segments.last;
}

// flight segment
class Segment {
  final String departureIataCode;
  final String arrivalIataCode;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String duration;
  final String carrierCode;
  final String number;
  final Aircraft? aircraft;

  Segment({
    required this.departureIataCode,
    required this.arrivalIataCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.carrierCode,
    required this.number,
    this.aircraft,
  });

  // create segment from json
  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      departureIataCode: json['departure']?['iataCode'] ?? '',
      arrivalIataCode: json['arrival']?['iataCode'] ?? '',
      departureTime: DateTime.parse(json['departure']?['at'] ?? DateTime.now().toIso8601String()),
      arrivalTime: DateTime.parse(json['arrival']?['at'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'] ?? '',
      carrierCode: json['carrierCode'] ?? '',
      number: json['number'] ?? '',
      aircraft: json['aircraft'] != null ? Aircraft.fromJson(json['aircraft']) : null,
    );
  }

  // format flight number
  String get flightNumber => '$carrierCode $number';
}

class Aircraft {
  final String code;

  Aircraft({required this.code});

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    return Aircraft(
      code: json['code'] ?? '',
    );
  }
}
