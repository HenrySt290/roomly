import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/properties/providers/property_notifier.dart';
import 'package:roomly/features/payment/providers/payment_notifier.dart';
import 'package:roomly/presentation/widgets/common_widgets.dart';
import 'package:roomly/features/payment/presentation/screens/access_pass_purchase_screen.dart';
import 'package:roomly/features/location/presentation/widgets/property_location_map.dart';
import 'package:roomly/features/reviews/providers/review_notifier.dart';
import 'package:roomly/features/reviews/presentation/widgets/review_card.dart';
import 'package:roomly/features/reviews/presentation/widgets/rating_stars.dart';
import 'package:roomly/features/reviews/presentation/widgets/review_form.dart';
import 'package:roomly/features/reviews/presentation/screens/review_list_screen.dart';
import 'package:roomly/features/enquiries/providers/enquiry_notifier.dart';
import 'package:roomly/features/enquiries/presentation/screens/enquiry_chat_screen.dart';

/// Property Detail Screen with Access Pass logic
class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isLoading = true;
  bool _hasActivePass = false;

  @override
  void initState() {
    super.initState();
    _checkAccessPassAndLoadProperty();
  }

  Future<void> _checkAccessPassAndLoadProperty() async {
    setState(() => _isLoading = true);
    
    // Check if user has active access pass
    final paymentNotifier = context.read<PaymentNotifier>();
    final isPassActive = paymentNotifier.state is AccessPassActivated ||
        (paymentNotifier.state is PaymentSuccess && 
         paymentNotifier.state.paymentType == 'access_pass');
    
    setState(() {
      _hasActivePass = isPassActive;
      _isLoading = false;
    });
    
    // Load property details
    if (mounted) {
      context.read<PropertyNotifier>().loadPropertyDetail(widget.propertyId);
      // Load reviews for property (new review feature)
      context.read<ReviewNotifier>().loadReviews(widget.propertyId);
    }
  }

  void _handlePurchasePass() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccessPassPurchaseScreen()),
    );
  }

  Future<void> _handleChatWithOwner() async {
    final property = context.read<PropertyNotifier>().selectedProperty;
    if (property == null) return;
    final enquiryNotifier = context.read<EnquiryNotifier>();

    // Show dialog to enter initial message
    final messageController = TextEditingController(text: 'Hi, I am interested in ${property.title}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send Enquiry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Property: ${property.title}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
        ],
      ),
    );

    if (confirmed != true) return;

    final enquiry = await enquiryNotifier.createEnquiry(
      propertyId: property.id,
      message: messageController.text.trim(),
    );

    if (!mounted) return;

    if (enquiry != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnquiryChatScreen(enquiryId: enquiry.id, isOwnerView: false),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(enquiryNotifier.errorMessage ?? 'Failed to send enquiry'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _launchWhatsApp(String phone, String propertyTitle) async {
    final message = "Hi, I am interested in your property '$propertyTitle' listed on Roomly.";
    final url = "https://wa.me/91$phone?text=${Uri.encodeComponent(message)}";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    }
  }

  Future<void> _launchCall(String phone) async {
    final url = "tel:+91$phone";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not initiate phone call.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied to clipboard!')),
              );
            },
          ),
          Consumer<PropertyNotifier>(
            builder: (context, notifier, _) {
              final property = notifier.selectedProperty;
              final isFavourite = property != null && notifier.isFavourite(property.id);
              return IconButton(
                icon: Icon(isFavourite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  if (property != null) {
                    notifier.toggleFavourite(property.id);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? CommonWidgets.buildLoading()
          : Consumer<PropertyNotifier>(
              builder: (context, notifier, _) {
                if (notifier.selectedProperty == null) {
                  return CommonWidgets.buildEmptyState(
                    title: 'Property Not Found',
                    subtitle: 'The property you are looking for does not exist.',
                    icon: Icons.home_outlined,
                    onRefresh: () => notifier.loadPropertyDetail(widget.propertyId),
                  );
                }
                
                final property = notifier.selectedProperty!;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Images
                      _buildImageGallery(property),
                      
                      // Property Details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Rent
                            Text(
                              property.title ?? 'Property Title',
                              style: AppTextStyles.h2,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CommonWidgets.buildPriceTag(property.rent ?? 0, isLarge: true),
                                const SizedBox(width: 8),
                                Text(
                                  '/month',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Location
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.textHint),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _hasActivePass
                                          ? property.address ?? '${property.area}, ${property.city}'
                                          : '${property.area}, ${property.city}',
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                      if (!_hasActivePass)
                                        Text(
                                          'Full address visible after purchase',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Key Features
                            _buildSectionTitle('Key Features'),
                            _buildFeaturesGrid(property),
                            const SizedBox(height: 24),
                            
                            // Amenities
                            _buildSectionTitle('Amenities'),
                            _buildAmenitiesList(property),
                            const SizedBox(height: 24),
                            
                            // Description
                            _buildSectionTitle('Description'),
                            Text(
                              _hasActivePass
                                ? property.description ?? 'No description available.'
                                : (property.description.length > 100
                                    ? '${property.description.substring(0, 100)}...'
                                    : property.description),
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            
                            // Owner Info (Hidden without pass)
                            if (_hasActivePass && property.ownerName != null) ...[
                              _buildSectionTitle('Owner Details'),
                              _buildOwnerCard(property),
                              const SizedBox(height: 24),
                            ],
                            
                            // Location Map (Only visible with active pass)
                            if (_hasActivePass) ...[
                              _buildSectionTitle('Location Map'),
                              _buildLocationMap(property),
                              const SizedBox(height: 24),
                            ],

                            // Reviews Section (new)
                            _buildReviewsSection(),
                            const SizedBox(height: 24),

                            // CTA Button
                            _buildCTAButton(property),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildImageGallery(dynamic property) {
    final imageCount = property.images?.length ?? 0;
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey[300],
            child: imageCount > 0 && property.images!.isNotEmpty
                ? Image.network(
                    property.images!.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.home, size: 100, color: Colors.grey[400]),
                  )
                : Icon(Icons.home, size: 100, color: Colors.grey[400]),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '1/$imageCount',
                style: AppTextStyles.caption.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.h4,
      ),
    );
  }

  Widget _buildFeaturesGrid(dynamic property) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildFeatureItem(Icons.bed, 'Type: ${property.propertyType.value}'),
        _buildFeatureItem(Icons.room_service, 'Room: ${property.roomType.value}'),
        _buildFeatureItem(Icons.home_work, property.isFurnished ? 'Furnished' : 'Unfurnished'),
        _buildFeatureItem(Icons.calendar_today, property.availableFrom != null ? 'Avail: ${_formatDate(property.availableFrom!)}' : 'Available Now'),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesList(dynamic property) {
    final amenities = property.amenities ?? [];
    if (amenities.isEmpty) {
      return Text('No amenities listed', style: AppTextStyles.bodySmall);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.map<Widget>((amenity) {
        IconData icon;
        String label = amenity.toString();
        
        switch (label.toLowerCase()) {
          case 'wifi':
            icon = Icons.wifi;
            break;
          case 'parking':
            icon = Icons.local_parking;
            break;
          case 'ac':
          case 'air conditioning':
            icon = Icons.ac_unit;
            break;
          case 'tv':
            icon = Icons.tv;
            break;
          case 'water':
          case '24x7 water':
            icon = Icons.water_drop;
            break;
          case 'security':
            icon = Icons.security;
            break;
          case 'gym':
            icon = Icons.fitness_center;
            break;
          case 'elevator':
            icon = Icons.elevator;
            break;
          default:
            icon = Icons.check_circle_outline;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.bodyMedium),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOwnerCard(dynamic property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                child: Icon(Icons.person, size: 32, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.ownerName ?? 'Property Owner',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verified Landlord',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchWhatsApp('9876543210', property.title),
                  icon: const Icon(Icons.whatsapp, color: AppColors.success),
                  label: const Text('WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.success, width: 2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchCall('9876543210'),
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(dynamic property) {
    if (_hasActivePass) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleChatWithOwner,
              icon: const Icon(Icons.chat_bubble, color: Colors.white),
              label: const Text('Chat with Owner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchWhatsApp('9876543210', property.title),
                  icon: const Icon(Icons.whatsapp, color: AppColors.success),
                  label: const Text('WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.success, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchCall('9876543210'),
                  icon: const Icon(Icons.call, color: AppColors.primary),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Unlock Full Details',
            style: AppTextStyles.h4.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Purchase ₹5 Access Pass for 24 hours',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handlePurchasePass,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Buy Access Pass - ₹5',
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMap(dynamic property) {
    final latitude = property.latitude ?? 28.6139;
    final longitude = property.longitude ?? 77.2090;
    
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PropertyLocationMap(
            initialLocation: LatLng(latitude, longitude),
            showCurrentLocationButton: false,
            height: 250,
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_open, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Location Unlocked',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Consumer<ReviewNotifier>(builder: (context, reviewNotifier, _) {
      final reviews = reviewNotifier.reviews;
      final avg = reviewNotifier.averageRating;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Reviews (${reviews.length})'),
              if (reviews.isNotEmpty)
                TextButton(
                  onPressed: () {
                    final prop = context.read<PropertyNotifier>().selectedProperty;
                    if (prop == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewListScreen(
                          propertyId: prop.id,
                          propertyTitle: prop.title,
                        ),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          if (reviews.isNotEmpty) ...[
            Row(
              children: [
                RatingStars(rating: avg, size: 20),
                const SizedBox(width: 8),
                Text('${avg.toStringAsFixed(1)} • ${reviews.length} reviews',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ...reviews.take(2).map((r) => ReviewCard(review: r)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reviews_outlined, color: AppColors.textHint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('No reviews yet. Be the first to review!',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ReviewForm.show(context, widget.propertyId),
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Write a Review'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    });
  }
}
