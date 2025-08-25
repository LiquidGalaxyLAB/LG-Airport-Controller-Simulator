import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/screens/popup.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:provider/provider.dart';

class CommandScreen extends StatefulWidget {
  const CommandScreen({super.key});

  @override
  State<CommandScreen> createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  int altitude = 4000;
  String heading = "230";
  String command = "";
  final SocketService socketService = SocketService();
  final ThemeProvider themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    command = socketService.commandText.value;

    socketService.commandText.addListener(() {
      final newCommand = socketService.commandText.value;
      print("Command changed to: $newCommand");
      setState(() {
        command = newCommand;
      });
    });

    socketService.addListener(_onSocketServiceChanged);
  }

  void _onSocketServiceChanged() {
    if (socketService.selectedPlane == null) {
      print("Selected plane was deleted, returning bacl");
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    socketService.commandText.removeListener(() {});
    socketService.removeListener(_onSocketServiceChanged);
    super.dispose();
  }

  void _incrementAltitude() {
    if (socketService.selectedPlane == null) {
      _handlePlaneDeleted();
      return;
    }
    setState(() {
      socketService.increaseAltitude();
    });
  }

  void _decrementAltitude() {
    if (socketService.selectedPlane == null) {
      _handlePlaneDeleted();
      return;
    }
    setState(() {
      socketService.decreaseAltitude();
    });
  }

  void _onDirectionalTap(String direction) {
    if (socketService.selectedPlane == null) {
      _handlePlaneDeleted();
      return;
    }

    if (direction == 'left') {
      socketService.turnLeft();
    }

    if (direction == 'right') {
      socketService.turnRight();
    }

    if (direction == 'up') {
      socketService.turnRight();
      socketService.turnRight();
    }

    if (direction == 'down') {
      socketService.turnLeft();
      socketService.turnLeft();
    }

    print("Direction tapped: $direction");
  }

  void _handlePlaneDeleted() {
    print("Selected plane no longer exists, closing CommandScreen");
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _onClose() {
    print(socketService.selectedPlane);
    if ((socketService.selectedPlane?['altitude'] == 0 &&
        socketService.selectedPlane?['isnew'])) {
      BottomPopup.showError(
        context: context,
        title: 'Error'.tr(),
        subtitle: 'The plane is on the runway. It must take off first.'.tr(),
      );
    } else {
      socketService.clearSelectedPlane();
      Navigator.pop(context);
    }
  }

  void _onConfirm() {
    if (socketService.selectedPlane == null) {
      _handlePlaneDeleted();
      return;
    }
    final success = socketService.submitCommand();
    if (success) {
      Navigator.pop(
        context,
        MaterialPageRoute(builder: (context) => const CommandScreen()),
      );
      print("Command confirmed: ${socketService.commandText}");
    } else {
      BottomPopup.showError(
        context: context,
        title: 'Error'.tr(),
        subtitle: 'Please increase altitude before takeoff upto 1000 ft'.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onClose();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.appbar,
          title: Text(
            'Controller Room'.tr(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: Text(
                  command,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.colors.onSurface,
                    height: 2,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 0,
                        child: GestureDetector(
                          onTap: () => _onDirectionalTap('up'),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.colors.onSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: context.colors.onInverseSurface,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => _onDirectionalTap('down'),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.colors.onSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: context.colors.onInverseSurface,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 0,
                        child: GestureDetector(
                          onTap: () => _onDirectionalTap('left'),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.colors.onSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              color: context.colors.onInverseSurface,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _onDirectionalTap('right'),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.colors.onSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_right,
                              color: context.colors.onInverseSurface,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2C2C3E),
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _decrementAltitude,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              bottomLeft: Radius.circular(25),
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: context.colors.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            vertical: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Altitude'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: context.colors.onSurface,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _incrementAltitude,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            color: context.colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _onClose,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            'Close'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _onConfirm,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A5568),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            'Confirm'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
