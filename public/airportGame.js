import { generateMasterMap, generateSlaveMapLayout2, generateSlaveMapLayout3, labelMap ,SVGSTRING, TOP_OFFESET } from "./functions.js";

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


/**
 * Screen setup method -> responsible for setting variables for screen
 * @param {Object} screen screen object containing info like screen number and total of screens
 */
function screenSetup(screen) {
    nScreens = screen.nScreens;
    currentMap =
      screenNumber == 1
        ? generateMasterMap(rows, cols)
        : screenNumber == 2
        ? generateSlaveMapLayout2(rows, cols)
        : generateSlaveMapLayout3(rows, cols);
  
    // centerText.innerHTML = `${screenNumber == 1 ? 'WAITING FOR PLAYERS' : ''}`
  
    // initialize all foods eaten as false on all screens
  
    createGrid(currentMap);
  }
  socket.on("new-screen", screenSetup);



  function onCreateplane(aeroplane) {
    // Only render if it's for this screen
    if (Number(screenNumber) === Number(aeroplane.screen)) {
      // const coloredSVG = SVGSTRING.replace('fill="white"', 'fill="red"');
      const svgBlob = new Blob([SVGSTRING], {
        type: "image/svg+xml;charset=utf-8",
      });
      const url = URL.createObjectURL(svgBlob);
      const airplaneImage = new Image();
  
      airplaneImage.onload = () => {
        airplanes.push({
          ...aeroplane,
          img: airplaneImage,
          dx: aeroplane.dx || 0.5 ,
          dy: aeroplane.dy || 0 ,
          rotation: aeroplane.rotation || 0
        });
      };
  
      airplaneImage.src = url;
    }
  }
  
  socket.on('aeroplane-create', onCreateplane);




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
          if(!labelPositions.some(p => p.label === textLabels[key] &&  p.x === x && p.y === y)){
            labelPositions.push({
              label: textLabels[key],
              x: x,
              y: y
          });
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
  
  const airplanes = [];
  const characters = "abcdefghijklmnopqrstuvwxyz";
  
  function addAeroplane(row) {
    const map = row.map;
    const svgBlob = new Blob([SVGSTRING], {
      type: "image/svg+xml;charset=utf-8",
    });
    const url = URL.createObjectURL(svgBlob);
    const airplaneImage = new Image();
  
    airplaneImage.onload = function () {
  
      // Click to add planes
      // canvas.addEventListener("click", (e) => {
      //   const rect = canvas.getBoundingClientRect();
      //   const x = e.clientX - rect.left;
      //   const y = e.clientY - rect.top;
  
      //   airplanes.push({
      //     x,
      //     y,
      //     dx: 0,
      //     dy: 0,
      //     img: airplaneImage,
      //     label: getCharater(),
      //     screen: 1,
      //     currentMap: 'master',
      //   });
      // });
  
      function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        drawMap(row);
  
        for (const plane of airplanes ) {
          plane.x += plane.dx;
          plane.y += plane.dy;
  
          
        const transferred = handleTraverseAeroplane(plane, screenNumber);
        if (transferred) continue;

          ctx.save();
          ctx.translate(plane.x, plane.y);
          ctx.rotate(airplanes[aeroplanename]?.rotation);
          
          
          ctx.drawImage(plane.img, 0, 0, 40, 40);
          if (plane.label === airplanes[aeroplanename]?.label) {
              ctx.fillStyle = "#FF0000";  
          } else {
              ctx.fillStyle = "#fff"; 
          }
          ctx.fillText(plane.label, 0, 0);
          ctx.restore();
  
  
          
        }
  
        requestAnimationFrame(animate);
      }
      animate();
    };
  
    airplaneImage.src = url;
  }
  let aeroplanename = null;
  function getCharater() {
    const randomInd = Math.floor(Math.random() * characters.length);
    const character = characters[randomInd];
    const ischarater = airplanes.some(
      (plane) => plane.label === characters.charAt(randomInd)
    );
    if (ischarater) {
      return character + characters[ Math.floor(Math.random() * characters.length)];
    }
    return character;
  }

  document.addEventListener("keydown", (e) => {
    console.log("Pressed:", e.key);

   

    if (e.key.length === 1 && e.key.match(/[a-z]/i)) {
        const index = airplanes.findIndex((plane) => plane.label === e.key);
        if (index !== -1) {
            aeroplanename = index;
            console.log(`Selected plane: ${airplanes[aeroplanename].label}`);
        }
        return;
    }

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
        case "Escape":
            aeroplanename = null;
            break;
    }
});


function handleTraverseAeroplane(plane, screenNumber) {
  if (plane.x > canvas.width) {
      if (screenNumber == 1) {
          // middle → right
          socket.emit('transfer-aeroplane', {
              ...plane,
              x: 0,
              screen: 3
          });
      } else if (screenNumber == 2) {
          // left → middle
          socket.emit('transfer-aeroplane', {
              ...plane,
              x: 0,
              screen: 1
          });
      } else if (screenNumber == 3) {
          // right → wrap to left
          alert("Wrong exit")
      }
      airplanes.splice(airplanes.indexOf(plane), 1);
      return true;
  }

  if (plane.x < 0) {
      if (screenNumber == 1) {
          // middle → left
          socket.emit('transfer-aeroplane', {
              ...plane,
              x: canvas.width,
              screen: 2
          });
      } else if (screenNumber == 2) {
        confirm("Wrong exit")
          // left → wrap to right
      } else if (screenNumber == 3) {
          // right → middle
          socket.emit('transfer-aeroplane', {
              ...plane,
              x: canvas.width,
              screen: 1
          });
      }
      airplanes.splice(airplanes.indexOf(plane), 1);
      return true;
  }

  return false;
}




function postionAeroplane(screenNumber) {
  const newAeroplane = {
      x: labelPositions[0].x,
      y: labelPositions[0].y,
      label: getCharater(),
      screen: Number(screenNumber),
      dx: 0.5,
      dy: 0, 
      rotation: 0
  };
  socket.emit('create-aeroplane', newAeroplane);
  console.log("Sent create-aeroplane event:", newAeroplane);
  return;
}

// Listen for 'add-aeroplane' event and create the plane
socket.on('add-aeroplane', postionAeroplane);



function updatePlane(data) {
  console.log(data);
  
  if (aeroplanename === null) {
    return;
}

const rotate = airplanes[aeroplanename].rotation;
switch (data.dir) {
  case "left":
    airplanes[aeroplanename].rotation = rotate + 45;
    const angleRadl = airplanes[aeroplanename].rotation  * Math.PI / 180;
    airplanes[aeroplanename].dx = Math.cos(angleRadl) * 0.5;
    airplanes[aeroplanename].dy = Math.sin(angleRadl) * 0.5;
        break;
    case "right":
      airplanes[aeroplanename].rotation = rotate - 45;
      const angleRadr = airplanes[aeroplanename].rotation  * Math.PI / 180;
      airplanes[aeroplanename].dx = Math.cos(angleRadr) * 0.5;
      airplanes[aeroplanename].dy = Math.sin(angleRadr) * 0.5;
        break;
 

};


}
socket.on('update-plane', updatePlane);  


function selectPlane(data) {
  console.log(data);
  const index = airplanes.findIndex((plane) => plane.label === data.dir);
  if (index !== -1) {
      aeroplanename = index;
      console.log(`Selected plane: ${airplanes[aeroplanename].label}`);
  }
  return;
}
socket.on('select-aeroplane',selectPlane)

