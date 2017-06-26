console.log('Hello world');


var tmp = require('fs');
var randWeb = require('net');
var sql = require('m');
var util = require('util');
var connStr = "Driver={SQL Server Native Client 11.0};Server=myySqlDb,1433;Database=DB;UID=Henry;PWD=cat;";
var query = "SELECT * FROM GAData WHERE TestID = 17";

// Load the http module to create an http server.
var http = require('http');

var soapC
    // Configure our HTTP server to respond with Hello World to all requests.
var server = http.createServer(function(request, response) {

    sql.open(connStr, function(err, conn) {
        if (err) {
            return console.error("Could not connect to sql: ", err);
        }

        conn.query(query, function(err, results) {

            if (err) {
                return console.error("Error running query: ", err);
            }
            response.writeHead(200, { "Content-Length": results.length });
            response.writeHead(200, { "Content-Type": "application/json" });
            response.end(results);
        });
    });

});

// Listen on port 8000, IP defaults to 127.0.0.1
server.listen(8000);

// Put a friendly message on the terminal
console.log("Server running at http://127.0.0.1:8000/");