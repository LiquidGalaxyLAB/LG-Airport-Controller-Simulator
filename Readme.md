# LG_AIRPORT_CONTROLLER_SIMULATOR


💻 Local Development

To run the simulator locally:

git clone https://github.com/LiquidGalaxyLAB/LG-Airport-Controller-Simulator.git
cd LG-Airport-Controller-Simulator
npm install

Start the local server:

npm run server 5

Replace 5 with 3  if you have screen 3.

Now open:

    Screens: lg1:3000/1, lg2:3000/2, etc uptill 5 for 5 screen and same for 3.

📱 Controlling the Simulator

 > Note: if you find that my  rig are not connecting master and error is something related to connection time out  then try flush iptables ->  sudo iptables -F 

Access the controller interface from any device:


http://<MASTER_MACHINE_IP>:3000/controller

Use the Controller to:

    Add planes from airports

    Issue commands (turns, climbs, descents)

    Preview and submit ATC instructions

    View real-time conflicts and flight paths

🎮 Game Mechanics

    Conflict Detection: Planes flying too close emit alerts.

    Realistic Commands: Turns, takeoffs, landings, and altitude changes.

    Visual Labels: ALT, WSH, etc., across multiple screens.

    Voice Announcements: Commands are spoken using browser TTS.
