import 'package:flutter/material.dart';
import 'package:lg_airport_simulator_apk/screens/multipleColortheme.dart';
import 'dart:ui';

import 'package:lg_airport_simulator_apk/service/socket_service.dart';
import 'package:lg_airport_simulator_apk/screens/ssh.dart';
import 'package:easy_localization/easy_localization.dart';

enum PopupType {
  error,
  success,
  info,
  warning,
}

class PopupData {
  final PopupType type;
  final String title;
  final String? subtitle;
  final List<String>? options;
  final VoidCallback? onClose;
  final Function(String)? onOptionSelected;
  final bool showCloseButton;
  final Widget? customIcon;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool enableGlassEffect;

  PopupData({
    required this.type,
    required this.title,
    this.subtitle,
    this.options,
    this.onClose,
    this.onOptionSelected,
    this.showCloseButton = true,
    this.customIcon,
    this.backgroundColor,
    this.titleColor,
    this.enableGlassEffect = false,
  });
}

class BottomPopup extends StatelessWidget {
  final PopupData data;
  final SocketService _socketService = SocketService();

  BottomPopup({
    super.key,
    required this.data,
  });

  static void show({
    required BuildContext context,
    required PopupData data,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.3),
      pageBuilder: (context, animation, secondaryAnimation) => BottomPopup(data: data),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child ?? BottomPopup(data: data),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    String? subtitle,
    List<String>? options,
    Function(String)? onOptionSelected,
    VoidCallback? onClose,
    bool enableGlassEffect = false,
  }) {
    show(
      context: context,
      data: PopupData(
        type: PopupType.error,
        title: title,
        subtitle: subtitle,
        options: options,
        onOptionSelected: onOptionSelected,
        onClose: onClose,
        enableGlassEffect: enableGlassEffect,
      ),
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String title,
    String? subtitle,
    VoidCallback? onClose,
    bool enableGlassEffect = false,
  }) {
    show(
      context: context,
      data: PopupData(
        type: PopupType.success,
        title: title,
        subtitle: subtitle,
        onClose: onClose,
        enableGlassEffect: enableGlassEffect,
      ),
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    String? subtitle,
    List<String>? options,
    Function(String)? onOptionSelected,
    VoidCallback? onClose,
    bool enableGlassEffect = false,
  }) {
    show(
      context: context,
      data: PopupData(
        type: PopupType.info,
        title: title,
        subtitle: subtitle,
        options: options,
        onOptionSelected: onOptionSelected,
        onClose: onClose,
        enableGlassEffect: enableGlassEffect,
      ),
    );
  }

  static void showCountdown({
    required BuildContext context,
    required String title,
    required Function() onCountdownComplete,
    required SSH ssh,
    required SocketService socketService,
    bool enableGlassEffect = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.3),
      pageBuilder: (context, animation, secondaryAnimation) => CountdownPopup(
        title: title,
        onCountdownComplete: onCountdownComplete,
        ssh: ssh,
        socketService: socketService,
        enableGlassEffect: enableGlassEffect,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

    static void showSimpleCountdown({
    required BuildContext context,
    required String title,
    required Function() onCountdownComplete,
    bool enableGlassEffect = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.3),
      pageBuilder: (context, animation, secondaryAnimation) => SimpleCountdownPopup(
        title: title,
        onCountdownComplete: onCountdownComplete,
        enableGlassEffect: enableGlassEffect,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static void showInstruction({
    required BuildContext context,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.3),
      pageBuilder: (context, animation, secondaryAnimation) => Instruction(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
  static void showGameOver({
    required BuildContext context,
    required String title,
    required int score,
    required int conflicts,
    required int wrongExits,
    required int badDepature,
    Function()? onRestart,
    bool enableGlassEffect = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.3),
      pageBuilder: (context, animation, secondaryAnimation) => GameOverPopup(
        title: title,
        score: score,
        conflicts: conflicts,
        wrongExits: wrongExits,
        BadDepature: badDepature,
        onRestart: onRestart,
        enableGlassEffect: enableGlassEffect,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  Widget getTypeIcon() {
    if (data.customIcon != null) {
      return data.customIcon!;
    }

    Color iconColor;
    IconData iconData;
    Color containerColor;

    switch (data.type) {
      case PopupType.error:
        iconColor = Colors.red;
        iconData = Icons.close;
        containerColor = Colors.red;
        break;
      case PopupType.success:
        iconColor = Colors.green;
        iconData = Icons.check;
        containerColor = Colors.green;
        break;
      case PopupType.info:
        iconColor = Colors.blue;
        iconData = Icons.info;
        containerColor = Colors.blue;
        break;
      case PopupType.warning:
        iconColor = Colors.orange;
        iconData = Icons.warning;
        containerColor = Colors.orange;
        break;
    }

    return Container(
      width: 56,
      height: 25,
      decoration: BoxDecoration(
        color: data.enableGlassEffect 
            ? containerColor.withOpacity(0.15)
            : containerColor,
        shape: BoxShape.circle,
        border: data.enableGlassEffect 
            ? Border.all(color: containerColor.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Icon(
        iconData,
        color: data.enableGlassEffect ? iconColor : Colors.white,
        size: 28,
      ),
    );
  }

  Color getTitleColor() {
    if (data.titleColor != null) {
      return data.titleColor!;
    }

    if (data.enableGlassEffect) {
      switch (data.type) {
        case PopupType.error:
          return Colors.red.shade700;
        case PopupType.success:
          return Colors.green.shade700;
        case PopupType.info:
          return Colors.blue.shade700;
        case PopupType.warning:
          return Colors.orange.shade700;
      }
    } else {
      switch (data.type) {
        case PopupType.error:
          return Colors.red;
        case PopupType.success:
          return Colors.green;
        case PopupType.info:
          return Colors.blue;
        case PopupType.warning:
          return Colors.orange;
      }
    }
  }

  Widget buildGlassButton(String option, int index, BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: index > 0 ? 12 : 0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            data.onOptionSelected?.call(option);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSolidButton(String option, int index, BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: index > 0 ? 12 : 0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            data.onOptionSelected?.call(option);
          },
          child: Container(
            height: 25,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          data.onClose?.call();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.4),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: data.enableGlassEffect
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: data.backgroundColor?.withOpacity(0.1) ?? 
                                     Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: buildPopupContent(context),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: data.backgroundColor ?? Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: buildPopupContent(context),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPopupContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (data.showCloseButton)
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                data.onClose?.call();
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: data.enableGlassEffect
                    ? BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      )
                    : BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                child: Icon(
                  Icons.close,
                  color: data.enableGlassEffect 
                      ? Colors.black87 
                      : Colors.black54,
                  size: 18,
                ),
              ),
            ),
          ),

        Text(
          data.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: getTitleColor(),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        if (data.subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            data.subtitle!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: data.enableGlassEffect 
                  ? Colors.black87.withOpacity(0.7)
                  : Colors.grey.shade600,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 28),

        if (data.options != null && data.options!.isNotEmpty)
          Row(
            children: data.options!.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              
              return data.enableGlassEffect
                  ? buildGlassButton(option, index, context)
                  : buildSolidButton(option, index, context);
            }).toList(),
          ),
      ],
    );
  }
}

class CountdownPopup extends StatefulWidget {
  final String title;
  final Function() onCountdownComplete;
  final bool enableGlassEffect;
  final SSH ssh;
  final SocketService socketService;

  const CountdownPopup({
    super.key,
    required this.title,
    required this.onCountdownComplete,
    required this.ssh,
    required this.socketService,
    this.enableGlassEffect = false,
  });

  @override
  State<CountdownPopup> createState() => _CountdownPopupState();
}

class _CountdownPopupState extends State<CountdownPopup> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _countdown = 5;
  String _currentMessage = 'Server start...'.tr();
  bool _isProcessing = false;
  int _attempt = 0;

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
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 5; i >= 1; i--) {
      setState(() {
        _isProcessing = true;
        switch (i) {
          case 5:
            _currentMessage = 'Server start...'.tr();
            break;
          case 4:
            _currentMessage = 'Launching Chrome...'.tr();
            break;
          case 3:
            _currentMessage = 'Fetch airplanes...'.tr();
            break;
          case 2:
            _currentMessage = 'Verifying config...'.tr();
            break;
          case 1:
            _currentMessage = 'Starting game...'.tr();
            break;
        }
      });
      
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      bool success = await _executeOperation(i);
      
      if (!success && _attempt == 0 && i == 5) {
        await _retryOperation();
        if (_attempt == 1) {
          continue;
        } else {
          setState(() {
            _currentMessage = 'Failed to start server after retry'.tr();
          });
          await Future.delayed(Duration(seconds: 3));
          Navigator.of(context).pop();
          return;
        }
      }
      
      if (!success) {
        setState(() {
          _currentMessage = 'Operation failed: ${_getErrorMessage(i)}'.tr();
        });
        await Future.delayed(Duration(seconds: 3));
        Navigator.of(context).pop();
        return;
      }
      
      await Future.delayed(const Duration(seconds: 1));
    }
    
    Navigator.of(context).pop();
    widget.onCountdownComplete();
  }

  String _getErrorMessage(int countdownNumber) {
    switch (countdownNumber) {
      case 5:
        return 'Failed to start LG Airport server'.tr();
      case 4:
        return 'Failed to open Chrome'.tr();
      case 3:
        return 'Failed to connect to socket'.tr();
      case 2:
        return 'Server configuration verification failed'.tr();
      case 1:
        return 'Failed to start game'.tr();
      default:
        return 'Unknown error'.tr();
    }
  }

  Future<bool> _executeOperation(int countdownNumber) async {
    try {
      switch (countdownNumber) {
        case 5:
          setState(() {
            _currentMessage = 'Starting LG Airport server...'.tr();
          });
          final started = await widget.ssh.startLGAirport();
          if (!started) {
            return false;
          }
          setState(() {
            _currentMessage = 'Waiting for server to be ready...'.tr();
          });
          final ready = await widget.ssh.waitForLGAirportReady(timeoutSeconds: 120);
          if (!ready) {
            return false;
          }
          break;
          
        case 4:
          setState(() {
            _currentMessage = 'Opening Chrome...'.tr();
          });
          await widget.ssh.command_to_open_lg();
          await Future.delayed(Duration(seconds: 2));
          break;
          
        case 3:
          setState(() {
            _currentMessage = 'Connecting to socket...'.tr();
          });
          await widget.socketService.auto();
          break;
          
        case 2:
          setState(() {
            _currentMessage = 'Checking server config...'.tr();
          });
          
          break;
          
        case 1:
          setState(() {
            _currentMessage = 'Server is ready. You can now start the game'.tr();
          });
          await Future.delayed(Duration(seconds: 1));
          break;
      }
      return true;
    } catch (e) {
      setState(() {
        _currentMessage = 'Error: ${e.toString()}'.tr();
      });
      return false;
    }
  }

  Future<void> _retryOperation() async {
    setState(() {
      _currentMessage = 'Retrying connection...'.tr();
    });
    
    try {
      widget.ssh.disconnectFromLG();
      await Future.delayed(Duration(seconds: 2));
      widget.ssh.connectToLG();
      
      final started = await widget.ssh.startLGAirport();
      if (started) {
        final ready = await widget.ssh.waitForLGAirportReady(timeoutSeconds: 120);
        if (ready) {
          _attempt = 1;
          return;
        }
      }
      _attempt = 2;
    } catch (e) {
      _attempt = 2;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: widget.enableGlassEffect ? 10 : 0, sigmaY: widget.enableGlassEffect ? 10 : 0),
      child: Dialog(
        backgroundColor: widget.enableGlassEffect 
            ? Colors.white.withOpacity(0.1)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: widget.enableGlassEffect 
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                _currentMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (_isProcessing) ...[
                const SizedBox(height: 16),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GameOverPopup extends StatelessWidget {
  final String title;
  final int score;
  final int conflicts;
  final int wrongExits;
  final int BadDepature;
  final Function()? onRestart;
  final bool enableGlassEffect;

  const GameOverPopup({
    super.key,
    required this.title,
    required this.score,
    required this.conflicts,
    required this.wrongExits,
    required this.BadDepature,
    this.onRestart,
    this.enableGlassEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: enableGlassEffect ? 10 : 0, sigmaY: enableGlassEffect ? 10 : 0),
      child: Dialog(
        backgroundColor: enableGlassEffect 
            ? Colors.white.withOpacity(0.1)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: enableGlassEffect 
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Final Score: $score'.tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Crashes: $conflicts'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          color: context.colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Wrong Exits: $wrongExits'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          color: context.colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Bad Depature: $BadDepature'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onRestart,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: context.connectionSuccessColor,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Restart'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color:context.colors.onSurface, width: 1),
                         
                        ),
                        child: Center(
                          child: Text(
                            'Close'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleCountdownPopup extends StatefulWidget {
  final String title;
  final Function() onCountdownComplete;
  final bool enableGlassEffect;

  const SimpleCountdownPopup({
    super.key,
    required this.title,
    required this.onCountdownComplete,
    this.enableGlassEffect = false,
  });

  @override
  State<SimpleCountdownPopup> createState() => _SimpleCountdownPopupState();
}

class _SimpleCountdownPopupState extends State<SimpleCountdownPopup> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _countdown = 5;

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
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 5; i >= 1; i--) {
      setState(() {
        _countdown = i;
      });
      
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      await Future.delayed(const Duration(seconds: 1));
    }
    
    Navigator.of(context).pop();
    widget.onCountdownComplete();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: widget.enableGlassEffect ? 10 : 0, 
        sigmaY: widget.enableGlassEffect ? 10 : 0
      ),
      child: Dialog(
        backgroundColor: widget.enableGlassEffect 
            ? Colors.white.withOpacity(0.1)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: widget.enableGlassEffect 
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_countdown',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Instruction extends StatefulWidget {
  const Instruction({super.key});

  @override
  State<Instruction> createState() => _InstructionState();
}

class _InstructionState extends State<Instruction>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: const Icon(
                        Icons.flight_takeoff,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                "Instructions",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _instructions
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ",
                                style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class PopupDemo extends StatelessWidget {
  const PopupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Bottom Popup Demo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => showConflictPopup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Show Error Popup'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showSuccessPopup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Show Success Popup'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showInfoPopup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Show Info Popup'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showCustomPopup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Show Custom Popup'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Show Game Over Popup'),
            ),
          ],
        ),
      ),
    );
  }

  void showConflictPopup(BuildContext context) {
    BottomPopup.showError(
      context: context,
      title: "Conflict Detected".tr(),
      subtitle: "Select an option below to resolve".tr(),
      options: ["Option A".tr(), "Option B".tr()],
      enableGlassEffect: false,
      onOptionSelected: (selectedOption) {
        print("Selected: $selectedOption");
      },
      onClose: () {
        print("Popup closed");
      },
    );
  }

  void showSuccessPopup(BuildContext context) {
  }

  void showInfoPopup(BuildContext context) {
    BottomPopup.showInfo(
      context: context,
      title: "Information",
      subtitle: "Choose your next action",
      options: ["Continue", "Cancel"],
      enableGlassEffect: false,
      onOptionSelected: (selectedOption) {
        print("Info option selected: $selectedOption");
      },
    );
  }

  void showCustomPopup(BuildContext context) {
    BottomPopup.show(
      context: context,
      data: PopupData(
        type: PopupType.warning,
        title: "Custom Warning",
        subtitle: "This is a custom popup with special styling",
        showCloseButton: true,
        options: ["Accept", "Decline"],
        enableGlassEffect: false,
        onOptionSelected: (option) {
          print("Custom option: $option");
        },
        customIcon: Container(
          width: 56,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.purple.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.star,
            color: Colors.purple,
            size: 28,
          ),
        ),
        titleColor: Colors.purple.shade700,
      ),
    );
  }

}