import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';

/* PrayerApiService
| -------------------------------------------------------------------------
| AlAdhan Prayer Times API
| Documentation: https://aladhan.com/prayer-times-api
|-------------------------------------------------------------------------- */

class PrayerApiService extends NyApiService {
  PrayerApiService() : super(useNetworkLogger: true);

  @override
  String get baseUrl => "https://api.aladhan.com/v1";

  /// Fetch prayer times for a given date and location
  Future<Map<String, dynamic>?> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date ?? DateTime.now());
    
    final response = await network(
      request: (request) => request.get("/timings/$formattedDate", queryParameters: {
        "latitude": latitude,
        "longitude": longitude,
        "method": 2, // ISNA method as a default, can be customized
      }),
    );
    
    if (response != null && response['data'] != null) {
      return response['data'];
    }
    return null;
  }
}
