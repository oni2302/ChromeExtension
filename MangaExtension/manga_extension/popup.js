// Kết nối tới background.js
var port = chrome.runtime.connect({ name: "socket" });

// Gửi thông điệp tới background.js (nếu cần)
port.postMessage({action:"getIP"});

// Lắng nghe các thông điệp từ background.js
port.onMessage.addListener(function (msg) {
    var data = JSON.parse(msg);
    console.log(data);
    var qrcode = new QRCode("qr", {
        text: data.ip,
        width: 128,
        height: 128,
        colorDark : "#000000",
        colorLight : "#ffffff",
        correctLevel : QRCode.CorrectLevel.H
    });
});
