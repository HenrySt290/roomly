import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/domain/entities/property_entity.dart';
import 'package:roomly/features/properties/providers/property_notifier.dart';
import 'package:roomly/features/search/providers/search_notifier.dart';
import 'package:roomly/features/search/domain/entities/search_filter_entity.dart';
import 'package:roomly/features/search/presentation/widgets/search_map_view.dart';
import 'package:roomly/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:roomly/features/location/providers/location_notifier.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isMapView = false;
  PropertyEntity? _selectedPropertyForMap;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyNotifier>().loadProperties();
      context.read<SearchNotifier>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Search & Explore'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list_alt : Icons.map_outlined),
            tooltip: _isMapView ? 'List View' : 'Map View',
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
          Consumer<SearchNotifier>(builder: (context, searchNotifier, _) {
            final count = searchNotifier.state.filters.activeFiltersCount;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => _showFiltersBottomSheet(context),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Text('$count',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Unified Search Bar with integrated map filter queries
          _buildSearchBar(),
          // Quick city chips + rent range
          _buildQuickFilters(),
          // Results count + sort
          _buildResultsHeader(),
          // Main content: list or map
          Expanded(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by city, area, property name...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PropertyNotifier>().loadProperties(refresh: true);
                    setState(() {});
                  },
                ),
              IconButton(
                icon: const Icon(Icons.my_location, color: AppColors.primary),
                tooltip: 'Near me',
                onPressed: () {
                  final locNotifier = context.read<LocationNotifier>();
                  locNotifier.requestPermission();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Finding nearby properties...')),
                  );
                },
              ),
            ],
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
        onChanged: (value) {
          // Debounced search via PropertyNotifier with city filter
          final notifier = context.read<PropertyNotifier>();
          if (value.isEmpty) {
            notifier.setFilters(const PropertyFilters());
            notifier.loadProperties(refresh: true);
          } else {
            notifier.setFilters(PropertyFilters(city: value));
            notifier.loadProperties(refresh: true);
          }
        },
        onSubmitted: (value) {
          final searchNotifier = context.read<SearchNotifier>();
          searchNotifier.updateFilter('city', value);
          searchNotifier.searchProperties(isRefresh: true);
        },
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Consumer<SearchNotifier>(builder: (context, searchNotifier, _) {
      final filters = searchNotifier.state.filters;
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _quickChip('All', filters.city == null, () {
              searchNotifier.resetFilters();
              context.read<PropertyNotifier>().setFilters(const PropertyFilters());
              context.read<PropertyNotifier>().loadProperties(refresh: true);
            }),
            const SizedBox(width: 8),
            for (final city in ['Mumbai', 'Delhi', 'Bangalore', 'Pune', 'Hyderabad'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _quickChip(city, filters.city == city, () {
                  searchNotifier.updateFilter('city', city);
                  searchNotifier.loadAreas(city);
                  context.read<PropertyNotifier>().setFilters(PropertyFilters(city: city));
                  context.read<PropertyNotifier>().loadProperties(refresh: true);
                }),
              ),
            const SizedBox(width: 8),
            _quickChip('Furnished', filters.furnished == true, () {
              final newVal = filters.furnished != true;
              searchNotifier.updateFilter('furnished', newVal ? true : null);
            }),
            const SizedBox(width: 8),
            _quickChip('Parking', filters.parking == true, () {
              final newVal = filters.parking != true;
              searchNotifier.updateFilter('parking', newVal ? true : null);
            }),
            const SizedBox(width: 8),
            _quickChip('WiFi', filters.wifi == true, () {
              final newVal = filters.wifi != true;
              searchNotifier.updateFilter('wifi', newVal ? true : null);
            }),
          ],
        ),
      );
    });
  }

  Widget _quickChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: selected ? AppColors.primary : AppColors.border)),
    );
  }

  Widget _buildResultsHeader() {
    return Consumer2<PropertyNotifier, SearchNotifier>(builder: (context, propNotifier, searchNotifier, _) {
      final count = propNotifier.properties.length;
      final activeFilters = searchNotifier.state.filters.activeFiltersCount;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$count ${count == 1 ? 'property' : 'properties'} found${activeFilters > 0 ? ' • $activeFilters filters' : ''}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            Row(
              children: [
                if (activeFilters > 0)
                  TextButton(
                    onPressed: () {
                      searchNotifier.resetFilters();
                      propNotifier.setFilters(const PropertyFilters());
                      propNotifier.loadProperties(refresh: true);
                    },
                    child: const Text('Clear'),
                  ),
                DropdownButton<String>(
                  value: 'newest',
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    DropdownMenuItem(value: 'lowest_rent', child: Text('Lowest')),
                    DropdownMenuItem(value: 'highest_rent', child: Text('Highest')),
                    DropdownMenuItem(value: 'nearest', child: Text('Nearest')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      searchNotifier.updateFilter('sortBy', v);
                      propNotifier.setFilters(propNotifier.filters.copyWith(sortBy: v));
                      propNotifier.loadProperties(refresh: true);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildListView() {
    return Consumer<PropertyNotifier>(builder: (context, notifier, _) {
      if (notifier.isLoading && notifier.properties.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (notifier.error != null && notifier.properties.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(notifier.error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => notifier.loadProperties(refresh: true), child: const Text('Retry')),
            ],
          ),
        );
      }
      if (notifier.properties.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text('No properties match your filters', style: AppTextStyles.h4),
              const SizedBox(height: 6),
              Text('Try adjusting city, rent range or amenities',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<SearchNotifier>().resetFilters();
                  notifier.setFilters(const PropertyFilters());
                  notifier.loadProperties(refresh: true);
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => notifier.loadProperties(refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifier.properties.length,
          itemBuilder: (ctx, idx) {
            final p = notifier.properties[idx];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: p.images.isNotEmpty
                      ? Image.network(p.images.first, width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: AppColors.border, child: const Icon(Icons.home)))
                      : Container(width: 60, height: 60, color: AppColors.border, child: const Icon(Icons.home)),
                ),
                title: Text(p.title, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p.area}, ${p.city}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('₹${p.rent.toStringAsFixed(0)}',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(p.roomType.value, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PropertyDetailScreen(propertyId: p.id)),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildMapView() {
    return Consumer<PropertyNotifier>(builder: (context, notifier, _) {
      final properties = notifier.properties;
      return Stack(
        children: [
          SearchMapView(
            properties: properties,
            onMarkerTap: (prop) {
              setState(() => _selectedPropertyForMap = prop);
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => SearchMapBottomSheet(
                  property: prop,
                  onViewDetails: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PropertyDetailScreen(propertyId: prop.id)),
                    );
                  },
                ),
              );
            },
          ),
          // Map overlay with count
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('${properties.length} listings in this area',
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (_selectedPropertyForMap != null)
                    Text('₹${_selectedPropertyForMap!.rent.toStringAsFixed(0)} selected',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ),
          // My location FAB
          Positioned(
            bottom: 20,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: () {
                context.read<LocationNotifier>().getCurrentLocation();
              },
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      );
    });
  }

  void _showFiltersBottomSheet(BuildContext context) {
    final searchNotifier = context.read<SearchNotifier>();
    final propNotifier = context.read<PropertyNotifier>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          final filters = searchNotifier.state.filters;
          RangeValues rentRange = RangeValues(
            filters.minRent ?? 0,
            filters.maxRent ?? 50000,
          );
          return Container(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters', style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () {
                          searchNotifier.resetFilters();
                          propNotifier.setFilters(const PropertyFilters());
                          setModalState(() {});
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text('Rent Range', style: AppTextStyles.labelLarge),
                  RangeSlider(
                    values: rentRange,
                    min: 0,
                    max: 50000,
                    divisions: 50,
                    labels: RangeLabels('₹${rentRange.start.toInt()}', '₹${rentRange.end.toInt()}'),
                    onChanged: (v) => setModalState(() => rentRange = v),
                    onChangeEnd: (v) {
                      searchNotifier.updateFilter('minRent', v.start);
                      searchNotifier.updateFilter('maxRent', v.end);
                      propNotifier.setFilters(propNotifier.filters.copyWith(minRent: v.start, maxRent: v.end));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${rentRange.start.toInt()}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                      Text('₹${rentRange.end.toInt()}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Property Type', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['apartment', 'house', 'pg', 'villa'].map((type) {
                      final selected = filters.propertyType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (_) {
                          searchNotifier.updateFilter('propertyType', selected ? null : type);
                          // Trigger property filter
                          PropertyType? pt;
                          if (!selected) {
                            try {
                              pt = PropertyType.fromString(type);
                            } catch (_) {}
                          }
                          propNotifier.setFilters(propNotifier.filters.copyWith(propertyType: selected ? null : pt));
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Amenities', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Furnished'),
                        selected: filters.furnished == true,
                        onSelected: (v) {
                          searchNotifier.updateFilter('furnished', v ? true : null);
                          propNotifier.setFilters(propNotifier.filters.copyWith(furnished: v ? true : null));
                          setModalState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('Parking'),
                        selected: filters.parking == true,
                        onSelected: (v) {
                          searchNotifier.updateFilter('parking', v ? true : null);
                          propNotifier.setFilters(propNotifier.filters.copyWith(parking: v ? true : null));
                          setModalState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('WiFi'),
                        selected: filters.wifi == true,
                        onSelected: (v) {
                          searchNotifier.updateFilter('wifi', v ? true : null);
                          propNotifier.setFilters(propNotifier.filters.copyWith(wifi: v ? true : null));
                          setModalState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('Pet Friendly'),
                        selected: filters.petFriendly == true,
                        onSelected: (v) {
                          searchNotifier.updateFilter('petFriendly', v ? true : null);
                          propNotifier.setFilters(propNotifier.filters.copyWith(petFriendly: v ? true : null));
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        propNotifier.loadProperties(refresh: true);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
