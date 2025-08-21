class Validators {
  static String? validateCropName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Crop name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Crop name must be at least 2 characters';
    }
    
    if (value.trim().length > 50) {
      return 'Crop name must be less than 50 characters';
    }
    
    return null;
  }
  
  static String? validateDates(DateTime? plantingDate, DateTime? harvestDate) {
    if (plantingDate == null || harvestDate == null) {
      return 'Both dates are required';
    }
    
    if (plantingDate.isAfter(harvestDate)) {
      return 'Planting date must be before harvest date';
    }
    
    // Check if harvest date is more than 2 years in the future
    final twoYearsFromNow = DateTime.now().add(const Duration(days: 730));
    if (harvestDate.isAfter(twoYearsFromNow)) {
      return 'Harvest date seems too far in the future';
    }
    
    return null;
  }
}
