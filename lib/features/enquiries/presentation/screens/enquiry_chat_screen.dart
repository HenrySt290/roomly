import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/domain/entities/enquiry_entity.dart';
import 'package:roomly/features/enquiries/providers/enquiry_notifier.dart';
import 'package:roomly/features/enquiries/providers/enquiry_state.dart';
import 'package:roomly/features/enquiries/presentation/widgets/chat_bubble.dart';
import 'package:roomly/features/enquiries/presentation/widgets/enquiry_input_bar.dart';
import 'package:roomly/features/enquiries/presentation/widgets/property_enquiry_header.dart';
import 'package:roomly/features/enquiries/presentation/widgets/booking_request_card.dart';

class EnquiryChatScreen extends StatefulWidget {
  final int enquiryId;
  final bool isOwnerView;

  const EnquiryChatScreen({super.key, required this.enquiryId, this.isOwnerView = false});

  @override
  State<EnquiryChatScreen> createState() => _EnquiryChatScreenState();
}

class _EnquiryChatScreenState extends State<EnquiryChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnquiryNotifier>().openEnquiryDetail(widget.enquiryId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Consumer<EnquiryNotifier>(builder: (context, notifier, _) {
          final enquiry = notifier.selectedEnquiry;
          if (enquiry == null) return const Text('Chat');
          final otherName = widget.isOwnerView ? (enquiry.tenantName ?? 'Tenant') : (enquiry.ownerName ?? 'Owner');
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(otherName, style: AppTextStyles.labelLarge),
                  Text(enquiry.status.value, style: AppTextStyles.caption.copyWith(color: _statusColor(enquiry.status))),
                ],
              ),
            ],
          );
        }),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              final notifier = context.read<EnquiryNotifier>();
              if (v == 'close') notifier.closeEnquiry(widget.enquiryId);
              if (v == 'accept' && widget.isOwnerView) notifier.acceptBooking(widget.enquiryId);
            },
            itemBuilder: (_) => [
              if (widget.isOwnerView) const PopupMenuItem(value: 'accept', child: Text('Accept Booking')),
              const PopupMenuItem(value: 'close', child: Text('Close Chat')),
            ],
          ),
        ],
      ),
      body: Consumer<EnquiryNotifier>(builder: (context, notifier, _) {
        final state = notifier.state;

        if (state is EnquiryDetailLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is EnquiryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(state.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => notifier.openEnquiryDetail(widget.enquiryId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final enquiry = notifier.selectedEnquiry;
        if (enquiry == null) {
          return const Center(child: Text('Enquiry not found'));
        }

        final messages = notifier.messages;

        return Column(
          children: [
            PropertyEnquiryHeader(enquiry: enquiry),
            // Booking action bar based on status
            if (enquiry.status == EnquiryStatus.pending && widget.isOwnerView)
              BookingRequestCard(
                isOwnerView: true,
                onAccept: () => notifier.acceptBooking(widget.enquiryId),
                onDecline: () => notifier.closeEnquiry(widget.enquiryId),
              ),
            if (enquiry.status == EnquiryStatus.pending && !widget.isOwnerView)
              BookingRequestCard(
                isOwnerView: false,
                onRequest: () => BookingRequestBottomSheet.show(context, (note) {
                  notifier.sendBookingRequest(enquiryId: widget.enquiryId, checkInNote: note);
                }),
              ),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text('No messages yet', style: AppTextStyles.h4),
                          const SizedBox(height: 6),
                          Text('Start the conversation', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (ctx, idx) {
                        final msg = messages[idx];
                        // Determine if message is from current user (simplified: tenant if not owner view)
                        final isMe = widget.isOwnerView ? msg.senderRole.toLowerCase() == 'owner' : msg.senderRole.toLowerCase() != 'owner';
                        return ChatBubble(message: msg, isMe: isMe);
                      },
                    ),
            ),
            EnquiryInputBar(
              isSending: notifier.isSending,
              onSend: (text) {
                notifier.sendMessage(enquiryId: widget.enquiryId, message: text).then((_) {
                  Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                });
              },
            ),
          ],
        );
      }),
    );
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
}
