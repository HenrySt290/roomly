import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/properties/providers/property_notifier.dart';
import 'package:roomly/features/search/presentation/widgets/filter_chip_widget.dart';
import 'package:roomly/features/search/presentation/widgets/search_bar_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedCity = 'All';
  String _selectedPropertyType = 'All';
  String _selectedRoomType = 'All';
  RangeValues _rentRange = const RangeValues(0, 50000);
  bool _furnished = false;
  bool _attachedBathroom = false;
  bool _parking = false;
  bool _wifi = false;
  bool _petFriendly = false;
  String _sortBy = 'newest';
  bool _showFilters = false;

  final List<String> _cities = ['All', 'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Pune', 'Hyderabad'];
  final List<String> _propertyTypes = ['All', 'Apartment', 'House', 'PG', 'Hostel'];
  final List<String> _roomTypes = ['All', '1 RK', '1 BHK', '2 BHK', '3 BHK', 'Shared'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyNotifier>().loadProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Properties'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          const SearchBarWidget(),
          
          // Filters Section
          if (_showFilters) _buildFiltersPanel(),
          
          // Quick Filters
          _buildQuickFilters(),
          
          // Results Count
          _buildResultsCount(),
          
          // Property List
          Expanded(child: _buildPropertyList()),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // City Filter
          _buildFilterSection('City', DropdownButton<String>(
            value: _selectedCity,
            underline: const SizedBox(),
            items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
            onChanged: (value) => setState(() => _selectedCity = value!),
          )),
          const SizedBox(height: 12),
          
          // Property Type
          _buildFilterSection('Property Type', DropdownButton<String>(
            value: _selectedPropertyType,
            underline: const SizedBox(),
            items: _propertyTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) => setState(() => _selectedPropertyType = value!),
          )),
          const SizedBox(height: 12),
          
          // Room Type
          _buildFilterSection('Room Type', DropdownButton<String>(
            value: _selectedRoomType,
            underline: const SizedBox(),
            items: _roomTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) => setState(() => _selectedRoomType = value!),
          )),
          const SizedBox(height: 16),
          
          // Rent Range
          Text('Rent Range', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          RangeSlider(
            values: _rentRange,
            min: 0,
            max: 50000,
            divisions: 50,
            labels: RangeLabels('₹${_rentRange.start.toInt()}', '₹${_rentRange.end.toInt()}'),
            onChanged: (values) => setState(() => _rentRange = values),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${_rentRange.start.toInt()}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                Text('₹${_rentRange.end.toInt()}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Amenities
          Text('Amenities', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(label: const Text('Furnished'), selected: _furnished, onSelected: (v) => setState(() => _furnished = v)),
              FilterChip(label: const Text('Attached Bathroom'), selected: _attachedBathroom, onSelected: (v) => setState(() => _attachedBathroom = v)),
              FilterChip(label: const Text('Parking'), selected: _parking, onSelected: (v) => setState(() => _parking = v)),
              FilterChip(label: const Text('WiFi'), selected: _wifi, onSelected: (v) => setState(() => _wifi = v)),
              FilterChip(label: const Text('Pet Friendly'), selected: _petFriendly, onSelected: (v) => setState(() => _petFriendly = v)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Sort By
          Text('Sort By', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(label: const Text('Newest'), selected: _sortBy == 'newest', onSelected: (v) => setState(() => _sortBy = 'newest')),
              FilterChip(label: const Text('Lowest Rent'), selected: _sortBy == 'lowest_rent', onSelected: (v) => setState(() => _sortBy = 'lowest_rent')),
              FilterChip(label: const Text('Highest Rent'), selected: _sortBy == 'highest_rent', onSelected: (v) => setState(() => _sortBy = 'highest_rent')),
            ],
          ),
          const SizedBox(height: 16),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String label, Widget child) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        child,
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(label: const Text('All'), selected: _selectedCity == 'All', onSelected: (_) => setState(() => _selectedCity = 'All')),
            const SizedBox(width: 8),
            ..._cities.where((c) => c != 'All').map((city) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(label: Text(city), selected: _selectedCity == city, onSelected: (_) => setState(() => _selectedCity = city)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCount() {
    return Consumer<PropertyNotifier>(
      builder: (context, notifier, _) {
        final count = notifier.properties.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '$count propert${count == 1 ? 'y' : 'ies'} found',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          ),
        );
      },
    );
  }

  Widget _buildPropertyList() {
    return Consumer<PropertyNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notifier.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Failed to load properties', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: () => notifier.loadProperties(), child: const Text('Retry')),
              ],
            ),
          );
        }
        if (notifier.properties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppColors.textLight),
                const SizedBox(height: 16),
                Text('No properties found', style: AppTextStyles.headingSmall.copyWith(color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text('Try adjusting your filters', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => notifier.loadProperties(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifier.properties.length,
            itemBuilder: (ctx, index) {
              final property = notifier.properties[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: property.images.isNotEmpty
                        ? Image.network(property.images.first, width: 60, height: 60, fit: BoxFit.cover)
                        : Container(width: 60, height: 60, color: AppColors.border, child: const Icon(Icons.home)),
                  ),
                  title: Text(property.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('${property.area}, ${property.city}'),
                  trailing: Text('₹${property.rent.toInt()}', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Navigate to detail
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _applyFilters() {
    // TODO: Apply filters to property search
    setState(() => _showFilters = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters applied (backend integration pending)')),
    );
  }
}
