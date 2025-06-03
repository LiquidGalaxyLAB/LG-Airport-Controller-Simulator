var socket = io()
let nScreens; // variable will be set to have total number of screens in screenSetup method

// dom variables
const aeroplaneviaSocket1 = document.getElementById('aeroplane')
const right = document.getElementById('right')
const left = document.getElementById('left')
const submit = document.getElementById('submit');
const input = document.getElementById('text-i');
const screen = document.getElementById('screen');




function aeroplaneviaSocket() {
    const data = screen.value;
    socket.emit('add-plane', data);
    console.log('Plane request sent');
}

aeroplaneviaSocket1.addEventListener('click', aeroplaneviaSocket);



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
    const key = input.value;
    console.log('direction selected:', key);
    socket.emit('select-plane', key);
});