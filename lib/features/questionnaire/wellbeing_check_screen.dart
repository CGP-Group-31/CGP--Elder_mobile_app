import 'package:flutter/material.dart';
import '../../core/session/elder_session_manager.dart';
import '../theme.dart';
import 'questionnaire_service.dart';

class WellBeingCheckScreen extends StatefulWidget {
  const WellBeingCheckScreen({super.key});

  @override
  State<WellBeingCheckScreen> createState() => _WellBeingCheckScreenState();
}

class _WellBeingCheckScreenState extends State<WellBeingCheckScreen> {
  final QuestionnaireService _service = QuestionnaireService();

  bool _loading = false;

  String? _mood;
  String? _sleepQuantity;
  String? _waterIntake;
  String? _appetiteLevel;
  String? _energyLevel;
  String? _overallDay;
  String? _movementToday;
  String? _lonelinessLevel;
  String? _talkInteraction;
  String? _stressLevel;

  final List<String> _painAreas = [];
  final List<String> _activities = [];

  final List<String> moods = ["Happy", "Sad", "Neutral"];
  final List<String> sleepOptions = ["Good", "Average", "Poor"];
  final List<String> waterOptions = ["Enough", "Normal", "Low"];
  final List<String> appetiteOptions = ["Good", "Normal", "Low"];
  final List<String> energyOptions = ["Good", "Normal", "Low"];
  final List<String> overallDayOptions = ["Good", "Okay", "Not Good"];
  final List<String> movementOptions = [
    "Moved around the house alot",
    "Moved around the house a little",
    "Went outside (more than 30 min)",
    "Went outside (less than 30 min)",
    "Mostly Resting",
  ];
  final List<String> lonelinessOptions = ["Not Lonely", "Sometimes", "Always"];
  final List<String> talkOptions = [
    "Yes, with several people",
    "Yes, with one person",
    "Just a quick Hello",
    "No interaction",
  ];
  final List<String> stressOptions = ["No", "A little", "Yes"];
  final List<String> painOptions = [
    "Head",
    "Neck",
    "Chest",
    "Legs",
    "Back",
    "Arms",
    "Other",
    "None",
  ];
  final List<String> activityOptions = [
    "House work",
    "Exercise",
    "Gardening",
    "Watching TV",
    "Sewing",
    "Mostly resting",
    "None",
  ];

  Future<void> _submit() async{
    final elderId = await ElderSessionManager.getElderUserId();
    if (elderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Elder session not found")),
      );
      return;
    }

    if (_mood == null ||
        _sleepQuantity == null ||
        _waterIntake == null ||
        _appetiteLevel == null ||
        _energyLevel == null ||
        _overallDay == null ||
        _movementToday == null ||
        _lonelinessLevel == null ||
        _talkInteraction == null ||
        _stressLevel == null ||
        _painAreas.isEmpty ||
        _activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _service.submitElderForm(
        elderId: elderId,
        mood: _mood!,
        sleepQuantity: _sleepQuantity!,
        waterIntake: _waterIntake!,
        appetiteLevel: _appetiteLevel!,
        energyLevel: _energyLevel!,
        overallDay: _overallDay!,
        movementToday: _movementToday!,
        lonelinessLevel: _lonelinessLevel!,
        talkInteraction: _talkInteraction!,
        stressLevel: _stressLevel!,
        painAreas: _painAreas,
        activities: _activities,
        infoDate: DateTime.now(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Well being check submitted")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 18),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _singleChoiceWrap({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((item) {
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _multiChoiceWrap ({
    required List<String> options,
    required List<String> selectedList,
    required ValueChanged<String> onToggle,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((item) {
        final isSelected = selectedList.contains(item);
        return GestureDetector(
          onTap: () => onToggle(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleExclusiveList(List<String> list, String value) {
    setState(() {
      if (value == "None"){
        list
          ..clear()
          ..add("None");
      } else {
        list.remove("None");
        if (list.contains(value)) {
          list.remove(value);
        } else {
          list.add(value);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Well Being Check"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("1. Which emoji describes your current mood?"),
                _singleChoiceWrap(
                  options: moods,
                  selected: _mood,
                  onSelected: (v) => setState(() => _mood = v),
                ),

                _sectionTitle("2. How was your sleep quality?"),
                _singleChoiceWrap(
                  options: sleepOptions,
                  selected: _sleepQuantity,
                  onSelected: (v) => setState(() => _sleepQuantity = v),
                ),

                _sectionTitle("3. How is your water intake?"),
                _singleChoiceWrap(
                  options: waterOptions,
                  selected: _waterIntake,
                  onSelected: (v) => setState(() => _waterIntake = v),
                ),

                _sectionTitle("4. How is your appetite?"),
                _singleChoiceWrap(
                  options: appetiteOptions,
                  selected: _appetiteLevel,
                  onSelected: (v) => setState(() => _appetiteLevel = v),
                ),

                _sectionTitle("5. What is your energy level today?"),
                _singleChoiceWrap(
                  options: energyOptions,
                  selected: _energyLevel,
                  onSelected: (v) => setState(() => _energyLevel = v),
                ),

                _sectionTitle("6. How was your overall day?"),
                _singleChoiceWrap(
                  options: overallDayOptions,
                  selected: _overallDay,
                  onSelected: (v) => setState(() => _overallDay = v),
                ),

                _sectionTitle("7. How did you move today?"),
                _singleChoiceWrap(
                  options: movementOptions,
                  selected: _movementToday,
                  onSelected: (v) => setState(() => _movementToday = v),
                ),

                _sectionTitle("8. How lonely did you feel?"),
                _singleChoiceWrap(
                  options: lonelinessOptions,
                  selected: _lonelinessLevel,
                  onSelected: (v) => setState(() => _lonelinessLevel = v),
                ),

                _sectionTitle("9. Did you talk with anyone today?"),
                _singleChoiceWrap(
                  options: talkOptions,
                  selected: _talkInteraction,
                  onSelected: (v) => setState(() => _talkInteraction = v),
                ),

                _sectionTitle("10. Did you feel stressed today?"),
                _singleChoiceWrap(
                  options: stressOptions,
                  selected: _stressLevel,
                  onSelected: (v) => setState(() => _stressLevel = v),
                ),

                _sectionTitle("11. Are you in pain today? If so, where?"),
                _multiChoiceWrap(
                  options: painOptions,
                  selectedList: _painAreas,
                  onToggle: (v) => _toggleExclusiveList(_painAreas, v),
                ),

                _sectionTitle("12. What activities did you do today?"),
                _multiChoiceWrap(
                  options: activityOptions,
                  selectedList: _activities,
                  onToggle: (v) => _toggleExclusiveList(_activities, v),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Done",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}