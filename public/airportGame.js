import {
  generateMasterMap,
  generateSlaveMapLayout2,
  generateSlaveMapLayout2_5,
  generateSlaveMapLayout3,
  generateSlaveMapLayout3_5,
  generateSlaveMapLayout4_5,
  generateSlaveMapLayout5,
  infobar,
  infobar2,
  infobar3,
  labelConfig,
  labelMap,
  LANDINGSVG,
  RUNWAY,
  SVGSTRING,
  TOP_OFFESET,
} from "./functions.js";

let url = window.location.href;
let num = url.substring(url.length - 1);
let screenNumber = num,
  nScreens,
  allFoodsEaten = {};
var centerText = document.getElementById("center-text");

var socket = io();

// Start of LG Connection
const galaxyPort = 5433;
const ip = "lg1";
const lgSocket = io(`http://${ip}:${galaxyPort}`);
lgSocket.on("reset", () => {
  const url = window.location.href;
  const num = url.substring(url.length - 1);
  window.location.href = `http://${ip}:${galaxyPort}/galaxy/basic/screensaver?num=${num}`;
});
// End of LG Connection

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

const airplanes = [];

let takeoffdata = 0;
let frameCount = 0;

// Pre-create airplane images to avoid repeated blob creation
const airplaneImages = {
  white: null,
  red: null,
  takeLandOff: null,
  runway: null,
};

// Create images once during initialization
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

// Initialize images
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
        ? generateSlaveMapLayout4_5(rows, cols)
        : screenNumber == 2
        ? generateSlaveMapLayout3_5(rows, cols)
        : screenNumber == 5
        ? generateSlaveMapLayout2_5(rows, cols)
        : generateSlaveMapLayout5(rows, cols);
  }

  if (screenNumber == 1) {
    infobar(centerText);
    socket.emit("postwidth", {
      width: WIDTH,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 2) {
    infobar2(centerText, nScreens === 3 ? "screen" : "none");
    socket.emit("postwidth", {
      width: WIDTH,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 3) {
    infobar3(centerText, nScreens === 3 ? "screen" : "none");
    socket.emit("postwidth", {
      width: WIDTH,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 4) {
    if (nScreens == 5) infobar2(centerText, "screen");
    socket.emit("postwidth", {
      width: WIDTH,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 5) {
    if (nScreens == 5) infobar3(centerText, "screen");
    socket.emit("postwidth", {
      width: WIDTH,
      height: HEIGHT,
      screen: screenNumber,
    });
  }

  createGrid(currentMap);
}
socket.on("new-screen", screenSetup);
function onCreateplane(aeroplane) {
  if (Number(screenNumber) === Number(aeroplane.screen)) {
    airplanes.push({
      ...aeroplane,
      img: airplaneImages.white,
      dx: aeroplane.dx || -0.5,
      dy: aeroplane.dy || 0,
      rotation: aeroplane.rotation !== undefined ? aeroplane.rotation : 0,
    });

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

  // Ensure odd numbers
  if (rows % 2 === 0) rows -= 1;
  if (cols % 2 === 0) cols -= 1;

  // Center grid
  const offsetX = (WIDTH - cols * spacing) / 2;
  const offsetY = (HEIGHT - rows * spacing) / 2;

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
      const x = offsetX + col * spacing;
      const y = offsetY + row * spacing;

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
          // (textLabels[key] === 'ALT') ? y - 25 : y,
          socket.emit("airport-positions", labelPositions);
        }
        ctx.font = "20px Inter";
        ctx.fontWeight = "bold";
        ctx.fillStyle = "#e2e8f0";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        if (textLabels[key] === "ALT") {
          ctx.drawImage(airplaneImages.runway, x - 60, y - 25); // 25 pixels above
        }
        ctx.fillText(textLabels[key], x, y);
      } else {
        // Draw dot normally
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
let previousConflicts = new Set(); // Track plane pairs that were already alerted

function addAeroplane(row) {
  const map = row.map;

  function animate() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawMap(row);

    const newConflicts = new Set();

    // Reset conflict state
    for (const plane of airplanes) {
      plane.conflict = false;
    }

    // Check all pairs for conflict
    for (let i = 0; i < airplanes.length; i++) {
      for (let j = i + 1; j < airplanes.length; j++) {
        const a = airplanes[i];
        const b = airplanes[j];

        const dx = a.x - b.x;
        const dy = a.y - b.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        const conflictThreshold = 50;

        if (distance < conflictThreshold) {
          a.conflict = true;
          b.conflict = true;

          const pairKey = [a.label, b.label].sort().join("-");

          // Alert if this conflict is new
          if (!previousConflicts.has(pairKey)) {
            socket.emit("error-popup", {
              error: "Conflict",
            });
            // alert(`⚠️ Conflict detected between planes ${a.label} and ${b.label}`);
            previousConflicts.add(pairKey);
          }

          newConflicts.add(pairKey);
        }
      }
    }

    // Remove resolved conflicts from previousConflicts
    for (const pairKey of [...previousConflicts]) {
      if (!newConflicts.has(pairKey)) {
        previousConflicts.delete(pairKey);
        socket.emit("error-popup", {
          error: "",
        });
      }
    }

    for (const plane of airplanes) {
      plane.x += plane.dx;
      plane.y += plane.dy;

      let transferred;
      if (nScreens == 3) {
        transferred = handleTraverseAeroplane(plane, screenNumber);
      } else {
        transferred = handleTraverseAeroplane5(plane, screenNumber);
      }
      if (transferred) continue;

      // Set image color based on conflict status
      // plane.img = plane.conflict ? ctx.drawImage(airplaneImages.red,-20,-20) : airplaneImages.white;

      // plane.img = plane.altitude === 0 ? airplaneImages.takeLandOff : airplaneImages.white;

      if (plane.conflict) {
        plane.img = airplaneImages.red;
      } else if (plane.altitude === 0) {
        plane.img = airplaneImages.takeLandOff;
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

      if (plane.takeoff) {
        if (frameCount % 20 === 0 && takeoffdata < 40) {
          takeoffdata += 5;
          takeoffdata === 40
            ? (plane.altitude = 1000,
              takeoffdata = 0,
               plane.takeoff = false,
               socket.emit("get-aeroplane", { airplanes, screenNumber:plane.screen })
              )
            : null;
        }
        ctx.rotate(degToRad(takeoffdata));
        const angleRad = degToRad(takeoffdata - 180);

        plane.dx = Math.cos(angleRad) * 0.5;
        plane.dy = Math.sin(angleRad) * 0.5;
      }

      // rotation
      else if (
        frameCount % 100 === 0 &&
        plane.rotationstack.length > 0 &&
        !plane.selected
      ) {
        const command = plane.rotationstack.shift(); // remove first

        console.log(`Rotating plane ${plane.rotation} `);
        if (command === "left") {
          plane.rotation -= 45;
        } else if (command === "right") {
          plane.rotation += 45;
        }

        const angleRad = degToRad(plane.rotation - 180);
        plane.dx = Math.cos(angleRad) * 0.5;
        plane.dy = Math.sin(angleRad) * 0.5;
      }

      //check location
      const destination = plane.destation;
      if (
        destination.screen === plane.screen &&
        Math.abs(destination.x - plane.x) < 10 &&
        Math.abs(destination.y - plane.y) < 10
      ) {
        console.log(`✔ Plane reached destination: ${plane.label}`);
        alert(`✔ Plane reached destination : ${plane.label}`);
        airplanes.splice(airplanes.indexOf(plane), 1);
        socket.emit("get-aeroplane", { airplanes, screenNumber });
      }
      if (plane.heading > 90 && plane.heading < 270 && plane.altitude === 0) {
        ctx.scale(1, -1); // Flip vertically to prevent upside down
      }

      ctx.drawImage(plane.img, -20, -20);
      ctx.restore();

      ctx.save();
      ctx.translate(plane.x, plane.y);
      ctx.fillStyle = plane.selected ? "#FF0000" : "#fff";
      ctx.fillText(plane.label, -10, 40);
      ctx.restore();
    }
    frameCount++;
    requestAnimationFrame(animate);
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

  // const randomInd = Math.floor(Math.random() * characters.length);
  // const character = characters[randomInd];
  // return character;
}

// document.addEventListener("keydown", (e) => {

//   switch (e.key) {
//     case "ArrowUp":

//   }
//   console.log("Pressed:", e.key);

//   if (aeroplanename === null) {
//     return;
//   }

//   switch (e.key) {
//     case "ArrowUp":
//       airplanes[aeroplanename].altitude > 5001?airplanes[aeroplanename].altitude += 1000 : null;
//       break;
//     case "ArrowDown":
//       airplanes[aeroplanename].altitude < 5001?airplanes[aeroplanename].altitude -= 1000 : null; ;
//       break;
//     case "ArrowLeft":
//       airplanes[aeroplanename].dx = -1;
//       break;
//     case "ArrowRight":
//       airplanes[aeroplanename].dx = 1;
//       break;
//     case "t":
//       console.log("takeoff");
//       airplanes[aeroplanename].altitude = 0;
//       airplanes[aeroplanename].takeoff = true;
//       airplanes[aeroplanename].landoff = false;
//       break;
//     case "l":
//     console.log("landed ");
//     takeoffdata = 0;
//     airplanes[aeroplanename].altitude = 1;
//     airplanes[aeroplanename].takeoff = false;
//     airplanes[aeroplanename].landoff = true;

//     break;
//     case "Escape":
//       aeroplanename = null;
//       break;
//   }
// });

function handleTraverseAeroplane(plane, screenNumber) {
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
      // alert("Wrong exit");
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
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 1,
      });
    } else if (screenNumber == 5) {
      // left → middle
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 3,
      });
    } else if (screenNumber == 2) {
      // left → middle
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 4,
      });
    } else if (screenNumber == 4) {
      // right → wrap to left
      socket.emit("error-popup", {
        error: "Wrong exit",
      });
      // alert("Wrong exit");
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
    } else if (screenNumber == 3) {
      // right → 1
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -5,
        screen: 5,
      });
    } else if (screenNumber == 5) {
      socket.emit("error-popup", {
        error: "Wrong exit",
      });
      // confirm("Wrong exit");
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
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -2,
        screen: 2,
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
  const label = data.source.label; // ensure uppercase
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
    altitude: data.label === "ALT" ? 0 : 1000,
    conflict: false,
    takeoff: data.label === "ALT" ? true : false,
    landoff: false,
    rotationstack: [],
    heading: 0,
    rotationstackPreview: [],
    destation: data.destation || { label: "WSH", x: 358.5, y: 26.5, screen: 2 },
    source: data.source || { label: "ALT", x: 293.5, y: 341.5, screen: 1 },
  };
  if (Number(screenNumber) === Number(data.source.screen)) {
    socket.emit("create-aeroplane", newAeroplane);
  }
  console.log("Sent create-aeroplane event:", newAeroplane);
  return;
}

const degToRad = (deg) => (deg * Math.PI) / 180;

// Listen for 'add-aeroplane' event and create the plane
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
      // Canceling out opposite directions
      plane.rotationstackPreview.pop();

      // Reverse the heading change based on what we're canceling
      // if (data.dir === "left") {
      //   plane.heading = plane.heading + 45; // Canceling a right turn, so add back
      // } else {
      //   plane.heading = plane.heading - 45; // Canceling a left turn, so subtract back
      // }
    } else {
      // Adding a new direction
      plane.rotationstackPreview.push(data.dir);

      // // Change heading based on direction
      // if (data.dir === "left") {
      //   plane.heading = plane.heading - 45; // Left turn decreases heading
      // } else {
      //   plane.heading = plane.heading + 45; // Right turn increases heading
      // }
    }
  }

  const angleRad = degToRad(plane.rotation - 180);
  plane.dx = Math.cos(angleRad) * 0.5;
  plane.dy = Math.sin(angleRad) * 0.5;

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
      altitude: plane.altitude,
      screen: nScreens == 3 ? "3" : "5",
    });
    plane.selected = true;
    console.log(`Selected plane: ${plane.label}`);
  }
}
socket.on("select-aeroplane", selectPlane);

socket.on("update-origin-destination", (data) => {
  console.log(data);
  if (data.screen !== screenNumber) {
    return;
  }
  document.getElementById("origin").textContent = data.origin;
  document.getElementById("destination").textContent = data.destination;
});

socket.on("update-heading-altitude", (data) => {
  console.log(data);
  if (data.screen !== screenNumber) {
    return;
  }
  document.getElementById("headingData").textContent = data.heading;
  document.getElementById("altitudeData").textContent = data.altitude;
});

let errorTimeout;
socket.on("error-popup", (data) => {
  console.log(data);
  if (screenNumber !== "1") return;
  const errorEl = document.getElementById("error");
  errorEl.textContent = data.error;
  if (errorTimeout) {
    clearTimeout(errorTimeout);
  }
  errorTimeout = setTimeout(() => {
    errorEl.textContent = "";
    errorTimeout = null; // Reset reference
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
    // plane.takeoff = data.takeoff;

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

socket.on("command-plane", (data) => {
  if (screenNumber !== "1") return;
  const commandEl = document.getElementById("command");
  commandEl.style.opacity = "1";
  commandEl.textContent = data;
  if (commandtimeout) {
    clearTimeout(commandtimeout);
  }
  commandtimeout = setTimeout(() => {
    commandEl.style.opacity = 0;
    commandtimeout = null; // Reset reference
  }, 5000);
});
