import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Enhanced Theme Provider with Color Selection and Persistence
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  static const String _accentColorKey = 'accent_color';
  
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.blue;
  Color _accentColor = Colors.blueAccent;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;
  
  // Predefined color options
  static const List<Color> availableColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightGreen,
  ];
  
  ThemeProvider() {
    _loadTheme();
  }
  
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    // Load custom colors
    final primaryColorValue = prefs.getInt(_primaryColorKey);
    final accentColorValue = prefs.getInt(_accentColorKey);
    
    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    }
    if (accentColorValue != null) {
      _accentColor = Color(accentColorValue);
    }
    
    notifyListeners();
  }
  
  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }
  
  void setPrimaryColor(Color color) async {
    _primaryColor = color;
    _accentColor = _generateAccentColor(color);
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
    await prefs.setInt(_accentColorKey, _accentColor.value);
    notifyListeners();
  }
  
  void setCustomColors(Color primary, Color accent) async {
    _primaryColor = primary;
    _accentColor = accent;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, primary.value);
    await prefs.setInt(_accentColorKey, accent.value);
    notifyListeners();
  }
  
  Color _generateAccentColor(Color primary) {
    final hsl = HSLColor.fromColor(primary);
    return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
  }
  
  void toggleTheme() {
    setTheme(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
  
  void resetToDefault() async {
    _primaryColor = Colors.blue;
    _accentColor = Colors.blueAccent;
    _themeMode = ThemeMode.system;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_primaryColorKey);
    await prefs.remove(_accentColorKey);
    await prefs.remove(_themeKey);
    notifyListeners();
  }
}

// 2. Enhanced App Theme Configuration
class AppThemes {
  static ThemeData lightTheme(Color primaryColor, Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.grey[300],
        elevation: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
      ),
    );
  }
  
  static ThemeData darkTheme(Color primaryColor, Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: primaryColor,
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
      ),
    );
  }
}

// 3. Color Picker Dialog
class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose App Color',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: ThemeProvider.availableColors.length,
              itemBuilder: (context, index) {
                final color = ThemeProvider.availableColors[index];
                return Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    final isSelected = themeProvider.primaryColor.value == color.value;
                    return GestureDetector(
                      onTap: () {
                        themeProvider.setPrimaryColor(color);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .resetToDefault();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset to Default'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Color Picker Button
class ColorPickerButton extends StatelessWidget {
  final bool showText;
  
  const ColorPickerButton({super.key, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return showText
            ? TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ColorPickerDialog(),
                  );
                },
                icon: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                label: const Text('Change Color'),
              )
            : IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ColorPickerDialog(),
                  );
                },
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                tooltip: 'Change App Color',
              );
      },
    );
  }
}

// 5. Theme Settings Widget - Complete settings panel
class ThemeSettingsPanel extends StatelessWidget {
  const ThemeSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Appearance',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                
                // Theme mode selection
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  title: const Text('Theme Mode'),
                  subtitle: Text(
                    themeProvider.themeMode == ThemeMode.system
                        ? 'System'
                        : themeProvider.isDarkMode
                            ? 'Dark'
                            : 'Light',
                  ),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) {
                        themeProvider.setTheme(mode);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Color selection
                ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: const Text('App Color'),
                  subtitle: const Text('Choose your preferred color theme'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ColorPickerDialog(),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Reset button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset Theme'),
                          content: const Text(
                            'This will reset all theme settings to default. Continue?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                themeProvider.resetToDefault();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Reset to Default'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 6. Updated Theme Helper Extension
extension ThemeHelper on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  // Custom color getters for your specific needs
  Color get connectionSuccessColor => isDarkMode ? Colors.green[400]! : Colors.green[600]!;
  Color get connectionErrorColor => isDarkMode ? Colors.red[400]! : Colors.red[600]!;
  Color get connectionPendingColor => isDarkMode ? Colors.orange[400]! : Colors.orange[600]!;
}

// 7. Updated Connection Status Widget (keeping your original)
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
          statusText = 'Connected to Liquid Galaxy';
        } else if (socketService.isConnecting) {
          statusColor = context.connectionPendingColor;
          statusIcon = Icons.wifi_find;
          statusText = 'Connecting...';
        } else {
          statusColor = context.connectionErrorColor;
          statusIcon = Icons.wifi_off;
          statusText = 'Not Connected';
        }

        return Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
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

// 8. Updated Theme Toggle Button
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

// 9. Updated Themed Card (keeping your original)
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
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// 10. Updated Theme Converters
class ThemeConverters {
  static Color getThemedColor(BuildContext context, String colorType) {
    switch (colorType) {
      case 'success':
        return context.connectionSuccessColor;
      case 'error':
        return context.connectionErrorColor;
      case 'warning':
        return context.connectionPendingColor;
      case 'primary':
        return context.colors.primary;
      case 'background':
        return context.colors.surface;
      case 'surface':
        return context.colors.surface;
      default:
        return context.colors.onSurface;
    }
  }
  
  static TextStyle getThemedTextStyle(BuildContext context, {
    FontWeight? fontWeight,
    double? fontSize,
    String colorType = 'onSurface',
  }) {
    return TextStyle(
      color: getThemedColor(context, colorType),
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }
}