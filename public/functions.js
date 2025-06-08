export function generateMasterMap(rows, cols) {
  const map = [];
  const middleRow = Math.floor(rows / 2);

  for (let row = 0; row < rows; row++) {
    const rowData = [];
    for (let col = 0; col < cols; col++) {
      if (row === middleRow) {
        rowData.push(1); // white dot
      } else {
        rowData.push(0); // blue dot
      }
    }
    map.push(rowData);
  }
  console.log("master map", map);

  const points = {
    middle: { row: middleRow, col: Math.floor(cols / 2) },
  };

  return {map , points};
}

export function generateSlaveMapLayout2(rows, cols) {
  const map = [];
  const centerRow = Math.floor(rows / 2);
  const one_thridpart = (cols - Math.floor(cols / 3));
  const centerCol = Math.floor(rows / 2);

  for (let row = 0; row < rows; row++) {
    const rowData = new Array(cols).fill(0);
    const offset = row; // 👈 changed from Math.abs(centerRow - row)
    if (row < cols && row <= centerCol) {
      rowData[row] = 1;
    }

    if( row >= centerCol) {
      let data_1 = (centerCol - (row - centerCol ) )
      rowData[data_1]  = 1;
      console.log("k0l", data_1);
    }

    rowData[one_thridpart] = 1;
    // Fill the center row completely
    if (row === centerRow) {
      for (let col = 0; col < cols; col++) {
        rowData[col] = 1;
      }
    }
    map.push(rowData);
  }
  const points = {
    topLeft: { row: 0, col: 0 },
    topCenterRow: { row: centerRow, col: 0 },
    bottomLeft: { row: rows - 1, col: 0 },
    topOneThird: { row: 0, col:  one_thridpart },
    bottomOneThird: { row: rows - 1, col: one_thridpart },
  };

  console.log("points", points);
  return {map , points};
}

export function generateSlaveMapLayout3(rows, cols) {
  const map = [];
  const middleRow = Math.floor(rows / 2);
  const middleCol = Math.floor(cols / 2);

  for (let row = 0; row < rows; row++) {
    const rowData = [];
    for (let col = 0; col < cols; col++) {
      if (row === middleRow) {
        rowData.push(1); // white dot
      }else if (col === middleCol) {
        rowData.push(1); // white dot
      }
      else  {
        rowData.push(0); // blue dot
      }
    }
    map.push(rowData);
  }
  const points = {
    middlestart: { row: middleRow, col: 0 },
    middleend: { row: middleRow, col: cols - 1 },
    topmiddle: { row: 0, col: middleCol },
    bottommiddle: { row: rows - 1, col: middleCol },
  };
  console.log("master map", map);
  return {map, points};
}

export const labelMap = {
  topLeft: "CHI",
  topCenterRow: "DAL",
  topOneThird: "WSH",
  topmiddle: "BST",
  // middlestart: "Middle Start",
  middleend: "LON",
middle: "ALT",
  bottomLeft: "NOR",
  bottomOneThird: "TAM",
  bottommiddle: "MIA"
};




export const SVGSTRING = `<svg width="43" height="46" viewBox="0 0 43 46" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M27.4431 0.0292778C27.7397 0.115734 28.0127 0.287914 28.2367 0.529816C28.4633 0.761147 28.6285 1.06271 28.7129 1.39918C28.7897 1.74477 28.7897 2.10736 28.7129 2.45296L25.4024 17.759L36.2863 18.4703L38.1003 15.6778C38.1487 15.5908 38.2163 15.5205 38.2961 15.4742C38.3758 15.4278 38.4648 15.4072 38.5538 15.4144H42.5219C42.6075 15.4148 42.6922 15.4362 42.7703 15.477C42.8484 15.5179 42.9183 15.5773 42.9754 15.6515C43.0082 15.7894 43.0082 15.9351 42.9754 16.073V16.2311L41.4108 23.0015L42.9754 29.7457C42.9959 29.8421 42.9974 29.9427 42.9797 30.0399C42.962 30.1371 42.9257 30.2284 42.8733 30.307C42.821 30.3855 42.754 30.4493 42.6774 30.4935C42.6009 30.5378 42.5167 30.5613 42.4312 30.5624H38.4631C38.3751 30.5624 38.2883 30.5386 38.2096 30.4928C38.1308 30.4471 38.0624 30.3807 38.0096 30.2989L36.1956 27.5064L25.3117 28.2177L28.6222 43.5238C28.7024 43.8599 28.7024 44.2151 28.6222 44.5512C28.5361 44.8943 28.3715 45.2039 28.146 45.4469C27.9238 45.6864 27.6493 45.8505 27.3524 45.9211C27.0646 46.0263 26.7559 46.0263 26.4681 45.9211L22.9535 44.5512C22.7232 44.4838 22.5122 44.3476 22.3413 44.1561C22.1648 43.9538 22.0259 43.7118 21.9331 43.4448L16.3324 28.2968H4.47347C3.27591 28.2979 2.12659 27.7486 1.27632 26.7688C0.456674 25.7612 0 24.4274 0 23.0411C0 21.6547 0.456674 20.3209 1.27632 19.3133C1.70007 18.825 2.20261 18.4387 2.75514 18.1765C3.30767 17.9143 3.89931 17.7814 4.49615 17.7854H16.3324L21.9331 2.61102C22.0249 2.35232 22.1635 2.1196 22.3396 1.92868C22.5156 1.73775 22.725 1.59311 22.9535 1.50456L26.4454 0.134651C26.7653 0.00376129 27.1082 -0.0324554 27.4431 0.0292778Z" fill="white"/>
</svg>
`;

export const TOP_OFFESET = 50;

export const airplanes = []
const offsetX = 0 //offsetX



export function infobar (container){
  const time = document.createElement("div");
  time.id = "time";
  time.textContent = '10.10.10';

  const command = document.createElement("div");
  command.id = "command";
  command.textContent = "DL146 TURN RIGHT HEADING 230 AT 4000 FEET"

  container.appendChild(time);
  container.appendChild(command);
}

export function infobar2 (container){
  const sourcemain = document.createElement("div"); 
  sourcemain.id = "sourcemain";
  sourcemain.className = "infobar";
  const source = document.createElement("div");
  source.id = "source";
  source.textContent = "Source: ";
  source.className = "infobar-label";

  const origin = document.createElement("div");
  origin.id = "origin";
  origin.textContent = "ALT";
  origin.className = "infobar-data";


  const destmain = document.createElement("div");
  destmain.id = "destmain";
  destmain.className = "infobar";

  const dest = document.createElement("div");
  dest.id = "dest";
  dest.textContent = "Dest: ";
  dest.className = "infobar-label";

  const destination = document.createElement("div"); 
  destination.id = "destination";
  destination.textContent = "MIA";
  destination.className = "infobar-data"; 


  sourcemain.appendChild(source);
  sourcemain.appendChild(origin);
  destmain.appendChild(dest);
  destmain.appendChild(destination);
  container.appendChild(sourcemain);
  container.appendChild(destmain);

}


export function infobar3 (container){
  const headingMain = document.createElement("div"); 
  headingMain.className = "infobar";

  const heading = document.createElement("div");
  heading.id = "heading";
  heading.textContent = "Heading: ";
  heading.className = "infobar-label";

  const headingData = document.createElement("div");
  headingData.id = "headingData";
  headingData.textContent = "225";
  headingData.className = "infobar-data";

  const altitudeMain = document.createElement("div");
  altitudeMain.className = "infobar";

  const altitude = document.createElement("div");
  altitude.id = "altitude";
  altitude.textContent = "Altitude: ";
  altitude.className = "infobar-label";

  const altitudeData = document.createElement("div");
  altitudeData.id = "altitudeData";
  altitudeData.textContent = "4000";
  altitudeData.className = "infobar-data";


  headingMain.appendChild(heading);
  headingMain.appendChild(headingData);
  altitudeMain.appendChild(altitude);
  altitudeMain.appendChild(altitudeData);
  container.appendChild(headingMain);
  container.appendChild(altitudeMain);
}