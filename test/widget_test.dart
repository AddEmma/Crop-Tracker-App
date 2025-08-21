import 'package:flutter_test/flutter_test.dart';
import 'package:crop_tracker/models/crop.dart';
import 'package:crop_tracker/utils/validators.dart';

void main() {
  group('Crop Model Tests', () {
    test('should create crop with correct properties', () {
      final now = DateTime.now();
      final crop = Crop(
        id: '1',
        name: 'Test Crop',
        plantingDate: now,
        expectedHarvestDate: now.add(const Duration(days: 30)),
        notes: 'Test notes',
        status: CropStatus.growing,
      );

      expect(crop.id, '1');
      expect(crop.name, 'Test Crop');
      expect(crop.notes, 'Test notes');
      expect(crop.status, CropStatus.growing);
      expect(crop.statusText, 'Growing');
    });

    test('should serialize and deserialize correctly', () {
      final now = DateTime.now();
      final crop = Crop(
        id: '1',
        name: 'Test Crop',
        plantingDate: now,
        expectedHarvestDate: now.add(const Duration(days: 30)),
        notes: 'Test notes',
        status: CropStatus.ready,
      );

      final json = crop.toJson();
      final deserializedCrop = Crop.fromJson(json);

      expect(deserializedCrop.id, crop.id);
      expect(deserializedCrop.name, crop.name);
      expect(deserializedCrop.notes, crop.notes);
      expect(deserializedCrop.status, crop.status);
    });

    test('should create copy with updated values', () {
      final now = DateTime.now();
      final crop = Crop(
        id: '1',
        name: 'Test Crop',
        plantingDate: now,
        expectedHarvestDate: now.add(const Duration(days: 30)),
      );

      final updatedCrop = crop.copyWith(
        name: 'Updated Crop',
        status: CropStatus.harvested,
      );

      expect(updatedCrop.name, 'Updated Crop');
      expect(updatedCrop.status, CropStatus.harvested);
      expect(updatedCrop.id, crop.id); // Should remain same
      expect(updatedCrop.plantingDate, crop.plantingDate); // Should remain same
    });
  });

  group('Validator Tests', () {
    test('should validate crop names correctly', () {
      expect(Validators.validateCropName('Tomato'), null);
      expect(Validators.validateCropName('A'), 'Crop name must be at least 2 characters');
      expect(Validators.validateCropName(''), 'Crop name is required');
      expect(Validators.validateCropName(null), 'Crop name is required');
      expect(Validators.validateCropName('A' * 51), 'Crop name must be less than 50 characters');
    });

    test('should validate dates correctly', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 30));
      final past = now.subtract(const Duration(days: 30));

      expect(Validators.validateDates(now, future), null);
      expect(Validators.validateDates(future, past), 'Planting date must be before harvest date');
      expect(Validators.validateDates(null, future), 'Both dates are required');
      expect(Validators.validateDates(now, null), 'Both dates are required');
    });
  });
}
