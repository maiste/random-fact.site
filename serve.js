/*
 * Server file
 */ 

// ---- IMPORT
const express = require('express')
const sqlite3 = require('sqlite3').verbose();
const app = express()
const path = require('path');

// ---- SETUP
const port = 8080
const db = new sqlite3.Database('random-fact')

db.serialize(function(){
  db.run('CREATE TABLE IF NOT EXISTS fact (id INTEGER PRIMARY KEY AUTOINCREMENT, fact TEXT)')
})


// ---- FUNCTION FOR DB
function isUndefined(row) {
  return row === undefined;
}

function send_random_sentence(callback) {
  db.get("SELECT MAX(id) from fact", function(_, row){
    if(isUndefined(row)) {
      return "An error occured.";
    } else {
      let max = Math.floor(Math.random() * row['MAX(id)']) + 1;
      let sql = "SELECT fact FROM fact WHERE id = "  + max;
      db.get(sql, function(err, row) {
        if(isUndefined(row)) {
          console.log(err);
          callback(err);
        } else {
          callback(row['fact']);
        }
    })
    }
  })
}

// ---- ROUTING
app.use('/static', express.static(path.join(__dirname, 'static')))
app.get('/', function(_, res){
  console.log("- main page")
  res.sendFile(path.join(__dirname, 'static', 'index.html'));
})

app.get('/api/random', function(_, res) {
  console.log("- random")
  send_random_sentence(function(result) {
    res.send(result)
  })
})

app.get('/api/about', function(_, res) {
  console.log("- about")
  res.send("Created by Etienne Marais")
})


// ---- RUN APP
app.listen(port, function() {
  console.log("Run on port", port)
})


