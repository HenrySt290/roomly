import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/property_notifier.dart';
import '../../../providers/auth_notifier.dart';
import '../../../payment/providers/payment_notifier.dart';
import '../widgets/common_widgets.dart';
import '../widgets/property_card.dart';
import 'property_detail_screen.dart';
import '../../../location/presentation/widgets/property_map_view.dart';
import '../../../payment/presentation/screens/access_pass_purchase_screen.dart';

/// Main Property List Screen with search and filters
class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();
    // Load properties on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyNotifier>().loadProperties();
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
      appBar: AppBar(
        title: Text('Roomly', style: AppTextStyles.h4),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Filter Chips + Map Toggle
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('All', true),
                      _buildFilterChip('₹3k-₹5k', false),
                      _buildFilterChip('₹5k-₹8k', false),
                      _buildFilterChip('1 RK', false),
                      _buildFilterChip('1 BHK', false),
                      _buildFilterChip('2 BHK', false),
                      _buildFilterChip('Furnished', false),
                      _buildFilterChip('WiFi', false),
                    ],
                  ),
                ),
              ),
              // Map/List Toggle Button
              IconButton(
                icon: Icon(_isMapView ? Icons.list : Icons.map),
                tooltip: _isMapView ? 'Show List' : 'Show Map',
                onPressed: () {
                  setState(() {
                    _isMapView = !_isMapView;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: _isMapView ? AppColors.primary : AppColors.surface,
                  foregroundColor: _isMapView ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          // Property List or Map View
          Expanded(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by city, area, or locality...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (value) {
          context.read<PropertyNotifier>().loadProperties(city: value);
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Dynamic filter loading mock
          context.read<PropertyNotifier>().loadProperties();
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryLight.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  /// Build ListView with properties
  Widget _buildListView() {
    return Consumer<PropertyNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isLoading) {
          return CommonWidgets.buildLoading();
        }
        
        if (notifier.properties.isEmpty) {
          return CommonWidgets.buildEmptyState(
            title: 'No Properties Found',
            subtitle: 'Try adjusting your search or filters',
            icon: Icons.home_outlined,
            onRefresh: () => notifier.loadProperties(),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => notifier.loadProperties(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifier.properties.length,
            itemBuilder: (context, index) {
              final property = notifier.properties[index];
              return PropertyCard(
                property: property,
                isFavorite: notifier.isFavourite(property.id),
                onFavoriteToggle: () => notifier.toggleFavourite(property.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyDetailScreen(propertyId: property.id),
                    ),
                  );
                },
                showAccessBadge: true,
              );
            },
          ),
        );
      },
    );
  }

  /// Build Map View with property markers
  Widget _buildMapView() {
    return Consumer<PropertyNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isLoading) {
          return CommonWidgets.buildLoading();
        }
        
        if (notifier.properties.isEmpty) {
          return CommonWidgets.buildEmptyState(
            title: 'No Properties on Map',
            subtitle: 'Try adjusting your search area',
            icon: Icons.map_outlined,
            onRefresh: () => notifier.loadProperties(),
          );
        }
        
        // Safely map entities to JSON maps expected by PropertyMapView
        final propertiesJson = notifier.properties.map((p) => p.toJson()).toList();
        return PropertyMapView(properties: propertiesJson);
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 1) {
          Navigator.pushNamed(context, '/search');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/my-listings');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_work_outlined),
          activeIcon: Icon(Icons.home_work),
          label: 'My Listings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    final authState = context.watch<AuthNotifier>().state;
    if (authState is AuthAuthenticated && authState.role == 'owner') {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-property');
        },
        icon: const Icon(Icons.add),
        label: const Text('List Property'),
        backgroundColor: AppColors.primary,
      );
    }
    return const SizedBox.shrink();
  }
}
