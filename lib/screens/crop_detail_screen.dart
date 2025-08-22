import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/crop.dart';
import '../providers/crop_provider.dart';
import 'add_crop_screen.dart';

class CropDetailScreen extends StatelessWidget {
  final String cropId;

  const CropDetailScreen({super.key, required this.cropId});

  Future<void> _showDeleteConfirmation(BuildContext context, Crop crop) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text('Are you sure you want to delete "${crop.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CropProvider>().deleteCrop(crop.id);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Crop deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    Crop crop,
    CropStatus newStatus,
  ) async {
    final updatedCrop = crop.copyWith(status: newStatus);
    await context.read<CropProvider>().updateCrop(crop.id, updatedCrop);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildCropImage() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/icons/crop.jpg',
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Debug: Print error to console
            debugPrint('Failed to load crop image in CropDetailScreen: $error');
            // Fallback to agriculture icon if image fails to load
            return Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.agriculture,
                size: 32,
                color: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final cropProvider = context.read<CropProvider>();
              final crop = cropProvider.getCropById(cropId);
              if (crop == null) return;

              switch (value) {
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCropScreen(cropToEdit: crop),
                    ),
                  );
                  break;
                case 'delete':
                  await _showDeleteConfirmation(context, crop);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<CropProvider>(
        builder: (context, cropProvider, child) {
          final crop = cropProvider.getCropById(cropId);

          if (crop == null) {
            return const Center(child: Text('Crop not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildCropImage(),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    crop.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: crop.statusColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      crop.statusText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Planting Date'),
                        subtitle: Text(
                          DateFormat(
                            'EEEE, MMM dd, yyyy',
                          ).format(crop.plantingDate),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('Expected Harvest Date'),
                        subtitle: Text(
                          DateFormat(
                            'EEEE, MMM dd, yyyy',
                          ).format(crop.expectedHarvestDate),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.timer),
                        title: const Text('Days Until Harvest'),
                        subtitle: Text(
                          _getDaysUntilHarvest(crop),
                          style: TextStyle(
                            color:
                                _getDaysUntilHarvest(crop).contains('overdue')
                                ? Colors.red
                                : _getDaysUntilHarvest(crop).contains('today')
                                ? Colors.orange
                                : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (crop.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notes),
                              const SizedBox(width: 8),
                              Text(
                                'Notes',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              crop.notes,
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                if (crop.status != CropStatus.harvested) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Status',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: CropStatus.values.map((status) {
                              if (status == crop.status)
                                return const SizedBox.shrink();

                              return ElevatedButton.icon(
                                onPressed: () =>
                                    _updateStatus(context, crop, status),
                                icon: Icon(_getStatusIcon(status), size: 18),
                                label: Text(
                                  status.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getStatusColor(status),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDaysUntilHarvest(Crop crop) {
    final now = DateTime.now();
    final difference = crop.expectedHarvestDate.difference(now).inDays;

    if (crop.status == CropStatus.harvested) {
      return 'Already harvested';
    } else if (difference < 0) {
      return '${difference.abs()} days overdue';
    } else if (difference == 0) {
      return 'Ready today!';
    } else {
      return '$difference days remaining';
    }
  }

  IconData _getStatusIcon(CropStatus status) {
    switch (status) {
      case CropStatus.growing:
        return Icons.grass;
      case CropStatus.ready:
        return Icons.eco;
      case CropStatus.harvested:
        return Icons.check_circle;
    }
  }

  Color _getStatusColor(CropStatus status) {
    switch (status) {
      case CropStatus.growing:
        return const Color(0xFF4CAF50);
      case CropStatus.ready:
        return const Color(0xFFFF9800);
      case CropStatus.harvested:
        return const Color(0xFF8D6E63);
    }
  }
}
