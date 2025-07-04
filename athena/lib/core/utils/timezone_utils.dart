import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Utility class for handling timezone conversions
/// Provides methods to convert between UTC and Malaysian time (UTC+8)
class TimezoneUtils {
  /// Malaysian timezone location
  static late tz.Location malaysianTimezone;

  /// Initialize timezone data
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    malaysianTimezone = tz.getLocation('Asia/Kuala_Lumpur');
  }

  /// Convert local DateTime to Malaysian timezone
  static tz.TZDateTime toMalaysianTime(DateTime dateTime) {
    if (dateTime.isUtc) {
      return tz.TZDateTime.from(dateTime, malaysianTimezone);
    } else {
      // Convert local time to UTC first, then to Malaysian time
      final utcTime = dateTime.toUtc();
      return tz.TZDateTime.from(utcTime, malaysianTimezone);
    }
  }

  /// Convert Malaysian timezone to UTC
  static DateTime toUtc(tz.TZDateTime malaysianTime) {
    return malaysianTime.toUtc();
  }

  /// Create a DateTime in Malaysian timezone
  static tz.TZDateTime createMalaysianTime(
    int year,
    int month,
    int day, [
    int hour = 0,
    int minute = 0,
    int second = 0,
  ]) {
    return tz.TZDateTime(
      malaysianTimezone,
      year,
      month,
      day,
      hour,
      minute,
      second,
    );
  }

  /// Get current time in Malaysian timezone
  static tz.TZDateTime nowInMalaysia() {
    return tz.TZDateTime.now(malaysianTimezone);
  }

  /// Convert DateTime to Malaysian timezone and format as ISO string
  static String toMalaysianIsoString(DateTime dateTime) {
    final malaysianTime = toMalaysianTime(dateTime);
    return malaysianTime.toIso8601String();
  }

  /// Parse ISO string as Malaysian time and convert to UTC
  static DateTime parseFromMalaysianIso(String isoString) {
    final malaysianTime = tz.TZDateTime.parse(malaysianTimezone, isoString);
    return malaysianTime.toUtc();
  }

  /// Convert TimeOfDay to Malaysian DateTime
  static tz.TZDateTime combineDateAndTimeInMalaysia(
    DateTime date,
    TimeOfDay time,
  ) {
    return tz.TZDateTime(
      malaysianTimezone,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  /// Check if two dates are the same day in Malaysian timezone
  static bool isSameDayMalaysia(DateTime date1, DateTime date2) {
    final malaysianDate1 = toMalaysianTime(date1);
    final malaysianDate2 = toMalaysianTime(date2);

    return malaysianDate1.year == malaysianDate2.year &&
        malaysianDate1.month == malaysianDate2.month &&
        malaysianDate1.day == malaysianDate2.day;
  }

  /// Format Malaysian time for display
  static String formatMalaysianTime(DateTime dateTime, String pattern) {
    final malaysianTime = toMalaysianTime(dateTime);
    // You can use intl package for formatting
    return malaysianTime.toString(); // Basic formatting
  }

  /// Get Malaysian timezone offset in hours
  static int getMalaysianOffsetHours() {
    final now = nowInMalaysia();
    return now.timeZoneOffset.inHours;
  }

  /// Debug method to show timezone information
  static Map<String, dynamic> debugTimezone(DateTime dateTime) {
    final malaysianTime = toMalaysianTime(dateTime);
    return {
      'original': dateTime.toString(),
      'originalIsUtc': dateTime.isUtc,
      'malaysianTime': malaysianTime.toString(),
      'malaysianOffset': malaysianTime.timeZoneOffset.toString(),
      'utcFromMalaysian': toUtc(malaysianTime).toString(),
    };
  }
}

/// Extension on DateTime for convenience methods
extension DateTimeExtension on DateTime {
  /// Convert to Malaysian timezone
  tz.TZDateTime toMalaysianTime() => TimezoneUtils.toMalaysianTime(this);

  /// Check if same day in Malaysian timezone
  bool isSameDayMalaysia(DateTime other) =>
      TimezoneUtils.isSameDayMalaysia(this, other);
}

/// Extension on TimeOfDay for timezone handling
extension TimeOfDayExtension on TimeOfDay {
  /// Combine with date in Malaysian timezone
  tz.TZDateTime combineDateInMalaysia(DateTime date) =>
      TimezoneUtils.combineDateAndTimeInMalaysia(date, this);
} 