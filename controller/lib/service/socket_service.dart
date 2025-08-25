import 'dart:async';

import 'package:lg_airport_simulator_apk/main.dart' show navigatorKey;
import 'package:lg_airport_simulator_apk/screens/active_approaches_screen.dart';
import 'package:lg_airport_simulator_apk/screens/command_screen.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:lg_airport_simulator_apk/screens/popup.dart';
import 'package:lg_airport_simulator_apk/service/tts_service.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SocketService extends ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket _socket;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  String _ip = '';
  bool _isConnected = false;
  bool _isConnecting = false;
  final List<String> _logs = [];

  List<dynamic> _airplanes = [];
  List<dynamic> _airplanesData = [];

  Map<String, dynamic>? _selectedPlane;
  int _degrees = 0;
  int _changeDegrees = 0;
  int _changeAltitude = 0;
  int? _previousAltitude;
  bool _pause = false;
  String _commandText = "";
  List<dynamic> _takeoffPlanes = [];
  bool _gameOverPopupShown = false;
  bool _isGameStarted = false;

  int _orbitCount = 0;
  int _originalHeading = 0;

  String get ip => _ip;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  List<String> get logs => _logs;
  List<dynamic> get airplanes => _airplanes;
  List<dynamic> get airplanesData => _airplanesData;
  Map<String, dynamic>? get selectedPlane => _selectedPlane;
  int get degrees => _degrees;
  int get changeAltitude => _changeAltitude;
  bool get ispause => _pause;
  bool get isGameStarted => _isGameStarted;
  int get orbitCount => _orbitCount;

  final ValueNotifier<String> commandText = ValueNotifier<String>("");

  void log(String message) {
    print(message);
    _logs.insert(0, message);
    notifyListeners();
  }

  Future<void> loadSavedIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString('ip') ?? '';
    notifyListeners();
  }

  Future<void> _saveIP(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', ip);
  }

  Future<void> auto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString('ip') ?? '';
    if (_ip != '') {
      connectToSocket(_ip);
    } else {
      _speak("no ip address found. please enter it");
    }
    notifyListeners();
  }

  Future<bool> connectToSocket(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log('🔌 Trying to connect to $ip');
    _saveIP(ip);
    _ip = ip;
    _isConnecting = true;
    notifyListeners();

    var serverport = prefs.getString('serverport') ?? '8111';

    Completer<bool> completer = Completer<bool>();

    _socket = IO.io('http://$ip:$serverport', {
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      log(' Connected to $ip');
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();

      if (!completer.isCompleted) {
        completer.complete(true);
      }

      _socket.emitWithAck(
        'get-airport-positions',
        {},
        ack: (data) {
          _airplanes = List.from(data);
          log(' Received airplanes via callback.');
          notifyListeners();
        },
      );
    });

    _socket.onConnectError((err) {
      log(' Connection error: $err');
      _isConnected = false;
      _isConnecting = false;
      notifyListeners();

      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    _socket.onDisconnect((reason) {
      log(' Disconnected from server do hear when disconnect ');
      if (reason == 'io server disconnect') {
        log('🚨 SERVER KICKED US OUT! This is the problem!');
        _isConnecting = false;
      } else if (reason == 'ping timeout') {
        log('📡 Connection lost due to ping timeout');
        _isConnecting = false;
      } else {
        _isConnecting = false;
      }
      _airplanes = [];
      _airplanesData = [];
      _selectedPlane = null;
      _isConnected = false;
      _socket.disconnect();
      notifyListeners();
    });

    _socket.on('fetch-airplanes', (data) {
      print('Received airplanes data: $data');
      if (data is List) {
        _takeoffPlanes = data;
        notifyListeners();
      }
    });

    _socket.on('aeroplane-data', (data) {
      log(' aeroplane-data received for $data');
      List<dynamic> flatPlanes = [];
      (data as Map<String, dynamic>).forEach((i, planes) {
        if (planes is List) {
          flatPlanes.addAll(planes);
        }
      });
      log(" Flattened planes: ${flatPlanes.map((p) => p['label']).toList()}");
      _airplanesData = flatPlanes;
      notifyListeners();
    });

    _socket.on('takeoff-planes', (data) {
      log('takeoff-planes received: $data');

      if (data is List) {
        List<dynamic> flatPlanes = data;

        log("Flattened planes: ${flatPlanes.map((p) => p['label']).toList()}");
        log("Detailed planes data: $flatPlanes");
        _airplanes = flatPlanes;

        notifyListeners();
      } else {
        log("Unexpected data format for takeoff-planes: $data");
      }
    });

    _socket.on('error-popup', (data) => _playErrorSound());
    _socket.on('Completed', (data) => _playSuccessSound());
    _socket.on(
      'all-airport-positions',
      (data) => log('All airport positions: $data'),
    );

    _socket.on('gameStopData', (data) {
      _airplanesData = [];
      _airplanes = [];
      _takeoffPlanes = [];
      _pause = false;
      _isGameStarted = false;
      _gameOverPopupShown = false;
      notifyListeners();
    });

    _socket.on('gameOverData', (data) {
      _airplanesData = [];
      _airplanes = [];
      _takeoffPlanes = [];
      _isGameStarted = false;

      if (!_gameOverPopupShown) {
        _gameOverPopupShown = true;
        BottomPopup.showGameOver(
          context: navigatorKey.currentContext!,
          conflicts: data['conflictCount'],
          wrongExits: data['wrongExitCount'],
          score: data['successCount'],
          badDepature: data['baddepartureCount'],
          title: 'Game Over',
          onRestart: () async {
            _instance.startGame();

            Future.delayed(Duration.zero, () {
              if (navigatorKey.currentContext != null) {
                Navigator.pushAndRemoveUntil(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) => const ActiveApproachesScreen(),
                  ),
                  (route) => false,
                );
              }
            });
          },
        );
      }
      notifyListeners();
    });

    _socket.on('gameStartData', (data) {
      _airplanesData = [];
      _airplanes = [];
      _takeoffPlanes = [];
      _isGameStarted = true;
      _gameOverPopupShown = false;

      notifyListeners();
    });

    _socket.on('gameResetData', (data) {
      _pause = false;
      _isGameStarted = true;
      _gameOverPopupShown = false;
      notifyListeners();
    });

    return completer.future;
  }

  void disconnectSocket() {
    if (_socket.connected) {
      _socket.disconnect();
      _isConnected = false;
      _selectedPlane = null;
      _logs.insert(0, '🔌 Disconnected manually');
      notifyListeners();
    }
  }

  Future<bool> sendGameOver({int timeoutMs = 1500}) async {
    try {
      if (!_isConnected) return false;
      final completer = Completer<bool>();
      bool completed = false;
      Timer(Duration(milliseconds: timeoutMs), () {
        if (!completed && !completer.isCompleted) {
          completed = true;
          completer.complete(false);
        }
      });
      _socket.emitWithAck(
        'game-over',
        {},
        ack: (data) {
          if (!completed && !completer.isCompleted) {
            completed = true;
            completer.complete(true);
          }
        },
      );
      return completer.future;
    } catch (_) {
      return false;
    }
  }

  Map<String, int> getGameStatistics() {
    return {'score': 0, 'conflicts': 0, 'wrongExits': 0, 'correctExits': 0};
  }

  bool addPlane(Map<String, dynamic> plane) {
    try {
      _socket.emit('add-plane-controller', {
        'screen': plane['screen'],
        'x': plane['x'],
        'y': plane['y'],
        'label': plane['label'],
        'destation': plane['destation'],
        'source': plane['source'],
      });
      log("add-plane emitted for ${plane['label']}");
      return true;
    } catch (e) {
      return false;
    }
  }

  void _playSuccessSound() async {
    await _player.play(AssetSource('audio/success.mp3'));
  }

  void _playErrorSound() async {
    await _player.play(AssetSource('audio/error.mp3'));
  }

  Future<bool> startGame() async {
    try {
      if (!_isConnected) return false;

      _airplanes = [];
      _airplanesData = [];
      _takeoffPlanes = [];
      _selectedPlane = null;
      _gameOverPopupShown = false;

      _socket.emit('gameStart');
      _socket.emit('fetch-airplanes-io');

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> pauseGame() async {
    try {
      if (!_isConnected) return false;

      _socket.emit('gamePause');
      _pause = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resumeGame() async {
    try {
      if (!_isConnected) return false;

      _socket.emit('gameResume');
      _pause = false;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stopGame() async {
    try {
      if (!_isConnected) return false;
      _socket.emit('gameStop');
      _pause = false;
      _isGameStarted = false;
      _gameOverPopupShown = false;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyServerConfiguration() async {
    try {
      if (!_isConnected) return false;

      var maxAttempts = true;

      while (_airplanes.length < 5) {
        await Future.delayed(const Duration(seconds: 3));

        _socket.emit('fetch-airplanes-io');
      }
      if (_airplanes.length >= 0 && _airplanes.length <= 5) {
        maxAttempts = false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void refreshTakeoffPlanes() {
    if (_isConnected) {
      log('Refreshing takeoff planes...');
      _socket.emit('fetch-airplanes-io');
    }
  }

  void selectPlane(Map<String, dynamic> plane) {
    _selectedPlane = plane;
    _changeAltitude = plane['altitude'] ?? 0;
    _degrees = plane['heading'] ?? 0;
    _changeDegrees = plane['heading'] ?? 0;

    _orbitCount = 0;
    _originalHeading = plane['heading'] ?? 0;

    _socket.emit('select-plane', {
      'dir': plane['label'],
      'altitude': plane['altitude'],
    });

    _updateCommandPreview();
    notifyListeners();
  }

  void clearSelectedPlane() {
    if (_selectedPlane != null) {
      _socket.emit('deselect-plane', {
        'label': _selectedPlane!['label'],
        "altitude": _selectedPlane!['altitude'],
      });

      _orbitCount = 0;
      _originalHeading = 0;

      notifyListeners();
    }
  }

  void turnLeft() {
    if (_selectedPlane == null) return;

    if (_orbitCount == 0) {
      _originalHeading = _selectedPlane!['heading'] ?? 0;
    }

    if (_orbitCount > 0) {
      _orbitCount--;
      _degrees += 45;
      _socket.emit('update-plane-left');
      _updateCommandPreview();
      notifyListeners();
    } else if (_orbitCount > -8) {
      _orbitCount--;
      _degrees -= 45;
      _socket.emit('update-plane-left');
      _updateCommandPreview();
      notifyListeners();
    }
  }

  void turnRight() {
    if (_selectedPlane == null) return;

    if (_orbitCount == 0) {
      _originalHeading = _selectedPlane!['heading'] ?? 0;
    }

    if (_orbitCount < 0) {
      _orbitCount++;
      _degrees -= 45;
      _socket.emit('update-plane-right');
      _updateCommandPreview();
      notifyListeners();
    } else if (_orbitCount < 8) {
      _orbitCount++;
      _degrees += 45;
      _socket.emit('update-plane-right');
      _updateCommandPreview();
      notifyListeners();
    }
  }

  void increaseAltitude() {
    if (_changeAltitude < 5000) {
      _changeAltitude += 1000;
      _updateCommandPreview();
      notifyListeners();
    }
  }

  void decreaseAltitude() {
    if (_changeAltitude > 0) {
      _changeAltitude -= 1000;
      _updateCommandPreview();
      notifyListeners();
    }
  }

  bool submitCommand() {
    if (_selectedPlane == null) return false;

    _previousAltitude = _selectedPlane!['altitude'];
    _selectedPlane!['altitude'] = _changeAltitude;
    _selectedPlane!['heading'] = _degrees;

    if (_selectedPlane!['isnew'] && _selectedPlane!['altitude'] == 0) {
      return false;
    }
    var ls = _selectedPlane!['altitude'];
    var cmd;
    if (_selectedPlane!['isnew'] && ls > 0) {
      _selectedPlane!['takeoff'] = true;
      _selectedPlane!['isnew'] = false;
      cmd = 'CLIMB AND MAINTAIN $ls FEET CLEARED TO TAKEOFF';
    }

    final command = _generateCommandSpeech(
      _selectedPlane!,
      _previousAltitude ?? 0,
      cmd,
    );
    _socket.emit('submit-plane', _selectedPlane);
    _socket.emit('send-command', command);
    _speak(command);
    commandText.value = command;
    notifyListeners();
    return true;
  }

  void _updateCommandPreview() {
    if (_selectedPlane == null) return;
    final simulatedData = Map<String, dynamic>.from(_selectedPlane!);
    simulatedData['altitude'] = _changeAltitude;
    final prevAlt = _selectedPlane!['altitude'];
    final command = _generateCommandSpeech(simulatedData, prevAlt);
    commandText.value = command;
    _socket.emit('send-command', command);
    notifyListeners();
  }

  String _generateCommandSpeech(
    Map<String, dynamic> data,
    int prevAltitude, [
    String? takeoffcmd,
  ]) {
    final callSign = data['label'];
    final altitude = data['altitude'];
    final heading = data['heading'];

    String command1 = "";

    int displayHeading = (_originalHeading + _degrees) % 360;
    if (displayHeading < 0) displayHeading += 360;

    if (_orbitCount >= 8) {
      command1 = "ORBIT";
    } else if (_orbitCount <= -8) {
      command1 = "ORBIT";
    } else if (_orbitCount > 0) {
      final formattedHeading = displayHeading.toString().padLeft(3, '0');
      command1 = "TURN RIGHT -> $formattedHeading";
    } else if (_orbitCount < 0) {
      final formattedHeading = displayHeading.toString().padLeft(3, '0');
      command1 = "TURN LEFT -> $formattedHeading";
    } else {
      command1 = "Head to $heading";
    }

    String command2 = "";
    if (prevAltitude != altitude && altitude != 0) {
      command2 =
          prevAltitude > altitude
              ? "DESCEND AND MAINTAIN $altitude FEET."
              : "CLIMB AND MAINTAIN $altitude FEET.";
    } else if (altitude != 0) {
      command2 = "AT $altitude FEET";
    }

    if (takeoffcmd != null || data['isnew'] == true) {
      command2 =
          takeoffcmd ?? "CLIMB AND MAINTAIN $altitude FEET CLEARED TO TAKEOFF";
      takeoffcmd = null;
    }

    return "$callSign $command1 $command2";
  }

  Future<void> _speak(String text) async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(0.5);
    await _tts.awaitSynthCompletion(true);

    await _tts.setLanguage("en-US");

    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak("Roger");
  }

  void setIP(String ip) {
    _ip = ip;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isConnected) {
      _socket.disconnect();
    }
    _selectedPlane = null;
    _tts.stop();
    _player.dispose();
    super.dispose();
  }
}
