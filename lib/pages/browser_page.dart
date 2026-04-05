import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
  }

  Future<void> _initUserAgent() async {
    final ua = await UserAgentGenerator.generate();
    setState(() => _userAgent = ua);
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
      body: SafeArea(
        child: Column(
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
