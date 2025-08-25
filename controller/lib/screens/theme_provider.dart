import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Theme Provider with Persistence
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }
  
  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }
  
  void toggleTheme() {
    setTheme(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

// 2. App Theme Configuration
class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 2,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.grey[800],
      shadowColor: Colors.black,
      elevation: 2,
    ),
  );
}

extension ThemeHelper on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  Color get connectionSuccessColor => isDarkMode ? Colors.green[400]! : Colors.green[600]!;
  Color get connectionErrorColor => isDarkMode ? Colors.red[400]! : Colors.red[600]!;
  Color get connectionPendingColor => isDarkMode ? Colors.orange[400]! : Colors.orange[600]!;
  Color get appbar  => isDarkMode ?  Colors.grey[600]! : Colors.white;
}

class ConnectionStatusWidget extends StatelessWidget {
  final TextStyle? textStyle;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  
  const ConnectionStatusWidget({
    super.key,
    this.textStyle,
    this.showIcon = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketService>(
      builder: (context, socketService, child) {
        Color statusColor;
        IconData statusIcon;
        String statusText;
        
        if (socketService.isConnected) {
          statusColor = context.connectionSuccessColor;
          statusIcon = Icons.wifi;
          statusText = 'Connected to Liquid Galaxy'.tr();
        } else if (socketService.isConnecting) {
          statusColor = context.connectionPendingColor;
          statusIcon = Icons.wifi_find;
          statusText = 'Connecting...'.tr();
        } else {
          statusColor = context.connectionErrorColor;
          statusIcon = Icons.wifi_off;
          statusText = 'Not Connected'.tr();
        }

        return Container(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(statusIcon, color: statusColor, size: 20),
                SizedBox(width: 8),
              ],
              Text(
                statusText,
                style: textStyle ?? TextStyle(
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  final bool showText;
  
  const ThemeToggleButton({super.key, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return showText
            ? TextButton.icon(
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                label: Text(themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode'),
              )
            : IconButton(
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
      },
    );
  }
}
class ThemedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool highlighted;
  
  const ThemedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlighted 
          ? context.colors.primaryContainer 
          : context.theme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}