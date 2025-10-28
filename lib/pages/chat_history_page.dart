import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_app/data/conversations_provider.dart';
import 'package:flutter_app/models/conversation.dart';
import 'package:flutter_app/pages/chat_page.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Conversation> _allChats;
  late List<Conversation> _favoritedChats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    conversationsProvider.addListener(_onConversationsChanged);
    _loadChats();
  }

  @override
  void dispose() {
    conversationsProvider.removeListener(_onConversationsChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _loadChats() {
    _allChats = conversationsProvider.allConversations;
    _favoritedChats = conversationsProvider.favoritedConversations;
  }

  void _onConversationsChanged() {
    setState(() {
      _loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(_allChats),
          _buildChatList(_favoritedChats, isFavoritesTab: true),
        ],
      ),
    );
  }

  Widget _buildChatList(List<Conversation> conversations, {bool isFavoritesTab = false}) {
    if (conversations.isEmpty) {
      return Center(
        child: Text(
          isFavoritesTab ? 'No favorited conversations yet.' : 'No conversations yet.',
          style: GoogleFonts.cormorantGaramond(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final lastMessage = conversation.messages.isNotEmpty ? conversation.messages.last.text : 'No messages yet.';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: conversation.partner.accent.withOpacity(0.2),
            child: Text(
              conversation.partner.name[0].toUpperCase(),
              style: GoogleFonts.cormorantGaramond(fontSize: 24, color: conversation.partner.accent, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(conversation.partner.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            icon: Icon(
              conversation.isFavorited ? Icons.star : Icons.star_border,
              color: conversation.isFavorited ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              conversationsProvider.toggleFavorite(conversation.id);
            },
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatPage(profile: conversation.partner),
            ));
          },
        );
      },
    );
  }
}
