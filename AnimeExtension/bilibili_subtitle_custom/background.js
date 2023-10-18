// background.js
var socket = null;
// Import các API của extension
chrome.runtime.onConnect.addListener(function (port) {
  // Khi một kết nối mới được thiết lập từ popup.js hoặc content.js
  if (port.name === "socket") {
    // Xử lý kết nối socket ở đây
    if (!socket || socket.readyState !== WebSocket.OPEN) {
      // Ví dụ: Kết nối tới một server socket
      socket = new WebSocket("ws://localhost:8080");

      // Xử lý các sự kiện của socket
      socket.onopen = function (event) {
        console.log("Socket connected");
        // Gửi dữ liệu tới popup.js hoặc content.js (nếu cần)
        port.postMessage({ message: "Socket connected" });
      };

      socket.onmessage = function (event) {
        // Xử lý dữ liệu nhận được từ server
        console.log("Received data: " + event.data);
        port.postMessage({ request: { token: event.data } });
      };

      socket.onclose = function (event) {
        console.log("Socket closed");
        // Gửi thông báo đóng kết nối tới popup.js hoặc content.js (nếu cần)
        port.postMessage({ message: "Socket closed" });
      };
    }
    // Lắng nghe các thông điệp từ popup.js hoặc content.js
    port.onMessage.addListener(function (msg) {
      if (msg.message === 'getToken') {
        send(socket, msg.message);
      }
    });

    // Đóng kết nối socket khi extension bị tắt
    chrome.runtime.onSuspend.addListener(function () {
      socket.close();
    });
  }
});
function send(socket, message) {
  socket.send(message);
}
