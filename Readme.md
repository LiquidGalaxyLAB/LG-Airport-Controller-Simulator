# LG_AIRPORT_CONTROLLER_SIMULATOR
Here's a properly rephrased and polished version of your message:

---

**For Node v4.2.6**

You’ll find a `.zip` file. After unzipping it, if everything is set up correctly, you can directly run the server with the following command:

```bash
node index.js
```

---

**After Server Starts**

Open the following URLs in your browser (replace `lg1` with your rig hostname or IP if needed):

* For 5 screens:
  `lg1:3001/1`, `lg1:3001/2`, `lg1:3001/3`, `lg1:3001/4`, `lg1:3001/5`

* For 3 screens:
  `lg1:3001/1`, `lg1:3001/2`, `lg1:3001/3`

---

**If You Encounter Connection Issues**

If you get an error like:

> "Rigs are not connecting", "Connection refused", or "Connection timed out"

I’ve provided a repair script. Navigate to the `bash` directory and run:

```bash
bash repair.sh
```

Once you see the success message, you can restart the server with:

```bash
node index.js
```

Everything should work smoothly after that.



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


Thanks to my main mentor vedant  and secondary  mentors Rosemarie Garcia , prayag biswas And thanks to the team of the Liquid Galaxy LAB Lleida, Headquarters of the Liquid Galaxy project: Alba, Paula, Josep, Jordi, Oriol, Sharon, Alejandro, Marc, and admin Andreu, for their continuous support on my project.
Info in www.liquidgalaxy.eu