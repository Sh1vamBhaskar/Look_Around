import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/place.dart';

class PlacesService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  
  Future<List<Place>> getNearbyPlaces(
    double lat,
    double lng,
    String type,
    {int radius = 1500}
  ) async {
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
    if (apiKey == null) throw Exception('Google Places API key not found');

    final url = Uri.parse(
      '$baseUrl?location=$lat,$lng&radius=$radius&type=$type&key=$apiKey'
    );

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results
              .map((place) => Place.fromJson(place, lat, lng))
              .toList()
            ..sort((a, b) => a.distance.compareTo(b.distance));
        } else {
          throw Exception(data['error_message'] ?? 'Failed to fetch places');
        }
      } else {
        throw Exception('Failed to fetch places');
      }
    } catch (e) {
      throw Exception('Error fetching places: $e');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
    if (apiKey == null) throw Exception('Google Places API key not found');

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey'
    );

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'] as Map<String, dynamic>;
        } else {
          throw Exception(data['error_message'] ?? 'Failed to fetch place details');
        }
      } else {
        throw Exception('Failed to fetch place details');
      }
    } catch (e) {
      throw Exception('Error fetching place details: $e');
    }
  }
} 