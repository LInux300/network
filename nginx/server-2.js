var ws = new WebSocket('ws://localhost:8050/');

ws.onmessage = function(event) {
  console.log('Count is: ' + event.data);
};
