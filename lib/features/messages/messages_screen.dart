import 'dart:async';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../../core/session/elder_session_manager.dart';
import 'message_model.dart';
import 'messages_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final MessageService _service = MessageService();
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  Timer? _pollTimer;

  int? _relationshipId;
  int? _myId;

  bool _loading = true;
  String? _error;

  final List<ChatMessage> _messages = [];
  int _lastMessageId = 0;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
    _initTts();
  }

  @override
  void dispose(){
    _pollTimer?.cancel();
    _tts.stop();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _initTts() async{
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _ttsReady = true;
  }

  Future<void> _speak(String text) async{
    if (!_ttsReady) return;
    await _tts.stop();
    await _tts.speak(text);
  }


  Future<void> _initAndLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final relId = await ElderSessionManager.getRelationshipId();
    final myId = await ElderSessionManager.getElderUserId();

    if (!mounted) return;

    if (relId == null || myId == null){
      setState(() {
        _loading = false;
        _error = "Missing relationship_id or elder_id. Please login again.";
      });
      return;
    }

    _relationshipId = relId;
    _myId = myId;

    await _loadInitial();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollNew());
  }

  Future<void> _loadInitial() async{
    try {
      final data = await _service.getMessages(
        relationshipId: _relationshipId!,
        afterId: 0,
        limit: 200,
      );

      final list = (data["messages"] as List<dynamic>? ?? [])
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      setState(() {
        _messages
          ..clear()
          ..addAll(list);
        _lastMessageId = _messages.isNotEmpty ? _messages.last.messageId : 0;
        _loading = false;
        _error = null;
      });

      await _markIncomingAsRead(list);
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }
  Future<void> _pollNew() async {
    if(_relationshipId == null || _myId == null) return;

    try {
      final data = await _service.getMessages(
        relationshipId: _relationshipId!,
        afterId: _lastMessageId,
        limit: 200,
      );

      final list = (data["messages"] as List<dynamic>? ?? [])
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (list.isEmpty) return;

      final exisitingIds = _messages.map((m) => m.messageId).toSet();
      final unique = list.where((m) => !exisitingIds.contains(m.messageId)).toList();

      if(unique.isEmpty) return;

      setState(() {
        _messages.addAll(unique);
        _lastMessageId = _messages.last.messageId;
      });

      await _markIncomingAsRead(list);
      _scrollToBottom();
    } catch (_){

    }
  }

  Future<void> _markIncomingAsRead(List<ChatMessage> newMessages) async {
    if (_relationshipId == null || _myId == null) return;

    final incomingUnreadIds = newMessages
        .where((m) => m.senderId != _myId && m.isRead == false)
        .map((m) => m.messageId)
        .toList();

    await _service.markRead(
      relationshipId: _relationshipId!,
      readerId: _myId!,
      messageIds: incomingUnreadIds,
    );
  }

  Future<void> _sendMessage([String? quickText]) async {
    final text = (quickText ?? _textCtrl.text).trim();
    if (text.isEmpty) return;
    if (_relationshipId == null || _myId == null) return;

    FocusScope.of(context).unfocus();
    _textCtrl.clear();

    try {
      await _service.sendMessage(
        relationshipId: _relationshipId!,
        senderId: _myId!,
        messageText: text,
      );

      await _pollNew();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatTime(DateTime t){
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? "PM" : "AM";
    return "$h:$m $ampm";
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: _initAndLoad,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : _chatUi(),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Couldn't load messages",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.descriptionText),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _initAndLoad,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
  Widget _chatUi(){
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.sectionBackground.withValues(alpha: 0.55),
            const Color(0xFFF6F7F3),
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Divider(
              height: 10,
              thickness: 1.4,
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          Expanded(child: _messagesList()),
          _composer(),
        ],
      ),
    );
  }

  Widget _quickReplies(){
    Widget chip(String text, Color bg, Color fg){
      return InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _sendMessage(text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Replies",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              chip("I'm okay", const Color(0xFFBEE8DA), AppColors.primaryText),
              chip("I need help", const Color(0xFFFBDADA), const Color(0xFFC62828)),
              chip("I took my medicine", const Color(0xFFBEE8DA), AppColors.primaryText),
              chip("Call me", const Color(0xFFE6B566), AppColors.primaryText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messagesList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemCount: _messages.length,
      itemBuilder: (_, i){
        final m = _messages[i];
        final isMe = (m.senderId == _myId);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  constraints: const BoxConstraints(maxWidth: 310),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : const Color(0xFFBEE8DA),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    m.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(m.sentAt),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.descriptionText,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (!isMe) ...[
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _speak(m.text),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        size: 18,
                        color: AppColors.primary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _composer(){
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.45), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: "Type your message...",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _sendMessage(),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}