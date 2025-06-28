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
        changeAltitude = airport.altitude
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
  if (degrees === 0){
     return
   }else{
    degrees -= 45
    
  }
  updateAndSpeakCommandIfChanged(); 
    socket.emit('update-plane-left');
    console.log('dorection left ');
}

left.addEventListener('click', fleft);



function fright() {
 if (degrees === 360){
     return
   }
   else{
    degrees += 45
    
  }
  updateAndSpeakCommandIfChanged();

    socket.emit('update-plane-right');
    console.log('dorection right  ');;
}

right.addEventListener('click', fright);

let previousAltitude ;
submit.addEventListener('click', (event) => {
  previousAltitude = submitdata.altitude;
  if(submitdata.altitude === 0 && submitdata.takeoff === true){
      submitdata.altitude = 1000;
    }else{
      submitdata.altitude =changeAltitude
    }

    const command = generateCommandSpeech();
    console.log(command);
    speakCommand(command);

    console.log('submited selected:', submitdata);
    socket.emit('submit-plane', submitdata);
});

plus.addEventListener("click", (event) => {
  if(changeAltitude === 5000){
  return}
  changeAltitude +=1000;
  updateAndSpeakCommandIfChanged();

})

minus.addEventListener("click", (event) => {
  if(changeAltitude === 0){
    return}
  changeAltitude -= 1000;
  updateAndSpeakCommandIfChanged();
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
   if (degrees > 0) {
    const dir = degrees >= 180 ? "RIGHT" : "LEFT";
    const formattedHeading = degrees.toString().padStart(3, "0");
    command = `${callSign}, turn ${dir} heading ${formattedHeading}.`;
  }
  // Priority 4: Climb or descend if altitude
  else if (previousAltitude !== submitdata.altitude) {
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

function updateAndSpeakCommandIfChanged() {
  const command = generateCommandSpeech();
    commandElement.textContent = command;
}
// 10.0.2.10