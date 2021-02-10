const express = require('express')
const app = express()
const path = require('path');
const port = 8080

app.use('/static', express.static(path.join(__dirname, 'static')))
app.get('/', function(req, res){
  console.log("- main page")
  res.sendFile(path.join(__dirname, 'static', 'index.html'));
})

app.get('/api/random', function(req, res) {
  console.log("- random")
  res.send("Random")
})

app.get('/api/about', function(req, res, next) {
  console.log("- about")
  res.send("About")
})

app.listen(port, function() {
  console.log("Run on port", port)
})
