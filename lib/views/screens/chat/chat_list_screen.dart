import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/chat_controller.dart';
import 'package:food_bridge/models/chat_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/chat/chat_screen.dart';
import 'package:food_bridge/views/widgets/app_card.dart';
import 'package:food_bridge/views/widgets/empty_state_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(ChatController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: Text('chats'.tr),
      ),
      body: StreamBuilder<List<ConversationModel>>(
        stream: chatController.streamConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('error'.tr));
          }

          final conversations = snapshot.data ?? [];
          if (conversations.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.chat_bubble_outline,
              title: 'no_messages'.tr,
              subtitle: 'Turn surplus food into meaningful support for communities.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final peerId = conversation.participants.firstWhere(
                (uid) => uid != chatController.currentUserId,
                orElse: () => '',
              );

              if (peerId.isEmpty) return const SizedBox.shrink();

              // Fetch Peer user details dynamically
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(peerId).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const SizedBox(
                      height: 72,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }

                  final userData = userSnap.data!.data() as Map<String, dynamic>?;
                  final peerName = userData?['name'] as String? ?? 'User';
                  final peerRole = userData?['role'] as String? ?? 'user';
                  final initials = peerName.isNotEmpty ? peerName[0].toUpperCase() : 'U';

                  final unreadCount = conversation.unreadCounts[chatController.currentUserId] ?? 0;
                  final formattedTime = conversation.lastMessageTime != null
                      ? _formatChatTime(conversation.lastMessageTime!)
                      : '';

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              peerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                              color: unreadCount > 0 ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                conversation.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 13,
                                  color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                                  fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Get.to(() => ChatScreen(
                              peerId: peerId,
                              peerName: peerName,
                            ));
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatChatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }
}
