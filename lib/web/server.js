const express = require('express')
const path = require('path')
const vm = require("vm");
const fs = require('fs');
const app = express();

// Config.
const port = 3001;
const db_path = 'db.js';

// Configure express.
app.use(express.json());
app.use(express.static('.'));
app.use('/dist', express.static('../dist'));

// Respond with React app.
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'))
})

////
// READ
////

var load_db = () => {

  const data = fs.readFileSync(db_path);
  const script = new vm.Script(data);
  script.runInThisContext();

  return JSON.parse(db);

}

////
// WRITE
////

var save_db = (db) => {
  // Save JS file to disk.
  try {
    fs.writeFileSync(db_path, 'var db = ' + JSON.stringify(JSON.stringify(db)) + ';');
  }
  catch (err) {
    console.log("ERROR: save_db() failed to save.");
    console.error(err);
  }

}

////
// DELETE.
////

// Handle controls delete request.
app.post('/controls/delete', (req, res) => {

  // Get execution ID that controls share.
  var exe_id = req.body.exe_id;

  // Get database.
  db = load_db();

  // Delete controls.
  for (let [index, control] of db.controls.entries()) {
    if (control.exe_id == exe_id) {
      console.log("DELETE CONTROL:");
      console.log(db.controls[index]);
      db.controls.splice(index, 1);
    }
    if (control.base_id != null && control.base_id == exe_id) {
      console.log("DELETE:");
      console.log(db.controls[index]);
      db.controls.splice(index, 1);
    }
  }

  // Save database.
  save_db(db)

  res.status(200).send({ message: 'ok' });

})

// Handle control delete request.
app.post('/control/delete', (req, res) => {

  // Get control ID.
  ref_id = req.body.ref_id;

  // Get database.
  db = load_db();

  // Delete control.
  for (let [index, control] of db.controls.entries()) {
    if (control.r == ref_id) {
      console.log("DELETE CONTROL:")
      console.log(db.controls[index]);
      db.controls.splice(index, 1);
      break;
    }
  }

  // Save database.
  save_db(db)

  res.status(200).send({ message: 'ok' });

})

////
// SERVE
////

// Listen for requests.
app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
