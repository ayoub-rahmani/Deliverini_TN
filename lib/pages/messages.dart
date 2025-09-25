import 'dart:async';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/widgets/message_card.dart';
import 'package:app3/services/chat_service.dart';
import 'package:app3/models/chat_user.dart';
import 'package:app3/pages/conversation.dart';
import 'package:app3/common/scroll_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app3/services/auth_service.dart';
import 'package:lottie/lottie.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> with AutomaticKeepAliveClientMixin, ScrollHelper {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();

  List<ChatUser> _allUsers = [];
  List<ChatUser> _filteredUsers = [];
  bool _isSearching = false;
  bool _isLoading = true;
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadUsers() async {
    try {
      final users = await _chatService.getChatUsers();
      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _searchUsers(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        setState(() {
          _filteredUsers = _allUsers;
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);
      final results = _allUsers.where((user) =>
          user.name.toLowerCase().contains(query.toLowerCase())).toList();
      setState(() {
        _filteredUsers = results;
        _isSearching = false;
      });
    });
  }

  void _navigateToChat(ChatUser user) {
    HapticFeedback.selectionClick();
    final chatId = _chatService.generateChatId(ChatService.currentUserId, user.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Conversation(chatId: chatId, otherUser: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: DeviceUtils.height(context),
        width: DeviceUtils.width(context),
        color: Colors.black,
        child: Stack(
          children: [
            // Header
            Positioned(
              bottom: DeviceUtils.height(context) * 0.88 + 10,
              right: 30,
              child: const Text(
                "الشات",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "NotoSansArabic",
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Main content
            Positioned(
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)
                    ),
                  ),
                  width: DeviceUtils.width(context),
                  height: DeviceUtils.height(context) * 0.88,
                  child: Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: _searchController,
                          textDirection: TextDirection.rtl,
                          onChanged: _searchUsers,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن المستخدمين...',
                            hintStyle: const TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.grey,
                            ),
                            prefixIcon: _isSearching
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                                : const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _searchUsers('');
                              },
                            )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ),

                      // User list
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                            : ListView.builder(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return MessageCard(
                              key: ValueKey(user.id),
                              user: user,
                              onTap: () => _navigateToChat(user),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animation
            Positioned(
              bottom: DeviceUtils.height(context) * 0.873,
              left: DeviceUtils.width(context) * 0.05,
              child: Lottie.asset(
                "images/chat.json",
                width: DeviceUtils.width(context) * 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
