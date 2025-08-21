import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crop.dart';
import '../screens/crop_detail_screen.dart';

class CropCard extends StatelessWidget {
  final Crop crop;

  const CropCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CropDetailScreen(cropId: crop.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.agriculture,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Planted: ${DateFormat('MMM dd, yyyy').format(crop.plantingDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: crop.statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      crop.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Harvest: ${DateFormat('MMM dd, yyyy').format(crop.expectedHarvestDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    _getDaysText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDaysColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (crop.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  crop.notes,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDaysText() {
    final now = DateTime.now();
    final difference = crop.expectedHarvestDate.difference(now).inDays;
    
    if (crop.status == CropStatus.harvested) {
      return 'Harvested';
    } else if (difference < 0) {
      return '${difference.abs()} days overdue';
    } else if (difference == 0) {
      return 'Ready today!';
    } else {
      return '$difference days left';
    }
  }

  Color _getDaysColor() {
    if (crop.status == CropStatus.harvested) {
      return const Color(0xFF8D6E63);
    }
    
    final now = DateTime.now();
    final difference = crop.expectedHarvestDate.difference(now).inDays;
    
    if (difference < 0) {
      return Colors.red;
    } else if (difference <= 7) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFF4CAF50);
    }
  }
}
