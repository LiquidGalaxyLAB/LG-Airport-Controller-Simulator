// Server initialization
import express from "express";
var app = express();
import httpImport from "http";
var http = httpImport.createServer(app);
import { Server } from "socket.io";
var io = new Server(http);
import path from "path";
const __dirname = path.resolve();
const port = 3000;

// Setup files to be sent on connection
const filePath = "/public"; // Do not add '/' at the end
const gameFile = "index.html";
const mapBuilderFile = "mapbuilder/index.html";
const controllerFile = "controller/index.html";

// Variables
var screenNumber = 1;
var myArgs = process.argv.slice(2);
var nScreens = Number(myArgs[0]);
if (myArgs.length == 0 || isNaN(nScreens)) {
  console.log(
    "Number of screens invalid or not informed, default number is 5."
  );
  nScreens = 5;
}
console.log(
  `Running Galaxy Pacman for Liquid Galaxy with ${nScreens} screens!`
);

app.use(express.static(__dirname + filePath));

app.get("/:id", (req, res) => {
  const id = req.params.id;
  if (id == "mapbuilder") {
    res.sendFile(__dirname + `${filePath}/${mapBuilderFile}`);
  } else if (id == "controller") {
    res.sendFile(__dirname + `${filePath}/${controllerFile}`);
  } else {
    screenNumber = id;
    res.sendFile(__dirname + `${filePath}/${gameFile}`);
  }
});

// Socket listeners and functions
    io.on("connect", (socket) => {
        console.log(`User connected with id ${socket.id}`);
        socket.emit("new-screen", {
            number: Number(screenNumber),
            nScreens: nScreens,
    }); //tell to load screen on local and its number

  // Listen for create-aeroplane request from client
  socket.on("create-aeroplane", (data) => {
            console.log("Received create-aeroplane request:", data);
            // Add some default values if missing
            const aeroplaneData = {
            ...data,
            dx: data.dx || 0,
            dy: data.dy || 0,
            id: Date.now() + Math.random(), // unique ID
            };
            // Broadcast to ALL clients (this will trigger the creation)
    io.emit("aeroplane-create", aeroplaneData);
  });

  // Handle transfer between screens
  socket.on("transfer-aeroplane", (planeData) => {
        console.log("Transferring aeroplane to screen", planeData.screen);
        io.emit("aeroplane-create", planeData);
  });


    socket.on("add-plane", (data)=>{
      io.emit("add-aeroplane", data);
      console.log("Adding aeroplane" , data);
    });


    function updateDirectionLeft() {
        io.emit("update-plane", { dir: "left" });
        console.log("Adding aeroplane left");
    }
    
    function updateDirectionRight() {
        io.emit("update-plane", { dir: "right" });
        console.log("Adding aeroplane right");
    }
    
    socket.on("update-plane-left", updateDirectionLeft);
    socket.on("update-plane-right", updateDirectionRight);
    
 
    // Server
socket.on('select-plane', (key) => {
    io.emit('select-aeroplane', { dir: key });
    console.log('Selecting plane', key);
});
 
    
    function sleep(duration) {
    return new Promise((resolve) => setTimeout(resolve, duration));
  }
  socket.on('disconnect', () => {
    console.log('User disconnected');
  });
});

http.listen(port, "0.0.0.0", () => {
  console.log(`Listening on port ${port}`);
});
