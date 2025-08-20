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
  nScreens ;

let gameOversend = false;
var gameCanvas = document.getElementById("gameCanvas");
var centerText = document.getElementById("center-text");
var centerText2 = document.getElementById("screen-text2"); 
var centerText3 = document.getElementById("screen-text3");
var centerText4 = document.getElementById("screen-text4");
var centerText5 = document.getElementById("screen-text5");
var headingData = document.getElementById("headingData");
var altitudeData =  document.getElementById("altitudeData");
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



// window.addEventListener('beforeunload', function (event) {
//   socket.emit('gameStop');
// });

// Start of LG Connection
const galaxyPort = 8111;
const ip = "lg1";
socket.on('reconnect', () => {
  console.log('Server restarted - reloading page');
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
  // if (nScreens == 5) {
  //   currentMap =
  //     screenNumber == 1
  //       ? generateMasterMap(rows, cols)
  //       : screenNumber == 3
  //       ? generateSlaveMapLayout4_5(rows, cols)
  //       : screenNumber == 2
  //       ? generateSlaveMapLayout3_5(rows, cols)
  //       : screenNumber == 5
  //       ? generateSlaveMapLayout2_5(rows, cols)
  //       : generateSlaveMapLayout5(rows, cols);
  // }


//lleida

  if (nScreens == 5) {
    currentMap =
      screenNumber == 1
        ? generateMasterMap(rows, cols)
        : screenNumber == 3
        ? generateSlaveMapLayout5(rows, cols)
        : screenNumber == 2
        ? generateSlaveMapLayout3_5(rows, cols)
        : screenNumber == 5
        ?  generateSlaveMapLayout4_5(rows, cols)
        : generateSlaveMapLayout2_5(rows, cols)
  }


  if (screenNumber == 1) {
    centerText.style.display = "flex";
    socket.emit("postwidth", {
      width: WIDTH - 60,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 2) {
    // infobar2(centerText2, nScreens === 3 ? "screen" : "none");
    centerText3.style.display = "flex";
    
    // gameCanvas.style.marginRight = "20px";
    socket.emit("postwidth", {
      width: WIDTH - 60,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 3) {
    centerText2.style.display = "flex";
    // infobar3(centerText, nScreens === 3 ? "screen" : "none");
    // gameCanvas.style.marginLeft = "20px";
    if(nScreens !== 5 ){
      mainlogo.style.display = "block";
   }
   
    socket.emit("postwidth", {
      width: WIDTH - 60,
      height: HEIGHT,
      screen: screenNumber,
    });
  } else if (screenNumber == 4) {
    // gameCanvas.style.marginRight = "20px";
    centerText4.style.display = "flex";
    if(nScreens == 5 ){
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
      width: WIDTH - 60 ,
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
  
  // reducing further the grid for center 
  const maxWidth = WIDTH - 60; // Leave some margin
  const maxHeight = HEIGHT ;
  
  let actualSpacing = spacing;
  
  // Auto-adjust spacing if grid is too large
  // if (actualCols * actualSpacing > maxWidth) {
  //     actualSpacing = Math.floor(maxWidth / actualCols);
  // }
  // if (actualRows * actualSpacing > maxHeight) {
  //     actualSpacing = Math.min(actualSpacing, Math.floor(maxHeight / actualRows));
  // }
  
  const offsetX = (WIDTH - actualCols * actualSpacing) / 2;
  const offsetY = (HEIGHT - actualRows * actualSpacing) / 2;
  // added a lastoffset to the drawmap to calculate that the plane is on the dot
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
          // (textLabels[key] === 'ALT') ? y - 25 : y,
          socket.emit("airport-positions", labelPositions);
        }
        ctx.font = "20px Inter";
        ctx.fontWeight = "bold";
        ctx.fillStyle = "#e2e8f0";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        const PAD_TOP = 20;
        const PAD_BOTTOM = 20;
        const PAD_LEFT = Number(nScreens) === 5 ? Number(screenNumber) === 4 ? 35 : 10 : Number(screenNumber) === 2 ? 35 : 10 ; // extra left padding for screen 2
        const PAD_RIGHT = Number(nScreens) === 5 ? Number(screenNumber) === 5 ? 35 : 10 : Number(screenNumber) === 3 ? 35 : 10; // extra left padding for screen 2
        // const PAD_RIGHT = 0

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
let previousConflicts = new Set();
const previousWarnings = new Set();
const planecheckWarnings = 5000;
function addAeroplane(row) {
  const map = row.map;

  function animate() {
    
    requestAnimationFrame(animate);
    
    if(isGameOver && !gameOversend && screenNumber == "1"){
      socket.emit('gameOver')
	gameOversend = true;
      return;
    }

	if(isGameOver){
	return;
	}

    if(isPause) {
      return;
    };
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawMap(row);
    
    if(isStopped) {
      return;
    };
    
    const newConflicts = new Set();
    const newWarnings = new Set(); 

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
        const warningThreshold = 250;
        
        const currentTime = Date.now();

        const pairKey = [a.label, b.label].sort().join("-");
        
        if (
          distance < warningThreshold &&
          distance >= conflictThreshold &&
          a.altitude === b.altitude
          && areMovingTowardsEachother(a, b)
        ) {
          newWarnings.add(pairKey);
         
          if (!previousWarnings.has(pairKey)) {
            previousWarnings.add(pairKey);
            console.log('warning for', pairKey);
            socket.emit("error-popup", {
              error: `Warning: ${a.label} and ${b.label} are too close.`,
              warning: `Warning: ${a.label} and ${b.label} are too close.`,
              data: previousWarnings
            });
          }
        }

        if (distance < conflictThreshold && (a.altitude == b.altitude)) {
          a.conflict = true;
          b.conflict = true;
          
          // Alert if this conflict is new
          if (!previousConflicts.has(pairKey)) {
            socket.emit("error-popup", {
              conflict: true,
              error: `Crash between planes ${a.label} and ${b.label}`,
            });
           
            const indexA = airplanes.indexOf(a);
            const indexB = airplanes.indexOf(b);
            
            if (indexA > indexB) {
              airplanes.splice(indexA, 1); 
              airplanes.splice(indexB, 1); 
            } else {
              airplanes.splice(indexB, 1); 
              airplanes.splice(indexA, 1);
             }
            
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
    
    // Remove warnings that are no longer active
    for (const pairKey of [...previousWarnings]) {
      if (!newWarnings.has(pairKey)) {
        previousWarnings.delete(pairKey);
      }
    }
    newWarnings.clear();

    for (const plane of airplanes) {
      if((plane.altitude === 0 || plane.altitude === undefined) && plane.isnew) {

      } else {
        plane.x += plane.dx;
        plane.y += plane.dy;

        // dot tracking last movement
        const offX = drawMap.lastOffsetX ?? 0;
        const offY = drawMap.lastOffsetY ?? 0;
        const sp = drawMap.lastSpacing ?? spacing;

        // finalize dot tracking like for 1 pixel tolerance
        const colF = (plane.x - offX) / sp;
        const rowF = (plane.y - offY) / sp;

        const tol = Math.max(1, sp * 0.04); 
        const nearCol = Math.abs((colF - Math.round(colF)) * sp) < tol;
        const nearRow = Math.abs((rowF - Math.round(rowF)) * sp) < tol;
        const nearestCol = Math.round(colF);
        const nearestRow = Math.round(rowF);
        const reachedNewDot = nearCol && nearRow && (
          nearestCol !== plane.lastdotcol || nearestRow !== plane.lastdotrow
        );

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
      }  else {
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

    if (plane.takeoff && frameCount % 180 === 0 ) {
      plane.takeoff = false;
      //   if (frameCount % 20 === 0 && takeoffdata < 55) {
      //     takeoffdata += 5;
      //     takeoffdata === 55
      //       ? (takeoffdata = 0,
      //          plane.takeoff = false,
      //          socket.emit("get-aeroplane", { airplanes, screenNumber:plane.screen })
      //         )
      //       : null;
      //   }
      //   ctx.rotate(degToRad(takeoffdata));
      //   const angleRad = degToRad(takeoffdata - 180);

      //   plane.dx = Math.cos(angleRad) * 0.5;
      //   plane.dy = Math.sin(angleRad) * 0.5;
      }

      // rotation
       else if (!plane.takeoff && rotationongrid(plane)) {
        
        const command = plane.rotationstack.shift();
        console.log(`Rotating plane ${plane.rotation} at snapped position (${plane.x}, ${plane.y})`);
        if (command === "left") {
          plane.rotation -= 45;
        } else if (command === "right") {
          plane.rotation += 45;
        }
        // After changing direction, recompute velocity to align with dot grid
        setLastoffSettrackingandSpeedDirection(plane);
      }
      else if (plane.previousAltitude !== plane.altitude && plane.altitude > plane.previousAltitude &&  frameCount % 180 === 0) {
        plane.previousAltitude = plane.previousAltitude + 1000;
        console.log("plus",plane.previousAltitude);
      }
      else if (plane.previousAltitude !== plane.altitude && plane.altitude < plane.previousAltitude &&  frameCount % 180 === 0) {
        plane.previousAltitude = plane.previousAltitude - 1000;
        console.log("minus",plane.previousAltitude);

      }


      //check location
      const destination = plane.destation;
      if (
        destination.screen === plane.screen &&
        Math.abs(destination.x - plane.x) < 10 &&
        Math.abs(destination.y - plane.y) < 10 
      ) {
        if(plane.destation.label === 'ALT' && plane.altitude !== 0 && plane.heading !== 0) {
          ctx.restore(); // Restore canvas state before returning
          return;
        }else if(plane.destation.label !== 'ALT' && plane.altitude !== 4000) {
          airplanes.splice(airplanes.indexOf(plane), 1);
          socket.emit("error-popup", {
            badDeparture: true,
            error: "Bad departure for plane " + plane.label, 
          });
          ctx.restore(); // Restore canvas state before returning
          return;
        };
          
        console.log(`Plane reached destination: ${plane.label}`);
        var sData ='Plane reached destination ' + plane.label 
        socket.emit("success-plane", {sData} );
        airplanes.splice(airplanes.indexOf(plane), 1);
        socket.emit("get-aeroplane", { airplanes, screenNumber });
      }
      // if (plane.heading > 90 && plane.heading < 270 &&  plane.previousAltitude === 0) {
      //   ctx.scale(1, -1); // Flip vertically to prevent upside down
      // }

      ctx.drawImage(plane.img, -20, -20);
      ctx.restore();

      ctx.save();
      ctx.translate(plane.x, plane.y);
      ctx.fillStyle = plane.selected ? "#FFFF00" : "#FFFFFF";
      ctx.textBaseline = 'middle'; 
      ctx.fillText(plane.label, -10, 40);
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

  // const randomInd = Math.floor(Math.random() * characters.length);
  // const character = characters[randomInd];
  // return character;
}



function handleTraverseAeroplane(plane, screenNumber) {
  if (plane.x > canvas.width ) {
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
        x:  0,
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
      // socket.emit("transfer-aeroplane", {
      //   ...plane,
      //   x: 0,
      //   screen: 1,
      // });
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
      // socket.emit("error-popup", {
      //   error: "Wrong exit",
      // });
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: 0,
        screen: 5,
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
      // socket.emit("error-popup", {
      //   error: "Wrong exit",
      // });
      socket.emit("transfer-aeroplane", {
        ...plane,
        x: -4,
        screen: 4,
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
      // socket.emit("transfer-aeroplane", {
      //   ...plane,
      //   x: -2,
      //   screen: 2,
      // });
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
    altitude: data.label === "ALT" ? 0 : 4000,
    previousAltitude:0,
    conflict: false,
    takeoff: false,
    landoff: false,
    rotationstack: [],
    isnew: data.label === 'ALT' ? true : false,
    heading: config.angle || 0,
    rotationstackPreview: [],
    destation: data.destation || { label: "WSH", x: 358.5, y: 26.5, screen: 2 },
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
  const norm = Math.round(rot / 45) * 45 % 360;

  // Defaults
  let dx = 0;
  let dy = 0;

  switch (norm) {
    case 0: // left
      dx = -perAxis; dy = 0; break;
    case 45: // up-left
      dx = -perAxis; dy = -perAxis; break;
    case 90: // up
      dx = 0; dy = -perAxis; break;
    case 135: // up-right
      dx = perAxis; dy = -perAxis; break;
    case 180: // right
      dx = perAxis; dy = 0; break;
    case 225: // down-right
      dx = perAxis; dy = perAxis; break;
    case 270: // down
      dx = 0; dy = perAxis; break;
    case 315: // down-left
      dx = -perAxis; dy = perAxis; break;
  }
  plane.dx = dx;
  plane.dy = dy;
}

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
  errorData.textContent = data.error;
  errorData.style.opacity = 1;
  if (errorTimeout) {
    clearTimeout(errorTimeout);
  }
  errorTimeout = setTimeout(() => {
    errorData.style.opacity = 0;
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
    commandtimeout = null; // Reset reference
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
    successDataTimer = null; // Reset reference
  }, 5000);
} );

socket.on("gameOverData", (data) => {
  stopTimer();
  characters = 65;
  airplanes = [];
  if((nScreens !== 3 && screenNumber == "3" ) || (nScreens !== 5 && screenNumber == "4")) {
    mainlogo.style.display = "block";
  };
  if(screenNumber !== "1") return;
  gameover.style.display = "block";
  scoreID.textContent = data.successCount;
  confilct.textContent = data.conflictCount;
  wrong.textContent = data.wrongExitCount;
  bad.textContent = data.baddepartureCount;
});

socket.on('disconnect', (reason) => {
  console.log(' Disconnected');
});

socket.on('gameStartData', (reason) => {
gameOversend = false;
  mainlogo.style.display = "none";
  gameover.style.display = "none";
  resumeTimer();
  if(screenNumber !== "1") return;
 startTimer();

});

socket.on('gameStopData', (reason) => {
gameOversend = false;
  if((nScreens !== 3 && screenNumber == "3" ) || (nScreens !== 5 && screenNumber == "4")) {
    mainlogo.style.display = "block";
  };
  airplanes.length = 0;
  characters = 65;
  aeroplanename = null;
  frameCount = 0;
  // if(screenNumber !== "1") return;
 stopTimer();
});
socket.on('gamePauseData', (reason) => {
  // if(screenNumber !== "1") return;
 pauseTimer();
});

socket.on('gameResumeData',()=>{
  startTimer();
})

socket.on('deselect-plane', (data) => {
  console.log('Deselecting plane', data);
  const plane = airplanes.find((plane) => plane.label === data.label);
  if (plane) {
    plane.selected = false;
    plane.rotationstackPreview = [];
    socket.emit("get-aeroplane", { airplanes, screenNumber });
  }
});

socket.on('gameResetData' , handlereset);

function handlereset() {
  gameOversend = false;
  // Clear everything
  airplanes.length = 0;
  characters = 65;
  aeroplanename = null;
  frameCount = 0;
  
  // Hide game over elements
  gameover.style.display = "none";
  mainlogo.style.display = "none";
  
  // Emit restart sequence
  socket.emit('gameStop');
  
  // Small delay before starting new game
  setTimeout(() => {
    socket.emit('gameStart');
    socket.emit('fetch-airplanes-io');
    console.log('✅ Restart sequence completed');
  }, 500);
}


let heartbeatInterval;

function startHeartbeat() {
  if (heartbeatInterval) clearInterval(heartbeatInterval);
  
  heartbeatInterval = setInterval(() => {
    if (socket.connected) {
      socket.emit('heartbeat', {
        screenNumber: screenNumber,
        isPaused: isPause,
        isStopped: isStopped,
        isGameOver: isGameOver,
        timestamp: Date.now()
      });
    }
  }, 5000); // Every 5 seconds
}

function stopHeartbeat() {
  if (heartbeatInterval) {
    clearInterval(heartbeatInterval);
    heartbeatInterval = null;
  }
}

startHeartbeat();
