import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop.dart';

class CropProvider with ChangeNotifier {
  List<Crop> _crops = [];
  List<Crop> _filteredCrops = [];
  String _searchQuery = '';

  List<Crop> get crops => _filteredCrops.isEmpty && _searchQuery.isEmpty 
      ? _crops 
      : _filteredCrops;

  String get searchQuery => _searchQuery;

  CropProvider() {
    _loadCrops();
  }

  // Load crops from local storage
  Future<void> _loadCrops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cropsJson = prefs.getStringList('crops') ?? [];
      
      if (cropsJson.isEmpty) {
        _initializeMockData();
      } else {
        _crops = cropsJson
            .map((json) => Crop.fromJson(jsonDecode(json)))
            .toList();
      }
      
      notifyListeners();
    } catch (e) {
      _initializeMockData();
    }
  }

  // Save crops to local storage
  Future<void> _saveCrops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cropsJson = _crops
          .map((crop) => jsonEncode(crop.toJson()))
          .toList();
      await prefs.setStringList('crops', cropsJson);
    } catch (e) {
      debugPrint('Error saving crops: $e');
    }
  }

  // Initialize with mock data
  void _initializeMockData() {
    final now = DateTime.now();
    _crops = [
      Crop(
        id: '1',
        name: 'Tomatoes',
        plantingDate: now.subtract(const Duration(days: 30)),
        expectedHarvestDate: now.add(const Duration(days: 45)),
        notes: 'Cherry tomatoes, need regular watering',
        status: CropStatus.growing,
      ),
      Crop(
        id: '2',
        name: 'Corn',
        plantingDate: now.subtract(const Duration(days: 60)),
        expectedHarvestDate: now.add(const Duration(days: 15)),
        notes: 'Sweet corn variety',
        status: CropStatus.ready,
      ),
      Crop(
        id: '3',
        name: 'Carrots',
        plantingDate: now.subtract(const Duration(days: 90)),
        expectedHarvestDate: now.subtract(const Duration(days: 10)),
        notes: 'Orange carrots, harvested last week',
        status: CropStatus.harvested,
      ),
      Crop(
        id: '4',
        name: 'Lettuce',
        plantingDate: now.subtract(const Duration(days: 20)),
        expectedHarvestDate: now.add(const Duration(days: 25)),
        notes: 'Romaine lettuce for salads',
        status: CropStatus.growing,
      ),
      Crop(
        id: '5',
        name: 'Bell Peppers',
        plantingDate: now.subtract(const Duration(days: 45)),
        expectedHarvestDate: now.add(const Duration(days: 30)),
        notes: 'Red and green bell peppers',
        status: CropStatus.growing,
      ),
    ];
    _saveCrops();
  }

  // Add new crop
  Future<void> addCrop(Crop crop) async {
    _crops.add(crop);
    await _saveCrops();
    _applySearch();
    notifyListeners();
  }

  // Update existing crop
  Future<void> updateCrop(String id, Crop updatedCrop) async {
    final index = _crops.indexWhere((crop) => crop.id == id);
    if (index != -1) {
      _crops[index] = updatedCrop;
      await _saveCrops();
      _applySearch();
      notifyListeners();
    }
  }

  // Delete crop
  Future<void> deleteCrop(String id) async {
    _crops.removeWhere((crop) => crop.id == id);
    await _saveCrops();
    _applySearch();
    notifyListeners();
  }

  // Get crop by ID
  Crop? getCropById(String id) {
    try {
      return _crops.firstWhere((crop) => crop.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search functionality
  void searchCrops(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredCrops = [];
    } else {
      _filteredCrops = _crops
          .where((crop) => crop.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }
}
