import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';
import '../theme.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TalkToCompanionScreen extends StatefulWidget {
  const TalkToCompanionScreen({super.key});

  @override
  State<TalkToCompanionScreen> createState() => _TalkToCompanionScreenState();
}

class _TalkToCompanionScreenState extends State<TalkToCompanionScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();

  bool _ttsReady = false;
  bool _isLoading = true;
  bool _isSending = false;

  int? _elderId;

  bool _hasActiveCheckin = false;
  bool _isCheckinAvailable = false;

  int? _currentRunId;
  int? _currentThreadId;
  String? _checkinWindowType;
  String? _availabilityMessage;
  String? _activeCheckinMessage;

  final List<_ChatBubbleData> _messages = [];

  Dio get _dio => DioClient.dioSecond;

  @override
  void initState() {
    super.initState();
    _initPage();
    _initTts();
  }

  @override
  void dispose() {
    _tts.stop();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _ttsReady = true;
  }

  Future<void> _speak(String text) async {
    if(!_ttsReady || text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _initPage() async {
    setState(() => _isLoading = true);

    try {
      final elderId = await ElderSessionManager.getElderUserId();

      if (elderId == null) {
        if (!mounted) return;
        _showSnackBar("Elder user id not found.");
        setState(() => _isLoading = false);
        return;
      }

      _elderId = elderId;
      await _loadCheckinState();
    } catch (_) {
      _showSnackBar("Failed to load AI page.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCheckinState() async {
    if (_elderId == null) return;

    try {
      final availabilityResp =
      await _dio.get("/ai/checkin/availability/$_elderId");
      final currentResp = await _dio.get("/ai/checkin/current/$_elderId");

      final availabilityData = availabilityResp.data as Map<String, dynamic>;
      final currentData = currentResp.data as Map<String, dynamic>;

      final hasActiveCheckin = currentData["has_active_checkin"] == true;

      _messages.clear();

      if (hasActiveCheckin) {
        _hasActiveCheckin = true;
        _isCheckinAvailable = false;
        _currentRunId = currentData["run_id"];
        _currentThreadId = currentData["thread_id"];
        _checkinWindowType = currentData["window_type"]?.toString();
        _activeCheckinMessage = currentData["message"]?.toString();
        _availabilityMessage = null;

        if ((_activeCheckinMessage ?? "").trim().isNotEmpty) {
          _messages.add(
            _ChatBubbleData(
              role: "assistant",
              text: _activeCheckinMessage!,
            ),
          );
        }
      } else {
        _hasActiveCheckin = false;
        _currentRunId = null;
        _currentThreadId = null;
        _activeCheckinMessage = null;

        _isCheckinAvailable = availabilityData["available"] == true;
        _checkinWindowType = availabilityData["window_type"]?.toString();
        _availabilityMessage = availabilityData["message"]?.toString();
      }

      if (mounted) setState(() {});
    } catch (_) {
      _showSnackBar("Failed to load check-in state.");
    }
  }

  Future<void> _startCheckin() async {
    if (_elderId == null) return;

    try {
      setState(() => _isSending = true);

      final resp = await _dio.post(
        "/ai/checkin/start",
        data: {
          "elder_id": _elderId,
        },
      );

      final data = resp.data as Map<String, dynamic>;

      _hasActiveCheckin = true;
      _isCheckinAvailable = false;
      _currentRunId = data["run_id"];
      _currentThreadId = data["thread_id"];
      _checkinWindowType = data["window_type"]?.toString();
      _activeCheckinMessage = data["message"]?.toString();

      _messages.clear();

      if ((_activeCheckinMessage ?? "").trim().isNotEmpty) {
        _messages.add(
          _ChatBubbleData(
            role: "assistant",
            text: _activeCheckinMessage!,
          ),
        );
      }

      if (mounted) setState(() {});
      _scrollToBottom();
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data["detail"]?.toString() ??
          e.message ??
          "Unknown error")
          : (e.message ?? "Unknown error");
      _showSnackBar("Failed to start check-in: $msg");
    } catch (_) {
      _showSnackBar("Failed to start check-in.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _closeCheckin() async {
    if (_elderId == null || _currentRunId == null) return;

    try {
      setState(() => _isSending = true);

      await _dio.post(
        "/ai/checkin/close",
        data: {
          "run_id": _currentRunId,
          "elder_id": _elderId,
        },
      );

      _hasActiveCheckin = false;
      _currentRunId = null;
      _currentThreadId = null;
      _checkinWindowType = null;
      _activeCheckinMessage = null;

      await _loadCheckinState();

      if (mounted) {
        setState(() {});
        _showSnackBar("Check-in completed.");
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data["detail"]?.toString() ??
          e.message ??
          "Unknown error")
          : (e.message ?? "Unknown error");
      _showSnackBar("Failed to close check-in: $msg");
    } catch (_) {
      _showSnackBar("Failed to close check-in.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _elderId == null || _isSending) return;

    _messageController.clear();

    setState(() {
      _isSending = true;
      _messages.add(
        _ChatBubbleData(
          role: "elder",
          text: text,
        ),
      );
    });

    _scrollToBottom();

    try {
      if (_hasActiveCheckin && _currentRunId != null) {
        await _sendCheckinResponse(text);
      } else {
        await _sendNormalChat(text);
      }
    } catch (_) {
      _showSnackBar("Failed to send message.");
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  Future<void> _sendCheckinResponse(String text) async {
    final resp = await _dio.post(
      "/ai/checkin/respond",
      data: {
        "run_id": _currentRunId,
        "elder_id": _elderId,
        "message": text,
      },
    );

    final data = resp.data as Map<String, dynamic>;
    final answer = data["answer"]?.toString() ?? "";

    if (answer.isNotEmpty) {
      setState(() {
        _messages.add(
          _ChatBubbleData(
            role: "assistant",
            text: answer,
          ),
        );
      });
    }

    _hasActiveCheckin = true;
  }

  Future<void> _sendNormalChat(String text) async {
    final resp = await _dio.get(
      "/ai/chat/$_elderId",
      queryParameters: {
        "question": text,
      },
    );

    final data = resp.data as Map<String, dynamic>;
    final answer = data["answer"]?.toString() ?? "";

    if (answer.isNotEmpty) {
      setState(() {
        _messages.add(
          _ChatBubbleData(
            role: "assistant",
            text: answer,
          ),
        );
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasActiveCheckin && _currentRunId != null) {
      final shouldClose = await _showCloseCheckinDialog();
      if (shouldClose == true) {
        await _closeCheckin();
        return true;
      }
      return false;
    }
    return true;
  }

  Future<bool?> _showCloseCheckinDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Stop daily check-in?",
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            "Your daily check-in is still active.\n\nIf you leave now, the check-in will be completed and closed.",
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Stay Here",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sosButton,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Stop Check-in",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 140,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryText,
        content: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckinCard() {
    if (_hasActiveCheckin) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.sectionBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  color: AppColors.primary,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${_checkinWindowType ?? 'Daily'} Check-in Active",
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSending
                    ? null
                    : () async {
                  final shouldClose = await _showCloseCheckinDialog();
                  if (shouldClose == true) {
                    await _closeCheckin();
                  }
                },
                icon: const Icon(
                  Icons.stop_circle_outlined,
                  size: 24,
                  color: AppColors.sosButton,
                ),
                label: const Text(
                  "Stop Daily Check-in",
                  style: TextStyle(
                    color: AppColors.sosButton,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.sosButton,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isCheckinAvailable) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.containerBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.primary,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _availabilityMessage ?? "Check-in is available.",
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _startCheckin,
                icon: const Icon(
                  Icons.play_circle_fill,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  "Start ${_checkinWindowType ?? ''} Check-in",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _availabilityMessage ?? "No check-in available right now.",
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.primaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _hasActiveCheckin
                ? "Your check-in is ready. Reply below to continue."
                : "Start a conversation with your AI assistant.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final item = _messages[index];
        final isUser = item.role == "elder";
        final isAssistant = item.role == "assistant";

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.82,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.containerBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.sectionSeparator),
                  ),
                  child: Text(
                    item.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.primaryText,
                      fontSize: isUser ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      height: 1.45,
                    ),
                  ),
                ),

                if(isAssistant) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _speak(item.text),
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

  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: _hasActiveCheckin
                      ? "Reply to your daily check-in..."
                      : "Type your message...",
                  hintStyle: const TextStyle(
                    color: AppColors.descriptionText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: AppColors.containerBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    const BorderSide(color: AppColors.sectionSeparator),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    const BorderSide(color: AppColors.sectionSeparator),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 56,
              width: 56,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: _isSending
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshPage() async {
    await _loadCheckinState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.mainBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text(
            "AI Companion",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: !_hasActiveCheckin,
          leading: _hasActiveCheckin
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldClose = await _showCloseCheckinDialog();
              if (shouldClose == true && mounted) {
                await _closeCheckin();
                if (mounted) Navigator.of(context).maybePop();
              }
            },
          )
              : null,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _refreshPage,
          color: AppColors.primary,
          child: Column(
            children: [
              _buildCheckinCard(),
              Expanded(child: _buildMessages()),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubbleData {
  final String role;
  final String text;

  _ChatBubbleData({
    required this.role,
    required this.text,
  });
}