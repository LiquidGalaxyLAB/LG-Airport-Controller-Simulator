import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/screens/about_page.dart';
import 'package:lg_airport_simulator_apk/screens/game_task.dart';
import 'package:lg_airport_simulator_apk/screens/instructionpage.dart';
import 'package:lg_airport_simulator_apk/screens/language.dart';
import 'package:lg_airport_simulator_apk/screens/lg_task.dart';
  import 'package:lg_airport_simulator_apk/screens/qr_scanner.dart';
  import 'package:lg_airport_simulator_apk/screens/qr_utility.dart';
import 'package:lg_airport_simulator_apk/screens/ssh.dart';
  import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:lg_airport_simulator_apk/screens/tts_popup.dart';
import 'package:lg_airport_simulator_apk/screens/tts_settingpage.dart';
import 'package:lg_airport_simulator_apk/screens/popup.dart';
  import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:lg_airport_simulator_apk/service/tts_service.dart';
  import 'package:provider/provider.dart';
  import 'package:dartssh2/dartssh2.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class SettingsPage extends StatefulWidget {
    const SettingsPage({super.key});

    @override
    _SettingsPageState createState() => _SettingsPageState();
  }

  class _SettingsPageState extends State<SettingsPage> {
    bool connectionStatus = false;
    bool isConnecting = false;
    late SSH ssh;

    @override
    void initState() {
      super.initState();
      ssh = SSH();
      _loadSettingsAndConnect();
    }

    final TextEditingController _ipController = TextEditingController();
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _portController = TextEditingController();
    final TextEditingController _rigsController = TextEditingController();
    final TextEditingController _gemini = TextEditingController();
    final SocketService _socketService = SocketService();
    ThemeProvider get themeProvider => ThemeProvider();
    final TtsService tts = TtsService();


    @override
    void dispose() {
      _ipController.dispose();
      _usernameController.dispose();
      _passwordController.dispose();
      _portController.dispose();
      _rigsController.dispose();
      _gemini.dispose();
      super.dispose();
    }

    Future<void> _loadSettingsAndConnect() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _ipController.text = prefs.getString('ip') ?? '';
        _usernameController.text = prefs.getString('username') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
        _portController.text = prefs.getString('port') ?? '';
        _rigsController.text = prefs.getString('screens') ?? '';
      });

      // // Check if we have saved preferences and auto-connect
      // if (_hasValidSettings()) {
      //   await _attemptAutoConnect();
      // }
    }


 Future<void> connectAndExecute() async {
      try {
        final connected = await ssh.connectToLG();
        if (connected!) { 
        final  result =  await ssh.command_to_open_lg();
        if(result){
          BottomPopup.showSuccess(context: context, title: 'Successfully Launched'.tr(), subtitle: 'command has executed successfully please give it a moment'.tr());
        }
        else{
          BottomPopup.showError(context: context, title: 'Error'.tr(), subtitle: 'Error executing LG Chrome command'.tr());
        }
        return ;
    }
      }
      catch (error) {
        print('Error executing LG command:  $error');
      }
    }

void killChrome() async{
    try{ final connected = await ssh.connectToLG();
        if (connected!) { 
  await ssh.command_to_chrome_kill();
    BottomPopup.showSuccess(context: context, title: 'Successfully Killed'.tr(), subtitle: 'command has executed successfully please give it a moment'.tr());
  }}
  catch(error){
    BottomPopup.showSuccess(context: context, title: 'Error'.tr(), subtitle: 'command has executed successfully please give it a moment'.tr());
    
  }
}

    Future<void> _attemptConnect() async {
      if (isConnecting) return; // Prevent multiple connection attempts
      
      setState(() {
        isConnecting = true;
      });

      try {
        if(_socketService.isConnected){_socketService.disconnectSocket();}
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
        _showSnackBar('Connection error: ${e.toString()}', context.connectionErrorColor);
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
      if (_gemini.text.isNotEmpty) {
        await prefs.setString('gemini', _gemini.text);
      }
    }

    Future<void> _scanQRCode() async {
      final Map<String, dynamic>? settings = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QRScannerPage()),
      );

      if (settings != null) {
        setState(() {
          _ipController.text = settings['ip'] ?? _ipController.text;
          _usernameController.text = settings['username'] ?? _usernameController.text;
          _passwordController.text = settings['password'] ?? _passwordController.text;
          _portController.text = settings['port'] ?? _portController.text;
          _rigsController.text = settings['screens'] ?? _rigsController.text;
          _gemini.text = settings['gemini'] ?? _gemini.text;
        });
        
        // Save settings - user can connect manually later
        // await _saveSettings();
      }
    }


    @override
    Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, connectionStatus);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title:  Text('Connection Settings',
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
              children: <Widget>[
                // Connection Status Indicator
                // Container(
                //   padding: const EdgeInsets.all(12),
                //   margin: const EdgeInsets.only(bottom: 20),
                //   decoration: BoxDecoration(
                //     color: _socketService.isConnected 
                //         ? context.connectionSuccessColor.withOpacity(0.1)
                //         : isConnecting 
                //             ? context.connectionPendingColor.withOpacity(0.1)
                //             : context.connectionErrorColor.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(8),
                //     border: Border.all(
                //       color: _socketService.isConnected 
                //           ? context.connectionSuccessColor
                //           : isConnecting 
                //               ? context.connectionPendingColor
                //               : context.connectionErrorColor,
                //     ),
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(
                //         _socketService.isConnected 
                //             ? Icons.check_circle
                //             : isConnecting 
                //                 ? Icons.sync
                //                 : Icons.error,
                //         color: _socketService.isConnected 
                //             ? context.connectionSuccessColor
                //             : isConnecting 
                //                 ? context.connectionPendingColor
                //                 : context.connectionErrorColor,
                //       ),
                //       const SizedBox(width: 8),
                //       // Text(
                //       //   _socketService.isConnected 
                //       //       ? 'Connected Game'.tr()
                //       //       : isConnecting 
                //       //           ? 'Connecting...'.tr()
                //       //           : 'Game Not Connected'.tr(),
                //       //   style: TextStyle(
                //       //     fontWeight: FontWeight.w500,
                //       //     color: _socketService.isConnected 
                //       //         ? context.connectionSuccessColor
                //       //         : isConnecting 
                //       //             ? context.connectionPendingColor
                //       //             : context.connectionErrorColor,
                //       //   ),
                //       // ),
                //     ],
                //   ),
                // ),

                // Settings Options
                settingItem(title: "Scan QR".tr(), onTap: _scanQRCode , context: context), 
                // settingItem(title: "Connect Chromium ", onTap: connectAndExecute , context: context), 
                // settingItem(title: "Disconnect Chromium ", onTap: killChrome , context: context), 
                settingItem(title: "Manual Connect".tr(),context: context, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QRGeneratorPage()),
                  );
                } , shouldShowIcon: true),
                settingItem(title: "Game Control".tr(),shouldShowIcon: true, context: context, onTap: () {  
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LG_AIRPORT_M()),  
                );
                }),
                 settingItem(title: "LG Task".tr(),shouldShowIcon: true, context: context, onTap: () { 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LG_Task()),  
                );
                }),
  
                settingItem(title: "Setting voice".tr(),shouldShowIcon: true, context: context, onTap: () { 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const  TtsSettingsPage()),  
                );
                }),
                settingItem ( title: "Theme: ${context.watch<ThemeProvider>().isDarkMode ? 'Dark Mode' : 'Light Mode'}".tr(), context: context, onTap: () {
                  context.read<ThemeProvider>().toggleTheme();
                  setState(() {}); // Force rebuild to update the title
                },),
                settingItem(title: "Language", shouldShowIcon: true, context: context, onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const  LanguageSelectionPage()),  
                );
                }),
            //     settingItem(title: "speak", context: context, onTap: () {
            //     tts.speak('Hello World!');
            
            // }),

              //     settingItem(title: "speak2", context: context, onTap: () {
              //   tts.speak('Hello World!');
                
              //   tts.speak(
              //   'This is a custom voice test',
              //   customRate: 1.0,
              //   customPitch: 1.5,
              // addRoger: false,
              // );
              //   }),
                
                 settingItem(title: "Instructions", shouldShowIcon: true, context: context, onTap: () async {
                  // Reset the "don't show again" preference so instructions can be shown again
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('dont_show_instructions', false);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const InstructionPage()));
                }),

                settingItem(title: "About".tr(),shouldShowIcon: true, context: context, onTap: () { 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const  AboutPage()),  
                );
                }),
                
                // Add a hidden option to reset "don't show instructions" for testing
                settingItem(title: "Reset Instructions", context: context, onTap: () async {
                  BottomPopup.showInfo(context: context, title: 'Reset Instructions'.tr(), subtitle: 'You’ll see the instructions again the next time you open the app..', options: ['OK'], onOptionSelected: (selectedOption) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('dont_show_instructions', false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Instructions reset — they’ll be shown on restart.')),
                  );
                  });
                }),
                const SizedBox(height: 20),

                // Connect/Reconnect Button
              //   if (!_socketService.isConnected && !isConnecting)
              //     ElevatedButton.icon(
              //       icon: const Icon(Icons.wifi),
              //       label: Text(_hasValidSettings() ? 'Connect'.tr() : 'Set Connection Details'.tr()),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: _hasValidSettings() ? Colors.blue : Colors.grey,
              //         padding: const EdgeInsets.all(12),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(50),
              //         ),
              //       ),
              //       onPressed: _hasValidSettings() ? _attemptConnect : null,
              //     ),

              //   // Loading indicator when connecting
              //   if (isConnecting)
              //     const Padding(
              //       padding: EdgeInsets.symmetric(vertical: 20),
              //       child: Center(
              //         child: CircularProgressIndicator(),
              //       ),
              //     ),

              // // Disconnect Section
              //   if (_socketService.isConnected) ...[
              //     const SizedBox(height: 20),
              //     ElevatedButton.icon(
              //       icon: Icon(Icons.close,
              //         color: context.colors.onError,),
              //       label: Text('Disconnect'.tr(),
              //         style: TextStyle(color: context.colors.onError),),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: context.connectionErrorColor,
              //         padding: const EdgeInsets.all(12),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(50),
              //         ),
              //       ),
                  //   onPressed: () {
                  //     _socketService.disconnectSocket();
                  //     setState(() {
                  //       connectionStatus = false;
                  //     });
                  //     _showSnackBar('Disconnected successfully'.tr(), context.connectionPendingColor);
                  //   },
                  // ),
                // ]
              ],
            ),
          ),
        ),
      );
    }

    Widget settingItem({
      required String title,
      required VoidCallback onTap,
      required BuildContext context,
      bool shouldShowIcon = false,
    }) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            title,
            style:  TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: context.colors.onSurface,
            ),
          ),
          trailing: shouldShowIcon ? Icon(
            Icons.chevron_right,
            color: context.colors.onSurface,
            size: 24,
          ): null,
          onTap: onTap,
        ),
      );
    }
  }