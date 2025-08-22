class Validators {
  // Date constraints
  static final DateTime _minPlantingDate = DateTime.now().subtract(
    const Duration(days: 365),
  );
  static final DateTime _maxPlantingDate = DateTime.now().add(
    const Duration(days: 90),
  );
  static final DateTime _minHarvestDate = DateTime.now();
  static final DateTime _maxHarvestDate = DateTime.now().add(
    const Duration(days: 730),
  );

  static String? validateCropName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Crop name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Crop name must be at least 2 characters';
    }

    if (trimmed.length > 50) {
      return 'Crop name must be less than 50 characters';
    }

    // Check for valid characters (letters, numbers, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z0-9\s\-']+$").hasMatch(trimmed)) {
      return 'Crop name contains invalid characters';
    }

    return null;
  }

  static String? validateDates(DateTime? plantingDate, DateTime? harvestDate) {
    if (plantingDate == null && harvestDate == null) {
      return 'Both planting and harvest dates are required';
    }

    if (plantingDate == null) {
      return 'Planting date is required';
    }

    if (harvestDate == null) {
      return 'Harvest date is required';
    }

    // Validate planting date range
    if (plantingDate.isBefore(_minPlantingDate)) {
      return 'Planting date cannot be more than 1 year ago';
    }

    if (plantingDate.isAfter(_maxPlantingDate)) {
      return 'Planting date cannot be more than 3 months in the future';
    }

    // Validate harvest date range
    if (harvestDate.isBefore(_minHarvestDate)) {
      return 'Harvest date cannot be in the past';
    }

    if (harvestDate.isAfter(_maxHarvestDate)) {
      return 'Harvest date cannot be more than 2 years in the future';
    }

    // Validate relationship between planting and harvest dates
    if (plantingDate.isAfter(harvestDate) ||
        plantingDate.isAtSameMomentAs(harvestDate)) {
      return 'Harvest date must be after planting date';
    }

    // Check minimum growth period (at least 1 day)
    final growthPeriod = harvestDate.difference(plantingDate).inDays;
    if (growthPeriod < 1) {
      return 'Crops need at least 1 day to grow';
    }

    // Check maximum growth period (2 years)
    if (growthPeriod > 730) {
      return 'Growth period cannot exceed 2 years';
    }

    // Warn about very short growth periods
    if (growthPeriod < 7) {
      return 'Growth period is very short (${growthPeriod} days). Are you sure?';
    }

    // Warn about very long growth periods
    if (growthPeriod > 365) {
      return 'Growth period is very long (${growthPeriod} days). Are you sure?';
    }

    return null; // All validations passed
  }

  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Notes are optional
    }

    if (value.trim().length > 500) {
      return 'Notes must be less than 500 characters';
    }

    return null;
  }

  // Helper method to get date constraints for UI
  static Map<String, DateTime> getDateConstraints() {
    return {
      'minPlantingDate': _minPlantingDate,
      'maxPlantingDate': _maxPlantingDate,
      'minHarvestDate': _minHarvestDate,
      'maxHarvestDate': _maxHarvestDate,
    };
  }

  // Helper method to check if planting date is valid
  static bool isValidPlantingDate(DateTime date) {
    return date.isAfter(_minPlantingDate.subtract(const Duration(days: 1))) &&
        date.isBefore(_maxPlantingDate.add(const Duration(days: 1)));
  }

  // Helper method to check if harvest date is valid
  static bool isValidHarvestDate(DateTime date, DateTime? plantingDate) {
    if (plantingDate != null &&
        date.isBefore(plantingDate.add(const Duration(days: 1)))) {
      return false;
    }
    return date.isAfter(_minHarvestDate.subtract(const Duration(days: 1))) &&
        date.isBefore(_maxHarvestDate.add(const Duration(days: 1)));
  }
}
