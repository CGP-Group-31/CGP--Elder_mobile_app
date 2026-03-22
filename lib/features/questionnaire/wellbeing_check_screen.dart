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
  int _currentStep = 0;

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

  List<Widget> _buildSteps() {
    return [
      _buildSingle("1. Which emoji describes your current mood?", moods, _mood, (v) => _mood = v),

      _buildSingle("2. How was your sleep quality?", sleepOptions, _sleepQuantity, (v) => _sleepQuantity = v),

      _buildSingle("3. How is your water intake?", waterOptions, _waterIntake, (v) => _waterIntake = v),

      _buildSingle("4. How is your appetite?", appetiteOptions, _appetiteLevel, (v) => _appetiteLevel = v),

      _buildSingle("5. What is your energy level today?", energyOptions, _energyLevel, (v) => _energyLevel = v),

      _buildSingle("6. How was your overall day?", overallDayOptions, _overallDay, (v) => _overallDay = v),

      _buildSingle("7. How did you move today?", movementOptions, _movementToday, (v) => _movementToday = v),

      _buildSingle("8. How lonely did you feel?", lonelinessOptions, _lonelinessLevel, (v) => _lonelinessLevel = v),

      _buildSingle("9. Did you talk with anyone today?", talkOptions, _talkInteraction, (v) => _talkInteraction = v),

      _buildSingle("10. Did you feel stressed today?", stressOptions, _stressLevel, (v) => _stressLevel = v),

      _buildMulti("11. Are you in pain today? If so, where?", painOptions, _painAreas),

      _buildMulti("12. What activities did  you do today?", activityOptions, _activities),
    ];
  }

  Widget _buildSingle(String title, List<String> options, String? selected, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        _singleChoiceWrap(
          options: options,
          selected: selected,
          onSelected: (v) => setState(() => onSelect(v)),
        ),
      ],
    );
  }

  Widget _buildMulti(String title, List<String> options, List<String> list){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        _multiChoiceWrap(
          options: options,
          selectedList: list,
          onToggle: (v) => _toggleExclusiveList(list, v),
        ),
      ],
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final steps = _buildSteps();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, // Fill the screen height
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background, // your white box
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // so it doesn't stretch
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Step ${_currentStep + 1} of ${steps.length}",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.descriptionText,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Current question
                        steps[_currentStep],

                        const SizedBox(height: 30),

                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _currentStep--),
                                  child: const Text("Previous"),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                  if (_currentStep == steps.length - 1) {
                                    _submit();
                                  } else {
                                    setState(() => _currentStep++);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  _currentStep == steps.length - 1
                                      ? "Submit"
                                      : "Next",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}