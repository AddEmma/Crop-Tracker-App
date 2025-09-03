import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../widgets/crop_card.dart';
import '../models/crop.dart';
import 'add_crop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  CropStatus? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Filter by Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_selectedFilter != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = null;
                        });
                        context.read<CropProvider>().filterByStatus(null);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear All'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // All crops filter chip
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedFilter == null,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = null;
                      });
                      context.read<CropProvider>().filterByStatus(null);
                      Navigator.of(context).pop();
                    },
                  ),
                  // Status-based filter chips
                  ...CropStatus.values.map((status) {
                    final isSelected = _selectedFilter == status;
                    return ChoiceChip(
                      label: Text(status.name.capitalize()),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedFilter = status;
                        });
                        context.read<CropProvider>().filterByStatus(status);
                        Navigator.of(context).pop();
                      },
                      selectedColor: _getStatusColor(status).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? _getStatusColor(status) : null,
                        fontWeight: isSelected ? FontWeight.w500 : null,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Tracker'), elevation: 0),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).appBarTheme.backgroundColor ??
                  Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by notes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<CropProvider>().searchCrops('');
                              setState(() {});
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: _selectedFilter != null
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                          onPressed: _showFilterBottomSheet,
                          tooltip: 'Filter',
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    context.read<CropProvider>().searchCrops(value);
                    setState(() {});
                  },
                ),

                // Active Filter Indicator
                if (_selectedFilter != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              _selectedFilter!,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(
                                _selectedFilter!,
                              ).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_alt,
                                size: 14,
                                color: _getStatusColor(_selectedFilter!),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedFilter!.name.capitalize(),
                                style: TextStyle(
                                  color: _getStatusColor(_selectedFilter!),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = null;
                                  });
                                  context.read<CropProvider>().filterByStatus(
                                    null,
                                  );
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: _getStatusColor(_selectedFilter!),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Consumer<CropProvider>(
                          builder: (context, cropProvider, child) {
                            final totalCount = cropProvider.totalCropsCount;
                            final filteredCount =
                                cropProvider.filteredCropsCount;

                            return Text(
                              '$filteredCount of $totalCount',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Crops List
          Expanded(
            child: Consumer<CropProvider>(
              builder: (context, cropProvider, child) {
                final crops = cropProvider.crops;

                if (crops.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedFilter != null
                              ? Icons.filter_alt_off
                              : Icons.agriculture,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter != null
                              ? 'No ${_selectedFilter!.name.toLowerCase()} crops found'
                              : 'No crops found',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilter != null
                              ? 'Try a different filter or add new crops'
                              : 'Tap the + button to add your first crop',
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        if (_selectedFilter != null) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilter = null;
                              });
                              context.read<CropProvider>().filterByStatus(null);
                            },
                            child: const Text('Show All Crops'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    return CropCard(crop: crops[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCropScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
