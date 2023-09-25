const WebSocket = require('ws');
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('WebSocket Server');
});

const wss = new WebSocket.Server({ server });

const connections = {}; // Lưu trữ kết nối bằng ID hoặc tên người dùng

wss.on('connection', (ws) => {
  console.log('Client connected');

  // Gán một ID hoặc tên người dùng cho kết nối
  const connectionId = generateUniqueId(); // Hàm này tạo ID ngẫu nhiên, bạn có thể tùy chỉnh
  connections[connectionId] = ws;

  ws.on('message', (message) => {
    if(message.toString() === 'getToken'){
      ws.send(connectionId);
    }else{
      var request = message.toString().split('|');
      var id = request[0];
      console.log(id);
      var content = request[1];
      connections[id].send(id+'|'+content);
    }
  });

  ws.on('close', () => {
    console.log('Client disconnected');

    // Xóa kết nối đã đóng khỏi danh sách connections
    delete connections[connectionId];
  });
});

server.listen(8080, () => {
  console.log('Server is listening on port 8080');
});


function generateUniqueId() {
  // Hàm này để tạo một ID ngẫu nhiên, bạn có thể sử dụng UUID hoặc cách tạo ID duy nhất khác
  return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
}