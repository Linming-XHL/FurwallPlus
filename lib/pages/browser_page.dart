import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/user_agent.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? _controller;
  String _userAgent = '';
  bool _isLoading = true;
  double _progress = 0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initUserAgent();
    _checkForUpdates();
  }

  Future<void> _initUserAgent() async {
    final ua = await UserAgentGenerator.generate();
    setState(() => _userAgent = ua);
  }

  Future<void> _checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse('https://api.github.com/repos/Linming-XHL/FurwallPlus/releases/latest'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'];
        if (latestVersion != 'v1.0.8') {
          _showUpdateDialog(latestVersion);
        }
      }
    } catch (e) {
      // 忽略更新检查错误
    }
  }

  void _showUpdateDialog(String latestVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('发现新版本'),
        content: Text('当前版本: v1.0.8\n最新版本: $latestVersion\n\n是否前往下载更新？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('暂不更新'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openUpdatePage();
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  void _openUpdatePage() {
    InAppBrowser.openWithSystemBrowser(
      url: WebUri('https://github.com/Linming-XHL/FurwallPlus/releases/latest'),
    );
  }

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (_userAgent.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return _buildErrorView();
    }

    return Scaffold(
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 3,
            ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(sourceUrl)),
              initialSettings: InAppWebViewSettings(
                userAgent: _userAgent,
                javaScriptEnabled: true,
                cacheEnabled: true,
                transparentBackground: false,
                offscreenPreRaster: true,
                javaScriptCanOpenWindowsAutomatically: false,
                allowsInlineMediaPlayback: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
              onWebViewCreated: (controller) => _controller = controller,
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                  _progress = 0;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _isLoading = false;
                  _progress = 1.0;
                });
                if (_isMobile) {
                  controller.evaluateJavascript(source: removeAppBannerJS);
                }
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onReceivedError: (controller, request, error) => _handleError(error.description),
              onReceivedHttpError: (controller, request, error) => _handleError('HTTP ${error.statusCode}'),
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                final shouldProceed = await _showSslDialog();
                if (shouldProceed) {
                  return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                }
                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.CANCEL);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                });
                _controller?.reload();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isLoading = false;
      _progress = 0;
    });
  }

  Future<bool> _showSslDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('安全警告'),
        content: const Text('SSL证书验证失败，是否继续连接？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('继续'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
