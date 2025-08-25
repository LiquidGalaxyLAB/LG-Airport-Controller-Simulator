import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lg_airport_simulator_apk/service/tts_service.dart';
import 'package:provider/provider.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';

class TtsSettingsPage extends StatefulWidget {
  const TtsSettingsPage({Key? key}) : super(key: key);

  @override
  State<TtsSettingsPage> createState() => TtsSettingsPageState();
}

class TtsSettingsPageState extends State<TtsSettingsPage> {
  late TtsService ttsService;

  @override
  void initState() {
    super.initState();
    ttsService = TtsService();
    initializeTts();
  }

  Future<void> initializeTts() async {
    await ttsService.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ttsService,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Voice Settings'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: context.colors.onSurface,
            ),
          ),
          backgroundColor: context.appbar,
          iconTheme: IconThemeData(color: context.colors.onSurface),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => showResetDialog(),
            ),
          ],
        ),
        body: Consumer<TtsService>(
          builder: (context, tts, child) {
            if (!tts.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTestSection(tts),
                  const SizedBox(height: 24),
                  buildLanguageSection(tts),
                  const SizedBox(height: 24),
                  buildVoiceSection(tts),
                  const SizedBox(height: 24),
                  buildSpeechRateSection(tts),
                  const SizedBox(height: 24),
                  buildVolumeSection(tts),
                  const SizedBox(height: 24),
                  buildPitchSection(tts),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildTestSection(TtsService tts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Voice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => tts.speak('Hello, this is a test message'),
                    icon: const Icon(Icons.play_arrow),
                    label: Text('Test Voice'.tr()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => tts.stop(),
                  icon: const Icon(Icons.stop),
                  label: Text('Stop'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLanguageSection(TtsService tts) {
    final languageStrings =
        tts.availableLanguages.map((lang) => lang.toString()).toList();

    String? validSelectedLanguage = tts.selectedLanguage;
    if (validSelectedLanguage != null &&
        !languageStrings.contains(validSelectedLanguage)) {
      validSelectedLanguage =
          languageStrings.isNotEmpty ? languageStrings.first : null;

      if (validSelectedLanguage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          tts.updateLanguage(validSelectedLanguage);
        });
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: validSelectedLanguage,
              decoration: InputDecoration(
                labelText: 'Select Language'.tr(),
                border: const OutlineInputBorder(),
              ),
              items:
                  languageStrings.map<DropdownMenuItem<String>>((langString) {
                    return DropdownMenuItem<String>(
                      value: langString,
                      child: Text(langString),
                    );
                  }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  tts.updateLanguage(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVoiceSection(TtsService tts) {
    final voicesForLanguage = tts.getVoicesForLanguage(
      tts.selectedLanguage ?? 'en-US',
    );

    String? validSelectedVoice = tts.selectedVoice;
    final availableVoiceNames =
        voicesForLanguage.map((voice) => voice['name'].toString()).toList();

    if (validSelectedVoice != null &&
        !availableVoiceNames.contains(validSelectedVoice)) {
      validSelectedVoice =
          availableVoiceNames.isNotEmpty ? availableVoiceNames.first : null;

      if (validSelectedVoice != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          tts.updateVoice(validSelectedVoice);
        });
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: validSelectedVoice,
              decoration: InputDecoration(
                labelText: 'Select Voice'.tr(),
                border: const OutlineInputBorder(),
              ),
              items:
                  voicesForLanguage.map<DropdownMenuItem<String>>((voice) {
                    return DropdownMenuItem<String>(
                      value: voice['name'].toString(),
                      child: Text('${voice['name']} (${voice['locale']})'),
                    );
                  }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  tts.updateVoice(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSpeechRateSection(TtsService tts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speech Rate: ${tts.speechRate.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Slider(
              value: tts.speechRate,
              min: 0.1,
              max: 2.0,
              divisions: 19,
              label: tts.speechRate.toStringAsFixed(2),
              onChanged: (value) => tts.updateSpeechRate(value),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Slow (0.1)'),
                Text('Normal (0.5)'),
                Text('Fast (2.0)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVolumeSection(TtsService tts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volume: ${(tts.volume * 100).toInt()}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Slider(
              value: tts.volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(tts.volume * 100).toInt()}%',
              onChanged: (value) => tts.updateVolume(value),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('0%'), Text('50%'), Text('100%')],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPitchSection(TtsService tts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pitch: ${tts.pitch.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Slider(
              value: tts.pitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: tts.pitch.toStringAsFixed(2),
              onChanged: (value) => tts.updatePitch(value),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low (0.5)'),
                Text('Normal (1.0)'),
                Text('High (2.0)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Settings'.tr()),
          content: Text(
            'Are you sure you want to reset all voice settings to default?'
                .tr(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                ttsService.resetToDefaults();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings reset to default'.tr())),
                );
              },
              child: Text('Reset'.tr()),
            ),
          ],
        );
      },
    );
  }
}
