import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/core/utils/validators.dart';
import 'package:roomly/domain/entities/property_entity.dart';
import 'package:roomly/features/properties/providers/property_notifier.dart';
import 'package:roomly/presentation/widgets/common_widgets.dart';
import 'package:roomly/features/location/presentation/screens/location_picker_screen.dart';

class AddPropertyScreen extends StatefulWidget {
  final PropertyEntity? initialProperty;

  const AddPropertyScreen({Key? key, this.initialProperty}) : super(key: key);

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _rentController;
  late TextEditingController _depositController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _areaController;

  String _propertyType = 'Apartment';
  String _roomType = '1 RK';
  String _genderPreference = 'Any';
  bool _furnished = false;
  bool _attachedBathroom = false;
  bool _parking = false;
  bool _wifi = false;
  bool _petFriendly = false;
  
  double? _latitude;
  double? _longitude;
  String? _selectedAddress;
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialProperty?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initialProperty?.description ?? '');
    _rentController = TextEditingController(text: widget.initialProperty?.rent != null ? widget.initialProperty!.rent.toStringAsFixed(0) : '');
    _depositController = TextEditingController(text: widget.initialProperty?.securityDeposit != null ? widget.initialProperty!.securityDeposit.toStringAsFixed(0) : '');
    _addressController = TextEditingController(text: widget.initialProperty?.address ?? '');
    _cityController = TextEditingController(text: widget.initialProperty?.city ?? '');
    _areaController = TextEditingController(text: widget.initialProperty?.area ?? '');

    if (widget.initialProperty != null) {
      _propertyType = _getDisplayPropertyType(widget.initialProperty!.propertyType);
      _roomType = _getDisplayRoomType(widget.initialProperty!.roomType);
      _genderPreference = widget.initialProperty!.genderPreference ?? 'Any';
      _furnished = widget.initialProperty!.isFurnished;
      _attachedBathroom = widget.initialProperty!.hasAttachedBathroom;
      _parking = widget.initialProperty!.hasParking;
      _wifi = widget.initialProperty!.hasWifi;
      _petFriendly = widget.initialProperty!.isPetFriendly;
    }
  }

  String _getDisplayPropertyType(PropertyType type) {
    switch (type) {
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.house:
        return 'Independent House';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.pg:
        return 'PG';
      default:
        return 'Apartment';
    }
  }

  String _getDisplayRoomType(RoomType type) {
    switch (type) {
      case RoomType.r1rk:
        return '1 RK';
      case RoomType.bhk1:
        return '1 BHK';
      case RoomType.bhk2:
        return '2 BHK';
      case RoomType.bhk3:
        return '3 BHK';
      case RoomType.single:
        return 'Single Room';
      case RoomType.shared:
        return 'Shared Room';
      default:
        return '1 BHK';
    }
  }

  PropertyType _mapPropertyType(String value) {
    switch (value.toLowerCase()) {
      case 'apartment':
        return PropertyType.apartment;
      case 'independent house':
      case 'house':
        return PropertyType.house;
      case 'villa':
        return PropertyType.villa;
      case 'pg':
        return PropertyType.pg;
      default:
        return PropertyType.other;
    }
  }

  RoomType _mapRoomType(String value) {
    switch (value.toLowerCase()) {
      case '1 rk':
      case '1rk':
        return RoomType.r1rk;
      case '1 bhk':
      case '1bhk':
        return RoomType.bhk1;
      case '2 bhk':
      case '2bhk':
        return RoomType.bhk2;
      case '3 bhk':
      case '3bhk':
        return RoomType.bhk3;
      case 'single room':
      case 'single':
        return RoomType.single;
      case 'shared room':
      case 'shared':
        return RoomType.shared;
      default:
        return RoomType.single;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        limit: 5 - _selectedImages.length,
        imageQuality: 80,
      );
      if (pickedFiles != null) {
        setState(() => _selectedImages.addAll(pickedFiles));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty && widget.initialProperty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one property image')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final notifier = context.read<PropertyNotifier>();

    final amenities = <String>[];
    if (_furnished) amenities.add('wifi'); // alignment mockup
    if (_attachedBathroom) amenities.add('attached_bathroom');
    if (_parking) amenities.add('parking');
    if (_wifi) amenities.add('wifi');
    if (_petFriendly) amenities.add('pet_friendly');

    try {
      if (widget.initialProperty == null) {
        await notifier.createProperty(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          rent: double.parse(_rentController.text.trim()),
          deposit: double.parse(_depositController.text.trim()),
          propertyType: _mapPropertyType(_propertyType),
          roomType: _mapRoomType(_roomType),
          area: _areaController.text.trim(),
          city: _cityController.text.trim(),
          address: _addressController.text.trim(),
          latitude: _latitude ?? 28.6139,
          longitude: _longitude ?? 77.2090,
          amenities: amenities,
          rules: const [],
          availableFrom: DateTime.now(),
          imageUrls: const ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267'], // Mock fallback
        );
      } else {
        await notifier.updateProperty(
          id: widget.initialProperty!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          rent: double.parse(_rentController.text.trim()),
          deposit: double.parse(_depositController.text.trim()),
          propertyType: _mapPropertyType(_propertyType),
          roomType: _mapRoomType(_roomType),
          area: _areaController.text.trim(),
          city: _cityController.text.trim(),
          address: _addressController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          amenities: amenities,
          rules: const [],
          availableFrom: DateTime.now(),
          imageUrls: widget.initialProperty!.images,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialProperty == null 
                ? 'Property submitted for approval!' 
                : 'Property updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialProperty != null;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Property' : 'Add Property'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Photos'),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: _selectedImages.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textHint),
                          const SizedBox(height: 8),
                          Text('Tap to add photos', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
                        ],
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        itemCount: _selectedImages.length,
                        itemBuilder: (ctx, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Icon(Icons.image, size: 100, color: AppColors.primary),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Basic Details'),
            CommonWidgets.buildTextField(
              controller: _titleController,
              label: 'Property Title',
              hint: 'e.g., Sunny 1RK near Metro Station',
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            CommonWidgets.buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your property...',
              maxLines: 4,
              validator: Validators.required,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Pricing'),
            Row(
              children: [
                Expanded(
                  child: CommonWidgets.buildTextField(
                    controller: _rentController,
                    label: 'Monthly Rent (\u20B9)',
                    hint: 'e.g., 8000',
                    keyboardType: TextInputType.number,
                    validator: Validators.required,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonWidgets.buildTextField(
                    controller: _depositController,
                    label: 'Deposit (\u20B9)',
                    hint: 'e.g., 16000',
                    keyboardType: TextInputType.number,
                    validator: Validators.required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Location'),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationPickerScreen(),
                        ),
                      );
                      if (result != null && mounted) {
                        setState(() {
                          _latitude = result['latitude'];
                          _longitude = result['longitude'];
                          _selectedAddress = result['address'];
                          _addressController.text = _selectedAddress ?? '';
                        });
                      }
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Pick on Map'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (_latitude != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AppColors.success),
                        SizedBox(width: 4),
                        Text('Set', style: TextStyle(fontSize: 12, color: AppColors.success)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            CommonWidgets.buildTextField(
              controller: _addressController,
              label: 'Full Address',
              hint: 'Street, Landmark',
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CommonWidgets.buildTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'e.g., Bangalore',
                    validator: Validators.required,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonWidgets.buildTextField(
                    controller: _areaController,
                    label: 'Area/Locality',
                    hint: 'e.g., Indiranagar',
                    validator: Validators.required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Property Type'),
            DropdownButtonFormField<String>(
              value: _propertyType,
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: ['Apartment', 'Independent House', 'Villa', 'PG']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _propertyType = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _roomType,
              decoration: InputDecoration(
                labelText: 'Room Configuration',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: ['1 RK', '1 BHK', '2 BHK', '3 BHK', 'Single Room', 'Shared Room']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _roomType = v!),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Amenities'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildAmenityChip('Furnished', _furnished, (v) => setState(() => _furnished = v)),
                _buildAmenityChip('Attached Bathroom', _attachedBathroom, (v) => setState(() => _attachedBathroom = v)),
                _buildAmenityChip('Parking', _parking, (v) => setState(() => _parking = v)),
                _buildAmenityChip('WiFi', _wifi, (v) => setState(() => _wifi = v)),
                _buildAmenityChip('Pet Friendly', _petFriendly, (v) => setState(() => _petFriendly = v)),
              ],
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isEdit ? 'Update Property' : 'Submit for Approval (\u20B99)',
                      style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.h4.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String label, bool value, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: value ? AppColors.primary : AppColors.textPrimary,
        fontWeight: value ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: value ? AppColors.primary : AppColors.border),
      ),
    );
  }
}
