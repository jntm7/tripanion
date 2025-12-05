import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight.dart';

class FlightService {
  static const String _baseUrl = 'https://test.api.amadeus.com';
  static const String _tokenUrl = '/v1/security/oauth2/token';
  static const String _flightURL = '/v2/shopping/flight-destinations';

  final String _apiKey;
  final String _apiSecret;
  String? _accessToken;
  DateTime? _tokenExpiry;

  // constructor
  FlightService({
    required String apiKey,
    required String apiSecret,
  })  : _apiKey = apiKey,
        _apiSecret = apiSecret;

  // get access token
  Future<void> _authenticate() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_tokenUrl'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': _apiKey,
          'client_secret': _apiSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
      } else {
        throw Exception('Failed to authenticate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  // search flight offers
  Future<List<FlightOffer>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? returnDate,
    required int adults,
    int children = 0,
    String travelClass = 'ECONOMY',
    String currencyCode = 'USD',
    bool nonStop = false,
    int maxResults = 50,
  }) async {
    await _authenticate();

    final queryParams = {
      'originLocationCode': origin,
      'destinationLocationCode': destination,
      'departureDate': _formatDate(departureDate),
      'adults': adults.toString(),
      'currencyCode': currencyCode,
      'max': maxResults.toString(),
      'travelClass': travelClass,
    };

    if (returnDate != null) {
      queryParams['returnDate'] = _formatDate(returnDate);
    }

    if (children > 0) {
      queryParams['children'] = children.toString();
    }

    if (nonStop) {
      queryParams['nonStop'] = 'true';
    }

    try {
      final uri = Uri.parse('$_baseUrl$_flightURL')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> offersData = data['data'] ?? [];

        return offersData
            .map((offer) => FlightOffer.fromJson(offer))
            .toList();
      } else {
        throw Exception('Failed to search flights: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Flight search error: $e');
    }
  }

  // format date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
