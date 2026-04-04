import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class UserAgentGenerator {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<String> generate() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return _androidUA(info);
    }
    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return _iosUA(info);
    }
    if (Platform.isWindows) return _windowsUA();
    if (Platform.isLinux) return _linuxUA();
    if (Platform.isMacOS) return _macosUA();
    return _fallbackUA();
  }

  static String _androidUA(AndroidDeviceInfo info) {
    final version = info.version;
    final release = version.release;
    final sdk = version.sdkInt;
    final model = info.model;
    return 'Mozilla/5.0 (Linux; Android $release; $model) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/$sdk.0.0.0 Mobile Safari/537.36';
  }

  static String _iosUA(IosDeviceInfo info) {
    final version = info.systemVersion;
    final versionUnderscore = version.replaceAll('.', '_');
    return 'Mozilla/5.0 (iPhone; CPU iPhone OS $versionUnderscore like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/$version Mobile/15E148 Safari/604.1';
  }

  static String _windowsUA() {
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  }

  static String _linuxUA() {
    return 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  }

  static String _macosUA() {
    return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  }

  static String _fallbackUA() {
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
  }
}
