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
let airportPositions = []
let airplones = [];
let submitdata = {};
let altitude = 0;
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



function fleft() {
    socket.emit('update-plane-left');
    console.log('dorection left ');
}

left.addEventListener('click', fleft);



function fright() {
    socket.emit('update-plane-right');
    console.log('dorection right  ');;
}

right.addEventListener('click', fright);

submit.addEventListener('click', (event) => {
  if(submitdata.altitude === 0 && submitdata.takeoff === true){
    submitdata.altitude = 1000;
  }

  const command = generateCommandSpeech();
  console.log(command);
  speakCommand(command);

    console.log('submited selected:', submitdata);
    socket.emit('submit-plane', submitdata);
});

plus.addEventListener("click", (event) => {
  if(submitdata.altitude === 5000){
  return}
  submitdata.altitude = submitdata.altitude +1000;
})

minus.addEventListener("click", (event) => {
  if(submitdata.altitude === 0){
    return}
  submitdata.altitude = submitdata.altitude - 1000;
 
})

function generateCommandSpeech() {
  if (!submitdata?.label) {
    console.warn("No plane selected.");
    return "No valid plane selected.";
  }

  const callSign = submitdata.label.toUpperCase();
  const altitude = submitdata.altitude;
  const heading = submitdata.heading;   // You can extend this
  const waypoint = submitdata.waypoint; // Optional custom field

  let command = "";

  // Priority 1: Taxi if runway + route
  // Priority 2: Landing clearance if runway only
  // Priority 3: Turn if heading is given
   if (heading !== undefined) {
    const dir = heading >= 180 ? "RIGHT" : "LEFT";
    const formattedHeading = heading.toString().padStart(3, "0");
    command = `${callSign}, turn ${dir} heading ${formattedHeading}.`;
  }
  // Priority 4: Climb or descend if altitude
  else if (altitude !== undefined) {
    if (altitude > 3000) {
      command = `${callSign}, climb and maintain ${altitude.toLocaleString()} feet.`;
    } else if (altitude < 3000) {
      command = `${callSign}, descend and maintain ${altitude.toLocaleString()} feet.`;
    } else {
      command = `${callSign}, maintain ${altitude.toLocaleString()} feet.`;
    }
  }
  else {
    command = `${callSign}, say again.`;
  }

  return command;
}

function speakCommand(text) {
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.rate = 0.9;
  speechSynthesis.speak(utterance);
}