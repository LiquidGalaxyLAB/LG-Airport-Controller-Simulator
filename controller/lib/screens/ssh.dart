
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/main.dart';
import 'package:lg_airport_simulator_apk/screens/popup.dart';
import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

class SSH extends ChangeNotifier  {
   final TextEditingController _ipController = TextEditingController();
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _portController = TextEditingController();
    final TextEditingController _rigsController = TextEditingController();
    final TextEditingController _serverportController = TextEditingController();
    String  _serverPath = "/home/lg/LG-Airport-Controller-Simulator";
    static const String _nodePath = '~/.nvm/versions/node/v4.2.6/bin';
    // static const String _nodePath = '/home/lg/.nvm/versions/node/v14.21.3/bin/node';
    bool isConnectedLg = false;
    bool get isConnectedLG => isConnectedLg;
    SSHClient? _client;


  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
     _ipController.text = prefs.getString('ip') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _portController.text = prefs.getString('port') ?? '';
      _rigsController.text = prefs.getString('screens') ?? '';
      _serverportController.text = prefs.getString('serverport') ?? '8111';
      _serverPath = prefs.getString('airport_simulator_path') ?? '/home/lg/LG-Airport-Controller-Simulator';
  }
  bool hasValidSettings() {
      return _ipController.text.isNotEmpty &&
            _usernameController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            _portController.text.isNotEmpty && 
            _rigsController.text.isNotEmpty && 
            _serverportController.text.isNotEmpty;
    }
  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    if(!hasValidSettings()) {
      BottomPopup.showInfo (context: navigatorKey.currentContext!, title: "LG is not connected. Kindly establish a connection first.");
      return false;
    }

    try {
      final socket = await SSHSocket.connect(_ipController.text, int.parse(_portController.text));

      _client = SSHClient(
        socket,
        username: _usernameController.text,
        onPasswordRequest: () => _passwordController.text,

      );

      isConnectedLg = true;
      print("lg connected");
      return true;

    } on SocketException catch (e) {
      print('Failed to connect: $e');
      isConnectedLg = false;
      return false;
    }
  }


Future<bool> disconnectFromLG() async {
    _client?.close();
    return true;
  }
  Future<SSHSession?> execute() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final demo_result = await _client!.execute(
          ' echo "search=India" >/tmp/query.txt');
      return demo_result;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }


  Future<void> relaunchLG() async {
    try {
      for (var i = 1; i <= int.parse(_rigsController.text); i++) {
        String cmd = """RELAUNCH_CMD="\\
        if [ -f /etc/init/lxdm.conf ]; then
          export SERVICE=lxdm
        elif [ -f /etc/init/lightdm.conf ]; then
          export SERVICE=lightdm
        else
          exit 1
        fi
        if [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
          echo ${_passwordController.text} | sudo -S service \\\${SERVICE} start
        else
          echo ${_passwordController.text} | sudo -S service \\\${SERVICE} restart
        fi
        " && sshpass -p ${_passwordController.text} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await _client?.run(
            '"/home/${_usernameController}/bin/lg-relaunch" > /home/${_usernameController}/log.txt');
        await _client?.run(cmd);
      }
    } catch (error) {
      print(error);
    }
  }


  Future cleanrig() async {
   String clean = '''<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
      </Document>
</kml>

  ''';

      try {
        if (_client == null) {
          print('SSH client is not initialized.');
          return null;}
        else{
        await _client?.execute("echo '$clean' > /var/www/html/kml/slave_3.kml");
        print('done');
      }} catch (e) {
        return Future.error(e);
      }
  }

  Future<void> rebootlg() async {
    try {
      for (var i = 1; i <= int.parse(_rigsController.text); i++) {
        await _client?.run(
            'sshpass -p ${_passwordController.text} ssh -t lg$i "echo ${_passwordController.text} | sudo -S reboot"');
      }
    } catch (error) {
      throw error;
    }
  }

  
  
  // Helper method to decode result
  String _decodeResult(dynamic result) {
    if (result == null) return 'No response';
    if (result is List<int>) {
      return String.fromCharCodes(result);
    }
    return result.toString();
  }

  Future<bool> startLGAirport() async {
    try {
      if(_serverPath == '') {
        return false;
      };           
      print('Starting LG Airport Controller...');
      await initConnectionDetails();

      if (_client == null) {
        final connected = await connectToLG();
        if (connected != true) {
          return false;
        }
      }

      final rig = _rigsController.text;
      final testResult = await _client!.run('echo "SSH test successful"');
        print('SSH test result: ${_decodeResult(testResult)}');

      // final startCmd = 'bash -lc "cd $_serverPath && nohup $_nodePath/node index.js $rig > server.log 2>&1 & echo \$! > server.pid; echo STARTED"';
      final startCmd = 'bash -lc "cd $_serverPath && nohup $_nodePath/node index.js $rig > server.log 2>&1 & echo STARTED"';
      _client!.run(startCmd).then((res) {
        try {
          print('Server start cmd: ${_decodeResult(res)}');
        } catch (_) {}
      }).catchError((e) {
        print('Server start error: $e');
      });

      return true;
    } catch (error) {
      print('Error starting LG Airport: $error');
      rethrow;
    }
  }

  Future<bool> waitForLGAirportReady({int timeoutSeconds = 40}) async {
    try {
      await initConnectionDetails();
      if (_client == null) {
        final connected = await connectToLG();
        if (connected != true) return false;
      }

      final String portStr = _serverportController.text.isEmpty ? '8111' : _serverportController.text;
      final int port = int.tryParse(portStr) ?? 8111;

      final String waitCmd = "bash -lc 'i=0; while ! (echo > /dev/tcp/localhost/$port) >/dev/null 2>&1; do sleep 1; i=\$((i+1)); if [ \$i -ge $timeoutSeconds ]; then echo TIMEOUT; exit 1; fi; done; echo READY'";
      final result = await _client!.run(waitCmd);
      final output = _decodeResult(result);
      print('Wait for server output: $output');
      return output.contains('READY');
    } catch (error) {
      print('Error waiting for LG Airport readiness: $error');
      return false;
    }
  }

  Future<void> stopLGAirport() async {
    try {
      await initConnectionDetails();
      final connected = await connectToLG();
      if (connected != true) {
        print('Unable to connect to LG for stopping server');
        return;
      }
      print('Stopping LG Airport Controller...');
      final String portStr = _serverportController.text.isEmpty ? '8111' : _serverportController.text;
      final int port = int.tryParse(portStr) ?? 8111;

      final stopCmd = "bash -lc '\nPORT=$port\nBASE=\"$_serverPath\"\n# Kill by recorded PID if exists\nif [ -f \"$_serverPath/server.pid\" ]; then PID=\$(cat \"$_serverPath/server.pid\"); kill -9 \"\$PID\" >/dev/null 2>&1 || true; rm -f \"$_serverPath/server.pid\" || true; fi\n# Kill by port if tools available\n(fuser -k -n tcp \$PORT) >/dev/null 2>&1 || true\n(lsof -ti:\$PORT | xargs -r kill -9) >/dev/null 2>&1 || true\n# Fallback: kill by command line match\npkill -9 -f \"[n]ode .*index.js\" >/dev/null 2>&1 || true\n# Verify port is closed (up to 10s)\ni=0; while (echo > /dev/tcp/localhost/\$PORT) >/dev/null 2>&1; do sleep 1; i=\$((i+1)); if [ \$i -ge 10 ]; then echo TIMEOUT; exit 1; fi; done; echo STOPPED'";

      final result = await _client!.run(stopCmd);
      print('Stop result: ${_decodeResult(result)}');
    } catch (error) {
      print('Error stopping LG Airport: $error');
      rethrow;
    }
  }

  Future<void> restartLGAirport() async {
    try {
      
      print('Restarting LG Airport Controller...');
      await stopLGAirport();
    Future.delayed(const Duration(seconds: 5));
    await startLGAirport();
      print('Restart result:');
      
    } catch (error) {
      print('Error restarting LG Airport: $error');
      rethrow;
    }
  }
 Future<bool> command_to_open_lg() async {
 
//  String password = _passwordController.text;
//   int rigCount = int.parse(_rigsController.text);

//   for (int i = 1; i <= rigCount; i++) {

//     String screenNumber = '$i';
//     String targetURL = 'http://192.168.123.171:3000/$screenNumber';
//     String cmd =
//         'export DISPLAY=:0; chromium-browser $targetURL --start-fullscreen --autoplay-policy=no-user-gesture-required </dev/null >/dev/null 2>&1 &';

//     print("Launching Chromium on lg$i...");
//     await _client!.run(cmd);
//     await Future.delayed(Duration(seconds: 1));
//   }
try {
  await initConnectionDetails();
    String password = _passwordController.text;
      int rigCount = int.parse(_rigsController.text);
      // Launch Chromium on all machines...
    for (int i = 1; i <= rigCount; i++) {
      String screenNumber = '$i';
      String targetURL = 'http://lg1:${_serverportController.text}/$screenNumber';
      String cmd = 'export DISPLAY=:0; chromium-browser $targetURL --start-fullscreen --autoplay-policy=no-user-gesture-required </dev/null >/dev/null 2>&1 &';
      
      print("Launching Chromium on lg$i...");
      
      await _client?.run(
          'sshpass -p $password ssh -t lg$i "$cmd"');
      
      await Future.delayed(Duration(seconds: 1));
    }
      return true;
  } catch (error) {
    print("Error launching Chromium: $error");
    return false;
  }
}


Future<void> command_to_chrome_kill() async {
     try {
    connectToLG();
    String password = _passwordController.text;
    int rigCount = int.parse(_rigsController.text);
   
    for (int i = 1; i <= rigCount; i++) {
      print("Killing Chromium on lg$i...");
      
      // More comprehensive kill commands
      List<String> killCommands = [
        'pkill -f chromium-browser || true',
        'pkill -f chrome || true', 
        'pkill -f Google.Chrome || true',
        'killall chromium-browser || true',
        'killall chrome || true',
        'pkill -9 -f chromium || true', 
        'pkill -9 -f chrome || true'    
      ];
      
      for (String killCmd in killCommands) {
        await _client?.run(
            'sshpass -p $password ssh lg$i "$killCmd"');
        await Future.delayed(Duration(milliseconds: 500));
      }
      
      await Future.delayed(Duration(seconds: 1));
    }

  } catch (error) {
    print("Error killing Chromium: $error");
    throw error;
  }
}

 Future  sendKml() async {
      String name = '''<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>task 2</name>
    <open>1</open>
    <description>dev t gadani </description>
    <Folder>

      <ScreenOverlay id="abc">
        <name>task 2 </name>
        <Icon><href>https://github.com/devtgadani/kml-dataimg/blob/2576fb88a541c2ea25fac7b25a07366cb9858faa/main_logo.png?raw=true</href></Icon>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0" y="0.98" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="500" y="300" xunits="pixels" yunits="pixels"/>
      </ScreenOverlay>
      </Folder>
  </Document>
</kml>
  ''';

      try {
        if (_client == null) {
          print('SSH client is not initialized.');
          return null;}
        else{
        await _client?.execute("echo '$name' > /var/www/html/kml/slave_3.kml");
        print('done');
      }} catch (e) {
        return Future.error(e);
      }
  }

 Future  sendBallon(String name, String millisecondsSinceEpoch ) async {
    String clean = '''<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
      </Document>
</kml>

  ''';
      try { 
        if (_client == null) {
          print('SSH client is not initialized.');
          return null;}
        else{
          await _client?.execute("echo '$clean' > /var/www/html/kml/slave_2.kml");
        await _client?.execute("echo '$name' > /var/www/html/kml/slave_2.kml");
        print('done');
      }} catch (e) {
        return Future.error(e);
      }
  }
}




