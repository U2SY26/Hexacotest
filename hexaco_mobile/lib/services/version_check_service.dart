import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckService {
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.hexaco.hexaco_mobile';

  // Remote Config 키
  static const String _keyLatestVersion = 'latest_version';
  static const String _keyForceUpdate = 'force_update';
  static const String _keyUpdateMessage = 'update_message';
  static const String _keyUpdateMessageEn = 'update_message_en';

  /// 허용 버전 차이 (latest 기준 patch 2까지 허용, 그 이하 강제 업데이트)
  static const int _allowedVersionsBehind = 2;

  /// Remote Config 초기화 (앱 시작 시 1회 호출)
  static Future<void> init() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await rc.setDefaults({
        _keyLatestVersion: '1.0.0',
        _keyForceUpdate: false,
        _keyUpdateMessage: '',
        _keyUpdateMessageEn: '',
      });
      await rc.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config init failed: $e');
    }
  }

  /// 버전 체크 및 업데이트 다이얼로그 표시
  static Future<void> checkForUpdate(BuildContext context, {bool isKo = true}) async {
    try {
      final rc = FirebaseRemoteConfig.instance;

      // 백그라운드에서 최신 값 fetch (이미 activate된 값 사용)
      try {
        await rc.fetchAndActivate();
      } catch (_) {
        // fetch 실패해도 캐시된 값 사용
      }

      final latestVersion = rc.getString(_keyLatestVersion);
      final forceUpdate = rc.getBool(_keyForceUpdate);
      final updateMessage = rc.getString(_keyUpdateMessage);
      final updateMessageEn = rc.getString(_keyUpdateMessageEn);

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // latest_version에서 자동으로 min_version 계산 (patch를 2만큼 뺌)
      final minVersion = _subtractPatch(latestVersion, _allowedVersionsBehind);
      final needsForceUpdate = _compareVersions(currentVersion, minVersion) < 0;
      final hasNewVersion = _compareVersions(currentVersion, latestVersion) < 0;

      if (!context.mounted) return;

      if (needsForceUpdate || forceUpdate) {
        _showForceUpdateDialog(
          context,
          latestVersion: latestVersion,
          message: isKo ? updateMessage : updateMessageEn,
          isKo: isKo,
        );
      } else if (hasNewVersion) {
        _showOptionalUpdateDialog(
          context,
          latestVersion: latestVersion,
          message: isKo ? updateMessage : updateMessageEn,
          isKo: isKo,
        );
      }
    } catch (e) {
      debugPrint('Version check failed: $e');
    }
  }

  /// latest 버전에서 patch를 n만큼 빼서 최소 허용 버전 계산
  /// 예: _subtractPatch('1.0.33', 2) → '1.0.31'
  static String _subtractPatch(String version, int n) {
    final parts = version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    parts[2] = (parts[2] - n).clamp(0, parts[2]);
    return parts.join('.');
  }

  /// 버전 비교 (-1: a < b, 0: a == b, 1: a > b)
  static int _compareVersions(String a, String b) {
    final aParts = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final bParts = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = aParts.length > bParts.length ? aParts.length : bParts.length;

    for (var i = 0; i < maxLength; i++) {
      final aVal = i < aParts.length ? aParts[i] : 0;
      final bVal = i < bParts.length ? bParts[i] : 0;

      if (aVal < bVal) return -1;
      if (aVal > bVal) return 1;
    }
    return 0;
  }

  /// 강제 업데이트 다이얼로그 (닫기 불가)
  static void _showForceUpdateDialog(
    BuildContext context, {
    required String latestVersion,
    String? message,
    required bool isKo,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFA855F7), width: 1.5),
          ),
          elevation: 24,
          shadowColor: const Color(0xFFA855F7),
          title: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.system_update, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                isKo ? '업데이트 필요' : 'Update Required',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isKo
                    ? '새로운 버전($latestVersion)이 출시되었습니다.\n앱을 계속 사용하려면 업데이트가 필요합니다.'
                    : 'A new version ($latestVersion) is available.\nPlease update to continue using the app.',
                style: const TextStyle(color: Colors.white70, height: 1.5),
                textAlign: TextAlign.center,
              ),
              if (message != null && message.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openStore(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                  shadowColor: const Color(0xFFA855F7).withValues(alpha: 0.5),
                ),
                child: Text(
                  isKo ? '업데이트하기' : 'Update Now',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 선택적 업데이트 다이얼로그
  static void _showOptionalUpdateDialog(
    BuildContext context, {
    required String latestVersion,
    String? message,
    required bool isKo,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFFA855F7).withValues(alpha: 0.5), width: 1),
        ),
        elevation: 24,
        shadowColor: const Color(0xFFA855F7),
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFA855F7), Color(0xFF6366F1)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.new_releases, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              isKo ? '새 버전 안내' : 'New Version Available',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isKo
                  ? '새로운 버전($latestVersion)이 출시되었습니다.\n더 나은 경험을 위해 업데이트해주세요.'
                  : 'A new version ($latestVersion) is available.\nUpdate for a better experience.',
              style: const TextStyle(color: Colors.white70, height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              isKo ? '나중에' : 'Later',
              style: const TextStyle(color: Colors.white54, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openStore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA855F7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 8,
              shadowColor: const Color(0xFFA855F7).withValues(alpha: 0.5),
            ),
            child: Text(
              isKo ? '업데이트' : 'Update',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// 스토어 열기
  static Future<void> _openStore() async {
    final url = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
