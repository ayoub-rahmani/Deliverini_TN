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

  List<ChatUser> _chattedUsers = [];
  List<ChatUser> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = true;
  Timer? _debounceTimer;
  bool _showSearchResults = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadChattedUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadChattedUsers() async {
    try {
      final users = await _chatService.getChattedUsers();
      if (mounted) {
        setState(() {
          _chattedUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _searchUsers(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _chatService.searchUsers(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _showSearchResults = true;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  void _navigateToChat(ChatUser user) async {
    HapticFeedback.selectionClick();
    try {
      final chatId = await _chatService.getOrCreateChatRoom(user.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Conversation(chatId: chatId, otherUser: user),
        ),
      ).then((_) {
        // Reload chatted users when returning from conversation
        _loadChattedUsers();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في فتح المحادثة'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteConversation(ChatUser user) async {
    HapticFeedback.heavyImpact();

    final chatId = _chatService.generateChatId(ChatService.currentUserId, user.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المحادثة'),
        content: Text('هل أنت متأكد من أنك تريد حذف هذه المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _chatService.deleteConversation(chatId);
                setState(() {
                  _chattedUsers.removeWhere((u) => u.id == user.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف المحادثة'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل في حذف المحادثة'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<ChatUser> users, {bool isSearchResult = false}) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          isSearchResult ? 'لا توجد نتائج' : 'لا توجد محادثات',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Dismissible(
          key: ValueKey(user.id + (isSearchResult ? '_search' : '_chat')),
          direction: isSearchResult ? DismissDirection.none : DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            // Show confirmation dialog
            final bool? shouldDelete = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('حذف المحادثة'),
                content: Text('هل أنت متأكد من أنك تريد حذف هذه المحادثة؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('حذف', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            return shouldDelete ?? false;
          },
          onDismissed: (_) {
            // Remove the item from the list immediately
            if (isSearchResult) {
              setState(() {
                _searchResults.removeAt(index);
              });
            } else {
              setState(() {
                _chattedUsers.removeAt(index);
              });
            }
            // Then delete from Firebase
            _deleteConversationFromFirebase(user);
          },
          child: MessageCard(
            key: ValueKey(user.id),
            user: user,
            onTap: () => _navigateToChat(user),
            showDeleteIcon: !isSearchResult,
            onDelete: () => _showDeleteDialog(user, isSearchResult ? _searchResults : _chattedUsers, index),
          ),
        );
      },
    );
  }

  void _deleteConversationFromFirebase(ChatUser user) async {
    final chatId = _chatService.generateChatId(ChatService.currentUserId, user.id);
    try {
      await _chatService.deleteConversation(chatId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف المحادثة'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في حذف المحادثة'),
          duration: Duration(seconds: 2),
        ),
      );
      // If deletion fails, reload the users to restore the list
      _loadChattedUsers();
    }
  }

// Show delete confirmation dialog for the delete icon
  void _showDeleteDialog(ChatUser user, List<ChatUser> userList, int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المحادثة'),
        content: Text('هل أنت متأكد من أنك تريد حذف هذه المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // Remove from UI immediately
      setState(() {
        userList.removeAt(index);
      });

      // Then delete from Firebase
      _deleteConversationFromFirebase(user);
    }
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
                            hintText: 'ابحث عن مستخدمين...',
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
                            : _showSearchResults
                            ? _buildUserList(_searchResults, isSearchResult: true)
                            : _buildUserList(_chattedUsers),
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