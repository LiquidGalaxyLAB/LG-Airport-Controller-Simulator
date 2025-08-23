import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstructionPage extends StatefulWidget {
  final bool isFirstTime;
  const InstructionPage({super.key, this.isFirstTime = false});

  @override
  State<InstructionPage> createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _dontShowAgain = false;

  final List<String> _instructions = [
    "Welcome to Airport Controller – your mission is to safely manage and direct all incoming and outgoing flights.",
    "Use the control panel to guide aircraft to their designated runways and exit points.",
    "Prevent collisions by maintaining safe distances between planes at all times.",
    "Avoid wrong exits – ensure planes are guided in the correct direction based on their destination.",
    "Runway deployment is final – once a plane is placed on a runway, it must take off. Make your decision carefully. All available airports will be displayed when selecting a takeoff destination.",
    "Altitude awareness – At 0 ft altitude, a plane cannot receive any command. At 4000 ft altitude, a plane is eligible to exit through an airport.",
    "Start procedure – you must first run the server before starting the game.",
    "Flight options – once the game begins, you can choose to take off planes and direct them to other airports. Make sure all screens are connected; otherwise, the airports will not be displayed."
  ];

   final List<Map<String, String>> _startingSteps = [
      {
        'title': '1. Connect to Liquid Galaxy',
        'description': 'Ensure all Liquid Galaxy rigs and display screens are connected and operational.',
        'icon': 'screen',
      },
      {
        'title': '2. Start the Server',
        'description': 'Launch the airport control server on your system before starting the game.',
        'icon': 'server',
      },
      {
        'title': '3. Start the Game',
        'description': 'Verify that all devices are connected to the same network before starting gameplay.',
        'icon': 'network',
      },
    ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveDontShowAgain() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dont_show_instructions', true);
    }
  }

  Future<void> _beginGame() async {
    await _saveDontShowAgain();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/active_approaches');
    }
  }

  IconData _getStepIcon(String iconType) {
    switch (iconType) {
      case 'server':
        return Icons.dns;
      case 'screen':
        return Icons.desktop_windows;
      case 'network':
        return Icons.wifi;
      default:
        return Icons.info;
    }
  }

  Widget _buildStartingSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Manual Setup Required",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Please complete these steps manually before starting the game:",
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          ..._startingSteps.map((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getStepIcon(step['icon']!),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['description']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Instructions",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: context.colors.onSurface,
          ),
        ),
        backgroundColor: context.appbar,
        iconTheme: IconThemeData(color: context.colors.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._instructions.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• ",
                      style: TextStyle(
                        fontSize: 16,
                        color: context.colors.onSurface,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Starting Steps Section
            const SizedBox(height: 32),
            Text(
              "Before You Start",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildStartingSteps(),

            if (widget.isFirstTime) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _dontShowAgain,
                    onChanged: (value) {
                      setState(() {
                        _dontShowAgain = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Don't show this again",
                      style: TextStyle(
                        fontSize: 16,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _beginGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Continue to Game",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}