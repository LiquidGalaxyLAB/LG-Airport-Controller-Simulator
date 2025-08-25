import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lg_airport_simulator_apk/screens/ssh.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:lg_airport_simulator_apk/screens/popup.dart';

class LG_Task extends StatefulWidget {
   const LG_Task({Key? key}) : super(key: key);

  @override
  _LGTaskState createState() => _LGTaskState();
  

}

class _LGTaskState extends State<LG_Task> {
  late SSH ssh;
  bool connectionStatus = false;
  

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:  Text('LG Task'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: context.colors.onSurface,
              )),
            backgroundColor: context.appbar,
            iconTheme: IconThemeData(color: context.colors.onSurface),
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(Icons.restart_alt, 'Relaunch'.tr(), ()async {
              print('dev'.tr());
            BottomPopup.showInfo(context: context, title: "Relaunch LG".tr(), subtitle: "Are you sure. Restarting the LG ?".tr(), options: ["ok".tr()], onOptionSelected: (selectedOption) async {
            await ssh.relaunchLG();
            });
              print('dev');

             
            }),
            _buildButton(Icons.power_settings_new, 'Clean kml'.tr(), () async{
              await ssh.cleanrig();
             
            }),
            _buildButton(Icons.autorenew, 'Reboot'.tr(), ()async {
              BottomPopup.showInfo(context: context, title: "Reboot LG".tr(), subtitle: "Are you sure. Rebooting the LG ?".tr(), options: ["ok".tr()], onOptionSelected: (selectedOption) async {
            await ssh.rebootlg();
            });
            }),
            _buildButton(Icons.image, 'Display Logo'.tr(), () async {
              await ssh.sendKml();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 30,
            color: context.colors.onSurface),
        label: Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,
              color: context.colors.onSurface),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0,),
          shadowColor: context.colors.onSurface
        ),
      ),
    );
  }
}
