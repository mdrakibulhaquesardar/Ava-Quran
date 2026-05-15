import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:avaquran_app/app/networking/prayer_api_service.dart';
import 'package:avaquran_app/app/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesWidget extends StatefulWidget {
  const PrayerTimesWidget({super.key});

  @override
  State<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  Map<String, dynamic>? _timings;
  Map<String, dynamic>? _dateInfo;
  bool _isLoading = true;
  String? _locationName;
  String? _nextPrayerName;
  DateTime? _nextPrayerDateTime;
  Timer? _countdownTimer;
  String _timeRemaining = "";

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextPrayerDateTime != null) {
        final now = DateTime.now();
        final difference = _nextPrayerDateTime!.difference(now);
        
        if (difference.isNegative) {
          _calculateNextPrayer(); // Recalculate if time passed
        } else {
          setState(() {
            _timeRemaining = _formatDuration(difference);
          });
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _loadPrayerTimes() async {
    setState(() => _isLoading = true);
    try {
      Position? position = await LocationService.getCurrentPosition();
      if (position != null) {
        final data = await PrayerApiService().fetchPrayerTimes(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        if (data != null) {
          setState(() {
            _timings = data['timings'];
            _dateInfo = data['date'];
            _locationName = data['meta']['timezone'];
            _calculateNextPrayer();
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      NyLogger.error("Error loading prayer times: $e");
      setState(() => _isLoading = false);
    }
  }

  void _calculateNextPrayer() {
    if (_timings == null) return;
    
    final now = DateTime.now();
    final DateFormat format = DateFormat("HH:mm");
    
    List<String> prayerNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
    
    for (String name in prayerNames) {
      final timeStr = _timings![name];
      final prayerTime = format.parse(timeStr);
      final prayerDateTime = DateTime(now.year, now.month, now.day, prayerTime.hour, prayerTime.minute);
      
      if (prayerDateTime.isAfter(now)) {
        _nextPrayerName = name;
        _nextPrayerDateTime = prayerDateTime;
        return;
      }
    }
    
    // If all prayers today have passed, the next one is Fajr tomorrow
    final fajrTime = format.parse(_timings!["Fajr"]);
    _nextPrayerName = "Fajr";
    _nextPrayerDateTime = DateTime(now.year, now.month, now.day + 1, fajrTime.hour, fajrTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_timings == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 140, // Even more compact
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // BACKGROUND IMAGE
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  "assets/images/auth_background.png",
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            // OVERLAY
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B).withAlpha(150),
                      const Color(0xFF267B92).withAlpha(150),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // CONTENT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: Colors.white70, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                _locationName?.split('/').last.replaceAll('_', ' ') ?? "Dhaka",
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${_dateInfo?['hijri']?['day']} ${_dateInfo?['hijri']?['month']?['en']} ${_dateInfo?['hijri']?['year']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 18),
                        onPressed: _loadPrayerTimes,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Next: $_nextPrayerName",
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatTime(_timings![_nextPrayerName] ?? "00:00"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Time Remaining",
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                          Text(
                            _timeRemaining,
                            style: const TextStyle(
                              color: Color(0xFF5DD5E4), // Brighter teal for countdown
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final DateFormat inputFormat = DateFormat("HH:mm");
      final DateFormat outputFormat = DateFormat("hh:mm a");
      final DateTime dateTime = inputFormat.parse(time);
      return outputFormat.format(dateTime);
    } catch (e) {
      return time;
    }
  }
}
