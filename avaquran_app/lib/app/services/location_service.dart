import 'package:geolocator/geolocator.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      NyLogger.error('Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        NyLogger.error('Location permissions are denied');
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      NyLogger.error('Location permissions are permanently denied, we cannot request permissions.');
      return null;
    } 

    return await Geolocator.getCurrentPosition();
  }
}
