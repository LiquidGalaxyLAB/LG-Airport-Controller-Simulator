// Server initialization
var express = require("express");
var app = express();
var http = require("http");
var server = http.createServer(app);
var io = require("socket.io")(server);
var path = require("path");
var __dirname = path.resolve();
var port = 8111;

// Setup files to be sent on connection
var filePath = "/public";
var gameFile = "index.html";
var mapBuilderFile = "mapbuilder/index.html";
var controllerFile = "controller/index.html";

//norrmal variables

var screenNumber = 1;
var myArgs = process.argv.slice(2);
var nScreens = Number(myArgs[0]);

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

// Edge screen conflict variables
var crossScreenConflicts = new Set();
var crossScreenWarnings = new Set();
var crossScreenCheckInterval = null;

var planes = {
  1: [],
  2: [],
  3: [],
  4: [],
  5: [],
};

if (myArgs.length == 0 || isNaN(nScreens)) {
  console.log(
    "Number of screens invalid or not informed, default number is 5."
  );
  nScreens = 5;
}
console.log(
  "Running LG AIRPORT SIMULATOR for Liquid Galaxy with " +
    nScreens +
    " screens!"
);

app.use(express.static(__dirname + filePath));

app.get("/:id", function (req, res) {
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

// Helper function to find array element
function findInArray(array, predicate) {
  for (var i = 0; i < array.length; i++) {
    if (predicate(array[i])) {
      return array[i];
    }
  }
  return undefined;
}

// Helper function to find array index
function findIndexInArray(array, predicate) {
  for (var i = 0; i < array.length; i++) {
    if (predicate(array[i])) {
      return i;
    }
  }
  return -1;
}

// Socket listeners and functions
io.on("connect", function (socket) {
  console.log("User connected with id " + socket.id);
  socket.emit("new-screen", {
    number: Number(screenNumber),
    nScreens: nScreens,
  });

  socket.on("create-aeroplane", function (data) {
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

  // Handle transfer conflict checking
  socket.on("check-transfer-conflict", function (data) {
    var plane = data.plane;
    var fromScreen = data.fromScreen;
    var direction = data.direction;
    var toScreen;

    if (nScreens === 3) {
      if (fromScreen == 1 && direction === "right") toScreen = 2;
      else if (fromScreen == 1 && direction === "left") toScreen = 3;
      else if (fromScreen == 2 && direction === "left") toScreen = 1;
      else if (fromScreen == 3 && direction === "right") toScreen = 1;
    } else if (nScreens === 5) {
      if (fromScreen == 1 && direction === "right") toScreen = 2;
      else if (fromScreen == 1 && direction === "left") toScreen = 5;
      else if (fromScreen == 2 && direction === "right") toScreen = 3;
      else if (fromScreen == 2 && direction === "left") toScreen = 1;
      else if (fromScreen == 3 && direction === "left") toScreen = 2;
      else if (fromScreen == 4 && direction === "right") toScreen = 5;
      else if (fromScreen == 5 && direction === "right") toScreen = 1;
      else if (fromScreen == 5 && direction === "left") toScreen = 4;
    }

    if (!toScreen) return;

    var destinationPlanes = planes[toScreen] || [];
    var edgeBuffer = 100;
    var toScreenWidth = getScreenWidth(toScreen);

    for (var i = 0; i < destinationPlanes.length; i++) {
      var destPlane = destinationPlanes[i];

      var nearTransferEdge = false;
      if (direction === "right") {
        nearTransferEdge = destPlane.x <= edgeBuffer && destPlane.dx < 0;
      } else if (direction === "left") {
        nearTransferEdge =
          destPlane.x >= toScreenWidth - edgeBuffer && destPlane.dx > 0;
      }

      if (nearTransferEdge && destPlane.altitude === plane.altitude) {
        io.emit("cross-screen-warning", {
          error: ``,
          warning: `Transfer Warning: ${plane.label} (screen ${fromScreen}) and ${destPlane.label} (screen ${toScreen}) may conflict during transfer.`,
          screenA: fromScreen,
          screenB: toScreen,
          planeA: plane.label,
          planeB: destPlane.label,
          transferDirection: direction,
        });
        console.log(
          `Transfer conflict warning: ${plane.label} (${fromScreen} → ${toScreen}) vs ${destPlane.label} on ${toScreen}`
        );
        break;
      }
    }
  });

  // Handle transfer between screens
  socket.on("transfer-aeroplane", function (planeData) {
    // -4<-2<-1<-3<-5

    if (planeData.x === -3) {
      var screenEntry = findInArray(allscreenwidth, function (obj) {
        return obj[3];
      });
      if (screenEntry) {
        planeData.x = screenEntry[3].data.width;
      }
    }
    if (planeData.x === -2) {
      var screenEntry = findInArray(allscreenwidth, function (obj) {
        return obj[2];
      });
      if (screenEntry) {
        planeData.x = screenEntry[2].data.width;
      }
    }
    if (planeData.x === -4) {
      var screenEntry = findInArray(allscreenwidth, function (obj) {
        return obj[4];
      });
      if (screenEntry) {
        planeData.x = screenEntry[4].data.width;
      }
    }
    if (planeData.x === -5) {
      var screenEntry = findInArray(allscreenwidth, function (obj) {
        return obj[5];
      });
      if (screenEntry) {
        planeData.x = screenEntry[5].data.width;
      }
    }

    if (planeData.x === -1) {
      var screenEntry = findInArray(allscreenwidth, function (obj) {
        return obj[1];
      });
      if (screenEntry) {
        planeData.x = screenEntry[1].data.width;
      }
    }

    console.log("Transferring aeroplane to screen", planeData.screen);
    io.emit("aeroplane-create", planeData);
  });

  socket.on("add-plane", function (data) {
    var destationdata =
      allpostionAirpots[Math.floor(Math.random() * allpostionAirpots.length)];
    data.source = findInArray(allpostionAirpots, function (airport) {
      return airport.label === data.label;
    });
    data.destation =
      destationdata.label !== data.source.label
        ? destationdata
        : allpostionAirpots[
            Math.floor(Math.random() * allpostionAirpots.length)
          ];
    io.emit("add-aeroplane", data);
    console.log("Adding aeroplane", data);
  });

  socket.on("add-plane-controller", function (data) {
    io.emit("add-aeroplane", data);
    console.log("Adding aeroplane", data);
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

  socket.on("send-command", function (data) {
    io.emit("command-plane", data);
    console.log("Sending command to plane", data);
  });

  socket.on("select-plane", function (key) {
    console.log("Selecting plane flutter", key);
    io.emit("select-aeroplane", { dir: key.dir, altitude: key.altitude });
    console.log("Selecting plane", key);
  });

  socket.on("submit-plane", function (key) {
    io.emit("submit-aeroplane", key);
    console.log("Selecting plane", key);
  });

  socket.on("airport-positions", function (data) {
    console.log("Received updated airport positions client:", data);

    for (var i = 0; i < data.length; i++) {
      var incoming = data[i];
      if (incoming.label === "ALT") {
        incoming.y -= 2;
      }
      var index = findIndexInArray(allpostionAirpots, function (existing) {
        return existing.label === incoming.label;
      });

      if (index !== -1) {
        allpostionAirpots[index].x = incoming.x;
        allpostionAirpots[index].y = incoming.y;
        allpostionAirpots[index].screen = incoming.screen;
      } else {
        allpostionAirpots.push(incoming);
      }
    }

    console.log("Updated all airport positions:", allpostionAirpots);
    io.emit("all-airport-positions", allpostionAirpots);
    socket.emit("fetch-airplanes", allpostionAirpots);
  });

  socket.on("get-airport-positions", function (maybeCallback) {
    if (typeof maybeCallback === "function") {
      maybeCallback(allpostionAirpots);
      console.log("take one ", allpostionAirpots);
    } else {
      socket.emit("fetch-airplanes", allpostionAirpots);
      console.log("take one ", allpostionAirpots);
      io.emit("aeroplane-data", planes);
    }
  });

  socket.on("fetch-airplanes-io", function (data) {
    socket.emit("fetch-airplanes", allpostionAirpots);
    var planesTakeoff = gneratetakeoffPlanes(allpostionAirpots);
    if (planesTakeoff) {
      io.emit("takeoff-planes", planesTakeoff);
      calltakeoff = true;
    }
  });

  socket.on("get-aeroplane", function (data) {
    var screenNumber = data.screenNumber;
    var airplanes = data.airplanes;

    if (typeof screenNumber !== "undefined" && Array.isArray(airplanes)) {
      planes[screenNumber] = airplanes;

      console.log(
        " Updated screen " +
          screenNumber +
          " with " +
          airplanes.length +
          " planes"
      );
      console.log("Full planes state now:", JSON.stringify(planes, null, 2));

      io.emit("aeroplane-data", planes);

      console.log("send to flutter ");
    } else {
      console.warn("Invalid airplane data received");
    }
  });

  socket.on("success-plane", function (data) {
    successCount += 1;
    io.emit("Completed", data);
    console.log("Success plane", data);
  });

  socket.on("postwidth", function (data) {
    console.log("Received updated airport width from server:", data);
    var index = findIndexInArray(allscreenwidth, function (existing) {
      return Object.keys(existing)[0] === String(data.screen);
    });

    var screenData = {};
    screenData[data.screen] = { data: data };

    if (index !== -1) {
      allscreenwidth[index] = screenData;
    } else {
      allscreenwidth.push(screenData);
    }
  });

  console.log("screen all", allscreenwidth);

  socket.on("get-screen-width", function (callback) {
    callback(allscreenwidth);
  });

  socket.on("warning-popup", function (data) {
    console.log("Received warning data:", data);
  });

  socket.on("update-origin-destination", function (data) {
    io.emit("update-origin-destination", data);
  });

  socket.on("update-heading-altitude", function (data) {
    io.emit("update-heading-altitude", data);
  });

  socket.on("deselect-plane", function (data) {
    io.emit("deselect-plane", data);
  });

  socket.on("error-popup", function (data) {
    if (data.conflict) {
      conflictCount += 1;
    } else if (data.error === "Wrong exit") {
      wrongExitCount += 1;
    } else if (data.badDeparture) {
      baddepartureCount += 1;
    }
    io.emit("error-popup", data);
  });

  function sleep(duration) {
    return new Promise(function (resolve) {
      setTimeout(resolve, duration);
    });
  }

  socket.on("disconnect", function () {
    console.log("User disconnected");
    socket.removeAllListeners();
  });

  socket.on("reconnect", function () {
    console.log("User reconnected");
  });

  socket.on("gameOver", function () {
    clearInterval(aeroplaneIntervalId);
    isGameRunning = false;
    aeroplaneIntervalId = null;
    if (isGameover) return;
    isGameover = true;
    io.emit("gameOverData", {
      successCount: successCount,
      conflictCount: conflictCount,
      wrongExitCount: wrongExitCount,
      baddepartureCount: baddepartureCount,
    });
  });

  socket.on("gameStart", function () {
    planes = {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
    };
    isGameover = false;
    startGamePlane();
    startCrossScreenConflictDetection();
    io.emit("gameStartData");
  });
  socket.on("gameStop", function () {
    clearInterval(aeroplaneIntervalId);
    aeroplaneIntervalId = null;
    isGameRunning = false;
    isPlaneAdded = false;
    successCount = 0;
    wrongExitCount = 0;
    conflictCount = 0;
    isGameover = false;
    stopCrossScreenConflictDetection();
    planes = {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
    };
    io.emit("gameStopData");
  });
  socket.on("gamePause", function () {
    clearInterval(aeroplaneIntervalId);
    aeroplaneIntervalId = null;
    isGameRunning = false;

    io.emit("gamePauseData");
  });

  socket.on("gameResume", function () {
    if (!isGameRunning) {
      startGamePlane();
      isGameRunning = true;
    }
    io.emit("gameResumeData");
    console.log("Game resumed");
  });

  socket.on("gameReset", function () {
    successCount = 0;
    conflictCount = 0;
    wrongExitCount = 0;
    io.emit("gameResetData");
    isGameover = false;
  });

  socket.on("heartbeat", function (data) {
    console.log("Heartbeat from screen", data.screenNumber, "State:", {
      isPaused: data.isPaused,
      isStopped: data.isStopped,
      isGameOver: data.isGameOver,
    });

    socket.emit("heartbeat_response", {
      serverTime: Date.now(),
      clientTime: data.timestamp,
    });
  });
});

server.listen(port, "0.0.0.0", function () {
  console.log("Listening on port " + port);
});

function getAdjacentScreens(screenNum) {
  var adjacent = [];

  if (nScreens === 3) {
    // 3-screen layout: 3 <-> 1( center ) <-> 2

    switch (screenNum) {
      case 1:
        adjacent = [3, 2];
        break;
      case 2:
        adjacent = [1];
        break;
      case 3:
        adjacent = [1];
        break;
    }
  } else if (nScreens === 5) {
    // 5-screen layout: 4 <→ 5 <→ 1 (center) <→ 2 <→ 3
    switch (screenNum) {
      case 1:
        adjacent = [5, 2];
        break;
      case 2:
        adjacent = [1, 3];
        break;
      case 3:
        adjacent = [2];
        break;
      case 4:
        adjacent = [5];
        break;
      case 5:
        adjacent = [4, 1];
        break;
    }
  }

  return adjacent;
}

function getScreenWidth(screenNum) {
  var screenEntry = findInArray(allscreenwidth, function (obj) {
    return obj[screenNum];
  });
  return screenEntry ? screenEntry[screenNum].data.width : 800;
}

function isNearScreenEdge(plane, screenWidth, edgeBuffer) {
  var nearLeftEdge = plane.x <= edgeBuffer;
  var nearRightEdge = plane.x >= screenWidth - edgeBuffer;

  return {
    nearLeftEdge: nearLeftEdge,
    nearRightEdge: nearRightEdge,
    isNearEdge: nearLeftEdge || nearRightEdge,
  };
}

function calCrossScreenDistance(
  planeA,
  planeB,
  screenAWidth,
  screenBWidth,
  isAToTheLeft
) {
  var adjustedX;

  if (isAToTheLeft) {
    adjustedX = screenAWidth - planeA.x + planeB.x;
  } else {
    adjustedX = planeA.x + (screenBWidth - planeB.x);
  }

  var distance = Math.sqrt(
    adjustedX * adjustedX + (planeA.y - planeB.y) * (planeA.y - planeB.y)
  );
  return distance;
}

function isScreenALeftOfB(screenA, screenB) {
  if (nScreens === 3) {
    if (screenA === 3 && screenB === 1) return true;
    if (screenA === 1 && screenB === 2) return true;
    return false;
  } else if (nScreens === 5) {
    if (screenA === 4 && screenB === 5) return true;
    if (screenA === 5 && screenB === 1) return true;
    if (screenA === 1 && screenB === 2) return true;
    if (screenA === 2 && screenB === 3) return true;
    return false;
  }
  return false;
}

function areMovingTowardsEachOtherCrossScreen(planeA, planeB) {
  if (
    planeA.dx === undefined ||
    planeA.dy === undefined ||
    planeB.dx === undefined ||
    planeB.dy === undefined
  ) {
    return false;
  }

  var aMovingRight = planeA.dx > 0;
  var aMovingLeft = planeA.dx < 0;
  var bMovingRight = planeB.dx > 0;
  var bMovingLeft = planeB.dx < 0;

  return (aMovingRight && bMovingLeft) || (aMovingLeft && bMovingRight);
}

function checkIfPlanesWillMeetAtBoundary(
  planeA,
  planeB,
  screenAWidth,
  screenBWidth,
  isALeftOfB
) {
  var timeA, timeB;

  if (isALeftOfB) {
    timeA =
      planeA.dx > 0
        ? (screenAWidth - planeA.x) / Math.abs(planeA.dx)
        : Infinity;
    timeB = planeB.dx < 0 ? planeB.x / Math.abs(planeB.dx) : Infinity;
  } else {
    timeA = planeA.dx < 0 ? planeA.x / Math.abs(planeA.dx) : Infinity;
    timeB =
      planeB.dx > 0
        ? (screenBWidth - planeB.x) / Math.abs(planeB.dx)
        : Infinity;
  }

  if (timeA === Infinity || timeB === Infinity) {
    return false;
  }

  var timeDifference = Math.abs(timeA - timeB);
  var maxTimeDifference = 100;

  var yAtBoundaryA = planeA.y + planeA.dy * timeA;
  var yAtBoundaryB = planeB.y + planeB.dy * timeB;
  var yDifferenceAtBoundary = Math.abs(yAtBoundaryA - yAtBoundaryB);

  return timeDifference < maxTimeDifference && yDifferenceAtBoundary < 80;
}

function checkCrossScreenConflicts() {
  if (isGameover || !isGameRunning) {
    return;
  }

  var edgeBuffer = 80;
  var conflictThreshold = 45;
  var warningThreshold = 120;
  var yPositionTolerance = 60;

  var newConflicts = new Set();
  var newWarnings = new Set();

  for (var screenA = 1; screenA <= nScreens; screenA++) {
    if (!planes[screenA] || planes[screenA].length === 0) continue;

    var adjacentScreens = getAdjacentScreens(screenA);
    var screenAWidth = getScreenWidth(screenA);

    for (var i = 0; i < adjacentScreens.length; i++) {
      var screenB = adjacentScreens[i];
      if (!planes[screenB] || planes[screenB].length === 0) continue;

      var screenBWidth = getScreenWidth(screenB);

      for (var j = 0; j < planes[screenA].length; j++) {
        var planeA = planes[screenA][j];
        var edgeInfoA = isNearScreenEdge(planeA, screenAWidth, edgeBuffer);

        if (!edgeInfoA.isNearEdge) continue;

        for (var k = 0; k < planes[screenB].length; k++) {
          var planeB = planes[screenB][k];
          var edgeInfoB = isNearScreenEdge(planeB, screenBWidth, edgeBuffer);

          if (!edgeInfoB.isNearEdge) continue;

          if (planeA.altitude !== planeB.altitude) continue;

          var yDifference = Math.abs(planeA.y - planeB.y);
          if (yDifference > yPositionTolerance) {
            continue;
          }

          var movingTowardsSameBoundary = false;
          var isALeftOfB = isScreenALeftOfB(screenA, screenB);

          if (isALeftOfB) {
            movingTowardsSameBoundary =
              edgeInfoA.nearRightEdge &&
              planeA.dx > 0 &&
              edgeInfoB.nearLeftEdge &&
              planeB.dx < 0;
          } else {
            movingTowardsSameBoundary =
              edgeInfoA.nearLeftEdge &&
              planeA.dx < 0 &&
              edgeInfoB.nearRightEdge &&
              planeB.dx > 0;
          }

          if (!movingTowardsSameBoundary) continue;

          var distance = calCrossScreenDistance(
            planeA,
            planeB,
            screenAWidth,
            screenBWidth,
            isALeftOfB
          );
          var pairKey = [planeA.label, planeB.label].sort().join("-");

          console.log(
            `Cross-screen check: ${planeA.label} (screen ${screenA}, x:${planeA.x}, y:${planeA.y}, dx:${planeA.dx}) vs ${planeB.label} (screen ${screenB}, x:${planeB.x}, y:${planeB.y}, dx:${planeB.dx}) - Distance: ${distance}, Y-diff: ${yDifference}`
          );

          if (distance < warningThreshold && distance >= conflictThreshold) {
            var willMeetAtBoundary = checkIfPlanesWillMeetAtBoundary(
              planeA,
              planeB,
              screenAWidth,
              screenBWidth,
              isALeftOfB
            );
            if (!willMeetAtBoundary) {
              console.log(
                `Skipping warning - planes won't meet at boundary: ${planeA.label} vs ${planeB.label}`
              );
              continue;
            }

            newWarnings.add(pairKey);

            if (!crossScreenWarnings.has(pairKey)) {
              crossScreenWarnings.add(pairKey);
              io.emit("cross-screen-warning", {
                error: `Warning: ${planeA.label} and ${planeB.label} may conflict at screen boundary.`,
                warning: `Warning: ${planeA.label} and ${planeB.label} may conflict at screen boundary.`,
                screenA: screenA,
                screenB: screenB,
                planeA: planeA.label,
                planeB: planeB.label,
                distance: distance,
              });
              console.log(
                `Cross-screen warning: ${planeA.label} (screen ${screenA}) and ${planeB.label} (screen ${screenB}) distance: ${distance}`
              );
            }
          }

          // Conflict zone check
          if (distance < conflictThreshold) {
            newConflicts.add(pairKey);

            if (!crossScreenConflicts.has(pairKey)) {
              crossScreenConflicts.add(pairKey);
              conflictCount += 1;
              io.emit("cross-screen-conflict", {
                conflict: true,
                error: `Crash between planes ${planeA.label} and ${planeB.label} across screens`,
                screenA: screenA,
                screenB: screenB,
                planeA: planeA.label,
                planeB: planeB.label,
                distance: distance,
              });
              console.log(
                `Cross-screen conflict: ${planeA.label} (screen ${screenA}) and ${planeB.label} (screen ${screenB}) distance: ${distance}`
              );
            }
          }
        }
      }
    }
  }

  // Clean up old conflicts and warnings
  var allCurrentPairs = new Set([...newConflicts, ...newWarnings]);

  for (var conflict of crossScreenConflicts) {
    if (!newConflicts.has(conflict)) {
      crossScreenConflicts.delete(conflict);
    }
  }

  for (var warning of crossScreenWarnings) {
    if (!newWarnings.has(warning)) {
      crossScreenWarnings.delete(warning);
    }
  }
}

function startCrossScreenConflictDetection() {
  if (crossScreenCheckInterval) {
    clearInterval(crossScreenCheckInterval);
  }

  crossScreenCheckInterval = setInterval(checkCrossScreenConflicts, 100);
  console.log("Started cross-screen conflict detection");
}

function stopCrossScreenConflictDetection() {
  if (crossScreenCheckInterval) {
    clearInterval(crossScreenCheckInterval);
    crossScreenCheckInterval = null;
  }

  crossScreenConflicts.clear();
  crossScreenWarnings.clear();
  console.log("Stopped cross-screen conflict detection");
}

function startGamePlane() {
  isGameRunning = true;
  aeroplaneIntervalId = setInterval(function () {
    if (isPlaneAdded) {
      return;
    }

    if (allpostionAirpots.length < 2) {
      console.log("Not enough airports to create a plane.");
      return;
    }

    var sourcedata =
      allpostionAirpots[Math.floor(Math.random() * allpostionAirpots.length)];
    var destationdata =
      allpostionAirpots[Math.floor(Math.random() * allpostionAirpots.length)];

    do {
      sourcedata =
        allpostionAirpots[Math.floor(Math.random() * allpostionAirpots.length)];
    } while (sourcedata.label === "ALT" || (lastSourceLabel != null && sourcedata.label === lastSourceLabel));

    do {
      destationdata =
        allpostionAirpots[Math.floor(Math.random() * allpostionAirpots.length)];
    } while (destationdata.label === sourcedata.label);

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
    io.emit("add-aeroplane", data);

    isPlaneAdded = true;
    setTimeout(function () {
      isPlaneAdded = false;
    }, 30000);
  }, intervalTime);
}

function gneratetakeoffPlanes(allAirports) {
  const planes = [];

  if (allAirports.length < 8) {
    console.log("Not enough airports to generate data.");
    return;
  }

  const source = allAirports.find((a) => a.label === "ALT");
  if (!source) {
    console.log("No ALT-labeled airport found for source.");
    return planes;
  }

  const usedDestinations = new Set();
  var attempts = 0;
  const maxAttempts = 50;

  while (planes.length < 5 && attempts < maxAttempts) {
    attempts++;

    const destination =
      allAirports[Math.floor(Math.random() * allAirports.length)];

    if (
      !destination ||
      destination.label === source.label ||
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
    console.warn(
      `Only ${planes.length} unique takeoff planes could be generated.`
    );
  }

  return planes;
}
