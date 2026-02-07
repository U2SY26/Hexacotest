import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfo {
  final String minVersion; // 최소 지원 버전 (강제 업데이트)
  final String latestVersion; // 최신 버전 (선택 업데이트)
  final String? updateMessage; // 업데이트 메시지
  final String? updateMessageEn;
  final bool forceUpdate; // 강제 업데이트 여부

  VersionInfo({
    required this.minVersion,
    required this.latestVersion,
    this.updateMessage,
    this.updateMessageEn,
    this.forceUpdate = false,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      minVersion: json['minVersion'] ?? '1.0.0',
      latestVersion: json['latestVersion'] ?? '1.0.0',
      updateMessage: json['updateMessage'],
      updateMessageEn: json['updateMessageEn'],
      forceUpdate: json['forceUpdate'] ?? false,
    );
  }
}

class VersionCheckService {
  // 버전 정보를 가져올 URL (vercel 또는 GitHub에 호스팅)
  static const String _versionUrl = 'https://hexacotest.vercel.app/version.json';
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.hexaco.mobile';

  /// 버전 체크 및 업데이트 다이얼로그 표시
  static Future<void> checkForUpdate(BuildContext context, {bool isKo = true}) async {
    try {
      final versionInfo = await _fetchVersionInfo();
      if (versionInfo == null) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final needsForceUpdate = _compareVersions(currentVersion, versionInfo.minVersion) < 0;
      final hasNewVersion = _compareVersions(currentVersion, versionInfo.latestVersion) < 0;

      if (!context.mounted) return;

      if (needsForceUpdate || versionInfo.forceUpdate) {
        // 강제 업데이트 다이얼로그
        _showForceUpdateDialog(context, versionInfo, isKo);
      } else if (hasNewVersion) {
        // 선택적 업데이트 다이얼로그
        _showOptionalUpdateDialog(context, versionInfo, isKo);
      }
    } catch (e) {
      // 버전 체크 실패 시 조용히 넘어감
      debugPrint('Version check failed: $e');
    }
  }

  /// 서버에서 버전 정보 가져오기
  static Future<VersionInfo?> _fetchVersionInfo() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return VersionInfo.fromJson(json);
      }
    } catch (e) {
      debugPrint('Failed to fetch version info: $e');
    }
    return null;
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
  static void _showForceUpdateDialog(BuildContext context, VersionInfo info, bool isKo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.system_update, color: Color(0xFFA855F7)),
              const SizedBox(width: 12),
              Text(
                isKo ? '업데이트 필요' : 'Update Required',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isKo
                    ? '새로운 버전이 출시되었습니다.\n앱을 계속 사용하려면 업데이트가 필요합니다.'
                    : 'A new version is available.\nPlease update to continue using the app.',
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
              if (info.updateMessage != null || info.updateMessageEn != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isKo ? (info.updateMessage ?? '') : (info.updateMessageEn ?? ''),
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => _openStore(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isKo ? '업데이트하기' : 'Update Now'),
            ),
          ],
        ),
      ),
    );
  }

  /// 선택적 업데이트 다이얼로그
  static void _showOptionalUpdateDialog(BuildContext context, VersionInfo info, bool isKo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.new_releases, color: Color(0xFFA855F7)),
            const SizedBox(width: 12),
            Text(
              isKo ? '새 버전 안내' : 'New Version Available',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isKo
                  ? '새로운 버전(${info.latestVersion})이 출시되었습니다.\n더 나은 경험을 위해 업데이트해주세요.'
                  : 'A new version (${info.latestVersion}) is available.\nUpdate for a better experience.',
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            if (info.updateMessage != null || info.updateMessageEn != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isKo ? (info.updateMessage ?? '') : (info.updateMessageEn ?? ''),
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isKo ? '나중에' : 'Later',
              style: const TextStyle(color: Colors.white54),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isKo ? '업데이트' : 'Update'),
          ),
        ],
      ),
    );
  }

  /// 스토어 열기
  static Future<void> _openStore() async {
    // Android는 Play Store, iOS는 App Store
    final url = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
