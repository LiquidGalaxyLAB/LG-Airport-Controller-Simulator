import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lg_airport_simulator_apk/screens/ssh.dart';
import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:lg_airport_simulator_apk/screens/settings_page.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '22');
  final TextEditingController _rigsController = TextEditingController();
  final TextEditingController _serverportController = TextEditingController();

  final SocketService _socketService = SocketService();

  String _qrData = '';
  bool _hasError = false;
  String _errorMessage = '';
  bool isConnecting = false;
  bool connectionStatus = false;
  late SSH ssh = SSH();

@override
    void initState() {
      super.initState();
      _loadSettingsAndConnect();
    }

    Future<void> _loadSettingsAndConnect() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _ipController.text = prefs.getString('ip') ?? '';
        _usernameController.text = prefs.getString('username') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
        _portController.text = prefs.getString('port') ?? '';
        _rigsController.text = prefs.getString('screens') ?? '';
        _serverportController.text = prefs.getString('serverport') ?? '';
      });}



  void _generateQRCode() {
    // Clear previous error
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    // Validate inputs
    if (_ipController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _portController.text.isEmpty ||
        _rigsController.text.isEmpty
      ) {
      setState(() {
        _hasError = true;
        _errorMessage = 'All fields are required'.tr();
      });
      return;
    }

    try {
      // Create a map with the settings
      final Map<String, dynamic> settings = {
        'ip': _ipController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
        'port': int.tryParse(_portController.text) ?? 22,
        'screens': int.tryParse(_rigsController.text) ?? 1,
        'serverport': int.tryParse(_serverportController.text) ?? 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch, // Add timestamp for uniqueness
      };

      // Convert the map to a JSON string
      final String jsonSettings = jsonEncode(settings);
      
      setState(() {
        _qrData = jsonSettings;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error generating QR code: $e'.tr();
      });
    }
  }


    void _showSnackBar(String message, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }


   

    Future<void> _saveSettings() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      if (_ipController.text.isNotEmpty) {
        await prefs.setString('ip', _ipController.text);
      }
      if (_usernameController.text.isNotEmpty) {
        await prefs.setString('username', _usernameController.text);
      }
      if (_passwordController.text.isNotEmpty) {
        await prefs.setString('password', _passwordController.text);
      }
      if (_portController.text.isNotEmpty) {
        await prefs.setString('port', _portController.text);
      }
      if (_rigsController.text.isNotEmpty) {
        await prefs.setString('screens', _rigsController.text);
      }
      if (_serverportController.text.isNotEmpty) {
        await prefs.setString('serverport', _serverportController.text);
      }
    }

  void save_connectclear
  () async{
    await _saveSettings();
   final success =  await ssh.connectToLG();
   if(success!){
      _showSnackBar("Connected to lG".tr(), Colors.green);
      Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) => const QRGeneratorPage()),
            );
   }
   else{
      _showSnackBar("Error in Connect to LG".tr(), Colors.red);

   }
  }  

    Future<void> _attemptConnect() async {
      if (isConnecting) return; // Prevent multiple connection attempts
      
      setState(() {
        isConnecting = true;
      });

      try {
        // Attempt to connect using saved settings
        final success = await _socketService.connectToSocket(_ipController.text);
        
        setState(() {
          connectionStatus = _socketService.isConnected;
          isConnecting = false;
        });
        
        if (success && _socketService.isConnected) {
          _showSnackBar('Connected successfully!'.tr(), context.connectionSuccessColor);
        } else {
          _showSnackBar('Failed to connect. Please check your settings.'.tr(), context.connectionErrorColor);
        }
      } catch (e) {
        setState(() {
          connectionStatus = false;
          isConnecting = false;
        });
        _showSnackBar('Connection error: ${e.toString()}'.tr(), context.connectionErrorColor);
      }
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Connect and Generate LG Settings QR Code'.tr(),
         style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: context.colors.onSurface,
              )),
            backgroundColor: context.appbar,
            iconTheme: IconThemeData(color: context.colors.onSurface),
    ),
    
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IP Address field
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'IP Address *'.tr(),
                hintText: 'Enter Master IP'.tr(),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // Username field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username *'.tr(),
                hintText: 'Enter LG username'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password *'.tr(),
                hintText: 'Enter LG password'.tr(),
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // SSH Port field
            TextField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: 'SSH Port *'.tr(),
                hintText: '22',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _serverportController,
              decoration: InputDecoration(
                labelText: 'Server Port *'.tr(),
                hintText: '3001',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
              TextField(
              controller: _rigsController,
              decoration: InputDecoration(
                labelText: 'Number of Rigs *'.tr(),
                hintText: 'Enter number of LG rigs'.tr(),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Error message display
            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            // Generate QR button
            ElevatedButton(
              onPressed:save_connectclear,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                backgroundColor: context.connectionSuccessColor,
              ),
              child:  Text('Save & Connect'.tr(),
                  style: TextStyle(
                    color:Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            const SizedBox(height: 24),
             ElevatedButton(
              onPressed: _generateQRCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                backgroundColor: context.colors.onSurfaceVariant,
              ),
              child:  Text('Generate QR code'.tr(),
                  style: TextStyle(
                    color :context.colors.surface,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            const SizedBox(height: 24),

            // QR code display area
            if (_qrData.isNotEmpty)
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 250.0,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H, // Higher error correction
                        gapless: false, // Add some padding between modules
                        padding: const EdgeInsets.all(10.0), // Padding around the QR code
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan this QR code with your LG control app to load settings'.tr(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Display the generated JSON data for debugging
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Generated Data:\n$_qrData'.tr(),
                        style: TextStyle(fontSize: 12, fontFamily: 'Inter'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}