import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop.dart';

class CropProvider with ChangeNotifier {
  List<Crop> _crops = [];
  List<Crop> _filteredCrops = [];
  String _searchQuery = '';
  CropStatus? _statusFilter;

  // Updated getter that handles both search and filter
  List<Crop> get crops {
    if (_searchQuery.isEmpty && _statusFilter == null) {
      return _crops;
    }
    return _filteredCrops;
  }

  String get searchQuery => _searchQuery;
  CropStatus? get statusFilter => _statusFilter;

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

      _applyFilters(); // Apply current filters after loading
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
        notes: 'Cherry tomatoes, need regular watering and organic fertilizer',
        status: CropStatus.growing,
      ),
      Crop(
        id: '2',
        name: 'Corn',
        plantingDate: now.subtract(const Duration(days: 60)),
        expectedHarvestDate: now.add(const Duration(days: 15)),
        notes: 'Sweet corn variety, planted in full sun area',
        status: CropStatus.ready,
      ),
      Crop(
        id: '3',
        name: 'Carrots',
        plantingDate: now.subtract(const Duration(days: 90)),
        expectedHarvestDate: now.subtract(const Duration(days: 10)),
        notes: 'Orange carrots, harvested last week, excellent yield',
        status: CropStatus.harvested,
      ),
      Crop(
        id: '4',
        name: 'Lettuce',
        plantingDate: now.subtract(const Duration(days: 20)),
        expectedHarvestDate: now.add(const Duration(days: 25)),
        notes: 'Romaine lettuce for salads, growing in shade',
        status: CropStatus.growing,
      ),
      Crop(
        id: '5',
        name: 'Bell Peppers',
        plantingDate: now.subtract(const Duration(days: 45)),
        expectedHarvestDate: now.add(const Duration(days: 30)),
        notes: 'Red and green bell peppers, need warm climate',
        status: CropStatus.growing,
      ),
    ];
    _saveCrops();
  }

  // Add new crop
  Future<void> addCrop(Crop crop) async {
    _crops.add(crop);
    await _saveCrops();
    _applyFilters(); // Apply current filters after adding
    notifyListeners();
  }

  // Update existing crop
  Future<void> updateCrop(String id, Crop updatedCrop) async {
    final index = _crops.indexWhere((crop) => crop.id == id);
    if (index != -1) {
      _crops[index] = updatedCrop;
      await _saveCrops();
      _applyFilters(); // Apply current filters after updating
      notifyListeners();
    }
  }

  // Delete crop
  Future<void> deleteCrop(String id) async {
    _crops.removeWhere((crop) => crop.id == id);
    await _saveCrops();
    _applyFilters(); // Apply current filters after deleting
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

  // Search functionality - searches only in notes
  void searchCrops(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  // Filter by status functionality
  void filterByStatus(CropStatus? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // Enhanced method that applies both search and status filters
  void _applyFilters() {
    if (_searchQuery.isEmpty && _statusFilter == null) {
      _filteredCrops = [];
      return;
    }

    _filteredCrops = _crops.where((crop) {
      // Check search query - searches both name and notes
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = crop.name.toLowerCase().contains(query);
        final notesMatch = crop.notes.toLowerCase().contains(query);
        matchesSearch = nameMatch || notesMatch;
      }

      // Check status filter
      bool matchesStatus =
          _statusFilter == null || crop.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Get crops count by status (useful for UI indicators)
  Map<CropStatus, int> getCropCountByStatus() {
    final Map<CropStatus, int> counts = {};
    for (final status in CropStatus.values) {
      counts[status] = _crops.where((crop) => crop.status == status).length;
    }
    return counts;
  }

  // Get total crops count
  int get totalCropsCount => _crops.length;

  // Get filtered crops count
  int get filteredCropsCount => crops.length;
}
