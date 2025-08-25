import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/screens/game_task.dart';
import 'package:lg_airport_simulator_apk/screens/ssh.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lg_airport_simulator_apk/screens/popup.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});
  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final SocketService _socketService = SocketService();

  Barcode? result;
  QRViewController? controller;
  bool isFlashOn = false;
  bool isProcessing = false;
  Timer? _connectionTimeout;
  bool _hasShownResult = false;
  final SSH ssh = SSH();

  @override
  void initState() {
    super.initState();
    _socketService.addListener(_onSocketServiceChanged);
  }

  @override
  void dispose() {
    _socketService.removeListener(_onSocketServiceChanged);
    _connectionTimeout?.cancel();
    controller?.dispose();
    super.dispose();
  }

  void _onSocketServiceChanged() {
    if (_hasShownResult || !isProcessing) return;

    if (_socketService.isConnected) {
      _hasShownResult = true;
      _connectionTimeout?.cancel();
      _dismissLoadingAndShowSuccess();
    } else if (!_socketService.isConnecting) {
      _hasShownResult = true;
      _connectionTimeout?.cancel();
      _dismissLoadingAndShowFailure();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (isProcessing) return;

      setState(() {
        result = scanData;
        if (result != null && result!.code != null) {
          isProcessing = true;
          _hasShownResult = false;
          _processQRData(result!.code!);
        }
      });
    });
  }

  void _processQRData(String data) async {
    try {
      controller?.pauseCamera();

      if (data.isEmpty || data.trim().isEmpty) {
        throw Exception('QR code is empty');
      }

      print('Processing QR data: $data');

      _showLoadingDialog();

      _connectionTimeout = Timer(Duration(seconds: 30), () {
        if (isProcessing && !_hasShownResult) {
          _hasShownResult = true;
          _dismissLoadingAndShowTimeout();
        }
      });

      Map<String, dynamic> settings;
      try {
        settings = jsonDecode(data.trim());
      } catch (jsonError) {
        throw Exception('Invalid QR code format. Expected JSON format.');
      }

      if (settings.isEmpty) {
        throw Exception('QR code contains no settings');
      }

      if (!settings.containsKey('ip') ||
          settings['ip'] == null ||
          settings['ip'].toString().trim().isEmpty) {
        throw Exception('Invalid QR code: Missing IP address');
      }

      String ip = settings['ip'].toString().trim();
      if (!RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(ip)) {
        throw Exception('Invalid IP address format');
      }

      print('Settings parsed successfully: $settings');

      await _saveSettings(settings);

      print('Attempting to connect to: $ip');

      final success = await ssh.connectToLG();

      _connectionTimeout?.cancel();

      if (success == true) {
        _hasShownResult = true;
        _dismissLoadingAndShowSuccess();
      } else {
        _hasShownResult = true;
        _dismissLoadingAndShowFailure();
      }
    } catch (e) {
      print('QR Processing Error: $e');

      _hasShownResult = true;
      _connectionTimeout?.cancel();
      _dismissLoadingDialog();

      String errorMessage = e.toString();
      if (errorMessage.contains('FormatException')) {
        errorMessage =
            'Invalid QR code format. Please scan a valid settings QR code.';
      }

      BottomPopup.showError(
        context: context,
        title: "QR Code Error",
        subtitle: errorMessage.replaceAll('Exception: ', ''),
      );

      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _resetScanningState();
        }
      });
    }
  }

  Future<void> _saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('saved_ip', settings['ip']);

    if (settings.containsKey('username')) {
      await prefs.setString('username', settings['username']);
    }
    if (settings.containsKey('password')) {
      await prefs.setString('password', settings['password']);
    }
    if (settings.containsKey('port')) {
      await prefs.setString('port', settings['port'].toString());
    }
    if (settings.containsKey('screens')) {
      await prefs.setString('screens', settings['screens'].toString());
    }

    print('Settings saved: $settings');
  }

  void _dismissLoadingDialog() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _dismissLoadingAndShowSuccess() {
    _dismissLoadingDialog();

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        BottomPopup.showSuccess(
          context: context,
          title: "Connection Successful",
          subtitle: "Successfully connected to the server.",
        );

        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LG_AIRPORT_M()),
            );
          }
        });
      }
    });
  }

  void _dismissLoadingAndShowFailure() {
    _dismissLoadingDialog();

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        BottomPopup.showError(
          context: context,
          title: "Connection Failed",
          subtitle: "Failed to connect to the server.",
        );

        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _resetScanningState();
          }
        });
      }
    });
  }

  void _dismissLoadingAndShowTimeout() {
    _dismissLoadingDialog();

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        BottomPopup.show(
          context: context,
          data: PopupData(
            type: PopupType.error,
            titleColor: context.connectionPendingColor,
            title: "Connection Timeout",
            subtitle: "The connection to the server timed out.",
          ),
        );

        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _resetScanningState();
          }
        });
      }
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Connecting to server...'),
                  SizedBox(height: 10),
                  Text(
                    'Please wait...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _resetScanningState() {
    if (mounted && controller != null) {
      controller!.resumeCamera();
      setState(() {
        isProcessing = false;
        _hasShownResult = false;
      });
    }
  }

  void _flashToggle() async {
    if (controller != null) {
      await controller!.toggleFlash();
      bool? flashStatus = await controller!.getFlashStatus();
      if (mounted) {
        setState(() {
          isFlashOn = flashStatus ?? false;
        });
      }
    }
  }

  void _cameraSwitch() async {
    if (controller != null) {
      await controller!.flipCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Settings QR Code'.tr(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: context.colors.onSurface,
          ),
        ),
        backgroundColor: context.appbar,
        iconTheme: IconThemeData(color: context.colors.onSurface),
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 40,
              borderWidth: 10,
              cutOutSize: 250,
            ),
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _flashToggle,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.camera_rotate_fill,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _cameraSwitch,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Scan a QR code to automatically connect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
