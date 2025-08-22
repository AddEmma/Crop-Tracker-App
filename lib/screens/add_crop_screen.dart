import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/crop.dart';
import '../providers/crop_provider.dart';
import '../utils/validators.dart';

class AddCropScreen extends StatefulWidget {
  final Crop? cropToEdit;

  const AddCropScreen({super.key, this.cropToEdit});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _plantingDate;
  DateTime? _expectedHarvestDate;
  bool _isLoading = false;
  String? _dateValidationError;

  bool get isEditing => widget.cropToEdit != null;

  // Define reasonable date ranges
  static final DateTime _minPlantingDate = DateTime.now().subtract(
    const Duration(days: 365),
  ); // 1 year ago
  static final DateTime _maxPlantingDate = DateTime.now().add(
    const Duration(days: 90),
  ); // 3 months future
  static final DateTime _minHarvestDate = DateTime.now(); // Today
  static final DateTime _maxHarvestDate = DateTime.now().add(
    const Duration(days: 730),
  ); // 2 years future

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final crop = widget.cropToEdit!;
      _nameController.text = crop.name;
      _notesController.text = crop.notes;
      _plantingDate = crop.plantingDate;
      _expectedHarvestDate = crop.expectedHarvestDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPlantingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _plantingDate?.isBefore(_maxPlantingDate) == true &&
              _plantingDate?.isAfter(_minPlantingDate) == true
          ? _plantingDate!
          : _minPlantingDate.add(const Duration(days: 1)),
      firstDate: _minPlantingDate,
      lastDate: _maxPlantingDate,
      helpText: 'Select Planting Date',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      fieldLabelText: 'Planting Date',
      fieldHintText: 'MM/DD/YYYY',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF4CAF50)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _plantingDate = picked;
        _dateValidationError = null;

        // Auto-adjust harvest date if it becomes invalid
        if (_expectedHarvestDate != null &&
            _expectedHarvestDate!.isBefore(
              picked.add(const Duration(days: 1)),
            )) {
          _expectedHarvestDate = picked.add(
            const Duration(days: 30),
          ); // Default 30 days growth period
        }
      });
      _validateDates();
    }
  }

  Future<void> _selectHarvestDate(BuildContext context) async {
    // Determine the minimum harvest date (at least 1 day after planting, or today if no planting date)
    final DateTime minDate = _plantingDate != null
        ? _plantingDate!.add(const Duration(days: 1))
        : _minHarvestDate;

    // Ensure initial date is within valid range
    DateTime initialDate =
        _expectedHarvestDate ?? minDate.add(const Duration(days: 30));
    if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    } else if (initialDate.isAfter(_maxHarvestDate)) {
      initialDate = _maxHarvestDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: _maxHarvestDate,
      helpText: 'Select Harvest Date',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      fieldLabelText: 'Expected Harvest Date',
      fieldHintText: 'MM/DD/YYYY',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF4CAF50)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _expectedHarvestDate = picked;
        _dateValidationError = null;
      });
      _validateDates();
    }
  }

  void _validateDates() {
    setState(() {
      _dateValidationError = Validators.validateDates(
        _plantingDate,
        _expectedHarvestDate,
      );
    });
  }

  Future<void> _saveCrop() async {
    // Clear any previous date validation errors
    _validateDates();

    if (!_formKey.currentState!.validate()) return;

    if (_plantingDate == null || _expectedHarvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both planting and harvest dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_dateValidationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_dateValidationError!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final crop = Crop(
        id: isEditing
            ? widget.cropToEdit!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        plantingDate: _plantingDate!,
        expectedHarvestDate: _expectedHarvestDate!,
        notes: _notesController.text.trim(),
        status: isEditing ? widget.cropToEdit!.status : CropStatus.growing,
      );

      final cropProvider = context.read<CropProvider>();

      if (isEditing) {
        await cropProvider.updateCrop(widget.cropToEdit!.id, crop);
      } else {
        await cropProvider.addCrop(crop);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Crop updated successfully!'
                  : 'Crop added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${isEditing ? 'updating' : 'adding'} crop: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getGrowthPeriodText() {
    if (_plantingDate != null && _expectedHarvestDate != null) {
      final days = _expectedHarvestDate!.difference(_plantingDate!).inDays;
      if (days > 0) {
        return '$days days growth period';
      }
    }
    return '';
  }

  Widget _buildCropIcon() {
    return SizedBox(
      width: 24,
      height: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          'assets/icons/crop.jpg',
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Debug: Print error to console
            debugPrint('Failed to load crop image in AddCropScreen: $error');
            // Fallback to agriculture icon if image fails to load
            return const Icon(Icons.agriculture);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Crop' : 'Add New Crop'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Planting: Up to 1 year ago to 3 months future\nHarvest: Today to 2 years future',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Crop Name *',
                border: const OutlineInputBorder(),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildCropIcon(),
                ),
                helperText: 'Enter the name of your crop (2-50 characters)',
              ),
              validator: Validators.validateCropName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Planting Date Selector
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: _plantingDate != null ? Colors.green : null,
                ),
                title: const Text('Planting Date *'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _plantingDate != null
                          ? DateFormat(
                              'EEEE, MMM dd, yyyy',
                            ).format(_plantingDate!)
                          : 'Select planting date',
                      style: TextStyle(
                        color: _plantingDate != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontWeight: _plantingDate != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    if (_plantingDate != null)
                      Text(
                        'Range: ${DateFormat('MMM dd, yyyy').format(_minPlantingDate)} - ${DateFormat('MMM dd, yyyy').format(_maxPlantingDate)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _selectPlantingDate(context),
              ),
            ),
            const SizedBox(height: 8),

            // Harvest Date Selector
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.event,
                  color: _expectedHarvestDate != null ? Colors.orange : null,
                ),
                title: const Text('Expected Harvest Date *'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _expectedHarvestDate != null
                          ? DateFormat(
                              'EEEE, MMM dd, yyyy',
                            ).format(_expectedHarvestDate!)
                          : 'Select harvest date',
                      style: TextStyle(
                        color: _expectedHarvestDate != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontWeight: _expectedHarvestDate != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    if (_plantingDate != null)
                      Text(
                        'Minimum: ${DateFormat('MMM dd, yyyy').format(_plantingDate!.add(const Duration(days: 1)))}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _selectHarvestDate(context),
                enabled:
                    true, // Always enabled, but will show appropriate date range
              ),
            ),

            // Growth period indicator
            if (_plantingDate != null && _expectedHarvestDate != null) ...[
              const SizedBox(height: 8),
              Card(
                color: _dateValidationError == null
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        _dateValidationError == null
                            ? Icons.check_circle
                            : Icons.error,
                        color: _dateValidationError == null
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dateValidationError ?? _getGrowthPeriodText(),
                          style: TextStyle(
                            color: _dateValidationError == null
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
                helperText: 'Add any additional information about your crop',
              ),
              maxLines: 3,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _saveCrop,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isEditing ? Icons.update : Icons.add),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Update Crop' : 'Add Crop',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
