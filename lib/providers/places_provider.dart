import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class PlacesProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();
  final SharedPreferences _prefs;

  List<Place> _places = [];
  List<Place> _favorites = [];
  Position? _currentLocation;
  String _selectedCategory = 'restaurant';
  bool _isLoading = false;
  String? _error;

  PlacesProvider(this._prefs) {
    _loadFavorites();
  }

  List<Place> get places => _places;
  List<Place> get favorites => _favorites;
  Position? get currentLocation => _currentLocation;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const Map<String, String> categoryTypes = {
    'Restaurants': 'restaurant',
    'Cafes': 'cafe',
    'Parks': 'park',
    'ATMs': 'atm',
    'Shopping': 'shopping_mall',
    'Hotels': 'lodging',
  };

  Future<void> _loadFavorites() async {
    final favoritesJson = _prefs.getStringList('favorites') ?? [];
    _favorites = favoritesJson
        .map((json) => Place.fromJson(
            Map<String, dynamic>.from(jsonDecode(json) as Map),
            _currentLocation?.latitude ?? 0,
            _currentLocation?.longitude ?? 0))
        .toList();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final favoritesJson = _favorites
        .map((place) => jsonEncode(place.toJson()))
        .toList();
    await _prefs.setStringList('favorites', favoritesJson);
  }

  Future<void> toggleFavorite(Place place) async {
    final index = _favorites.indexWhere((p) => p.id == place.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(place..isFavorite = true);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      _currentLocation = await _locationService.getCurrentLocation();
      await fetchNearbyPlaces();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNearbyPlaces() async {
    if (_currentLocation == null) return;

    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      _places = await _placesService.getNearbyPlaces(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _selectedCategory,
      );

      // Update favorite status
      for (var place in _places) {
        place.isFavorite = _favorites.any((f) => f.id == place.id);
      }
    } catch (e) {
      _error = e.toString();
      _places = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = categoryTypes[category] ?? category;
    fetchNearbyPlaces();
  }
} 