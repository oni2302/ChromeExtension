chrome.runtime.onConnect.addListener((port) => {
  // Xử lý kết nối socket ở đây và duy trì nó.
});
const socket = new WebSocket('ws://localhost:8080'); // Thay đổi địa chỉ máy chủ WebSocket tương ứng

function sendMessage(message) {
  socket.send(message);
}
socket.onopen = (event) => {
  console.log('Connected to server');

  document.getElementById("getToken").onclick = ()=>sendMessage('getToken');
};

socket.onmessage = (event) => {
  const message = event.data;
  if(message.includes('|')){
    var request = message.substring(message.indexOf('|')+1);
    document.getElementById('action').value = request;
  }else{
    document.getElementById('token').value= message;
  }
  // Xử lý dữ liệu nhận được từ máy chủ ở đây
};
chrome.action.onClicked.addListener((tab) => {
  chrome.scripting.executeScript({
    target: { tabId: tab.id },
    function: (tab) => {
      // Thực hiện các tác vụ trên trang web ở đây
      console.log('Extension đã tác động vào trang web:', tab.url);
    },
  });
});