// Kết nối tới background.js

var port = chrome.runtime.connect({ name: "socket" });

// Gửi thông điệp tới background.js (nếu cần)
port.postMessage({ message: "Hello from popup.js (or content.js)" });

// Lắng nghe các thông điệp từ background.js
port.onMessage.addListener(function (msg) {
  if(msg.message!=null){

  }
  if(msg.request!=null){
    if(msg.request.token!=null){
        document.getElementById("token").value = msg.request.token;
    }
  }
});
function send(port,message){
    port.postMessage({message:message});
}

document.getElementById("getToken").onclick = ()=>send(port,'getToken');
