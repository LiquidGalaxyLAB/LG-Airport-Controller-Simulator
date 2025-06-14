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
let airportPositions = []
let airplones = [];


setInterval(() => {
  
  
}, 100);
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
    airportPositions = data;
  
    data.forEach((airport) => {
      const button = document.createElement("button");
      button.className = "custom-button";
      button.textContent = airport.label;
  
      button.addEventListener("click", () => {
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

// submit.addEventListener('click', (event) => {
//     const key = input.value;
//     console.log('direction selected:', key);
//     socket.emit('select-plane', key);
// });
