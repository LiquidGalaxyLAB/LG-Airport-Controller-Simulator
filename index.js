// Server initialization
var express = require("express");
var app = express();
var http = require("http");
var server = http.createServer(app);
var io = require("socket.io")(server);
var path = require("path");
var __dirname = path.resolve();
var port = 3001;

// Setup files to be sent on connection
var filePath = "/public"; // Do not add '/' at the end
var gameFile = "index.html";
var mapBuilderFile = "mapbuilder/index.html";
var controllerFile = "controller/index.html";
var allpostionAirpots = [];
var allscreenwidth = [];

var planes = {
  1: [],
  2: [],
  3: [],
  4: [],
  5: [],
};

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
  "Running LG AIRPORT SIMULATOR for Liquid Galaxy with " + nScreens + " screens!"
);

app.use(express.static(__dirname + filePath));

app.get("/:id", function(req, res) {
  var id = req.params.id;
  if (id == "mapbuilder") {
    res.sendFile(__dirname + filePath + "/" + mapBuilderFile);
  } else if (id == "controller") {
    res.sendFile(__dirname + filePath + "/" + controllerFile);
  } else {
    screenNumber = id;
    res.sendFile(__dirname + filePath + "/" + gameFile);
  }
});

// Helper function to find array element (replacement for Array.find)
function findInArray(array, predicate) {
  for (var i = 0; i < array.length; i++) {
    if (predicate(array[i])) {
      return array[i];
    }
  }
  return undefined;
}

// Helper function to find array index (replacement for Array.findIndex)
function findIndexInArray(array, predicate) {
  for (var i = 0; i < array.length; i++) {
    if (predicate(array[i])) {
      return i;
    }
  }
  return -1;
}

// Socket listeners and functions
io.on("connect", function(socket) {
  console.log("User connected with id " + socket.id);
  socket.emit("new-screen", {
    number: Number(screenNumber),
    nScreens: nScreens,
  });  
  
  socket.on("create-aeroplane", function(data) {
    console.log("Received create-aeroplane request:", data);
    var aeroplaneData = {
      dx: data.dx || 0,
      dy: data.dy || 0,
      id: Date.now() + Math.random(), 
    };
    // Copy all properties from data to aeroplaneData
    for (var key in data) {
      if (data.hasOwnProperty(key)) {
        aeroplaneData[key] = data[key];
      }
    }
    io.emit("aeroplane-create", aeroplaneData);
  });

  // Handle transfer between screens
  socket.on("transfer-aeroplane", function(planeData) {
    // -4<-2<-1<-3<-5

    if(planeData.x === -3){
      var screenEntry = findInArray(allscreenwidth, function(obj) { return obj[3]; });
      if (screenEntry) {
        planeData.x = screenEntry[3].data.width;
      }
    }
    if(planeData.x === -2){
      var screenEntry = findInArray(allscreenwidth, function(obj) { return obj[2]; });
      if (screenEntry) {
        planeData.x = screenEntry[2].data.width;
      }
    }
    if(planeData.x === -4){
      var screenEntry = findInArray(allscreenwidth, function(obj) { return obj[4]; });
      if (screenEntry) {
        planeData.x = screenEntry[4].data.width;
      }
    }
    if(planeData.x === -5){
      var screenEntry = findInArray(allscreenwidth, function(obj) { return obj[3]; });
      if (screenEntry) {
        planeData.x = screenEntry[3].data.width;
      }
    }
  
    if(planeData.x === -4){
      var screenEntry = findInArray(allscreenwidth, function(obj) { return obj[4]; });
      if (screenEntry) {
        planeData.x = screenEntry[4].data.width;
      }
    }
  
    console.log("Transferring aeroplane to screen", planeData.screen);
    io.emit("aeroplane-create", planeData);
  });

  socket.on("add-plane", function(data) {
    var destationdata = allpostionAirpots[Math.floor(Math.random()*allpostionAirpots.length)];
    data.source = findInArray(allpostionAirpots, function(airport) { return airport.label === data.label; });
    data.destation = destationdata.label !== data.source.label ? destationdata : allpostionAirpots[Math.floor(Math.random()*allpostionAirpots.length)];
    io.emit("add-aeroplane", data);
    console.log("Adding aeroplane" , data);
  });

  function updateDirectionLeft() {
    io.emit("update-plane", { dir: "left"  });
    console.log("Adding aeroplane left");
  }
  
  function updateDirectionRight() {
    io.emit("update-plane", { dir: "right" });
    console.log("Adding aeroplane right");
  }
  
  socket.on("update-plane-left", updateDirectionLeft);
  socket.on("update-plane-right", updateDirectionRight);
  
  socket.on("send-command", function(data) {
    io.emit("command-plane", data);
    console.log("Sending command to plane", data);
  });

  socket.on('select-plane', function(key) {
    io.emit('select-aeroplane', { dir: key });
    console.log('Selecting plane', key);
  });

  socket.on('submit-plane', function(key) {
    io.emit('submit-aeroplane', key);
    console.log('Selecting plane', key);
  });

  socket.on('airport-positions', function(data) {
    console.log('Received updated airport positions client:', data);
    
    // Replace forEach with for loop
    for (var i = 0; i < data.length; i++) {
      var incoming = data[i];
      if(incoming.label === 'ALT') {
        incoming.y -= 20;
      }
      var index = findIndexInArray(allpostionAirpots, function(existing) { return existing.label === incoming.label; });
    
      if (index !== -1) {
        // Update existing
        allpostionAirpots[index].x = incoming.x;
        allpostionAirpots[index].y = incoming.y;
        allpostionAirpots[index].screen = incoming.screen;
      } else {
        // Add new
        allpostionAirpots.push(incoming);
      }
    }
    
    console.log('Updated all airport positions:', allpostionAirpots);
    io.emit('all-airport-positions', allpostionAirpots);
  });

  //callback 
  socket.on('get-airport-positions', function(callback) {
    callback(allpostionAirpots); // Send back data only to requester
  });

  socket.on("get-aeroplane", function(data) {
    var screenNumber = data.screenNumber;
    var airplanes = data.airplanes;
    
    if (
      typeof screenNumber !== "undefined" &&
      Array.isArray(airplanes)
    ) {
      planes[screenNumber] = airplanes;

      console.log("✅ Updated screen " + screenNumber + " with " + airplanes.length + " planes");
      console.log('📡 Full planes state now:', JSON.stringify(planes, null, 2));
      
      io.emit("aeroplane-data", planes);
    } else {
      console.warn("⚠️ Invalid airplane data received");
    }
  });

  socket.on('postwidth', function(data) {
    console.log('Received updated airport width from server:', data);
    var index = findIndexInArray(allscreenwidth, function(existing) { 
      return Object.keys(existing)[0] === String(data.screen); 
    });
    
    var screenData = {};
    screenData[data.screen] = {data: data};
    
    if(index !== -1){
      allscreenwidth[index] = screenData;
    }
    else{
      allscreenwidth.push(screenData);
    }
  });

  console.log("screen all",allscreenwidth);

  socket.on('get-screen-width', function(callback) {
    callback(allscreenwidth); 
  });

  socket.on('update-origin-destination', function(data) {
    io.emit('update-origin-destination', data); 
  });

  socket.on('update-heading-altitude', function(data) {
    io.emit('update-heading-altitude', data); 
  });
  
  socket.on('error-popup', function(data) {
    io.emit('error-popup', data);
  });

  function sleep(duration) {
    return new Promise(function(resolve) { 
      setTimeout(resolve, duration); 
    });
  }
  
  socket.on('disconnect', function() {
    console.log('User disconnected');
  });

  // Uncomment if needed - converted to Node 4.2.6 compatible syntax
  // setInterval(function() {
  //   var sourcedata = allpostionAirpots[Math.floor(Math.random()*allpostionAirpots.length)];
  //   var destationdata = allpostionAirpots[Math.floor(Math.random()*allpostionAirpots.length)];
  
  //   if(sourcedata && sourcedata.label === destationdata.label){
  //      destationdata = allpostionAirpots[Math.floor(Math.random()*allpostionAirpots.length)];
  //   }
  //   var data = {
  //     x: sourcedata.x,
  //     y: sourcedata.y,
  //     screen: sourcedata.screen,
  //     destation: destationdata,
  //     source: sourcedata,
  //   };
  //   console.log("interval" , data);
  //   io.emit('add-aeroplane', data);
  // }, 70000);
});

server.listen(port, "0.0.0.0", function() {
  console.log("Listening on port " + port);
});
