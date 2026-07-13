import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/property_notifier.dart';
import '../../../providers/auth_notifier.dart';
import '../../../payment/providers/payment_notifier.dart';
import '../widgets/common_widgets.dart';
import 'property_detail_screen.dart';
import ../../../location/presentation/widgets/property_map_view.dart;
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
              // TODO: Navigate to notifications
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
              // TODO: Show filter dialog
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
          // TODO: Implement search
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
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
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Implement filter logic
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
              return _buildPropertyCard(property);
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
        
        // Use the PropertyMapView widget
        return PropertyMapView(properties: notifier.properties);
      },
    );
  }

  Widget _buildPropertyCard(dynamic property) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(propertyId: property.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.home,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () {
                      // Toggle favorite
                      context.read<PropertyNotifier>().toggleFavourite(property.id);
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: CommonWidgets.buildBadge(
                    text: 'New',
                    backgroundColor: AppColors.success,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            // Property Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title ?? 'Property Title',
                    style: AppTextStyles.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.area ?? 'Area Name',
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CommonWidgets.buildPriceTag(
                        property.rent ?? 0,
                        isLarge: true,
                      ),
                      const Spacer(),
                      _buildAmenityIcon(Icons.bed, '${property.rooms ?? 1}'),
                      const SizedBox(width: 12),
                      _buildAmenityIcon(Icons.bathroom, '${property.bathrooms ?? 1}'),
                      const SizedBox(width: 12),
                      _buildAmenityIcon(Icons.square_foot, '${property.area ?? 0} sqft'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (property.furnished ?? false)
                        CommonWidgets.buildBadge(text: 'Furnished'),
                      if (property.furnished ?? false) const SizedBox(width: 8),
                      if (property.wifi ?? false)
                        CommonWidgets.buildBadge(text: 'WiFi'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityIcon(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        // Handle navigation based on index
        if (index == 2) {
          // Navigate to Saved/Favorites screen
          // TODO: Implement favorites screen
        } else if (index == 3) {
          // Navigate to Profile screen
          // TODO: Implement profile screen
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
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Saved',
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
    // Only show for owners
    final authState = context.watch<AuthNotifier>().state;
    if (authState is AuthAuthenticated && authState.role == 'owner') {
      return FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add property screen
        },
        icon: const Icon(Icons.add),
        label: const Text('List Property'),
        backgroundColor: AppColors.primary,
      );
    }
    return const SizedBox.shrink();
  }

  /// Navigate to Access Pass purchase screen
  void _navigateToAccessPassPurchase() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccessPassPurchaseScreen()),
    );
  }
}
