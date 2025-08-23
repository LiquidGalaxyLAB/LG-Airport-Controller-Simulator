import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/screens/active_approaches_screen.dart';
import 'package:lg_airport_simulator_apk/screens/instructionpage.dart';
import 'package:lg_airport_simulator_apk/screens/settings_page.dart';
import 'package:lg_airport_simulator_apk/screens/ssh.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:lg_airport_simulator_apk/service/languageChange.dart';
import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:lg_airport_simulator_apk/service/tts_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Check if this is the first time the app is run
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('is_first_run') ?? true;
  
  if (isFirstRun) {
    // Reset the "don't show instructions" flag on first run
    await prefs.setBool('dont_show_instructions', false);
    await prefs.setBool('is_first_run', false);
  }
  
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('ar'), 
        Locale('de'), 
        Locale('en'), 
        Locale('es'), 
        Locale('fr'), 
        Locale('gu'), 
        Locale('hi'), 
        Locale('ru'), 
      ],
      path: 'assets/lang',
      fallbackLocale: Locale('en'),
      startLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TtsService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SocketService()),
        ChangeNotifierProvider(create: (_) => SSH()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'LG AIRPORT CONTROLLER'.tr(),
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: SplashScreen(), // Changed to SplashScreen
            routes: {
              '/active_approaches': (context) => ActiveApproachesScreen(),
            },
          );
        },
      ),
    );
  }
}

// New Splash Screen Widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    
    _navigateToActiveApproaches();
  }

  _navigateToActiveApproaches() async {
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      // Check if we should show instructions first
      final prefs = await SharedPreferences.getInstance();
      final dontShowInstructions = prefs.getBool('dont_show_instructions') ?? false;
      
      if (!dontShowInstructions) {
        // Show instruction page first
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => InstructionPage(isFirstTime: true),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        // Go directly to active approaches
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ActiveApproachesScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo/Icon
                      Image.asset('assets/logo.png', fit: BoxFit.contain),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _socketService.loadSavedIP();
    _socketService.addListener(_onSocketServiceChanged);
  }

  @override
  void dispose() {
    _socketService.removeListener(_onSocketServiceChanged);
    super.dispose();
  }

  void _onSocketServiceChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Airplane Socket Controller'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActiveApproachesScreen()),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildConnectedView(),
      ),
    );
  }

  Widget _buildConnectedView() {
    return Column(
      children: [
        Text('Connected! Tap a plane to add, then control.'),
        Wrap(
          spacing: 8,
          children: _socketService.airplanes
              .map((plane) => ElevatedButton(
                    onPressed: () => _socketService.addPlane(plane),
                    child: Text(plane['label']),
                  ))
              .toList(),
        ),
        SizedBox(height: 16),
        Text('Select Active Plane:'),
        Wrap(
          spacing: 8,
          children: _socketService.airplanesData
              .map((plane) => ElevatedButton(
                    onPressed: () => _socketService.selectPlane(plane),
                    child: Text(plane['label']),
                  ))
              .toList(),
        ),
        SizedBox(height: 10),
        Text('Command Preview:'),
        // Text(
        //   // _socketService.commandText,
        //   // style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _socketService.turnLeft,
              child: Text('← Left'),
            ),
            ElevatedButton(
              onPressed: _socketService.turnRight,
              child: Text('Right →'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _socketService.increaseAltitude,
              child: Text('+ Alt'),
            ),
            ElevatedButton(
              onPressed: _socketService.decreaseAltitude,
              child: Text('- Alt'),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: _socketService.submitCommand,
          child: Text('Submit'),
        ),
      ],
    );
  }
  
  Widget _buildDisconnectedView() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Enter IP:PORT'),
          controller: TextEditingController(text: _socketService.ip),
          onChanged: (val) => _socketService.setIP(val),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _socketService.isConnecting
              ? null
              : () => _socketService.connectToSocket(_socketService.ip),
          child: _socketService.isConnecting
              ? CircularProgressIndicator()
              : Text('Connect'),
        ),
      ],
    );
  }
}