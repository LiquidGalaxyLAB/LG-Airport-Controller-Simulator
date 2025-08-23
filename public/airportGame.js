import {
  generateMasterMap,
  generateSlaveMapLayout2,
  generateSlaveMapLayout2_5,
  generateSlaveMapLayout3,
  generateSlaveMapLayout3_5,
  generateSlaveMapLayout4_5,
  generateSlaveMapLayout5,
  labelConfig,
  labelMap,
  LANDINGSVG,
  rotationongrid,
  RUNWAY,
  SVGSTRING,
  TOP_OFFESET,
  isGameOver,
  areMovingTowardsEachother,
  startTimer,
  stopTimer,
  pauseTimer,
  isPause,
  resumeTimer,
  isStopped,
} from "./functions.js";

let url = window.location.href;
let num = url.substring(url.length - 1);
let screenNumber = num,
  nScreens;

let gameOversend = false;
var gameCanvas = document.getElementById("gameCanvas");
var centerText = document.getElementById("center-text");
var centerText2 = document.getElementById("screen-text2");
var centerText3 = document.getElementById("screen-text3");
var centerText4 = document.getElementById("screen-text4");
var centerText5 = document.getElementById("screen-text5");
var headingData = document.getElementById("headingData");
var altitudeData = document.getElementById("altitudeData");
var errorData = document.getElementById("errorID");
var successData = document.getElementById("successID");
var commandData = document.getElementById("command");
var orgin = document.getElementById("origin");
var destination = document.getElementById("destination");
var gameover = document.getElementById("gameover");
var scoreID = document.getElementById("scoreID");
var confilct = document.getElementById("confilct");
var wrong = document.getElementById("wrong");
var bad = document.getElementById("bad");
var mainlogo = document.getElementById("mainlogo");
var socket = io();

// Start of LG Connection
const galaxyPort = 8111;
const ip = "lg1";
socket.on("reconnect", () => {
  console.log("Server restarted - reloading page");
  location.reload();
});

const HEIGHT = window.innerHeight - TOP_OFFESET;
const WIDTH = window.innerWidth - 10;
const labelPositions = [];
const canvas = document.getElementById("gameCanvas");

canvas.height = HEIGHT;
canvas.width = WIDTH;
const spacing = 45;
let rows = Math.floor(HEIGHT / spacing);
let cols = Math.floor(WIDTH / spacing);

const ctx = canvas.getContext("2d");

let currentMap = generateMasterMap(rows, cols);

let airplanes = [];

let takeoffdata = 0;
let frameCount = 0;

const airplaneImages = {
  white: null,
  red: null,
  takeLandOff: null,
  runway: null,
};

// Create images once during init to avoid repeated blob creation
function createAirplaneImages() {
  const whiteBlob = new Blob([SVGSTRING], {
    type: "image/svg+xml;charset=utf-8",
  });
  const redSVG = SVGSTRING.replace(/fill="[^"]+"/g, 'fill="red"');
  const redBlob = new Blob([redSVG], { type: "image/svg+xml;charset=utf-8" });
  const takeLandOff = new Blob([LANDINGSVG], {
    type: "image/svg+xml;charset=utf-8",
  });
  const runway = new Blob([RUNWAY], { type: "image/svg+xml;charset=utf-8" });

  const whiteUrl = URL.createObjectURL(whiteBlob);
  const redUrl = URL.createObjectURL(redBlob);
  const takeLandOffUrl = URL.createObjectURL(takeLandOff);
  const runwayUrl = URL.createObjectURL(runway);

  airplaneImages.white = new Image();
  airplaneImages.red = new Image();
  airplaneImages.takeLandOff = new Image();
  airplaneImages.runway = new Image();

  airplaneImages.white.src = whiteUrl;
  airplaneImages.red.src = redUrl;
  airplaneImages.takeLandOff.src = takeLandOffUrl;
  airplaneImages.runway.src = runwayUrl;
}

createAirplaneImages();

function screenSetup(screen) {
  nScreens = screen.nScreens;
  console.log(screenNumber);
  if (nScreens == 3) {
    currentMap =
      screenNumber == 1
        ? generateMasterMap(rows, cols)
        : screenNumber == 2
        ? generateSlaveMapLayout3(rows, cols, canvas)
        : generateSlaveMapLayout2(rows, cols, canvas);
  }

  if (nScreens == 5) {
    currentMap =
      screenNumber == 1
        ? generateMasterMap(rows, cols)
        : screenNumber == 3
        ? generateSlaveMapLayout5(rows, cols)
        : screenNumber == 2
        ? generateSlaveMapLayout3_5(rows, cols)
        : screenNumber == 5
        ? generateSlaveMapLayout4_5(rows, cols)
        : generateSlaveMapLayout2_5(rows, cols);
  }

  if (screenNumber == 1) {
    centerText.style.display = "flex";
    socket.emit("postwidth", {
      width: WIDTH - 60,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 2) {
    centerText3.style.display = "flex";
    socket.emit("postwidth", {
      width: WIDTH - 60,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 3) {
    centerText2.style.display = "flex";
    if (nScreens !== 5) {
      mainlogo.style.display = "block";
    }

    socket.emit("postwidth", {
      width: WIDTH - 60,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 4) {
    centerText4.style.display = "flex";
    if (nScreens == 5) {
      mainlogo.style.display = "block";
    }
    socket.emit("postwidth", {
      width: WIDTH - 60,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 5) {
    centerText5.style.display = "flex";
    socket.emit("postwidth", {
      width: WIDTH - 60,
      height: HEIGHT,
      screen: screenNumber,
    });
  }

  createGrid(currentMap);
}
socket.on("new-screen", screenSetup);
function onCreateplane(aeroplane) {
  if (Number(screenNumber) === Number(aeroplane.screen)) {
    const plane = {
      ...aeroplane,
      img: airplaneImages.white,
      dx: aeroplane.dx || -0.5,
      dy: aeroplane.dy || 0,
      rotation: aeroplane.rotation !== undefined ? aeroplane.rotation : 0,
      isondot: false,
    };

    const offX = drawMap.lastOffsetX ?? 0;
    const offY = drawMap.lastOffsetY ?? 0;
    const sp = drawMap.lastSpacing ?? spacing;

    // Snap planes coming from either direction, but only once
    if (!plane.isondot) {
      const col = Math.round((plane.x - offX) / sp);
      const row = Math.round((plane.y - offY) / sp);

      // Only snap if we get a valid grid position
      if (col >= 0 && col < cols && row >= 0 && row < rows) {
        plane.x = offX + col * sp;
        plane.y = offY + row * sp;
        plane.isondot = true;
        plane.lastdotcol = col;
        plane.lastdotrow = row;
      }
    }
    setLastoffSettrackingandSpeedDirection(plane);

    airplanes.push(plane);

    socket.emit("get-aeroplane", { airplanes, screenNumber });
  }
}

socket.on("aeroplane-create", onCreateplane);

function createGrid(row) {
  addAeroplane(row);
}

// === Draw entire map ===
function drawMap(row) {
  const dotRadius = 2;

  let actualRows = rows;
  let actualCols = cols;
  if (actualRows % 2 === 0) actualRows -= 1;
  if (actualCols % 2 === 0) actualCols -= 1;

  let actualSpacing = spacing;

  const offsetX = (WIDTH - actualCols * actualSpacing) / 2;
  const offsetY = (HEIGHT - actualRows * actualSpacing) / 2;
  drawMap.lastOffsetX = offsetX;
  drawMap.lastOffsetY = offsetY;
  drawMap.lastSpacing = actualSpacing;

  const textLabels = {};

  for (const key in row.points) {
    const pt = row.points[key];
    if (pt && labelMap[key]) {
      textLabels[`${pt.row},${pt.col}`] = labelMap[key];
    }
  }
  const map = row.map;
  for (let row = 0; row < map?.length; row++) {
    for (let col = 0; col < map[row]?.length; col++) {
      const x = offsetX + col * actualSpacing;
      const y = offsetY + row * actualSpacing;

      const key = `${row},${col}`;

      if (textLabels[key]) {
        if (
          !labelPositions.some(
            (p) => p.label === textLabels[key] && p.x === x && p.y === y
          )
        ) {
          labelPositions.push({
            label: textLabels[key],
            x: x,
            y: y,
            screen: parseInt(screenNumber),
          });
          socket.emit("airport-positions", labelPositions);
        }
        ctx.font = "20px Inter";
        ctx.fontWeight = "bold";
        ctx.fillStyle = "#e2e8f0";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        const PAD_TOP = 20;
        const PAD_BOTTOM = 20;
        // extra left padding for screen 2 to display proper airport
        const PAD_LEFT =
          Number(nScreens) === 5
            ? Number(screenNumber) === 4
              ? 35
              : 10
            : Number(screenNumber) === 2
            ? 35
            : 10;
        const PAD_RIGHT =
          Number(nScreens) === 5
            ? Number(screenNumber) === 5
              ? 35
              : 10
            : Number(screenNumber) === 3
            ? 35
            : 10;

        let textX = x;
        let textY = textLabels[key] === "ALT" ? y + 20 : y;
        textX = Math.max(PAD_LEFT, Math.min(canvas.width - PAD_RIGHT, textX));
        textY = Math.max(PAD_TOP, Math.min(canvas.height - PAD_BOTTOM, textY));

        ctx.fillText(textLabels[key], textX, textY);

        if (textLabels[key] === "ALT") {
          ctx.drawImage(
            airplaneImages.runway,
            x - airplaneImages.runway.width / 2,
            y - 8
          );
        }
      } else {
        ctx.beginPath();
        ctx.arc(x, y, dotRadius, 0, Math.PI * 2);

        if (map[row][col] === 1) {
          ctx.fillStyle = "#cbd5e1"; // white/gray
        } else {
          ctx.fillStyle = "#1C4EA6"; // base blue
        }

        ctx.fill();
      }
    }
  }
}

let characters = 65;
let previousConflicts = new Set();
const previousWarnings = new Set();
const planecheckWarnings = 5000;

function addAeroplane(row) {
  const map = row.map;

  function animate() {
    requestAnimationFrame(animate);

    if (isGameOver && !gameOversend && screenNumber == "1") {
      socket.emit("gameOver");
      gameOversend = true;
      return;
    }

    if (isGameOver) {
      return;
    }

    if (isPause) {
      return;
    }

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawMap(row);

    if (isStopped) {
      return;
    }

    const newConflicts = new Set();
    const newWarnings = new Set();

    for (const plane of airplanes) {
      plane.conflict = false;
    }

    for (const plane of airplanes) {
      if (
        (plane.altitude === 0 || plane.altitude === undefined) &&
        plane.isnew
      ) {
      } else {
        plane.x += plane.dx;
        plane.y += plane.dy;

        const offX = drawMap.lastOffsetX ?? 0;
        const offY = drawMap.lastOffsetY ?? 0;
        const sp = drawMap.lastSpacing ?? spacing;

        const colF = (plane.x - offX) / sp;
        const rowF = (plane.y - offY) / sp;

        const tol = Math.max(2, sp * 0.08);
        const nearCol = Math.abs((colF - Math.round(colF)) * sp) < tol;
        const nearRow = Math.abs((rowF - Math.round(rowF)) * sp) < tol;
        const nearestCol = Math.round(colF);
        const nearestRow = Math.round(rowF);
        const reachedNewDot =
          nearCol &&
          nearRow &&
          (nearestCol !== plane.lastdotcol || nearestRow !== plane.lastdotrow);

        if (reachedNewDot) {
          plane.x = offX + nearestCol * sp;
          plane.y = offY + nearestRow * sp;
          plane.lastdotcol = nearestCol;
          plane.lastdotrow = nearestRow;
          plane.isondot = true;
        } else {
          plane.isondot = false;
        }
      }
    }

    for (let i = 0; i < airplanes.length; i++) {
      for (let j = i + 1; j < airplanes.length; j++) {
        const a = airplanes[i];
        const b = airplanes[j];

        const distance = Math.sqrt((a.x - b.x) ** 2 + (a.y - b.y) ** 2);
        const conflictThreshold = 35;
        const warningThreshold = 150;

        const pairKey = [a.label, b.label].sort().join("-");

        if (a.altitude !== b.altitude) {
          continue;
        }

        if (
          distance < warningThreshold &&
          distance >= conflictThreshold &&
          areMovingTowardsEachother(a, b)
        ) {
          a.conflict = true;
          b.conflict = true;

          newWarnings.add(pairKey);

          if (!previousWarnings.has(pairKey)) {
            previousWarnings.add(pairKey);
            socket.emit("error-popup", {
              error: `Warning: ${a.label} and ${b.label} are too close.`,
              warning: `Warning: ${a.label} and ${b.label} are too close.`,
              data: previousWarnings,
            });
          }
        }

        if (distance < conflictThreshold) {
          if (!previousConflicts.has(pairKey)) {
            socket.emit("error-popup", {
              conflict: true,
              error: `Crash between planes ${a.label} and ${b.label}`,
            });

            const indexA = airplanes.indexOf(a);
            const indexB = airplanes.indexOf(b);
            airplanes.splice(indexA, 1);
            airplanes.splice(indexB > indexA ? indexB - 1 : indexB, 1);
            socket.emit("get-aeroplane", { airplanes, screenNumber });
            previousConflicts.add(pairKey);
            break;
          }
          newConflicts.add(pairKey);
        }
      }
    }
    for (const pairKey of [...previousConflicts]) {
      if (!newConflicts.has(pairKey)) {
        previousConflicts.delete(pairKey);
      }
    }

    for (const pairKey of [...previousWarnings]) {
      if (!newWarnings.has(pairKey)) {
        previousWarnings.delete(pairKey);
      }
    }
    newWarnings.clear();

    for (const plane of airplanes) {
      let transferred;
      if (nScreens == 3) {
        transferred = handleTraverseAeroplane(plane, screenNumber);
      } else {
        transferred = handleTraverseAeroplane5(plane, screenNumber);
      }
      if (transferred) continue;

      if (plane.conflict) {
        plane.img = airplaneImages.red;
      } else {
        plane.img = airplaneImages.white;
      }
      ctx.save();
      ctx.translate(plane.x, plane.y);

      if (plane.selected && plane.rotationstackPreview.length > 0) {
        // Apply preview of future rotation
        let tempRotation = plane.rotation;
        for (const cmd of plane.rotationstackPreview) {
          if (cmd === "left") tempRotation -= 45;
          else if (cmd === "right") tempRotation += 45;
        }
        ctx.rotate(degToRad(tempRotation));
      } else {
        ctx.rotate(degToRad(plane.rotation));
      }

      if (plane.takeoff && frameCount % 180 === 0) {
        plane.takeoff = false;
      }

      // rotation
      else if (!plane.takeoff && rotationongrid(plane)) {
        const command = plane.rotationstack.shift();
        console.log(
          `Rotating plane ${plane.rotation} at snapped position (${plane.x}, ${plane.y})`
        );
        if (command === "left") {
          plane.rotation -= 45;
        } else if (command === "right") {
          plane.rotation += 45;
        }
        setLastoffSettrackingandSpeedDirection(plane);
      } else if (
        plane.previousAltitude !== plane.altitude &&
        plane.altitude > plane.previousAltitude &&
        frameCount % 180 === 0
      ) {
        plane.previousAltitude = plane.previousAltitude + 1000;
        console.log("plus", plane.previousAltitude);
      } else if (
        plane.previousAltitude !== plane.altitude &&
        plane.altitude < plane.previousAltitude &&
        frameCount % 180 === 0
      ) {
        plane.previousAltitude = plane.previousAltitude - 1000;
        console.log("minus", plane.previousAltitude);
      }

      //check location
      const destination = plane.destation;
      if (
        destination.screen === plane.screen &&
        Math.abs(destination.x - plane.x) < 10 &&
        Math.abs(destination.y - plane.y) < 10
      ) {
        if (
          plane.destation.label === "ALT" &&
          plane.altitude !== 0 &&
          plane.heading !== 0
        ) {
          ctx.restore();
          return;
        } else if (plane.destation.label !== "ALT" && plane.altitude !== 4000) {
          airplanes.splice(airplanes.indexOf(plane), 1);
          socket.emit("error-popup", {
            badDeparture: true,
            error: "Bad departure for plane " + plane.label,
          });
          ctx.restore();
          return;
        }

        console.log(`Plane reached destination: ${plane.label}`);
        var sData = "Plane reached destination " + plane.label;
        socket.emit("success-plane", { sData });
        airplanes.splice(airplanes.indexOf(plane), 1);
        socket.emit("get-aeroplane", { airplanes, screenNumber });
      }

      ctx.drawImage(plane.img, -20, -20);
      ctx.restore();

      ctx.save();
      ctx.translate(plane.x, plane.y);
      ctx.fillStyle = plane.selected ? "#FFFF00" : "#FFFFFF";
      ctx.textBaseline = "middle";
      ctx.fillText(plane.label, -10, 40);
      if (plane.previousAltitude !== 0) {
        ctx.fillText(plane.previousAltitude, -11, 60);
      }
      ctx.restore();
    }
    frameCount++;
  }
  animate();
}

let aeroplanename = null;
function getCharater(data) {
  let name = String.fromCharCode(characters);
  characters++;
  name += data.source.label.charAt(0);
  name += data.destation.label.charAt(0);
  return name;
}

function handleTraverseAeroplane(plane, screenNumber) {
  const edgeBuffer = 50;

  if (plane.x > canvas.width - edgeBuffer || plane.x < edgeBuffer) {
    socket.emit("check-transfer-conflict", {
      plane: plane,
      fromScreen: screenNumber,
      direction: plane.x > canvas.width - edgeBuffer ? "right" : "left",
    });
  }

  if (plane.x > canvas.width) {
    if (screenNumber == 1) {
      // middle → right
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 2,
      });
    } else if (screenNumber == 2) {
      // left → middle
      socket.emit("error-popup", {
        error: "Wrong exit",
      });
    } else if (screenNumber == 3) {
      // right → wrap to left
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 1,
      });
    }
    airplanes.splice(airplanes.indexOf(plane), 1);
    socket.emit("get-aeroplane", { airplanes, screenNumber });
    return true;
  }

  if (plane.x < 0) {
    if (screenNumber == 1) {
      // middle → left
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -3,
        screen: 3,
      });
    } else if (screenNumber == 2) {
      // left → wrap to right
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -1,
        screen: 1,
      });
    } else if (screenNumber == 3) {
      // right → middle
      socket.emit("error-popup", {
        error: "Wrong exit",
      });
    }
    airplanes.splice(airplanes.indexOf(plane), 1);
    socket.emit("get-aeroplane", { airplanes, screenNumber });
    return true;
  }
  if (plane.y > canvas.height) {
    socket.emit("error-popup", {
      error: "Wrong exit",
    });
    airplanes.splice(airplanes.indexOf(plane), 1);
    socket.emit("get-aeroplane", { airplanes, screenNumber });
    return true;
  }

  if (plane.y < 0) {
    socket.emit("error-popup", {
      error: "Wrong exit",
    });
    airplanes.splice(airplanes.indexOf(plane), 1);
    socket.emit("get-aeroplane", { airplanes, screenNumber });
    return true;
  }

  return false;
}

function handleTraverseAeroplane5(plane, screenNumber) {
  const edgeBuffer = 50;

  if (plane.x > canvas.width - edgeBuffer || plane.x < edgeBuffer) {
    socket.emit("check-transfer-conflict", {
      plane: plane,
      fromScreen: screenNumber,
      direction: plane.x > canvas.width - edgeBuffer ? "right" : "left",
    });
  }

  if (plane.x > canvas.width) {
    if (screenNumber == 1) {
      // middle → right
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 2,
      });
    } else if (screenNumber == 3) {
      // left → middle
      socket.emit("error-popup", {
        error: "Wrong exit",
      });
    } else if (screenNumber == 5) {
      // left → middle
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 1,
      });
    } else if (screenNumber == 2) {
      // left → middle
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 3,
      });
    } else if (screenNumber == 4) {
      // right → wrap to left
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 5,
      });
    }
    airplanes.splice(airplanes.indexOf(plane), 1);
    socket.emit("get-aeroplane", { airplanes, screenNumber });
    return true;
  }

  if (plane.x < 0) {
    if (screenNumber == 1) {
      // middle → left
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -5,
        screen: 5,
      });
    } else if (screenNumber == 3) {
      // right → 1
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -2,
        screen: 2,
      });
    } else if (screenNumber == 5) {
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -4,
        screen: 4,
      });
      // left → wrap to right
    } else if (screenNumber == 2) {
      // right → 1
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -1,
        screen: 1,
      });
    } else if (screenNumber == 4) {
      // right → 3
      socket.emit("error-popup", {
        error: "Wrong exit",
      });
    }
    airplanes.splice(airplanes.indexOf(plane), 1);
    socket.emit("get-aeroplane", { airplanes, screenNumber });
    return true;
  }
  if (plane.y > canvas.height) {
    socket.emit("error-popup", {
      error: "Wrong exit",
    });
    airplanes.splice(airplanes.indexOf(plane), 1);
    socket.emit("get-aeroplane", { airplanes, screenNumber });
    return true;
  }

  if (plane.y < 0) {
    socket.emit("error-popup", {
      error: "Wrong exit",
    });
    airplanes.splice(airplanes.indexOf(plane), 1);
    socket.emit("get-aeroplane", { airplanes, screenNumber });
    return true;
  }

  return false;
}

function postionAeroplane(data) {
  const label = data.source.label;
  const config = labelConfig[label] || { angle: 0 };
  const speed = 0.5;

  const rad = (config.angle * Math.PI) / 180;
  const dx = -Math.cos(rad) * speed;
  const dy = -Math.sin(rad) * speed;
  const newAeroplane = {
    x: data.x,
    y: data.y,
    label: getCharater(data),
    screen: Number(data.source.screen) || 1,
    dx: dx,
    dy: dy,
    rotation: config.angle,
    selected: false,
    altitude: data.label === "ALT" ? 0 : 4000,
    previousAltitude: data.label === "ALT" ? 0 : 4000,
    conflict: false,
    takeoff: false,
    landoff: false,
    rotationstack: [],
    isnew: data.label === "ALT" ? true : false,
    heading: config.angle || 0,
    rotationstackPreview: [],
    destation: data.destation || { label: "WSH", x: 358.5, y: 26.5, screen: 2 }, // if any error for that why set manually ,
    source: data.source || { label: "ALT", x: 293.5, y: 341.5, screen: 1 },
    isondot: true,
  };
  if (Number(screenNumber) === Number(data.source.screen)) {
    socket.emit("create-aeroplane", newAeroplane);
  }
  console.log("Sent create-aeroplane event:", newAeroplane);
  return;
}

const degToRad = (deg) => (deg * Math.PI) / 180;

// Dot tracking
const DOT_STEP_FRAMES = 90;

function setLastoffSettrackingandSpeedDirection(plane) {
  const sp = drawMap.lastSpacing || spacing;
  const perAxis = sp / DOT_STEP_FRAMES;
  const rot = ((plane.rotation % 360) + 360) % 360;
  const norm = (Math.round(rot / 45) * 45) % 360;

  let dx = 0;
  let dy = 0;

  switch (norm) {
    case 0:
      dx = -perAxis;
      dy = 0;
      break;
    case 45:
      dx = -perAxis;
      dy = -perAxis;
      break;
    case 90:
      dx = 0;
      dy = -perAxis;
      break;
    case 135:
      dx = perAxis;
      dy = -perAxis;
      break;
    case 180:
      dx = perAxis;
      dy = 0;
      break;
    case 225:
      dx = perAxis;
      dy = perAxis;
      break;
    case 270:
      dx = 0;
      dy = perAxis;
      break;
    case 315:
      dx = -perAxis;
      dy = perAxis;
      break;
  }
  plane.dx = dx;
  plane.dy = dy;
}

socket.on("add-aeroplane", postionAeroplane);

function updatePlane(data) {
  const plane = airplanes.find((p) => p.selected === true);
  if (!plane) return;

  aeroplanename = plane.label;

  if (data.dir === "left" || data.dir === "right") {
    const lastRotation =
      plane.rotationstackPreview[plane.rotationstackPreview.length - 1];

    if (
      (data.dir === "left" && lastRotation === "right") ||
      (data.dir === "right" && lastRotation === "left")
    ) {
      plane.rotationstackPreview.pop();
    } else {
      plane.rotationstackPreview.push(data.dir);
    }
  }

  setLastoffSettrackingandSpeedDirection(plane);

  plane.altitude = data.altitude;
}
socket.on("update-plane", updatePlane);

function selectPlane(data) {
  airplanes.forEach((plane) => (plane.selected = false));
  const plane = airplanes.find((plane) => plane.label === data.dir);
  if (plane) {
    aeroplanename = plane.label;

    socket.emit("update-origin-destination", {
      origin: plane.source.label,
      destination: plane.destation.label,
      screen: nScreens == 3 ? "2" : "4",
    });

    plane.altitude = data.altitude;

    socket.emit("update-heading-altitude", {
      heading: plane.heading,
      altitude: plane.altitude || 1000,
      screen: nScreens == 3 ? "3" : "5",
    });
    plane.selected = true;
    console.log(`Selected plane: ${plane.label}`);
  }
}
socket.on("select-aeroplane", selectPlane);

socket.on("update-origin-destination", (data) => {
  console.log(data);
  orgin.textContent = data.origin;
  destination.textContent = data.destination;
});

socket.on("update-heading-altitude", (data) => {
  console.log(data);
  headingData.textContent = data.heading;
  altitudeData.textContent = data.altitude;
});

let errorTimeout;
socket.on("error-popup", (data) => {
  console.log(data);
  if (data.warning) {
    errorData.style.color = "yellow";
  }
  errorData.textContent = data.error;
  errorData.style.opacity = 1;
  if (errorTimeout) {
    clearTimeout(errorTimeout);
  }
  errorTimeout = setTimeout(() => {
    errorData.style.opacity = 0;
    errorData.style.color = "FF0000";
    errorTimeout = null;
  }, 5000);
  return;
});

function submitPlane(data) {
  const plane = airplanes.find((plane) => plane.label === data.label);
  if (plane) {
    plane.rotationstack = [];
    plane.rotationstack.push(...plane.rotationstackPreview);
    plane.rotationstackPreview = [];
    plane.altitude = data.altitude;
    plane.selected = false;
    plane.heading = Math.abs(data.heading);
    plane.takeoff = data.takeoff;
    plane.isnew = data.isnew;

    socket.emit("update-heading-altitude", {
      heading: plane.heading === 405 ? "HOLD" : plane.heading,
      altitude: plane.altitude,
      screen: nScreens == 3 ? "3" : "5",
    });
    const scr = plane.screen;
    airplanes.forEach((p) =>
      console.log(`Before emit: ${p.label} heading=${p.heading}`)
    );
    socket.emit("get-aeroplane", { airplanes, screenNumber: scr });
    console.log(`submited plane : ${plane.label}`);
  }
}
socket.on("submit-aeroplane", submitPlane);

let commandtimeout;
socket.on("command-plane", (data) => {
  if (screenNumber !== "1") return;
  commandData.style.opacity = "1";
  commandData.textContent = data;
  if (commandtimeout) {
    clearTimeout(commandtimeout);
  }
  commandtimeout = setTimeout(() => {
    commandData.style.opacity = 0;
    commandtimeout = null;
  }, 5000);
});

let successDataTimer;
socket.on("Completed", (data) => {
  successData.textContent = data.sData;
  successData.style.opacity = "1";
  if (successDataTimer) {
    clearTimeout(successDataTimer);
  }
  successDataTimer = setTimeout(() => {
    successData.style.opacity = 0;
    successDataTimer = null;
  }, 5000);
});

socket.on("gameOverData", (data) => {
  stopTimer();
  characters = 65;
  airplanes = [];
  if (
    (nScreens !== 3 && screenNumber == "3") ||
    (nScreens !== 5 && screenNumber == "4")
  ) {
    mainlogo.style.display = "block";
  }
  if (screenNumber !== "1") return;
  gameover.style.display = "block";
  scoreID.textContent = data.successCount;
  confilct.textContent = data.conflictCount;
  wrong.textContent = data.wrongExitCount;
  bad.textContent = data.baddepartureCount;
});

socket.on("disconnect", (reason) => {
  console.log(" Disconnected");
});

socket.on("gameStartData", (reason) => {
  gameOversend = false;
  mainlogo.style.display = "none";
  gameover.style.display = "none";
  resumeTimer();
  if (screenNumber !== "1") return;
  startTimer();
});

socket.on("gameStopData", (reason) => {
  gameOversend = false;
  if (
    (nScreens !== 3 && screenNumber == "3") ||
    (nScreens !== 5 && screenNumber == "4")
  ) {
    mainlogo.style.display = "block";
  }
  airplanes.length = 0;
  characters = 65;
  aeroplanename = null;
  frameCount = 0;

  stopTimer();
});
socket.on("gamePauseData", (reason) => {
  pauseTimer();
});

socket.on("gameResumeData", () => {
  startTimer();
});

// Cross-screen conflict handlers
socket.on("cross-screen-warning", (data) => {
  console.log("Cross-screen warning received:", data);

  for (const plane of airplanes) {
    if (plane.label === data.planeA || plane.label === data.planeB) {
      plane.conflict = true;
    }
  }

  errorData.style.color = "yellow";
  errorData.textContent = data.error;
  errorData.style.opacity = 1;

  if (errorTimeout) {
    clearTimeout(errorTimeout);
  }
  errorTimeout = setTimeout(() => {
    errorData.style.opacity = 0;
    errorData.style.color = "#FF0000";
    errorTimeout = null;
  }, 5000);
});

socket.on("cross-screen-conflict", (data) => {
  console.log("Cross-screen conflict received:", data);

  for (let i = airplanes.length - 1; i >= 0; i--) {
    const plane = airplanes[i];
    if (plane.label === data.planeA || plane.label === data.planeB) {
      airplanes.splice(i, 1);
    }
  }

  socket.emit("get-aeroplane", { airplanes, screenNumber });

  errorData.style.color = "#FF0000";
  errorData.textContent = data.error;
  errorData.style.opacity = 1;

  if (errorTimeout) {
    clearTimeout(errorTimeout);
  }
  errorTimeout = setTimeout(() => {
    errorData.style.opacity = 0;
    errorTimeout = null;
  }, 5000);
});

socket.on("deselect-plane", (data) => {
  console.log("Deselecting plane", data);
  const plane = airplanes.find((plane) => plane.label === data.label);
  if (plane) {
    plane.selected = false;
    plane.rotationstackPreview = [];
    socket.emit("get-aeroplane", { airplanes, screenNumber });
  }
});

socket.on("gameResetData", handlereset);

function handlereset() {
  gameOversend = false;

  airplanes.length = 0;
  characters = 65;
  aeroplanename = null;
  frameCount = 0;

  gameover.style.display = "none";
  mainlogo.style.display = "none";

  socket.emit("gameStop");

  setTimeout(() => {
    socket.emit("gameStart");
    socket.emit("fetch-airplanes-io");
    console.log("✅ Restart sequence completed");
  }, 500);
}

let heartbeatInterval;

function startHeartbeat() {
  if (heartbeatInterval) clearInterval(heartbeatInterval);

  heartbeatInterval = setInterval(() => {
    if (socket.connected) {
      socket.emit("heartbeat", {
        screenNumber: screenNumber,
        isPaused: isPause,
        isStopped: isStopped,
        isGameOver: isGameOver,
        timestamp: Date.now(),
      });
    }
  }, 5000);
}

function stopHeartbeat() {
  if (heartbeatInterval) {
    clearInterval(heartbeatInterval);
    heartbeatInterval = null;
  }
}

startHeartbeat();
