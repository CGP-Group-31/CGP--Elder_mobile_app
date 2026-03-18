import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';

class MealPage extends StatefulWidget {
  final String? initialMealTime;
  final String? initialScheduledFor;

  const MealPage({
    super.key,
    this.initialMealTime,
    this.initialScheduledFor,
  });

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final Dio _dio = DioClient.dio;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd  HH:mm');

  bool _loading = true;
  String _error = "";

  List<Map<String, dynamic>> _items = [];

  Map<String, dynamic>? _selected;
  int _selectedStatusId = 2; // default Taken
  final TextEditingController _dietCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodayMeals();
  }

  @override
  void dispose() {
    _dietCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTodayMeals() async {
    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      final elderId = await ElderSessionManager.getElderUserId();
      if (elderId == null) {
        setState(() {
          _error = "User not logged in.";
          _loading = false;
        });
        return;
      }

      final res = await _dio.get("/api/v1/elder/meals/today/$elderId");
      final data = res.data;

      final List<dynamic> raw = (data is Map && data["items"] is List)
          ? data["items"]
          : (data is List ? data : <dynamic>[]);

      _items = raw.map((e) => Map<String, dynamic>.from(e)).toList();

      _autoSelectFromNotification();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Could not load today’s meals. Please try again.";
        _loading = false;
      });
    }
  }

  void _autoSelectFromNotification() {
    if (_items.isEmpty) return;

    final incomingMealTime =
    (widget.initialMealTime ?? "").trim().toUpperCase();
    final incomingScheduledFor = (widget.initialScheduledFor ?? "").trim();

    if (incomingMealTime.isEmpty && incomingScheduledFor.isEmpty) return;

    Map<String, dynamic>? found;

    for (final item in _items) {
      final mealTime = (item["MealTime"] ?? "").toString().trim().toUpperCase();
      final scheduledFor = (item["ScheduledFor"] ?? "").toString().trim();

      final mealMatch =
          incomingMealTime.isNotEmpty && mealTime == incomingMealTime;

      final scheduleMatch =
          incomingScheduledFor.isNotEmpty && scheduledFor == incomingScheduledFor;

      if (scheduleMatch || mealMatch) {
        found = item;
        break;
      }
    }

    if (found != null) {
      _selected = found;
      _dietCtrl.text = (found["Diet"] ?? "").toString();

      final statusId = _parseStatusId(found["StatusID"] ?? found["Status"]);
      _selectedStatusId = statusId == 1 ? 2 : statusId;
    }
  }

  String _mealLabel(String mealTime) {
    switch (mealTime.toUpperCase()) {
      case "BREAKFAST":
        return "Breakfast";
      case "LUNCH":
        return "Lunch";
      case "DINNER":
        return "Dinner";
      default:
        return mealTime;
    }
  }

  int _parseStatusId(dynamic value) {
    if (value == null) return 1;

    if (value is int) return value;

    final text = value.toString().trim().toUpperCase();

    if (text == "2" || text == "TAKEN") return 2;
    if (text == "3" || text == "MISSED") return 3;
    if (text == "4" || text == "SKIPPED") return 4;

    return 1;
  }

  String _statusLabel(dynamic value) {
    final statusId = _parseStatusId(value);

    switch (statusId) {
      case 2:
        return "Taken";
      case 3:
        return "Missed";
      case 4:
        return "Skipped";
      default:
        return "Pending";
    }
  }

  Color _statusColor(String st) {
    st = st.toUpperCase();
    if (st == "TAKEN") return const Color(0xFF22C55E);
    if (st == "MISSED") return const Color(0xFFC62828);
    if (st == "SKIPPED") return const Color(0xFFEF6C00);
    return const Color(0xFFE6B566);
  }

  String _formatScheduledFor(String raw) {
    if (raw.trim().isEmpty) return "-";

    try {
      final dt = DateTime.parse(raw).toLocal();
      return _dateFormatter.format(dt);
    } catch (_) {
      return raw;
    }
  }

  Future<void> _submitUpdate() async {
    if (_selected == null) return;

    try {
      final elderId = await ElderSessionManager.getElderUserId();
      if (elderId == null) return;

      final mealTime = (_selected?["MealTime"] ?? "").toString();
      final scheduledFor = (_selected?["ScheduledFor"] ?? "").toString();

      await _dio.post(
        "/api/v1/elder/meals/update",
        data: {
          "elderId": elderId,
          "mealTime": mealTime,
          "scheduledFor": scheduledFor,
          "statusId": _selectedStatusId,
          "diet": _dietCtrl.text.trim().isEmpty ? null : _dietCtrl.text.trim(),
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2E7D7A),
          content: const Text(
            "Meal updated successfully",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );

      await _loadTodayMeals();

      setState(() {
        _selected = null;
        _dietCtrl.clear();
        _selectedStatusId = 2;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Update failed. Please try again.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
  }

  Widget _buildMealCard(Map<String, dynamic> m) {
    final mealTime = (m["MealTime"] ?? "").toString();
    final status = _statusLabel(m["StatusID"] ?? m["Status"]);
    final scheduledFor = _formatScheduledFor(
      (m["ScheduledFor"] ?? "").toString(),
    );
    final diet = (m["Diet"] ?? "").toString();

    final selected = _selected != null &&
        (_selected?["MealAdherenceID"] == m["MealAdherenceID"]);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = m;
          _dietCtrl.text = diet;

          final statusId = _parseStatusId(m["StatusID"] ?? m["Status"]);
          _selectedStatusId = statusId == 1 ? 2 : statusId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF2E7D7A)
                : const Color(0xFFBEE8DA),
            width: selected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 14,
              height: 92,
              decoration: BoxDecoration(
                color: _statusColor(status),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mealLabel(mealTime),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF243333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Status: ${status.toUpperCase()}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _statusColor(status),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 21,
                        color: Color(0xFF6F7F7D),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          scheduledFor,
                          style: const TextStyle(
                            fontSize: 19,
                            color: Color(0xFF445352),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (diet.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Diet: $diet",
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF243333),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 32,
              color: Color(0xFF6F7F7D),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBEE8DA), width: 2),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 54,
            color: Color(0xFF2E7D7A),
          ),
          SizedBox(height: 12),
          Text(
            "No meals found for today.",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF243333),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "When meal reminders are available, they will appear here.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5B6A68),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6B566), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Color(0xFFE6B566),
              ),
              const SizedBox(height: 12),
              Text(
                _error,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF243333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D7A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _loadTodayMeals,
                  child: const Text(
                    "Try Again",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meals"),
        backgroundColor: const Color(0xFF2E7D7A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFD6EFE6),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? _buildErrorState()
          : RefreshIndicator(
        onRefresh: _loadTodayMeals,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Select Today’s Meal",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF243333),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tap a meal card below to update it.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B6A68),
              ),
            ),
            const SizedBox(height: 14),

            if (_items.isEmpty)
              _buildEmptyState()
            else
              ..._items.map(_buildMealCard),

            if (_selected != null) ...[
              const SizedBox(height: 10),
              const Divider(
                height: 30,
                thickness: 2,
                color: Color(0xFFBEE8DA),
              ),
              const Text(
                "Update Selected Meal",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF243333),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Taken"),
                      selected: _selectedStatusId == 2,
                      onSelected: (_) =>
                          setState(() => _selectedStatusId = 2),
                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Missed"),
                      selected: _selectedStatusId == 3,
                      onSelected: (_) =>
                          setState(() => _selectedStatusId = 3),
                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Skipped"),
                      selected: _selectedStatusId == 4,
                      onSelected: (_) =>
                          setState(() => _selectedStatusId = 4),
                      labelStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _dietCtrl,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: "Diet (what did you eat?)",
                  hintStyle: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFBEE8DA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D7A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _submitUpdate,
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}