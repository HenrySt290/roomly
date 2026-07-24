import 'package:flutter/material.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/domain/entities/enquiry_entity.dart';
import 'package:intl/intl.dart';

class EnquiryCard extends StatelessWidget {
  final EnquiryEntity enquiry;
  final bool isOwnerView;
  final VoidCallback? onTap;

  const EnquiryCard({super.key, required this.enquiry, this.isOwnerView = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final otherName = isOwnerView ? (enquiry.tenantName ?? 'Tenant') : (enquiry.ownerName ?? 'Owner');
    final avatar = isOwnerView ? enquiry.tenantAvatar : enquiry.ownerAvatar;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: enquiry.hasUnread ? AppColors.primary.withOpacity(0.3) : AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: enquiry.propertyThumbnail != null
                    ? Image.network(enquiry.propertyThumbnail!,
                        width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderThumb())
                    : _placeholderThumb(),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(enquiry.propertyTitle,
                              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        _statusBadge(enquiry.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                          child: avatar == null
                              ? Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(otherName,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (enquiry.hasUnread)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                            child: Text('${enquiry.unreadCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      enquiry.lastMessage ?? enquiry.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: enquiry.hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: enquiry.hasUnread ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(enquiry.lastMessageAt ?? enquiry.updatedAt),
                          style: AppTextStyles.caption.copyWith(color: AppColors.textHint, fontSize: 11),
                        ),
                        const Spacer(),
                        Icon(_iconForMethod(enquiry.contactMethod), size: 14, color: AppColors.textHint),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.border,
      child: const Icon(Icons.home, color: AppColors.textHint),
    );
  }

  Widget _statusBadge(EnquiryStatus status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case EnquiryStatus.pending:
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
        label = 'Pending';
        break;
      case EnquiryStatus.replied:
        bg = AppColors.info.withOpacity(0.15);
        fg = AppColors.info;
        label = 'Replied';
        break;
      case EnquiryStatus.accepted:
        bg = AppColors.success.withOpacity(0.15);
        fg = AppColors.success;
        label = 'Accepted';
        break;
      case EnquiryStatus.closed:
        bg = AppColors.textHint.withOpacity(0.15);
        fg = AppColors.textSecondary;
        label = 'Closed';
        break;
      case EnquiryStatus.rejected:
        bg = AppColors.error.withOpacity(0.15);
        fg = AppColors.error;
        label = 'Rejected';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('dd MMM').format(dt);
  }

  IconData _iconForMethod(EnquiryContactMethod m) {
    switch (m) {
      case EnquiryContactMethod.whatsapp:
        return Icons.whatsapp;
      case EnquiryContactMethod.call:
        return Icons.call;
      case EnquiryContactMethod.chat:
        return Icons.chat_bubble_outline;
    }
  }
}
