import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';

// Option 1: Dedicated Language Selection Page
class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({Key? key}) : super(key: key);
  ThemeProvider get themeProvider => ThemeProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
            title:  Text('Language'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: context.colors.onSurface,
              )),
            backgroundColor: context.appbar,
            iconTheme: IconThemeData(color: context.colors.onSurface),
          ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your preferred'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                 _buildLanguageOption(
                  context,
                  locale: const Locale('ar'),
                  title: 'العربية',
                  subtitle: 'Arabic',
                  flag: '🇸🇦',
                  isSelected: context.locale.languageCode == 'ar',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  locale: const Locale('de'),
                  title: 'Deutsch',
                  subtitle: 'German',
                  flag: '🇩🇪',
                  isSelected: context.locale.languageCode == 'de',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  locale: const Locale('en'),
                  title: 'English',
                  subtitle: 'English',
                  flag: '🇺🇸',
                  isSelected: context.locale.languageCode == 'en',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  locale: const Locale('es'),
                  title: 'Español',
                  subtitle: 'Spanish',
                  flag: '🇪🇸',
                  isSelected: context.locale.languageCode == 'es',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  locale: const Locale('fr'),
                  title: 'Français',
                  subtitle: 'French',
                  flag: '🇫🇷',
                  isSelected: context.locale.languageCode == 'fr',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  locale: const Locale('gu'),
                  title: 'ગુજરાતી',
                  subtitle: 'Gujarati',
                  flag: '🇮🇳',
                  isSelected: context.locale.languageCode == 'gu',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  locale: const Locale('hi'),
                  title: 'हिन्दी',
                  subtitle: 'Hindi',
                  flag: '🇮🇳',
                  isSelected: context.locale.languageCode == 'hi',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  locale: const Locale('ru'),
                  title: 'Русский',
                  subtitle: 'Russian',
                  flag: '🇷🇺',
                  isSelected: context.locale.languageCode == 'ru',
                ),

                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: context.colors.inverseSurface,
                  foregroundColor: Colors.white, // Text color
                  ),
                
                child: Text(
                  'Done'.tr(),
                  style:TextStyle(fontSize: 16, fontWeight: FontWeight.w600 , color: context.connectionSuccessColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required Locale locale,
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        await context.setLocale(locale);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? context.colors.onSurface.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? context.colors.onSurface
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color:context.colors.onSurface,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}