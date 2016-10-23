var WebSocketServer = require('websocket').server;
var http = require('http');

var server = http.createServer(function (request, response) {

  time = (new Date).getTime().toString();

  response.writeHeader(200, {"Content-Type": "text/plain"});
  response.end(time);

});

server.listen(3000, "127.0.0.1");

console.log("Starting server running at http://127.0.0.1:3000/");

websocketServer = new WebSocketServer({
  httpServer: server,
  autoAcceptConnections: false
});

websocketServer.on('request', function(request) {
  console.log("Received connection");
  var connection = request.accept('echo-protocol', request.origin);

  time = (new Date).getTime().toString();
  connection.SendUTF(time);
});
