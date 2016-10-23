#!/usr/local/bin/node

console.log("Starting the server");
var Msg = '';
var WebSocketServer = require('ws').Server
    , wss = new WebSocketServer({port: 8050});
    wss.on('connection', function(ws) {
        ws.on('message', function(message) {
        console.log('Received from client: %s', message);
        ws.send('Server received from client: ' + message);
    });
 });
