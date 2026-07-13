import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entity.dart';
import '../../providers/property_notifier.dart';
import '../widgets/property_card.dart';
import '../widgets/property_status_chip.dart';
import 'add_property_screen.dart';
import 'property_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({Key? key}) : super(key: key);

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyNotifier>().loadOwnerProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
              );
              if (result == true) {
                context.read<PropertyNotifier>().loadOwnerProperties();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Published', 'published'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending_approval'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Occupied', 'occupied'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Expired', 'expired'),
                ],
              ),
            ),
          ),

          // Listings List
          Expanded(
            child: Consumer<PropertyNotifier>(
              builder: (context, notifier, _) {
                if (notifier.ownerPropertiesState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (notifier.ownerPropertiesState.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load listings',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => notifier.loadOwnerProperties(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var properties = notifier.ownerProperties;
                
                // Apply filter
                if (_filterStatus != 'all') {
                  properties = properties
                      .where((p) => p.status == _filterStatus)
                      .toList();
                }

                if (properties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filterStatus == 'all'
                              ? 'No listings yet'
                              : 'No $_filterStatus listings',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _filterStatus == 'all'
                              ? 'Tap + to add your first property'
                              : 'Try a different filter',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                        if (_filterStatus == 'all') ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddPropertyScreen(),
                                ),
                              );
                              if (result == true) {
                                notifier.loadOwnerProperties();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Property'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => notifier.loadOwnerProperties(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: properties.length,
                    itemBuilder: (ctx, index) {
                      final property = properties[index];
                      return _buildListingCard(property);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterStatus = status),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textDark,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildListingCard(PropertyEntity property) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: property.images.isNotEmpty
                        ? Image.network(
                            property.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.border,
                              child: Icon(Icons.image_not_supported,
                                  size: 48, color: AppColors.textLight),
                            ),
                          )
                        : Container(
                            color: AppColors.border,
                            child: Icon(Icons.home, size: 48, color: AppColors.textLight),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PropertyStatusChip(status: property.status),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${property.area}, ${property.city}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\u20B9${property.rent.toStringAsFixed(0)}/month',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (property.deposit > 0)
                        Text(
                          '+ \u20B9${property.deposit.toStringAsFixed(0)} deposit',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildInfoChip(Icons.bed, '${property.roomType}'),
                          const SizedBox(width: 8),
                          if (property.furnished)
                            _buildInfoChip(Icons.chair, 'Furnished'),
                        ],
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleMenuAction(value, property),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit, size: 20),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          if (property.status == 'published')
                            const PopupMenuItem(
                              value: 'occupy',
                              child: ListTile(
                                leading: Icon(Icons.lock, size: 20),
                                title: Text('Mark Occupied'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          if (property.status == 'occupied')
                            const PopupMenuItem(
                              value: 'relist',
                              child: ListTile(
                                leading: Icon(Icons.refresh, size: 20),
                                title: Text('Relist (\u20B99)'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, size: 20, color: AppColors.error),
                              title: Text('Delete', style: TextStyle(color: AppColors.error)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, PropertyEntity property) {
    switch (action) {
      case 'edit':
        Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => AddPropertyScreen(initialProperty: property),
          ),
        ).then((result) {
          if (result == true) {
            context.read<PropertyNotifier>().loadOwnerProperties();
          }
        });
        break;
      case 'occupy':
        _showConfirmDialog(
          'Mark as Occupied?',
          'This will hide the listing until you relist it.',
          () async {
            await context.read<PropertyNotifier>().markOccupied(property.id);
            context.read<PropertyNotifier>().loadOwnerProperties();
          },
        );
        break;
      case 'relist':
        _showConfirmDialog(
          'Relist Property?',
          'A \u20B99 fee will be charged to relist this property.',
          () async {
            await context.read<PropertyNotifier>().relistProperty(property.id);
            context.read<PropertyNotifier>().loadOwnerProperties();
          },
        );
        break;
      case 'delete':
        _showConfirmDialog(
          'Delete Property?',
          'This action cannot be undone.',
          () async {
            await context.read<PropertyNotifier>().deleteProperty(property.id);
            context.read<PropertyNotifier>().loadOwnerProperties();
          },
          isDestructive: true,
        );
        break;
    }
  }

  void _showConfirmDialog(
    String title,
    String message,
    VoidCallback onConfirm, {
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
            ),
            child: Text(isDestructive ? 'Delete' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}
