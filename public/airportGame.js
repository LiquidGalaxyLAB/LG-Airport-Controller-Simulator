import {
  generateMasterMap,
  generateSlaveMapLayout2,
  generateSlaveMapLayout3,
  infobar,
  infobar2,
  infobar3,
  labelMap,
  LANDINGSVG,
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
// Get canvas element from index.html
const canvas = document.getElementById("gameCanvas");
// const

canvas.height = HEIGHT;
canvas.width = WIDTH;
const spacing = 45; // distance between dots
// Calculate number of rows and cols (ensure they are odd)
let rows = Math.floor(HEIGHT / spacing);
let cols = Math.floor(WIDTH / spacing);

// canvas.width = BLOCK_SIZE * GRID_WIDTH + WALL_LINE_WIDTH

const ctx = canvas.getContext("2d");

let currentMap = generateMasterMap(rows, cols); //default to master map

const airplanes = [];


// Pre-create airplane images to avoid repeated blob creation
const airplaneImages = {
  white: null,
  red: null,
  takeLandOff: null
};

// Create images once during initialization
function createAirplaneImages() {
  const whiteBlob = new Blob([SVGSTRING], { type: "image/svg+xml;charset=utf-8" });
  const redSVG = SVGSTRING.replace(/fill="[^"]+"/g, 'fill="red"');
  const redBlob = new Blob([redSVG], { type: "image/svg+xml;charset=utf-8" });
  const takeLandOff = new Blob([LANDINGSVG], { type: "image/svg+xml;charset=utf-8" });
   
  const whiteUrl = URL.createObjectURL(whiteBlob);
  const redUrl = URL.createObjectURL(redBlob);
  const takeLandOffUrl = URL.createObjectURL(takeLandOff);
  
  airplaneImages.white = new Image();
  airplaneImages.red = new Image();
  airplaneImages.takeLandOff = new Image();
  
  airplaneImages.white.src = whiteUrl;
  airplaneImages.red.src = redUrl;
  airplaneImages.takeLandOff.src = takeLandOffUrl;
}

// Initialize images
createAirplaneImages();


function screenSetup(screen) {
  nScreens = screen.nScreens;
  currentMap =
    screenNumber == 1
      ? generateMasterMap(rows, cols) 
      : screenNumber == 2
      ? generateSlaveMapLayout2(rows, cols)
      : generateSlaveMapLayout3(rows, cols);

    if(screenNumber == 1) {
      infobar(centerText)
      socket.emit('postwidth', {width: WIDTH, height: HEIGHT , screen: screenNumber})
    }
    else if(screenNumber == 2) {
      infobar2(centerText)
      // socket.emit('postwidth', {width: WIDTH, height: HEIGHT , screen: screenNumber})
    }else if(screenNumber == 3) {
      infobar3(centerText)
      // socket.emit('postwidth', {width: WIDTH, height: HEIGHT , screen: screenNumber})
    }

  createGrid(currentMap);
}
socket.on("new-screen", screenSetup);

function onCreateplane(aeroplane) {
  // Only render if it's for this screen
  if (Number(screenNumber) === Number(aeroplane.screen)) {
    
      airplanes.push({
        ...aeroplane,
        img: airplaneImages.white,
        dx: aeroplane.dx || 0.5,
        dy: aeroplane.dy || 0,
        rotation: aeroplane.rotation !== undefined ? aeroplane.rotation : 0, 
      });

    socket.emit("get-aeroplane", airplanes);
  }
}

socket.on("aeroplane-create", onCreateplane);

/**
 * Create game grid based on selected map layout
 * @param {Array} map two dimensional array with map layout
 */
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
  // ctx.clearRect(0, 0, width, height);
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
            screen: screenNumber,
          });
          socket.emit('airport-positions', labelPositions);

        }
        ctx.font = "20px MONOSPACE";
        ctx.fontWeight = "bold";
        ctx.fillStyle = "#e2e8f0";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
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


const characters = "abcdefghijklmnopqrstuvwxyz";
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
              alert(`⚠️ Conflict detected between planes ${a.label} and ${b.label}`);
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
        }
      }
      

      for (const plane of airplanes) {
        plane.x += plane.dx;
        plane.y += plane.dy;

        const transferred = handleTraverseAeroplane(plane, screenNumber);
        if (transferred) continue;
  // Set image color based on conflict status
        plane.img = plane.conflict ? airplaneImages.red : airplaneImages.white;

        plane.img = plane.altitude === 0 ? airplaneImages.takeLandOff : airplaneImages.white;

        ctx.save();
        ctx.translate(plane.x, plane.y);
        
        if (plane.rotation !== undefined && plane.selected) {
          ctx.rotate(degToRad(plane.rotation));
        }

        
        ctx.drawImage(plane.img, -20, -20, 40, 40); 
        ctx.restore(); 
        
        ctx.save();
        ctx.translate(plane.x, plane.y);
        ctx.fillStyle = plane.selected ? "#FF0000" : "#fff";
        ctx.fillText(plane.label, -10, 40);
        ctx.restore();
      }

      requestAnimationFrame(animate);
    }
    animate();
  };

let aeroplanename = null;
function getCharater() {
  const randomInd = Math.floor(Math.random() * characters.length);
  const character = characters[randomInd];
  const ischarater = airplanes.some(
    (plane) => plane.label === characters.charAt(randomInd)
  );
  if (ischarater) {
    return (
      character + characters[Math.floor(Math.random() * characters.length)]
    );
  }
  return character;
}

document.addEventListener("keydown", (e) => {
  console.log("Pressed:", e.key);

 

  if (aeroplanename === null) {
    return;
  }

  switch (e.key) {
    case "ArrowUp":
      airplanes[aeroplanename].dy = -1; 
      break;
    case "ArrowDown":
      airplanes[aeroplanename].dy = 1;
      break;
    case "ArrowLeft":
      airplanes[aeroplanename].dx = -1;
      break;
    case "ArrowRight":
      airplanes[aeroplanename].dx = 1;
      break;
    case "l":
      console.log("landed");
      airplanes[aeroplanename].altitude = 0;
      break;
    case "t":
    console.log("landed");
    airplanes[aeroplanename].altitude = 1;
    break;
    case "Escape":
      aeroplanename = null;
      break;
  }
});

function handleTraverseAeroplane(plane, screenNumber) {
  if (plane.x > canvas.width) {
    if (screenNumber == 1) {
      // middle → right
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
        screen: 1,
      });
    } else if (screenNumber == 3) {
      // right → wrap to left
      alert("Wrong exit");
    }
    airplanes.splice(airplanes.indexOf(plane), 1);
    return true;
  }

  if (plane.x < 0) {
    if (screenNumber == 1) {
      // middle → left
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: canvas.width,
        screen: 2,
      });
    } else if (screenNumber == 2) {
      confirm("Wrong exit");
      // left → wrap to right
    } else if (screenNumber == 3) {
      // right → middle
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -3,
        screen: 1,
      });
    }
    airplanes.splice(airplanes.indexOf(plane), 1);
    return true;
  }

  return false;
}

function postionAeroplane(data) {
  const newAeroplane = {
    x: data.x,
    y: data.y,
    label: getCharater(),
    screen: Number(data.screen),
    dx: 0.5,
    dy: 0,
    rotation: 0,
    selected: false,
    altitude: 1,
    conflict: false,

  };
  if (Number(screenNumber) === Number(data.screen)) {
    socket.emit("create-aeroplane", newAeroplane);
  }
  console.log("Sent create-aeroplane event:", newAeroplane);
  return;
}


const degToRad = deg => (deg * Math.PI) / 180;

// Listen for 'add-aeroplane' event and create the plane
socket.on("add-aeroplane", postionAeroplane);

function updatePlane(data) {
  console.log(data);

  const index = airplanes.findIndex((plane) => plane.selected === true);
  if (index !== -1) {
    aeroplanename = index;
    console.log(`Selected plane: ${airplanes[aeroplanename].label}`);
  }

  if (aeroplanename === null) {
    return;
  }

  const rotation = airplanes[aeroplanename]?.rotation;
  switch (data.dir) {
    case "left":
      airplanes[aeroplanename].rotation = rotation + 45;
      break;
    case "right":
      airplanes[aeroplanename].rotation = rotation - 45;
      break;
  }
  
  const angleRad = degToRad(airplanes[aeroplanename].rotation - 180);
  
  airplanes[aeroplanename].dx = Math.cos(angleRad) * 0.5;
  airplanes[aeroplanename].dy = Math.sin(angleRad) * 0.5;
}
socket.on("update-plane", updatePlane);

function selectPlane(data) {
  console.log(data);
  airplanes.forEach((plane) => (plane.selected = false));
  const index = airplanes.findIndex((plane) => plane.label === data.dir);
  if (index !== -1) {
    aeroplanename = index;
    airplanes[aeroplanename].selected = true;
    console.log(`Selected plane: ${airplanes[aeroplanename].label}`);
  }
  return;
}
socket.on("select-aeroplane", selectPlane);
