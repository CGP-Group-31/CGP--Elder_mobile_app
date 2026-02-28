import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final Dio _dio = DioClient.dio;

  bool _loading = true;
  String _error = "";

  List<Map<String, dynamic>> _items = [];

  // selected item
  Map<String, dynamic>? _selected;
  String _status = "TAKEN"; // TAKEN / MISSED
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
          _error = "Elder not logged in.";
          _loading = false;
        });
        return;
      }

      final res = await _dio.get("/api/v1/elder/meals/today/$elderId");
      final data = res.data;

      final List<dynamic> raw = (data is Map && data["items"] is List)
          ? data["items"]
          : <dynamic>[];

      _items = raw.map((e) => Map<String, dynamic>.from(e)).toList();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load meals.";
        _loading = false;
      });
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

  Color _statusColor(String st) {
    st = st.toUpperCase();
    if (st == "TAKEN") return const Color(0xFF22C55E);
    if (st == "MISSED") return const Color(0xFFC62828);
    return const Color(0xFFE6B566); // pending-ish
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
          "status": _status,
          "diet": _dietCtrl.text.trim().isEmpty ? null : _dietCtrl.text.trim(),
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meal updated ")),
      );

      // refresh list
      await _loadTodayMeals();
      setState(() {
        _selected = null;
        _dietCtrl.clear();
        _status = "TAKEN";
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed ")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // elder-friendly: big text + strong contrast
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
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadTodayMeals,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Today’s Meals",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),

            // meal list
            ..._items.map((m) {
              final mealTime = (m["MealTime"] ?? "").toString();
              final status = (m["Status"] ?? "PENDING").toString();
              final scheduledFor = (m["ScheduledFor"] ?? "").toString();
              final diet = (m["Diet"] ?? "").toString();

              final selected =
                  _selected != null && (_selected?["MealAdherenceID"] == m["MealAdherenceID"]);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selected = m;
                    _status = "TAKEN";
                    _dietCtrl.text = diet;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2E7D7A)
                          : const Color(0xFFBEE8DA),
                      width: selected ? 3 : 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mealLabel(mealTime),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF243333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Status: ${status.toUpperCase()}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _statusColor(status),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scheduledFor,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6F7F7D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (diet.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                "Diet: $diet",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF243333),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 30, color: Color(0xFF6F7F7D)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            if (_selected != null) ...[
              const Divider(height: 30, thickness: 2, color: Color(0xFFBEE8DA)),
              const Text(
                "Update Selected Meal",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Taken"),
                      selected: _status == "TAKEN",
                      onSelected: (_) => setState(() => _status = "TAKEN"),
                      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Missed"),
                      selected: _status == "MISSED",
                      onSelected: (_) => setState(() => _status = "MISSED"),
                      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _dietCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: "Diet (what did you eat?)",
                  filled: true,
                  fillColor: const Color(0xFFBEE8DA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 56,
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
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