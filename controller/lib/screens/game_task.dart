import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/screens/active_approaches_screen.dart';
import 'package:lg_airport_simulator_apk/screens/ssh.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:lg_airport_simulator_apk/screens/popup.dart';
import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LG_AIRPORT_M extends StatefulWidget {
  const LG_AIRPORT_M({Key? key}) : super(key: key);
  
  static bool isServerReady = false;

  @override
  _LGdevi createState() => _LGdevi();
}

class _LGdevi extends State<LG_AIRPORT_M> {
  late SSH ssh;
  String storedPath = ""; 
  String nodeStoredPath = "";
  final TextEditingController _pathController = TextEditingController();
  final TextEditingController _nodePath = TextEditingController();
  final SocketService socketService = SocketService();
  var attempt = 0 ;
  var isStarted = false;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _loadStoredPath();
    socketService.addListener(_onSocketServiceChanged);
    // Sync local state with socket service state
    isStarted = socketService.isGameStarted;
  }

  void _onSocketServiceChanged() {
    setState(() {
      // Sync local state with socket service state
      isStarted = socketService.isGameStarted;
    });
  }

  Future<void> _loadStoredPath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      storedPath = prefs.getString('airport_simulator_path') ?? "/home/lg/LG-Airport-Controller-Simulator";
      _pathController.text = storedPath;
      nodeStoredPath = prefs.getString('node_path') ?? "~/.nvm/versions/node/v4.2.6/bin";
      _nodePath.text = nodeStoredPath ;
    });
  }

  Future<void> _saveStoredPath(String path, String node) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('airport_simulator_path', path);
    await prefs.setString('node_path', node);
  }

  @override
  void dispose() {
    _pathController.dispose();
    socketService.removeListener(_onSocketServiceChanged);
    super.dispose();
  }

  void _showPathDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Configure Path'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the airport simulator path:'.tr(),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _pathController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Path'.tr(),
                  hintText: '/home/lg/airport_simulator',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nodePath,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Node Path'.tr(),
                  hintText: '~/.nvm/versions/node/v4.2.6/bin',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  storedPath = _pathController.text;
                });
                await _saveStoredPath(storedPath, _nodePath.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Path updated successfully'.tr())),
                );
              },
              child: Text('Save'.tr()),
            ),
          ],
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(
        'Game Control'.tr(),
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
          icon: Icon(Icons.settings),
          onPressed: _showPathDialog,
          tooltip: 'Configure Path'.tr(),
        ),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Icon(
                      socketService.isConnected ? Icons.wifi : Icons.wifi_off,
                      color: socketService.isConnected ? Colors.green : Colors.red,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      socketService.isConnected ? 'Connected'.tr() : 'Disconnected'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      child: Text(
                        'Path: ${storedPath.split('/').last}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Game Section
            _buildSectionHeader('Game'.tr(), Icons.videogame_asset, Colors.green),
            SizedBox(height: 8),
            
            _buildControlCard(
              icon: socketService.isGameStarted ? Icons.stop : Icons.play_arrow,
              title: socketService.isGameStarted ? 'Stop Game'.tr() : 'Start Game'.tr(),
              color: socketService.isGameStarted ? Colors.red : Colors.green,
              onTap: () async {
                if (socketService.isGameStarted) {
                  // Stop game
                  BottomPopup.showInfo(
                    context: context,
                    title: "Do want to stop game?".tr(),
                    options: ["ok".tr()],
                    onOptionSelected: (selectedOption) async {
                      BottomPopup.showSimpleCountdown(
                        context: context,
                        title: 'Stopping Game...'.tr(),
                        onCountdownComplete: () async {
                          print('stopping game... 3');
                          await socketService.stopGame();
                          BottomPopup.showSuccess(
                            context: context, 
                            title: 'Stopped the game successfully'.tr(), 
                          );

                          print('Game stop');
                        },
                      );
                    },
                  );
                } else {
                  // Start game
                  BottomPopup.showSimpleCountdown(
                    context: context,
                    title: 'Starting Game...'.tr(),
                    onCountdownComplete: () async {
                      print('Starting game... 3');
                      await socketService.startGame();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ActiveApproachesScreen()));
                      BottomPopup.showSuccess(
                        context: context, 
                        title: 'Connected to game successfully'.tr(), 
                      );

                      print('Game started');
                    },
                  );
                }
              }
            ),

            SizedBox(height: 12),
            
            _buildControlCard(
              icon: socketService.ispause ? Icons.play_arrow : Icons.pause,
              title: socketService.ispause ? 'Resume Game'.tr() : 'Pause Game'.tr(),
              color: Colors.orange,
              onTap: () async {
                  if(!socketService.isGameStarted){
                    BottomPopup.showError(context: context, title: "Error".tr(), subtitle:  "Pause will be available once the game begins.".tr());
                  return;
                    }
                if (socketService.ispause) {
                  await socketService.resumeGame();
                  BottomPopup.showSuccess(
                    context: context, 
                    title: 'Successfully Resumed'.tr(),
                    subtitle: 'Game has been resumed successfully'.tr()
                  );
                } else {
                  await socketService.pauseGame();
                  BottomPopup.showSuccess(
                    context: context, 
                    title: 'Successfully Paused'.tr(),
                    subtitle: 'Game has been paused successfully'.tr()
                  );
                }
              },
            ),

            SizedBox(height: 12),
            _buildControlCard(
              icon: Icons.restart_alt,
              title: 'Restart Game'.tr(),
              color: Colors.orange,
              onTap: () async {
                  BottomPopup.showInfo(
                    context: context,
                    title: "Do want to restart server?".tr(),
                    subtitle: "This will restart the LG Airport server".tr(),
                    options: ["ok".tr()],
                    onOptionSelected: (selectedOption) async {
                    await socketService.stopGame();
                    BottomPopup.showSimpleCountdown(
                      context: context,
                      title: 'Restarting Game'.tr(),
                      onCountdownComplete: () async {
                        print('restarting game... 3');
                        await socketService.startGame();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ActiveApproachesScreen()));
                        BottomPopup.showSuccess(
                          context: context, 
                          title: 'Restarted game successfully'.tr(), 
                        );

                        print('Game started');
                      },
                  );
                   
                  },
                );
              },
            ),



            SizedBox(height: 32),

            // // Server Section
            _buildSectionHeader('Server'.tr(), Icons.dns, Colors.blue),
            SizedBox(height: 8),
            
            _buildControlCard(
              icon: Icons.cloud_queue,
              title: 'Start Server'.tr(),
              color: Colors.blue,
              onTap: () async {
                print('Starting server...');
                
                // Show countdown popup
                BottomPopup.showCountdown(
                  context: context,
                  title: 'Starting Server'.tr(),
                  ssh: ssh,
                  socketService: socketService,
                  onCountdownComplete: () async {
                    LG_AIRPORT_M.isServerReady = true;
                    // All operations completed during countdown, now navigate
                    BottomPopup.showSuccess(
                      context: context, 
                      title: 'Successfully'.tr(), 
                      subtitle: 'Successfully Launched and connected to the server'.tr()
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => ActiveApproachesScreen()),
                      (route) => false,
                    );
                  },
                );
              },
            ),

            SizedBox(height: 12),

            _buildControlCard(
              icon: Icons.stop_circle,
              title: 'Stop Server'.tr(),
              color: Colors.red[300]!,
              onTap: () async {
                BottomPopup.showInfo(
                  context: context,
                  title: "Do want to stop server?".tr(),
                  subtitle: "This will stop the LG Airport server".tr(),
                  options: ["ok".tr()],
                  onOptionSelected: (selectedOption) async {
                    socketService.stopGame();
                    await ssh.stopLGAirport();
                    await ssh.command_to_chrome_kill();
                    socketService.disconnectSocket();
                    LG_AIRPORT_M.isServerReady = false;
                    BottomPopup.showSuccess(
                      context: context, 
                      title: 'Successfully Stopped'.tr(),
                      subtitle: 'Server has been stopped successfully'.tr()
                    );
                  },
                );
              },
            ),

            SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSectionHeader(String title, IconData icon, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3), width: 1),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}
  Widget _buildControlCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      // Text(
                      //   // subtitle,
                      //   style: TextStyle(
                      //     fontSize: 11,
                      //     color: Colors.grey[600],
                      //   ),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}