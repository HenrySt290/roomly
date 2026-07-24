import 'package:flutter/material.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/domain/entities/chat_message_entity.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (message.type.isSystem) {
      return _systemBubble();
    }
    if (message.type == MessageType.bookingRequest) {
      return _bookingRequestBubble(context);
    }
    if (message.type == MessageType.bookingConfirmed) {
      return _bookingConfirmedBubble(context);
    }
    return _textBubble(context);
  }

  Widget _textBubble(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(message.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: isMe ? Colors.white70 : AppColors.textHint,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: message.isRead ? Colors.white : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _systemBubble() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.textHint.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message.message,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingRequestBubble(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.event_available, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text('Booking Request', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(message.message, style: AppTextStyles.bodyMedium),
            if (message.metadata != null && message.metadata!['checkin'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Check-in: ${message.metadata!['checkin']}', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(DateFormat('dd MMM, hh:mm a').format(message.timestamp),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingConfirmedBubble(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.verified, color: AppColors.success, size: 32),
            const SizedBox(height: 8),
            Text('Booking Confirmed!', style: AppTextStyles.labelLarge.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(message.message, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(DateFormat('dd MMM yyyy').format(message.timestamp),
                style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}
