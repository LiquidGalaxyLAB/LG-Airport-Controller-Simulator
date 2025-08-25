import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/main.dart';
import 'package:lg_airport_simulator_apk/screens/command_screen.dart';
import 'package:lg_airport_simulator_apk/screens/game_task.dart';
import 'package:lg_airport_simulator_apk/screens/instructionpage.dart';
import 'package:lg_airport_simulator_apk/screens/popup.dart';
import 'package:lg_airport_simulator_apk/screens/settings_page.dart';
import 'package:lg_airport_simulator_apk/service/languageChange.dart';
import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';

class ActiveApproachesScreen extends StatefulWidget {
  const ActiveApproachesScreen({super.key});

  @override
  State<ActiveApproachesScreen> createState() => _ActiveApproachesScreenState();
}

class _ActiveApproachesScreenState extends State<ActiveApproachesScreen>
    with SingleTickerProviderStateMixin {
  final SocketService _socketService = SocketService();
  final LG_AIRPORT_M _game = LG_AIRPORT_M();
  late TabController _tabController;
  bool _hasVisitedTakeoffTab = false;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _socketService.loadSavedIP();
    _socketService.addListener(_onSocketServiceChanged);
    
   
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_hasVisitedTakeoffTab) {
        _hasVisitedTakeoffTab = true;
        _socketService.refreshTakeoffPlanes();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _socketService.removeListener(_onSocketServiceChanged);
    super.dispose();
  }

  void _onSocketServiceChanged() {
    setState(() {});
    
   
    if (!_socketService.isGameStarted) {
      _hasVisitedTakeoffTab = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.appbar,
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _socketService.isConnected
                    ? context.connectionSuccessColor
                    : context.connectionErrorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
             'Airport Control'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
        actions: [
           IconButton(
            icon: Icon(
              _socketService.ispause ? Icons.play_arrow : Icons.pause,
              color: context.colors.onSurface,
              size: 24,
            ),
            onPressed: () {
               if(!_socketService.isGameStarted){
                BottomPopup.showError(context: context, title: "Error".tr(), subtitle:  "Pause will be available once the game begins.".tr());
              return;
              }
             if (_socketService.ispause) {
                _socketService.resumeGame();
              } else {
                _socketService.pauseGame();
              }
            }
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: context.colors.onSurface,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.colors.primary,
          indicatorWeight: 3,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.onSurface.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flight_land, size: 18),
                  const SizedBox(width: 6),
                  Text('Approaching'.tr() , style: TextStyle(color: context.colors.onSurface)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_socketService.airplanesData.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flight_takeoff, size: 18),
                  const SizedBox(width: 6),
                  Text('Takeoff'.tr(), style: TextStyle(color: context.colors.onSurface)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_getTakeoffPlanes().length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildApproachingTab(),
                _buildTakeoffTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApproachingTab() {
    return Column(
      children: [
        Expanded(
          child: _buildApproachesList(_socketService.airplanesData , _socketService.isConnected),
        ),
      ],
    );
  }

  Widget _buildTakeoffTab() {
    List<Map<String, dynamic>> takeoffPlanes = _getTakeoffPlanes();
    print('Takeoff tab - planes count: ${takeoffPlanes.length}');
    print('Takeoff planes: $takeoffPlanes');
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.green.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.flight_takeoff, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
               'Ready for Takeoff'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.green[700], size: 20),
                onPressed: () {
                  BottomPopup.showInfo(context: context, title: "Refresh".tr(), subtitle: "This action will refresh the takeoff planes list fully ".tr(),  options: ["ok".tr()],
                    onOptionSelected: (selectedOption) async {
                      if (selectedOption == "ok") {
                        _socketService.refreshTakeoffPlanes();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Refreshing takeoff planes...'.tr()),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } );
                },
                tooltip: 'Refresh'.tr(),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildTakeoffList(takeoffPlanes),
        ),
      ],
    );
  }


   Widget _buildTakeoffList(List<Map<String, dynamic>> takeoffPlanes) {
    if (takeoffPlanes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flight_takeoff,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
               'No planes ready for takeoff'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
               'Planes will appear here when ready for departure'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
               Text(
               'If no planes appear, tap the refresh button in the top-right corner.'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: takeoffPlanes.length,
      itemBuilder: (context, index) {
        final plane = takeoffPlanes[index];
        return _buildTakeoffCard(plane, index);
      },
    );
  }

  Widget _buildTakeoffCard(Map<String, dynamic> plane, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.green.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            _handleGeneralAction(plane);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flight_takeoff,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plane['deslabel'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.colors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:  Text(
                             'READY'.tr(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.flight_takeoff,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                           'Ready for Takeoff'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                           'From: ${plane['source']['label'] ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

List<Map<String, dynamic>> _getTakeoffPlanes() {
  print('Getting takeoff planes. Total airplanes: ${_socketService.airplanes.length}');
  
  return _socketService.airplanes.map<Map<String, dynamic>>((plane) {
    print('Processing plane: $plane');
    
   
    String label = 'Unknown';
    String deslabel = 'Unknown';
    
    if (plane is Map<String, dynamic>) {
     
      if (plane['source'] != null && plane['source'] is Map) {
        label = plane['source']['label']?.toString() ?? 'Unknown';
      } else if (plane['label'] != null) {
        label = plane['label'].toString();
      }
      
      if (plane['destination'] != null && plane['destination'] is Map) {
        deslabel = plane['destination']['label']?.toString() ?? 'Unknown';
      } else if (plane['destation'] != null && plane['destation'] is Map) {
        deslabel = plane['destation']['label']?.toString() ?? 'Unknown';
      }
    }
    
    return {
      'label': label,
      'deslabel': deslabel,
      'altitude': '0',
      'destation': plane['destination'] ?? plane['destation'] ?? '',
      'source': plane['source'] ?? plane,
      'x': plane['x'],
      'y': plane['y'],
    };
  }).toList();
}
  Widget _buildApproachesList(List<dynamic> approaches, bool isConnected) {
    if (approaches.isEmpty ) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flight,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
               'No planes found. '.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
            if (!isConnected) ...[
              Text(
                'Connect to the game to see active approaches'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _handleConnectGame,
                icon: const Icon(Icons.play_arrow),
                label: Text('Connect & Start Game'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ] else if (isConnected && !_socketService.isGameStarted) ...[
              Text(
                'Connected! Ready to start the game.'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _handleStartGame,
                icon: const Icon(Icons.play_arrow),
                label: Text('Start Game'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ] else if (isConnected && _socketService.isGameStarted) ...[
              Text(
                'Game is running. Waiting for planes to approach...'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Planes will appear here when they start approaching the airport.'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
            
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: approaches.length,
      itemBuilder: (context, index) {
        final approach = approaches[index] as Map<String, dynamic>;
        return _buildApproachCard(approach, index);
      },
    );
  }

  Widget _buildApproachCard(Map<String, dynamic> approach, int index) {
    int altitude = int.tryParse(approach['altitude'].toString()) ?? 0;
    bool isLowAltitude = altitude < 5000;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isLowAltitude ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            _socketService.selectPlane(approach);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommandScreen()),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${'Selected approaching plane'.tr()} ${approach['label']}'),
                duration: const Duration(seconds: 1),
                backgroundColor: Colors.blue,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLowAltitude 
                        ? Colors.orange.withOpacity(0.2) 
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flight_land,
                    color: isLowAltitude ? Colors.orange : Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            approach['label'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.colors.onSurface,
                            ),
                          ),
                          if (isLowAltitude) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.height,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${'Altitude'.tr()}: ${approach['altitude']} ft',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
void _handleStartGame() {
  if (!LG_AIRPORT_M.isServerReady) {
    BottomPopup.showInfo(
      context: context, 
      title: "Start server".tr(), 
      subtitle: "Please start the server first".tr()
    );
    return;
  }
  
  BottomPopup.showSimpleCountdown(
    context: context,
    title: 'Starting Game...'.tr(),
    onCountdownComplete: () async {
      print('Starting game...');
      await _socketService.startGame();
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const ActiveApproachesScreen())
      );
      BottomPopup.showSuccess(
        context: context, 
        title: 'Game started successfully'.tr(), 
      );
      print('Game started');
    },
  );
}

// Keep the existing _handleConnectGame method for connecting and starting
void _handleConnectGame() {
  if (!LG_AIRPORT_M.isServerReady) {
    BottomPopup.showInfo(
      context: context, 
      title: "Start server".tr(), 
      subtitle: "Please start the server first".tr()
    );
    return;
  }
  
  BottomPopup.showSimpleCountdown(
    context: context,
    title: 'Connecting & Starting Game...'.tr(),
    onCountdownComplete: () async {
      print('Connecting and starting game...');
      
     
      if (!_socketService.isConnected) {
         await _socketService.auto();
      }
      
     
      await _socketService.startGame();
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const ActiveApproachesScreen())
      );
      BottomPopup.showSuccess(
        context: context, 
        title: 'Connected and game started successfully'.tr(), 
      );
      print('Connected and game started');
    },
  );
}

  void _handleGeneralAction(plane) async {

    if(!_socketService.isGameStarted || _socketService.ispause){
      BottomPopup.showError(context: context, title: "Error".tr(), subtitle: _socketService.isGameStarted ? "Please resume the game to deploy the plane".tr() : "Please start the game to deploy the plane ".tr());
    return;
    }

    if (plane != null) {
     final success = _socketService.addPlane({
        'screen': "1",
        'x': plane['x'],
        'y': plane['y'],
        'label': plane['label'],
        'destation' : plane['destation'],
        'source' : plane['source']
      });
     if (success) {
       await Future.delayed(Duration(seconds: 1));
      
     
      final matchingPlane = findPlaneByLabelMatch(plane, _socketService.airplanesData);
      
      if (matchingPlane != null) {
        print('Found matching plane: $matchingPlane');
        _socketService.selectPlane(matchingPlane);
        _socketService.airplanes.removeWhere((item) => item['destination']?['label'] == plane['deslabel']);
       
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CommandScreen()),
        );
       
      } else {
        print('No matching plane found');
        return null;
      }
    
     }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully deployed plane'.tr()),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ALT airplane not found'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
Map<String, dynamic>? findPlaneByLabelMatch( searchLabel, List<dynamic> airplanesData) {
 
  final searchFirst = searchLabel['source']['label'][0].toUpperCase();  
  final searchSecond = searchLabel['destation']['label'][0].toUpperCase(); 
 
  try {
    final matchingPlane = airplanesData.firstWhere((planeData) {
      final plane = planeData as Map<String, dynamic>;
      final sourceLabel = plane['source']?['label']?.toString();
      final destLabel = plane['destation']?['label']?.toString();
     
      if (sourceLabel == null || sourceLabel.isEmpty || 
          destLabel == null || destLabel.isEmpty) return false;
     
      final sourceFirst = sourceLabel[0].toUpperCase();
      final destFirst = destLabel[0].toUpperCase();
     
      return searchFirst == sourceFirst && searchSecond == destFirst;
    }) as Map<String, dynamic>;
   
    return matchingPlane;
  } catch (e) {
    return null;
  }
}

bool removeAirplaneByDestLabel(List<dynamic> airplanes, String destLabel) {
  final indexToRemove = airplanes.indexWhere((plane) {
    final planeMap = plane as Map<String, dynamic>;
    final planeDestLabel = planeMap['destation']?['label']?.toString();
    return planeDestLabel == destLabel;
  });
  
  if (indexToRemove != -1) {
    airplanes.removeAt(indexToRemove);
    return true;
  }
  return false;
}