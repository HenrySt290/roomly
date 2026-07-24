import 'package:flutter/material.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/domain/entities/enquiry_entity.dart';

class PropertyEnquiryHeader extends StatelessWidget {
  final EnquiryEntity enquiry;

  const PropertyEnquiryHeader({super.key, required this.enquiry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: enquiry.propertyThumbnail != null
                ? Image.network(enquiry.propertyThumbnail!, width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(enquiry.propertyTitle, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _statusDot(enquiry.status),
                    const SizedBox(width: 6),
                    Text(enquiry.status.value.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: _statusColor(enquiry.status))),
                    const SizedBox(width: 12),
                    const Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text('Enquiry #${enquiry.id}', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(width: 56, height: 56, color: AppColors.border, child: const Icon(Icons.home, color: AppColors.textHint));
  }

  Color _statusColor(EnquiryStatus s) {
    switch (s) {
      case EnquiryStatus.pending:
        return AppColors.warning;
      case EnquiryStatus.replied:
        return AppColors.info;
      case EnquiryStatus.accepted:
        return AppColors.success;
      case EnquiryStatus.closed:
      case EnquiryStatus.rejected:
        return AppColors.textSecondary;
    }
  }

  Widget _statusDot(EnquiryStatus s) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: _statusColor(s), shape: BoxShape.circle));
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.block), title: const Text('Close Enquiry'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('Delete', style: TextStyle(color: Colors.red)), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
