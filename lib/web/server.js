const express = require('express')
const path = require('path')
const vm = require("vm");
const fs = require('fs');

const app = express();
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
// READ.
////

var load_db = () => {

  const data = fs.readFileSync(db_path);
  const script = new vm.Script(data);
  script.runInThisContext();
  return JSON.parse(db);

}

////
// DELETE.
////

// Handle executions delete request.
app.post('/executions/delete', (req, res) => {

  // Get reflection ID.
  var exe_id = req.body.exe_id;
  var number = req.body.number;
  console.log(number);

  // Get database.
  db = load_db();

  for (let [index, reflection] of db.reflections.entries()) {
    if (reflection.e == exe_id && reflection.n == number) {
      console.log("DELETED:")
      console.log(db.reflections[index]);
      db.reflections.splice(index, 1);
    }
    if (reflection.b != null && reflection.b == exe_id && reflection.n == number) {
      console.log("DELETED:")
      console.log(db.reflections[index]);
      db.reflections.splice(index, 1);
    }
  }

  // Save database.
  try {
    fs.writeFileSync(db_path, 'var db = ' + JSON.stringify(JSON.stringify(db)) + ';');
  }
  catch (err) {
    console.error(err)
  }

  res.status(200).send({ message: 'ok' });

})

// Handle reflections delete request.
app.post('/reflections/delete', (req, res) => {

  // Get reflection ID.
  ref_id = req.body.ref_id;

  // Get database.
  db = load_db();

  // Delete reflection.
  for (let [index, reflection] of db.reflections.entries()) {
    if (reflection.r == ref_id) {
      console.log("DELETED:")
      console.log(db.reflections[index]);
      db.reflections.splice(index, 1);
      break;
    }
  }

  // Save database.
  try {
    fs.writeFileSync(db_path, 'var db = ' + JSON.stringify(JSON.stringify(db)) + ';');
  }
  catch (err) {
    console.error(err)
  }

  res.status(200).send({ message: 'ok' });

})

////
// UPDATE.
////

// Handle reflections keep request.
app.post('/reflections/keep', (req, res) => {
  console.log(req.body);
})

// Listen for requests.
app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})

//fs.readFile('student.json', (err, data) => {
//  if (err) throw err;
//  let student = JSON.parse(data);
//  console.log(student);
//});
