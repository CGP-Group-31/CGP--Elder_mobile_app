import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';

class ElderSendLocation extends StatefulWidget {
  const ElderSendLocation({super.key});

  @override
  State<ElderSendLocation> createState() => _ElderSendLocationState();
}

class _ElderSendLocationState extends State<ElderSendLocation> {
  final Dio _dio = DioClient.dio;

  bool _saving = false;
  bool _sharedSuccessfully = false;
  bool _shareFailed = false;
  String _status = "Tap button to share location";

  Future<int> _getElderId() async {
    final elderId = await ElderSessionManager.getElderUserId();
    if (elderId == null) {
      throw Exception("Elder not logged in.");
    }
    return elderId;
  }

  Future<Position> _getCurrentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are turned off.");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _onSharePressed() async {
    setState(() {
      _saving = true;
      _sharedSuccessfully = false;
      _shareFailed = false;
      _status = "Getting current location...";
    });

    try {
      final elderId = await _getElderId();
      final position = await _getCurrentPosition();

      if (!mounted) return;

      setState(() {
        _status = "Sharing location...";
      });

      await _dio.post(
        "/api/v1/elder/location-sharing/share",
        data: {
          "elder_id": elderId,
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      if (!mounted) return;

      setState(() {
        _saving = false;
        _sharedSuccessfully = true;
        _shareFailed = false;
        _status = "Location shared successfully";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location shared successfully")),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      String message = "Failed to share location";
      final responseData = e.response?.data;

      if (responseData is Map && responseData["detail"] != null) {
        message = responseData["detail"].toString();
      }

      setState(() {
        _saving = false;
        _sharedSuccessfully = false;
        _shareFailed = true;
        _status = message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst("Exception: ", "");

      setState(() {
        _saving = false;
        _sharedSuccessfully = false;
        _shareFailed = true;
        _status = message.isEmpty ? "Failed to share location" : message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty ? "Failed to share location" : message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _sharedSuccessfully
        ? const Color(0xFF22C55E)
        : _shareFailed
            ? const Color(0xFFC62828)
            : _saving
                ? const Color(0xFF2E7D7A)
                : const Color(0xFF6F7F7D);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Location"),
        backgroundColor: const Color(0xFF2E7D7A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFD6EFE6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _sharedSuccessfully
                        ? const Color(0xFF22C55E)
                        : _shareFailed
                            ? const Color(0xFFC62828)
                            : const Color(0xFFBEE8DA),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _sharedSuccessfully
                            ? const Color(0xFFDDF7E7)
                            : _shareFailed
                                ? const Color(0xFFFDE7E7)
                                : const Color(0xFFBEE8DA),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _sharedSuccessfully
                            ? Icons.check_circle_rounded
                            : _shareFailed
                                ? Icons.error_rounded
                                : _saving
                                    ? Icons.gps_fixed_rounded
                                    : Icons.location_on_rounded,
                        size: 70,
                        color: _sharedSuccessfully
                            ? const Color(0xFF22C55E)
                            : _shareFailed
                                ? const Color(0xFFC62828)
                                : const Color(0xFF2E7D7A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Share Your Location",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF243333),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBEE8DA),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF2E7D7A),
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Press the button below to share your current location.",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF243333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onSharePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D7A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _saving ? "Sharing..." : "Share Location",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
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
}