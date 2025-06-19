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
const allpostionAirpots = [];
const allscreenwidth =[];

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
    // const width  = allscreenwidth.findIndex((existing) => existing.screen === planeData.screen);
    // -4<-2<-1<-3<-5

    if(planeData.x === -3){
      const screenEntry = allscreenwidth.find(obj => obj[1]);
      if (screenEntry) {
        planeData.x = screenEntry[1].data.width;
      }
    }
    if(planeData.x === -2){
      const screenEntry = allscreenwidth.find(obj => obj[2]);
      if (screenEntry) {
        planeData.x = screenEntry[2].data.width;
      }
    }
    if(planeData.x === -4){
      const screenEntry = allscreenwidth.find(obj => obj[4]);
      if (screenEntry) {
        planeData.x = screenEntry[4].data.width;
      }
    }
    if(planeData.x === -5){
      const screenEntry = allscreenwidth.find(obj => obj[3]);
      if (screenEntry) {
        planeData.x = screenEntry[3].data.width;
      }
    }
  
    if(planeData.x === -4){
      const screenEntry = allscreenwidth.find(obj => obj[4]);
      if (screenEntry) {
        planeData.x = screenEntry[4].data.width;
      }
    }
  
        console.log("Transferring aeroplane to screen", planeData.screen);
        io.emit("aeroplane-create", planeData);
  });


    socket.on("add-plane", (data)=>{
      data.destation = {label: 'WSH', x: 358.5, y: 26.5, screen: 2};
      data.source = {label: 'ALT', x: 293.5, y: 341.5, screen: 1};
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

socket.on('airport-positions', (data) => {
  console.log('====================================');
  console.log('Received updated airport positions ckient:', data);
  console.log('====================================');
  data.forEach((incoming) => {
    const index = allpostionAirpots.findIndex((existing) => existing.label === incoming.label);
  
    if (index !== -1) {
      // Update existing
      allpostionAirpots[index].x = incoming.x;
      allpostionAirpots[index].y = incoming.y;
      allpostionAirpots[index].screen = incoming.screen;
    } else {
      // Add new
      allpostionAirpots.push(incoming);
    }
  });
  
  // console.log('New airport positions:', newEntries);
  // allpostionAirpots.push(...newEntries);
  console.log('Updated all airport positions:', allpostionAirpots);
  io.emit('all-airport-positions', allpostionAirpots);

});
 

//callback 
socket.on('get-airport-positions', (callback) => {
  callback(allpostionAirpots); // Send back data only to requester
});


socket.on('get-aeroplane', (data) => {
  // Now re-emit to all connected clients
  io.emit('aeroplane-data', data); // you can rename this
});
    
  socket.on('postwidth', (data) => {
    console.log('Received updated airport width from server:', data);
    const index = allscreenwidth.findIndex(
      (existing) => Object.keys(existing)[0] === String(data.screen)
    );
    if(index !== -1){
      allscreenwidth[index] = {[data.screen]:{data}};
    }
    else{
     allscreenwidth.push({[data.screen]:{data}})};
  })

  socket.on('get-screen-width', (callback) => {
    callback(allscreenwidth); 
  });

  socket.on('update-origin-destination', (data) => {
    io.emit('update-origin-destination', data); // you can rename this
  });

    function sleep(duration) {
    return new Promise((resolve) => setTimeout(resolve, duration));
  }
  socket.on('disconnect', () => {
    console.log('User disconnected');
  });


// setTimeout(() => {
//   let sourcedata = allpostionAirpots[Math.floor(Math.random()*allpostionAirpots.length)]
//   let destationdata = allpostionAirpots[Math.floor(Math.random()*allpostionAirpots.length)]

//   if(sourcedata?.label === destationdata?.label){
//      destationdata = allpostionAirpots[Math.floor(Math.random()*allpostionAirpots.length)]
//   }
// const data ={
//   x: sourcedata.x,
//   y: sourcedata.y,
//   screen: sourcedata.screen,
//   destation :destationdata,
//   source :sourcedata,
// }
// console.log("interval" , data)
//   io.emit('add-aeroplane', data);
// },50000);


});

http.listen(port, "0.0.0.0", () => {
  console.log(`Listening on port ${port}`);
});


