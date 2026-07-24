import 'package:flutter/material.dart';

import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';

class PropertyStatusChip extends StatelessWidget {
  final String status;

  const PropertyStatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['color'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            config['label'] as String,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return {
          'label': 'Published',
          'color': AppColors.success,
          'icon': Icons.check_circle,
        };
      case 'pending_approval':
        return {
          'label': 'Pending',
          'color': AppColors.warning,
          'icon': Icons.schedule,
        };
      case 'occupied':
        return {
          'label': 'Occupied',
          'color': AppColors.error,
          'icon': Icons.lock,
        };
      case 'expired':
        return {
          'label': 'Expired',
          'color': AppColors.textLight,
          'icon': Icons.access_time,
        };
      case 'rejected':
        return {
          'label': 'Rejected',
          'color': Colors.grey.shade700,
          'icon': Icons.cancel,
        };
      default:
        return {
          'label': 'Draft',
          'color': Colors.grey.shade600,
          'icon': Icons.draft,
        };
    }
  }
}
