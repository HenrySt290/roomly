import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/enquiries/providers/enquiry_notifier.dart';
import 'package:roomly/features/enquiries/providers/enquiry_state.dart';
import 'package:roomly/features/enquiries/presentation/widgets/enquiry_card.dart';
import 'package:roomly/features/enquiries/presentation/screens/enquiry_chat_screen.dart';

class EnquiryListScreen extends StatefulWidget {
  const EnquiryListScreen({super.key});

  @override
  State<EnquiryListScreen> createState() => _EnquiryListScreenState();
}

class _EnquiryListScreenState extends State<EnquiryListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnquiryNotifier>().loadAllEnquiries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enquiries & Chat'),
            Consumer<EnquiryNotifier>(builder: (context, notifier, _) {
              final total = notifier.unreadTotal;
              return Text(
                total > 0 ? '$total unread messages' : 'Stay connected with owners/tenants',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              );
            }),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_outlined, size: 18),
                  const SizedBox(width: 6),
                  const Text('Sent'),
                  const SizedBox(width: 6),
                  Consumer<EnquiryNotifier>(builder: (context, n, _) {
                    final unread = n.myEnquiries.fold<int>(0, (s, e) => s + e.unreadCount);
                    return unread > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                            child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10)),
                          )
                        : const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 18),
                  const SizedBox(width: 6),
                  const Text('Received'),
                  const SizedBox(width: 6),
                  Consumer<EnquiryNotifier>(builder: (context, n, _) {
                    final unread = n.receivedEnquiries.fold<int>(0, (s, e) => s + e.unreadCount);
                    return unread > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                            child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10)),
                          )
                        : const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<EnquiryNotifier>(builder: (context, notifier, _) {
        final state = notifier.state;
        if (state is EnquiryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is EnquiryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(state.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () => notifier.loadAllEnquiries(), child: const Text('Retry')),
              ],
            ),
          );
        }
        return TabBarView(
          controller: _tabController,
          children: [
            _buildList(notifier.myEnquiries, isOwnerView: false, emptyMessage: 'No sent enquiries yet'),
            _buildList(notifier.receivedEnquiries, isOwnerView: true, emptyMessage: 'No enquiries received yet'),
          ],
        );
      }),
    );
  }

  Widget _buildList(List<dynamic> enquiries, {required bool isOwnerView, required String emptyMessage}) {
    if (enquiries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isOwnerView ? Icons.inbox_outlined : Icons.send_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(emptyMessage, style: AppTextStyles.h4),
            const SizedBox(height: 6),
            Text(isOwnerView ? 'Tenant enquiries will appear here' : 'Your enquiries to owners appear here',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<EnquiryNotifier>().loadAllEnquiries(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enquiries.length,
        itemBuilder: (ctx, idx) {
          final e = enquiries[idx];
          return EnquiryCard(
            enquiry: e,
            isOwnerView: isOwnerView,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EnquiryChatScreen(enquiryId: e.id, isOwnerView: isOwnerView)),
              ).then((_) => context.read<EnquiryNotifier>().loadAllEnquiries());
            },
          );
        },
      ),
    );
  }
}
