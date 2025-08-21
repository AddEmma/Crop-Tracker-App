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

  bool get isEditing => widget.cropToEdit != null;

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

  Future<void> _selectDate(BuildContext context, bool isPlantingDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPlantingDate 
          ? (_plantingDate ?? DateTime.now())
          : (_expectedHarvestDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isPlantingDate) {
          _plantingDate = picked;
        } else {
          _expectedHarvestDate = picked;
        }
      });
    }
  }

  Future<void> _saveCrop() async {
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

    setState(() => _isLoading = true);

    try {
      final crop = Crop(
        id: isEditing ? widget.cropToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
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
            content: Text('Error ${isEditing ? 'updating' : 'adding'} crop: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Crop' : 'Add New Crop'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Crop Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.agriculture),
              ),
              validator: Validators.validateCropName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Planting Date'),
              subtitle: Text(
                _plantingDate != null
                    ? DateFormat('MMM dd, yyyy').format(_plantingDate!)
                    : 'Select planting date',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _selectDate(context, true),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Expected Harvest Date'),
              subtitle: Text(
                _expectedHarvestDate != null
                    ? DateFormat('MMM dd, yyyy').format(_expectedHarvestDate!)
                    : 'Select harvest date',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _selectDate(context, false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCrop,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update Crop' : 'Add Crop'),
            ),
          ],
        ),
      ),
    );
  }
}
