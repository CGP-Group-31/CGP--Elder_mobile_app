import 'package:flutter/material.dart';

import '../dashboard/dashboard_screen.dart';
import '../navigation/elder_bottom_nav.dart';
import '../profile/profile_screen.dart';
import '../theme.dart';
import 'reminders_service.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -90,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.sectionBackground.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TopIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      Text(
                        "Reminders",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const Spacer(),
                      _TopIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  Text(
                    "Reminders",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _ReminderOptionCard(
                          title: "Medicine",
                          icon: Icons.medication_rounded,
                          backgroundColor: AppColors.sectionBackground,
                          iconBackground: Colors.white.withValues(alpha: 0.78),
                          textColor: AppColors.primaryText,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MedicineReminderScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _ReminderOptionCard(
                          title: "Appointments",
                          icon: Icons.calendar_month_rounded,
                          backgroundColor: AppColors.alertNonCritical,
                          iconBackground: Colors.white.withValues(alpha: 0.78),
                          textColor: AppColors.primaryText,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AppointmentReminderScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ElderBottomNav(
        activeTab: ElderTab.home,
        onHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        },
        onSos: () {},
        onProfile: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
    );
  }
}

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final RemindersService _service = RemindersService();

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _taken = [];
  List<Map<String, dynamic>> _missed = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.fetchTodayScheduled(),
        _service.fetchTodayTaken(),
        _service.fetchTodayMissed(),
      ]);

      setState(() {
        _pending = results[0];
        _taken = results[1];
        _missed = results[2];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Medicine",
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadMedicines,
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(
                  message: _error!,
                  onRetry: _loadMedicines,
                )
              : RefreshIndicator(
                  onRefresh: _loadMedicines,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      _MedicineSection(
                        title: "Pending",
                        subtitle: "Medicines still to be taken today",
                        backgroundColor: const Color(0xFFFFF1CC),
                        accentColor: const Color(0xFFE6B566),
                        icon: Icons.schedule_rounded,
                        medicines: _pending,
                        emptyMessage: "No pending medicines for today",
                      ),
                      const SizedBox(height: 20),
                      _MedicineSection(
                        title: "Taken",
                        subtitle: "Medicines already taken today",
                        backgroundColor: const Color(0xFFD6EFE6),
                        accentColor: const Color(0xFF2E7D7A),
                        icon: Icons.check_circle_rounded,
                        medicines: _taken,
                        emptyMessage: "No taken medicines for today",
                      ),
                      const SizedBox(height: 20),
                      _MedicineSection(
                        title: "Missed",
                        subtitle: "Medicines missed today",
                        backgroundColor: const Color(0xFFFBDADA),
                        accentColor: const Color(0xFFC62828),
                        icon: Icons.cancel_rounded,
                        medicines: _missed,
                        emptyMessage: "No missed medicines for today",
                      ),
                    ],
                  ),
                ),
    );
  }
}

class AppointmentReminderScreen extends StatefulWidget {
  const AppointmentReminderScreen({super.key});

  @override
  State<AppointmentReminderScreen> createState() =>
      _AppointmentReminderScreenState();
}

class _AppointmentReminderScreenState extends State<AppointmentReminderScreen> {
  final RemindersService _service = RemindersService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await _service.fetchUpcomingAppointments();
      setState(() {
        _appointments = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _loading = false;
      });
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return "-";

    try {
      final dt = DateTime.parse(raw);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (_) {
      return raw;
    }
  }

  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return "-";

    try {
      final clean = raw.split('.').first;
      final parts = clean.split(':');

      int hour = int.parse(parts[0]);
      final String minute = parts.length > 1 ? parts[1] : "00";

      final suffix = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return "$hour:$minute $suffix";
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Appointments",
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadAppointments,
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(
                  message: _error!,
                  onRetry: _loadAppointments,
                )
              : _appointments.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _loadAppointments,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                        children: [
                          Center(
                            child: Text(
                              "No appointments for the next 7 days",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.descriptionText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAppointments,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _appointments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _AppointmentInfoCard(
                              appointment: appointment,
                              formatDate: _formatDate,
                              formatTime: _formatTime,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _MedicineSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;
  final List<Map<String, dynamic>> medicines;
  final String emptyMessage;

  const _MedicineSection({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
    required this.medicines,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.descriptionText,
            ),
          ),
          const SizedBox(height: 16),
          if (medicines.isEmpty)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.22),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.descriptionText,
                    ),
                  ),
                ),
              ),
            )
          else
            ...medicines.map(
              (medicine) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MedicineInfoCard(
                  medicine: medicine,
                  accentColor: accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MedicineInfoCard extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final Color accentColor;

  const _MedicineInfoCard({
    required this.medicine,
    required this.accentColor,
  });

  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return "-";

    try {
      final dt = DateTime.parse(raw).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final suffix = dt.hour >= 12 ? 'PM' : 'AM';
      return "$hour:$minute $suffix";
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicineName = (medicine["MedicationName"] ?? "-").toString();
    final dosage = (medicine["Dosage"] ?? "-").toString();
    final scheduledFor = (medicine["ScheduledFor"] ?? "").toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.20),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _MedicineRow(
            label: "Medicine name",
            value: medicineName,
          ),
          const SizedBox(height: 10),
          _MedicineRow(
            label: "Dosage",
            value: dosage,
          ),
          const SizedBox(height: 10),
          _MedicineRow(
            label: "Time to be taken",
            value: _formatTime(scheduledFor),
          ),
        ],
      ),
    );
  }
}

class _AppointmentInfoCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final String Function(String?) formatDate;
  final String Function(String?) formatTime;

  const _AppointmentInfoCard({
    required this.appointment,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final doctor = (appointment["DoctorName"] ?? "-").toString();
    final title = (appointment["Title"] ?? "-").toString();
    final location = (appointment["Location"] ?? "-").toString();
    final notes = (appointment["Notes"] ?? "").toString();
    final date = (appointment["AppointmentDate"] ?? "").toString();
    final time = (appointment["AppointmentTime"] ?? "").toString();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.alertNonCritical.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _MedicineRow(label: "Doctor", value: doctor),
          const SizedBox(height: 10),
          _MedicineRow(label: "Title", value: title),
          const SizedBox(height: 10),
          _MedicineRow(label: "Date", value: formatDate(date)),
          const SizedBox(height: 10),
          _MedicineRow(label: "Time", value: formatTime(time)),
          const SizedBox(height: 10),
          _MedicineRow(label: "Location", value: location),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            _MedicineRow(label: "Notes", value: notes),
          ],
        ],
      ),
    );
  }
}

class _MedicineRow extends StatelessWidget {
  final String label;
  final String value;

  const _MedicineRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Text(
            "$label:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.descriptionText,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.primaryText,
            ),
            const SizedBox(height: 12),
            Text(
              "Could not load reminders",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.descriptionText,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                onRetry();
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackground;
  final Color textColor;
  final VoidCallback onTap;

  const _ReminderOptionCard({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconBackground,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        height: 235,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 54,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            icon,
            size: 28,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}