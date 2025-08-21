// Server initialization
var express = require("express");
var app = express();
var http = require("http");
var server = http.createServer(app);
var io = require("socket.io")(server);
var path = require("path");
var __dirname = path.resolve();
var port = 3000;

// Setup files to be sent on connection
var filePath = "/public"; // Do not add '/' at the end
var gameFile = "index.html";
var mapBuilderFile = "mapbuilder/index.html";
var controllerFile = "controller/index.html";
var allpostionAirpots = []; 
var allscreenwidth = [];
var aeroplaneIntervalId = undefined;
var isPlaneAdded = false;
var intervalTime = 5000;
var lastSourceLabel = null;
var successCount = 0;
var wrongExitCount = 0;
var conflictCount = 0;
var baddepartureCount = 0;
var isGameover = false;
var isGameRunning = false;

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
      var screenEntry = findInArray(allscreenwidth, function(obj) { return obj[5]; });
      if (screenEntry) {
        planeData.x = screenEntry[5].data.width;
      }
    }
  
    if(planeData.x === -1){
      var screenEntry = findInArray(allscreenwidth, function(obj) { return obj[1]; });
      if (screenEntry) {
        planeData.x = screenEntry[1].data.width;
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


    socket.on("add-plane-controller", function(data) {
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
 console.log('Selecting plane flutter', key);
    io.emit('select-aeroplane', { dir: key.dir , altitude: key.altitude});
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
        incoming.y -= 2;
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
    socket.emit('fetch-airplanes', allpostionAirpots);
  });

  //callback 
  // socket.on('get-airport-positions', function(callback) {
  //   callback(allpostionAirpots); // Send back data only to requester
  // });
  
  socket.on('get-airport-positions',function (maybeCallback)  {
    if (typeof maybeCallback === 'function') {
      maybeCallback(allpostionAirpots);
      console.log('take one ',allpostionAirpots)

    } else {
      socket.emit('fetch-airplanes', allpostionAirpots);
      console.log('take one ',allpostionAirpots)
      io.emit('aeroplane-data', planes);
   
    }})

    socket.on("fetch-airplanes-io", function(data) {	
    socket.emit('fetch-airplanes', allpostionAirpots);
      var planesTakeoff  = gneratetakeoffPlanes(allpostionAirpots);
        if(planesTakeoff){
          io.emit('takeoff-planes', planesTakeoff);
    calltakeoff = true;
}});
  
  socket.on("get-aeroplane", function(data) {
    var screenNumber = data.screenNumber;
    var airplanes = data.airplanes;
    
    if (
      typeof screenNumber !== "undefined" &&
      Array.isArray(airplanes)
    ) {
      planes[screenNumber] = airplanes;

      console.log(" Updated screen " + screenNumber + " with " + airplanes.length + " planes");
      console.log('Full planes state now:', JSON.stringify(planes, null, 2));
      
      io.emit("aeroplane-data", planes);

      console.log("send to flutter ");
    } else {
      console.warn("Invalid airplane data received");
    }
  });

  socket.on("success-plane", function(data) {
    successCount += 1;
    io.emit("Completed", data);
    console.log("Success plane", data);
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

  socket.on('warning-popup', function(data) {
    console.log('Received warning data:', data);
  });

  socket.on('update-origin-destination', function(data) {
    io.emit('update-origin-destination', data); 
  });

  socket.on('update-heading-altitude', function(data) {
    io.emit('update-heading-altitude', data); 
  });
  
  socket.on('deselect-plane', function(data) {
    io.emit('deselect-plane', data); 
  });

  socket.on('error-popup', function(data) {
    if(data.conflict){
      conflictCount += 1;
    }
    else if(data.error === 'Wrong exit'){
      wrongExitCount += 1;
    } 
    else if(data.badDeparture){
      baddepartureCount += 1;
    }
    io.emit('error-popup', data);
  });
  

  function sleep(duration) {
    return new Promise(function(resolve) { 
      setTimeout(resolve, duration); 
    });
  }
  
  socket.on('disconnect', function() {
    console.log('User disconnected');
    socket.removeAllListeners();
  });

  socket.on('reconnect', function() {
    console.log('User reconnected');
  });
  
  socket.on('gameOver',function(){
    clearInterval(aeroplaneIntervalId);
    isGameRunning = false;
    aeroplaneIntervalId = null; 
    if(isGameover) return;
    isGameover = true;
    io.emit('gameOverData',{ successCount: successCount, conflictCount: conflictCount, wrongExitCount: wrongExitCount ,baddepartureCount: baddepartureCount});
  }) 
  
  socket.on('gameStart',function(){
    // setDelayGameover();
    planes = {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
    };
	isGameover = false;
    startGamePlane();
    io.emit('gameStartData');
  })
  socket.on('gameStop',function(){
    clearInterval(aeroplaneIntervalId);
    aeroplaneIntervalId = null;
    isGameRunning = false;
    isPlaneAdded = false;
    successCount = 0;
    wrongExitCount = 0;
    conflictCount = 0;
    isGameover = false;
    planes = {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
    };
    io.emit('gameStopData');
  })
  socket.on('gamePause',function(){
    clearInterval(aeroplaneIntervalId);
    aeroplaneIntervalId = null;
    isGameRunning = false;

    io.emit('gamePauseData');
  })

  socket.on('gameResume', function() {
    if (!isGameRunning) {
      startGamePlane();
      isGameRunning = true;
    }
    io.emit('gameResumeData');
    console.log('Game resumed');
  });

  socket.on('gameReset',function(){
    successCount = 0;
    conflictCount = 0;
    wrongExitCount = 0;
    io.emit('gameResetData');
     isGameover = false;
  })

  socket.on('heartbeat', function(data) {
    console.log('Heartbeat from screen', data.screenNumber, 'State:', {
      isPaused: data.isPaused,
      isStopped: data.isStopped,
      isGameOver: data.isGameOver
    });

    socket.emit('heartbeat_response', {
      serverTime: Date.now(),
      clientTime: data.timestamp
    });
  });  
    
  
  
 });

server.listen(port, "0.0.0.0", function() {
  console.log("Listening on port " + port);
});


function startGamePlane() {
  isGameRunning = true;
  aeroplaneIntervalId = setInterval(function () {

    // if (isGamePaused) {
    //   console.log('Game is paused - not adding new planes');
    //   return;
    // }
    if (isPlaneAdded) {
      return;
    }
  
    if (allpostionAirpots.length < 2) {
      console.log("Not enough airports to create a plane.");
      return;
    }
  
    var sourcedata = allpostionAirpots[Math.floor(Math.random() * allpostionAirpots.length)];
    var destationdata = allpostionAirpots[Math.floor(Math.random() * allpostionAirpots.length)];
  
    do {
      sourcedata = allpostionAirpots[Math.floor(Math.random() * allpostionAirpots.length)];
    } while (
      sourcedata.label === 'ALT' ||
      (lastSourceLabel != null && sourcedata.label === lastSourceLabel)
    );
  
    do {
      destationdata = allpostionAirpots[Math.floor(Math.random() * allpostionAirpots.length)];
    } while (
      destationdata.label === sourcedata.label
    );
  
    lastSourceLabel = sourcedata.label;

    if (!sourcedata || !destationdata) {
      console.log("Invalid airport data. Aborting time limit.");
      return;
    }
  
    var data = {
      x: sourcedata.x,
      y: sourcedata.y,
      screen: sourcedata.screen,
      destation: destationdata,
      source: sourcedata,
    };
  
    console.log("Adding plane at", new Date().toLocaleTimeString(), data);
    io.emit('add-aeroplane', data);
  
    isPlaneAdded = true;
    setTimeout(function () {
      isPlaneAdded = false;
    }, 30000); //to be chnage 
  
  }, intervalTime);
}

function setDelayGameover(){
setTimeout(()=>{
 isGameover = false;
isplaneAdded = false;
},4000);
}


function gneratetakeoffPlanes(allAirports) {
  const planes = [];

  if (allAirports.length < 8) {
    console.log("Not enough airports to generate data.");
  // setTimeout(() => { gneratetakeoffPlanes(allAirports);},5000);
    return ;
  }

  const source = allAirports.find((a) => a.label === 'ALT');
  if (!source) {
    console.log("No ALT-labeled airport found for source.");
    return planes;
  }

  const usedDestinations = new Set();
  var attempts = 0;
  const maxAttempts = 50; // prevent infinite loop

  while (planes.length < 5 && attempts < maxAttempts) {
    attempts++;

    const destination = allAirports[Math.floor(Math.random() * allAirports.length)];

    if (
      !destination ||
      destination.label === source.label || // skip if same as ALT
      usedDestinations.has(destination.label)
    ) {
      continue;
    }

    usedDestinations.add(destination.label);

    planes.push({
      x: source.x,
      y: source.y,
      screen: source.screen,
      source: {
        label: source.label,
        x: source.x,
        y: source.y,
        screen: source.screen,
      },
      destination: {
        label: destination.label,
        x: destination.x,
        y: destination.y,
        screen: destination.screen,
      },
    });
  }

  if (planes.length < 5) {
    console.warn(`Only ${planes.length} unique takeoff planes could be generated.`);
  }
  
  return planes;
}

  
