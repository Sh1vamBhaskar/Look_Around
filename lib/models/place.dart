import 'dart:math';

class Place {
  final String id;
  final String name;
  final String address;
  final double rating;
  final bool isOpen;
  final double distance;
  final double lat;
  final double lng;
  bool isFavorite;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.isOpen,
    required this.distance,
    required this.lat,
    required this.lng,
    this.isFavorite = false,
  });

  factory Place.fromJson(Map<String, dynamic> json, double userLat, double userLng) {
    final location = json['geometry']['location'];
    final lat = location['lat'] as double;
    final lng = location['lng'] as double;

    // Calculate distance using the Haversine formula
    const R = 6371e3; // Earth's radius in meters
    final phi1 = userLat * (3.141592653589793 / 180);
    final phi2 = lat * (3.141592653589793 / 180);
    final deltaPhi = (lat - userLat) * (3.141592653589793 / 180);
    final deltaLambda = (lng - userLng) * (3.141592653589793 / 180);

    final a = sin(deltaPhi/2) * sin(deltaPhi/2) +
              cos(phi1) * cos(phi2) *
              sin(deltaLambda/2) * sin(deltaLambda/2);
    final c = 2 * atan2(sqrt(a), sqrt(1-a));
    final distance = R * c;

    return Place(
      id: json['place_id'] as String,
      name: json['name'] as String,
      address: json['vicinity'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['opening_hours']?['open_now'] as bool? ?? false,
      distance: distance,
      lat: lat,
      lng: lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'isOpen': isOpen,
      'distance': distance,
      'lat': lat,
      'lng': lng,
      'isFavorite': isFavorite,
    };
  }
} 