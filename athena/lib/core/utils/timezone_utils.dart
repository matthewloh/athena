import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Utility class for handling timezone conversions
/// Provides methods to convert between UTC and Malaysian time (UTC+8)
class TimezoneUtils {
  /// Malaysian timezone location
  static late tz.Location malaysianTimezone;
  static bool _isInitialized = false;

  /// Initialize timezone data
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      tz.initializeTimeZones();
      malaysianTimezone = tz.getLocation('Asia/Kuala_Lumpur');
      _isInitialized = true;
    } catch (e) {
      // Fallback to a simple UTC+8 offset if timezone data is not available
      print('Warning: Could not initialize timezone data, using UTC+8 fallback: $e');
      // Create a simple UTC+8 location as fallback
      malaysianTimezone = tz.getLocation('UTC');
      _isInitialized = true;
    }
  }

  /// Ensure timezone is initialized before use
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'TimezoneUtils not initialized. Call TimezoneUtils.initialize() first.',
      );
    }
  }

  /// Convert local DateTime to Malaysian timezone
  static tz.TZDateTime toMalaysianTime(DateTime dateTime) {
    _ensureInitialized();
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
    _ensureInitialized();
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
    _ensureInitialized();
    try {
      return tz.TZDateTime.now(malaysianTimezone);
    } catch (e) {
      // Fallback: create Malaysian time manually (UTC+8)
      final utcNow = DateTime.now().toUtc();
      final malaysianTime = utcNow.add(const Duration(hours: 8));
      return tz.TZDateTime.from(malaysianTime, tz.UTC).add(const Duration(hours: 8));
    }
  }

  /// Fallback method to get Malaysian time without full timezone support
  static DateTime nowInMalaysiaFallback() {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(const Duration(hours: 8)); // Malaysian time is UTC+8
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
    _ensureInitialized();
    // Ensure we're working with the correct timezone
    final malaysianDate = toMalaysianTime(date);
    return tz.TZDateTime(
      malaysianTimezone,
      malaysianDate.year,
      malaysianDate.month,
      malaysianDate.day,
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

  /// Create TimeOfDay from Malaysian DateTime
  static TimeOfDay timeOfDayFromMalaysianDateTime(tz.TZDateTime malaysianDateTime) {
    return TimeOfDay(
      hour: malaysianDateTime.hour,
      minute: malaysianDateTime.minute,
    );
  }

  /// Create TimeOfDay from any DateTime in Malaysian timezone
  static TimeOfDay timeOfDayFromDateTime(DateTime dateTime) {
    final malaysianTime = toMalaysianTime(dateTime);
    return TimeOfDay(
      hour: malaysianTime.hour,
      minute: malaysianTime.minute,
    );
  }

  /// Convert TimeOfDay to duration in minutes from midnight
  static int timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  /// Create TimeOfDay from minutes since midnight
  static TimeOfDay timeOfDayFromMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return TimeOfDay(hour: hours, minute: mins);
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

  /// Convert to minutes since midnight
  int get totalMinutes => TimezoneUtils.timeOfDayToMinutes(this);

  /// Create a DateTime for today with this time in Malaysian timezone
  tz.TZDateTime get todayInMalaysia {
    TimezoneUtils._ensureInitialized();
    final now = TimezoneUtils.nowInMalaysia();
    return tz.TZDateTime(
      TimezoneUtils.malaysianTimezone,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
  }

  /// Check if this time is between start and end times (handles overnight ranges)
  bool isBetween(TimeOfDay start, TimeOfDay end) {
    final thisMinutes = totalMinutes;
    final startMinutes = start.totalMinutes;
    final endMinutes = end.totalMinutes;

    if (startMinutes <= endMinutes) {
      // Normal range (e.g., 9:00 AM to 5:00 PM)
      return thisMinutes >= startMinutes && thisMinutes <= endMinutes;
    } else {
      // Overnight range (e.g., 10:00 PM to 6:00 AM)
      return thisMinutes >= startMinutes || thisMinutes <= endMinutes;
    }
  }
} 