import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showPopup = false;

  void _showConflictPopup() {
    setState(() {
      _showPopup = true;
    });
  }

  void _hidePopup() {
    setState(() {
      _showPopup = false;
    });
  }

  void _onOptionSelected(String option) {
    print("Selected option: $option");
    _hidePopup();
    // Handle the selected option here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Main Settings Content
          Column(
            children: [
              // Status bar space
              const SizedBox(height: 50),
              
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Divider
              Container(
                height: 1,
                color: Colors.grey[300],
              ),
              
              // Settings Items
              Expanded(
                child: Column(
                  children: [
                    _buildSettingsItem(
                      title: "mmmmmm",
                      onTap: () {
                        // Handle first item
                      },
                    ),
                    _buildSettingsItem(
                      title: "Language",
                      onTap: () {
                        // Handle language
                      },
                    ),
                    _buildSettingsItem(
                      title: "About",
                      onTap: () {
                        // Handle about
                      },
                    ),
                    _buildSettingsItem(
                      title: "Scan QR Code",
                      onTap: () {
                        // Show conflict popup when QR code is tapped
                        _showConflictPopup();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Popup Overlay
          if (_showPopup)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: _hidePopup,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Title
                      const Text(
                        'Conflit',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      const Text(
                        'Tap any one Below to resolve',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Options Row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onOptionSelected("AADC"),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: Text(
                                    'AADC',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onOptionSelected("BBAC"),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: Text(
                                    'BBAC',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required VoidCallback onTap,
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }
}

// Reusable Popup Overlay Widget
class PopupOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Color titleColor;
  final Function(String) onOptionSelected;
  final VoidCallback onClose;

  const PopupOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    this.titleColor = Colors.red,
    required this.onOptionSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Options
              Row(
                children: options.asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: index > 0 ? 16 : 0),
                      child: GestureDetector(
                        onTap: () => onOptionSelected(option),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage in other screens
class AnyScreen extends StatefulWidget {
  const AnyScreen({super.key});

  @override
  State<AnyScreen> createState() => _AnyScreenState();
}

class _AnyScreenState extends State<AnyScreen> {
  bool _showPopup = false;

  void showConflictPopup() {
    setState(() {
      _showPopup = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your main screen content
          Center(
            child: ElevatedButton(
              onPressed: showConflictPopup,
              child: const Text('Show Conflict Popup'),
            ),
          ),
          
          // Popup overlay
          if (_showPopup)
            PopupOverlay(
              title: "Conflit",
              subtitle: "Tap any one Below to resolve",
              options: ["AADC", "BBAC"],
              titleColor: Colors.red,
              onOptionSelected: (option) {
                print("Selected: $option");
                setState(() {
                  _showPopup = false;
                });
              },
              onClose: () {
                setState(() {
                  _showPopup = false;
                });
              },
            ),
        ],
      ),
    );
  }
}