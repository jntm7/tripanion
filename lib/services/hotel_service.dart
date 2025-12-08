import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';

class HotelService {
  final String apiKey;
  static const String baseUrl = 'https://api.liteapi.travel/v3.0';

  HotelService({required this.apiKey});

  // Search hotels by city
  Future<List<HotelOffer>> searchHotels({
    required String cityName,
    required String countryCode,
    required DateTime checkin,
    required DateTime checkout,
    required int adults,
    required int rooms,
    int children = 0,
  }) async {
    try {
      //print('Searching for hotels in: "$cityName", "$countryCode"');

      final hotelDetailsMap = await _searchHotelsByCity(cityName, countryCode);
      if (hotelDetailsMap.isEmpty) {
        //print('No hotels found in $cityName, $countryCode');
        return [];
      }

      final hotelIds = hotelDetailsMap.keys.toList();
      final hotels = await _getHotelRates(
        hotelIds: hotelIds,
        hotelDetailsMap: hotelDetailsMap,
        checkin: checkin,
        checkout: checkout,
        adults: adults,
        rooms: rooms,
        children: children,
      );

      return hotels;
    } catch (e) {
      //print('Hotel search error: $e');
      return [];
    }
  }

  // Get city ID from city name
  Future<String?> _getCityId(String cityName, String countryCode) async {
    try {
      //print('Searching for city: "$cityName" in country: "$countryCode"'); // Debug
      final url = Uri.parse('$baseUrl/data/city?countryCode=$countryCode');
      //print('City request: GET $url'); // Debug

      final response = await http.get(
        url,
        headers: {
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      //print('City response status: ${response.statusCode}'); // Debug
      //print('City response body: ${response.body}'); // Debug

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null && data['data'] is List) {
        final cities = data['data'] as List;
        //print('Found ${cities.length} cities');

        String normalize(String s) {
          return s.toLowerCase().trim();
        }

        final userCity = normalize(cityName);

        for (var city in cities) {
          final apiCity = normalize(city['city'] ?? '');

          if (apiCity == userCity ||
              apiCity.contains(userCity) ||
              apiCity.startsWith(userCity)) {
            //print('Matched city ID: ${city['id']}');
            return city['id'].toString();
          }
        }
      }
    }
    } catch (e) {
      //print('Error getting city ID: $e');
      return null;
    }
  }

  // Search hotels by city name and country code
  Future<Map<String, Map<String, dynamic>>> _searchHotelsByCity(String cityName, String countryCode) async {
    try {
      final url = Uri.parse('$baseUrl/data/hotels?countryCode=$countryCode&cityName=$cityName');
      //print('Hotels search request: GET $url');

      final response = await http.get(
        url,
        headers: {
          'X-API-Key': apiKey,
        },
      );

      //print('Hotels search response status: ${response.statusCode}');
      //print('Hotels search response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          final hotels = data['data'] as List;
          //print('Found ${hotels.length} hotels in $cityName');

          final hotelDetailsMap = <String, Map<String, dynamic>>{};
          for (var hotel in hotels.take(10)) {
            final hotelId = hotel['id']?.toString();
            if (hotelId != null && hotelId.isNotEmpty) {
              hotelDetailsMap[hotelId] = hotel;
            }
          }
          //print('Selected ${hotelDetailsMap.length} hotels with details');
          return hotelDetailsMap;
        }
      } else {
        //print('Error response: ${response.statusCode} - ${response.body}');
      }
      return {};
    } catch (e) {
      //print('Error searching hotels: $e');
      return {};
    }
  }

  // Get hotel rates for multiple hotels
  Future<List<HotelOffer>> _getHotelRates({
    required List<String> hotelIds,
    required Map<String, Map<String, dynamic>> hotelDetailsMap,
    required DateTime checkin,
    required DateTime checkout,
    required int adults,
    required int rooms,
    int children = 0,
  }) async {
    try {
      final checkinStr = _formatDate(checkin);
      final checkoutStr = _formatDate(checkout);

      final url = Uri.parse('$baseUrl/hotels/rates');

      final occupancies = List.generate(rooms, (index) => {
        'adults': adults,
        'children': children > 0 ? [children] : [],
      });

      final requestBody = {
        'hotelIds': hotelIds,
        'checkin': checkinStr,
        'checkout': checkoutStr,
        'occupancies': occupancies,
        'currency': 'USD',
        'guestNationality': 'US',
      };

      //print('Hotel rates request: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      //print('Hotel rates response status: ${response.statusCode}');
      //print('Hotel rates response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          final hotelsData = data['data'] as List;
          //print('Parsing ${hotelsData.length} hotels from rates response');
          final hotels = hotelsData
              .map((hotelData) {
                final hotelId = hotelData['hotelId']?.toString() ?? '';
                final hotelDetails = hotelDetailsMap[hotelId];
                return _parseHotelOffer(hotelData, hotelDetails);
              })
              .where((hotel) => hotel != null)
              .cast<HotelOffer>()
              .toList();
          //print('Successfully parsed ${hotels.length} hotels');
          return hotels;
        }
      } else {
        //print('Error getting hotel rates: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e) {
      //print('Error getting hotel rates: $e');
      return [];
    }
  }

  HotelOffer? _parseHotelOffer(Map<String, dynamic> rateData, Map<String, dynamic>? hotelDetails) {
  try {
    final hotelId = rateData['hotelId']?.toString() ?? '';
    //print('Parsing hotel: $hotelId');

    double minPrice = double.infinity;

    final roomsData = rateData['roomTypes'] ?? rateData['rooms'];

    if (roomsData != null && roomsData is List) {
      //print('Found ${roomsData.length} room types');
      for (var roomType in roomsData) {
        final rates = roomType['rates'];
        if (rates != null && rates is List && rates.isNotEmpty) {
          for (var rate in rates) {
            var priceValue = rate['retailRate']?['total']?[0]?['amount'] ??
                            roomType['offerRetailRate']?['amount'] ??
                            rate['retailRate']?['initialPrice']?[0]?['amount'];
            final price = double.tryParse(priceValue?.toString() ?? '0') ?? 0;
            if (price > 0 && price < minPrice) {
              minPrice = price;
            }
          }
        } else {
          var priceValue = roomType['offerRetailRate']?['amount'];
          final price = double.tryParse(priceValue?.toString() ?? '0') ?? 0;
          if (price > 0 && price < minPrice) {
            minPrice = price;
          }
        }
      }
    }

    if (minPrice == double.infinity) {
      //print('Warning: No valid price found, defaulting to 0');
      minPrice = 0;
    }

    //print('Parsed hotel: $hotelId with price: $minPrice');

    return HotelOffer(
      id: hotelId,
      name: hotelDetails?['name'] ?? rateData['hotelName'] ?? 'Unknown Hotel',
      address: hotelDetails?['address'] ?? rateData['address'] ?? '',
      city: hotelDetails?['city'] ?? rateData['cityName'] ?? '',
      country: hotelDetails?['country'] ?? rateData['countryCode'] ?? '',
      price: minPrice.toStringAsFixed(2),
      currency: 'USD',
      rating: (hotelDetails?['rating'] ?? rateData['rating'] ?? 0.0).toDouble(),
      stars: hotelDetails?['stars'] ?? rateData['stars'] ?? 0,
      amenities: [],
      imageUrl: hotelDetails?['image'] ?? rateData['image'] ?? '',
    );
  } catch (e) {
    //print('Error parsing hotel offer: $e');
    //print('Problem rate data: $rateData');
    //print('Problem hotel details: $hotelDetails');
    return null;
  }
}

  // Format date for API (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
