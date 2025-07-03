var socket = io()
let nScreens; // variable will be set to have total number of screens in screenSetup method

// dom variables
// const aeroplaneviaSocket1 = document.getElementById('aeroplane')
const right = document.getElementById('right')
const left = document.getElementById('left')
const submit = document.getElementById('submit');
const input = document.getElementById('text-i');
const screen = document.getElementById('screen');
const postionAirpots = document.getElementById('poistion-airport'); 
const planes = document.getElementById('plane'); 
const plus = document.getElementById('plus'); 
const minus = document.getElementById('minus'); 
const commandElement = document.getElementById('command'); 
let airportPositions = []
let airplones = [];
let submitdata = {};
let changeAltitude = 0;
let degrees = 0;
socket.on('all-airport-positions', (data) => {
    console.log('Received updated airport positions from server:', data);
  
    // You can store or display this data now
  });
  
  socket.emit('get-airport-positions', (data) => {
    console.log('Received from server via callback:', data);
    airplones = data;
        
    data.forEach((plane) => {
        const button = document.createElement("button");
        button.className = "custom-button";
        button.textContent = plane.label;
      
        // Click event → Call your function with screen number
        button.addEventListener("click", () => {
          aeroplaneviaSocket(plane);
        });
      
        planes.appendChild(button);
      });
  });

  socket.on('aeroplane-data', (data) => {
    console.log('Received from server via aeroplane:', data);
    postionAirpots.innerHTML = '';
    airportPositions = data;
  
    data.forEach((airport) => {
      const button = document.createElement("button");
      button.className = "custom-button";
      button.textContent = airport.label;
      button.addEventListener("click", () => {
        submitdata = airport;
        changeAltitude = airport.altitude;
        degrees = airport.heading;
        socket.emit('select-plane', airport.label);
      });
  
      postionAirpots.appendChild(button);
    });
  });
  




function aeroplaneviaSocket(airport) {
    const data ={screen:  airport.screen,
        x : airport.x,
        y : airport.y,
        label : airport.label,
       }
    socket.emit('add-plane', data);
    console.log('Plane request sent');
}

// aeroplaneviaSocket1.addEventListener('click', aeroplaneviaSocket);


let previousAltitude;

// LEFT turn logic
function fleft() {
  if (degrees === -405) return;
  degrees -= 45;
  handleCommandPreview();
  socket.emit('update-plane-left');
  console.log('direction: LEFT');
}
left.addEventListener('click', fleft);

// RIGHT turn logic
function fright() {
  if (degrees === 405) return;
  degrees += 45;
  handleCommandPreview();
  socket.emit('update-plane-right');
  console.log('direction: RIGHT');
}
right.addEventListener('click', fright);

// Altitude increase
plus.addEventListener("click", () => {
  if (changeAltitude === 5000) return;
  changeAltitude += 1000;
  handleCommandPreview();
});

// Altitude decrease
minus.addEventListener("click", () => {
  if (changeAltitude === 0) return;
  changeAltitude -= 1000;
  handleCommandPreview();
});

// Submit and issue command
submit.addEventListener('click', () => {
  previousAltitude = submitdata.altitude;

  if (submitdata.altitude === 0 ) {
    submitdata.altitude = 1000;
    submitdata.takeoff = true;

  } else {
    submitdata.altitude = changeAltitude;
  }

  const command = generateCommandSpeechFrom(submitdata, previousAltitude);
  console.log(command);
  speakCommand(command);
  commandElement.textContent = command;
  socket.emit('submit-plane', submitdata);

  degrees = 0;
  changeAltitude = 0;

  console.log('submitted data:', submitdata);
});

// Preview updated command (without submission)
function handleCommandPreview() {
  const simulatedAltitude = changeAltitude;
  const currentAltitude = submitdata.altitude;

  if (simulatedAltitude !== currentAltitude || degrees !== 0) {
    const tempSubmitData = { ...submitdata, altitude: simulatedAltitude };
    const simulatedCommand = generateCommandSpeechFrom(tempSubmitData, currentAltitude);
    console.log(simulatedCommand);
    commandElement.textContent = simulatedCommand;
  }
}

// Generate full command speech
function generateCommandSpeechFrom(data, prevAltitude) {
  const callSign = data.label;
  const altitude = data.altitude;
  const heading = data.heading;
  const dir = degrees < 0 ? "LEFT" : "RIGHT";
  const formattedHeading = Math.abs(degrees).toString().padStart(3, "0");

  let command1 = "";
  if (degrees !== 0) {
    if (degrees === -360 || degrees === 360) {
      command1 = `ORBIT ${dir}`;
    } else if (degrees === 405 || degrees === -405) {
      command1 = `HOLD ${dir}`;
    } else {
      command1 = `TURN ${dir} -> ${formattedHeading}`;
    }
  } else if (degrees === heading) {
    command1 = `Head to ${heading}`;
  }

  let command2 = "";
  if (prevAltitude !== altitude && altitude !== 0) {
    command2 = prevAltitude > altitude
      ? `DESCEND AND MAINTAIN ${altitude.toLocaleString()} FEET.`
      : `CLIMB AND MAINTAIN ${altitude.toLocaleString()} FEET.`;
  } else {
    command2 = `AT ${altitude.toLocaleString()} FEET `;
  }

  let  speechCommand = `${callSign} ${command1} ${command2}`;
  socket.emit('send-command', speechCommand);
  return speechCommand;
}

// Speak the command out loud
function speakCommand(text) {
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.rate = 0.9;
  speechSynthesis.speak(utterance);
}


// 10.0.2.10