const WebSocket = require('ws');
const http = require('http');
const os = require('os');
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('WebSocket Server');
});

const wss = new WebSocket.Server({ server });

const connections = {}; // Lưu trữ kết nối bằng ID hoặc tên người dùng

wss.on('connection', (ws) => {
  var connectionId = null; 
  console.log('Client connected');
  ws.on('message', (message) => {
    var data = JSON.parse(message.toString()); 
    if (data.action === 'newID') {
      if (connectionId==null) {
        connectionId = data.id;
        connections[connectionId] = ws;
        console.log(connectionId+" Connect");
      } else{
        console.log(connectionId+' Reconnect');
        connections[connectionId].send('{"action":"reconnect"}'); 
      }
    }
    if(data.action ==="remote"){
      connections[data.to].send(JSON.stringify(data));
      console.log(data);
    }
    if(data.action==="getIP"){
      var ip = getLocalIPAddress();
      var data = JSON.stringify({action:"responseIP",ip:ip});
      ws.send(data);
    }
  });

  ws.on('close', () => {
    console.log('Client disconnected');
    // Xóa kết nối đã đóng khỏi danh sách connections
    delete connections[connectionId];
  }); 
});
function getLocalIPAddress() {
  const networkInterfaces = os.networkInterfaces();
  // Assuming you want the first non-internal IPv4 address
  for (const interfaceName in networkInterfaces) {
    const interface = networkInterfaces[interfaceName];
    for (const item of interface) {
      if (item.family === 'IPv4' && !item.internal) {
        return item.address;
      }
    }
  }
  return '127.0.0.1'; // Default to localhost if no valid IP found
}
server.listen(8080, () => {
  console.log('Server is listening on port 8080');
});