import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/service/tts_service.dart';
import 'package:provider/provider.dart';

class TtsSettingsPopup extends StatelessWidget {
  const TtsSettingsPopup({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const TtsSettingsPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: TtsService(),
      child: Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voice Settings'.tr(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Consumer<TtsService>(
                  builder: (context, tts, child) {
                    if (!tts.isInitialized) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          buildQuickTest(tts),
                          const SizedBox(height: 16),
                          buildCompactControls(tts),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuickTest(TtsService tts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => tts.speak('Testing voice settings'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => tts.stop(),
              icon: const Icon(Icons.stop),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCompactControls(TtsService tts) {
    return Column(
      children: [
        buildCompactSlider(
          'Rate: ${tts.speechRate.toStringAsFixed(1)}',
          tts.speechRate,
          0.1,
          2.0,
          (value) => tts.updateSpeechRate(value),
        ),
        buildCompactSlider(
          'Volume: ${(tts.volume * 100).toInt()}%',
          tts.volume,
          0.0,
          1.0,
          (value) => tts.updateVolume(value),
        ),
        buildCompactSlider(
          'Pitch: ${tts.pitch.toStringAsFixed(1)}',
          tts.pitch,
          0.5,
          2.0,
          (value) => tts.updatePitch(value),
        ),
        buildVoiceDropdown(tts),
      ],
    );
  }

  Widget buildCompactSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVoiceDropdown(TtsService tts) {
    final voices = tts.getVoicesForLanguage(tts.selectedLanguage ?? 'en-US');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voice', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: tts.selectedVoice,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: voices.map<DropdownMenuItem<String>>((voice) {
                return DropdownMenuItem<String>(
                  value: voice['name'].toString(),
                  child: Text(
                    voice['name'].toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) => tts.updateVoice(value),
            ),
          ],
        ),
      ),
    );
  }
}