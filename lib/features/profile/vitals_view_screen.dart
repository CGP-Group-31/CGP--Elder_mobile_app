import 'package:flutter/material.dart';
import '../theme.dart';
import '../../core/session/elder_session_manager.dart';
import 'vitals_api.dart';


class VitalsShowPage extends StatefulWidget {
  const VitalsShowPage({super.key});

  @override
  State<VitalsShowPage> createState() => _VitalsShowPageState();
}

class _VitalsShowPageState extends State<VitalsShowPage> {
  bool _loading = true;
  String? _error;

  int? _elderId;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final elderId = await ElderSessionManager.getElderUserId();
      if (elderId == null) {
        throw Exception("Elder not logged in.");
      }

      final resp = await VitalsApi.getLatestVitalsByElder(
        elderId: elderId,
        limitPerType: 3,
      );

      final categories = (resp["categories"] as List?) ?? [];
      setState(() {
        _elderId = elderId;
        _categories = categories.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(String isoOrDateTime) {

    if (isoOrDateTime.length >= 16) return isoOrDateTime.replaceFirst("T", " ").substring(0, 16);
    return isoOrDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Vitals"),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      )
          : _categories.isEmpty
          ? const Center(child: Text("No vitals found yet."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final c = _categories[i];
          final vitalName = (c["vital_name"] ?? "").toString();
          final unit = (c["unit"] ?? "").toString();
          final last = (c["last"] as List?) ?? [];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.containerBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.sectionSeparator),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vitalName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    if (unit.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sectionBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (last.isEmpty)
                  const Text("No records", style: TextStyle(color: AppColors.primaryText))
                else
                  Column(
                    children: last.map((item) {
                      final r = Map<String, dynamic>.from(item);
                      final value = r["value"].toString();
                      final notes = (r["notes"] ?? "").toString();
                      final recordedAt = (r["recorded_at"] ?? "").toString();

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.sectionSeparator),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 95,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fmtDate(recordedAt),
                                    style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.w800,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  if (notes.trim().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      notes,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}