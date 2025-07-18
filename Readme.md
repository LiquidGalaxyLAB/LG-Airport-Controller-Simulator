# LG_AIRPORT_CONTROLLER_SIMULATOR

For node v4.2.6

> There is 2 way 

> Follow part 1
1. git clone my repo git clone https://github.com/LiquidGalaxyLAB/LG-Airport-Controller-Simulator.git

2. Because npm is too old decerpated we have to install dependenices manually these 2 same version 

npm install express@4.13.4
npm install socket.io@1.4.8

and two open all the chromium you can run open-airport like after navigating bash the type bash open-airport.sh


that after start terminal over there and type command node index.js 

and for 3 screen 3 and for 5 nothing 

eg node index.js 3

it will start server 

and reload all tabs once 

> Follow part 2

i have add a zip you can unzip and and if all is right you can directly run command node index.js 

--------------------
after all install complete 
---------------

Now open:

    Screens: lg1:3001/1, lg1:3001/2, etc uptill 5 for 5 screen and same for 3.


📱 Controlling the Simulator

 > Note: if you find that my  rig are not connecting master and error is something related to connection time out  then try flush iptables ->  sudo iptables -F 

Access the controller interface from any device:

http://<MASTER_MACHINE_IP>:3001/controller

> please make sure you open controller after all screen get initialize or if you open first you have reload to get all data from all screen for airports position  

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


Thanks to my main mentor vedant  and seconday mentors Rosemarie , prayag And thanks to the team of the Liquid Galaxy LAB Lleida, Headquarters of the Liquid Galaxy project: Alba, Paula, Josep, Jordi, Oriol, Sharon, Alejandro, Marc, and admin Andreu, for their continuous support on my project.
Info in www.liquidgalaxy.eu