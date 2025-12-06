class Airport {
  final String iataCode;
  final String name;
  final String municipality;
  final String isoCountry;

  Airport({
    required this.iataCode,
    required this.name,
    required this.municipality,
    required this.isoCountry,
  });

  // construct airport from airports.json
  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      iataCode: json['iata_code'] ?? '',
      name: json['name'] ?? '',
      municipality: json['municipality'] ?? '',
      isoCountry: json['iso_country'] ?? '',
    );
  }

  // format display name
  String get displayName => '$municipality ($iataCode) - $isoCountry';

  // search text for filtering airports
  String get searchText =>
      '${iataCode.toLowerCase()} ${municipality.toLowerCase()} ${name.toLowerCase()} ${isoCountry.toLowerCase()}';

  @override
  String toString() => displayName;

  // compare airports by matching IATA code
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Airport &&
          runtimeType == other.runtimeType &&
          iataCode == other.iataCode;
  // hash code based on IATA code
  @override
  int get hashCode => iataCode.hashCode;
}
