// background.js
var socket = null;
var idCon = 'oni';
var ip = null;
var currentPort = null;
// Import các API của extension
chrome.runtime.onConnect.addListener(function (port) {
  currentPort = port;
  // Khi một kết nối mới được thiết lập từ popup.js hoặc content.js
  if (port.name === "socket") {
    // Xử lý kết nối socket ở đây
    if (!socket || socket.readyState !== WebSocket.OPEN) {
      // Ví dụ: Kết nối tới một server socket
      socket = new WebSocket("ws://localhost:8080");
      setInterval(() => {
        if (!socket || socket.readyState !== WebSocket.OPEN)
          socket = new WebSocket("ws://localhost:8080");
        else {
          var data = JSON.stringify({ action: 'newID', id: idCon });
          socket.send(data);
        }
        console.log("connect");
      }, 10000);
      // Xử lý các sự kiện của socket
      socket.onopen = function (event) {
        var data = JSON.stringify({ action: "getIP" });
        socket.send(data);
      };
      socket.onmessage = function (event) {
        // Xử lý dữ liệu nhận được từ server
        const data = JSON.parse(event.data);
        if (data.action === "remote") {
          if (data.command === "down") {
            chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
              var distance = data.scroll;
              var duration = data.speed;
              chrome.scripting.executeScript({
                target: { tabId: tabs[0].id },
                function: (distance, duration) => {
                  const startingY = window.scrollY;
                  let start;

                  // Animation function
                  function step(timestamp) {
                    if (!start) start = timestamp;
                    const time = timestamp - start;
                    const percent = Math.min(time / duration, 1);
                    window.scrollTo(0, startingY + (distance * percent));
                    if (time < duration) {
                      window.requestAnimationFrame(step);
                    }
                  }

                  // Start the animation
                  window.requestAnimationFrame(step);
                },
                args: [distance, duration]
              });
            });

          } if (data.command === "up") {
            chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
              var distance = -data.scroll;
              var duration = data.speed;
              chrome.scripting.executeScript({
                target: { tabId: tabs[0].id },
                function: (distance, duration) => {
                  const startingY = window.scrollY;
                  let start;

                  // Animation function
                  function step(timestamp) {
                    if (!start) start = timestamp;
                    const time = timestamp - start;
                    const percent = Math.min(time / duration, 1);
                    window.scrollTo(0, startingY + (distance * percent));
                    if (time < duration) {
                      window.requestAnimationFrame(step);
                    }
                  }

                  // Start the animation
                  window.requestAnimationFrame(step);
                },
                args: [distance, duration]
              });
            });
          }
          if (data.command === "prev") {
            chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
              chrome.scripting.executeScript({
                target: { tabId: tabs[0].id },
                function: function () {
                  document.querySelector(".prev.control-button.link-prev-chap").click();
                },
              });
            });
          } if (data.command === "next") {
            chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
              chrome.scripting.executeScript({
                target: { tabId: tabs[0].id },
                function: function () {
                  document.querySelector(".next.control-button.link-next-chap").click();
                },
              });
            });
          }
        }
        if (data.action === "responseIP") {
          currentPort.postMessage(JSON.stringify(data));
        }
      };

      socket.onclose = function (event) {
        console.log("Socket closed");
        // Gửi thông báo đóng kết nối tới popup.js hoặc content.js (nếu cần)
        socket = new WebSocket("ws://localhost:8080");
      };
    }
    // Lắng nghe các thông điệp từ popup.js hoặc content.js
    port.onMessage.addListener(function (msg) {
      if (msg.action === "getIP") {
        if (ip == null) {
          var data = JSON.stringify({ action: "getIP" });
          socket.send(data);
        } else {
          var data = JSON.stringify({ action: "responseIP", ip: ip });
          currentPort.postMessage(data);
        }

      }
    });

    // Đóng kết nối socket khi extension bị tắt
    chrome.runtime.onSuspend.addListener(function () {
      socket.close();
    });
  }
});
