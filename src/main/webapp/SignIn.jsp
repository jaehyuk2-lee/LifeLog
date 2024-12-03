<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%
    // 브라우저 캐싱 방지
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html>
  <head>
    <link rel="stylesheet" href="" />
    <meta charset="UTF-8" />
    <link rel="icon" href="./images/Logo.png">
    <title>Life Log</title>
    <style type="text/css">
      body,
      html {
        margin: 0;
        padding: 0;
        height: 100%;
        box-sizing: border-box;
        background-color: #1e294a;
      }

      .container {
        color: white;
        display: flex;
        height: 100vh;
      }
      .menu-panel {
        flex: 2;
        display: grid;
        row-gap: 10px;
        align-items: center;
        padding-top: 40px;
        padding-bottom: 40px;
      }
      .menu-item {
        cursor: pointer;
        position: relative;
        transition: color 0.5s, background-color 0.5s;
        margin: 5px 0;
      }
      .bar {
        height: 25px;
        background-color: #007bff;
        width: 180px;
        transition: width 1s;
      }
      .menu-item.active .bar {
        width: 100%;
        transition: width 1s cubic-bezier(0.25, 0.46, 0.45, 0.94);
      }
      .menu-item:hover .bar {
        width: 100%;
      }
      .preview h1{
      	position:absolute;
      	top: 100px;
      }
      .preview {
        flex: 2;
        color: white;
        background-color: #1e1e1e;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        text-align: center;
        z-index: 0;
      }
      .preview img {
        margin-top: 100px;
        margin-bottom: 150px;
        max-width: 500px;
        max-height: 200px;
        opacity: 1;
        transition: opacity 0.5s ease-in-out;
      }
      .slide-in-right1 {
        animation: slide-in-right1 1s cubic-bezier(0.25, 0.46, 0.45, 0.94) both;
      }
      @keyframes slide-in-right1 {
        0% {
          transform: translateX(900px);
        }
        100% {
          transform: translateX(0);
        }
      }
      .slide-in-right2 {
        animation: slide-in-right2 1s cubic-bezier(0.25, 0.46, 0.45, 0.94) both;
      }
      @keyframes slide-in-right2 {
        0% {
          transform: translateX(200px);
        }
        100% {
          transform: translateX(0);
        }
      }
      .preview img.hidden {
        opacity: 0;
      }
      .login {
        flex: 1;
        background-color: #274a8f;
        color: white;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 20px;
        z-index: 1;
      }

      .login-header h1 {
        margin-bottom: 30px;
      }

      .login-form {
        margin-top: 100px;
        margin-bottom: 150px;
        width: 100%;
        max-width: 300px;
        display: flex;
        flex-direction: column;
      }

      .login-form label {
        margin-bottom: 5px;
        font-size: 14px;
      }

      .login-form input {
        margin-bottom: 15px;
        padding: 10px;
        border: none;
        border-radius: 5px;
        font-size: 14px;
      }

      button {
        padding: 10px;
        border: none;
        border-radius: 5px;
        font-size: 16px;
        cursor: pointer;
      }

      button.sign-in {
        background-color: #007bff;
        color: white;
        margin-bottom: 10px;
      }

      button.sign-up {
        background-color: transparent;
        color: white;
        border: 1px solid white;
      }
    </style>
    <script>
      document.addEventListener("DOMContentLoaded", () => {
        const menuItems = document.querySelectorAll(".menu-item");
        const previewImage = document.querySelector(".preview img");
        const images = [
          "./images/set.png",
          "./images/visualize.png",
          "./images/analysis.png",
          "./images/todo.png",
        ];
        let currentIndex = 0;
        let timer;

        function activateMenuItem(index) {
          menuItems.forEach((item) => item.classList.remove("active"));
          setTimeout(() => {
            menuItems[index].classList.add("active");
          }, 1);
          previewImage.classList.add("hidden");
          setTimeout(() => {
            previewImage.src = images[index];
            previewImage.classList.remove("hidden");
          }, 500);
        }

        function startCycle() {
          timer = setInterval(() => {
            currentIndex = (currentIndex + 1) % menuItems.length;
            activateMenuItem(currentIndex);
          }, 3000);
        }

        menuItems.forEach((item, index) => {
          item.addEventListener("mouseenter", () => {
            clearInterval(timer);

            activateMenuItem(index);
            currentIndex = index;
          });

          item.addEventListener("mouseleave", () => {
            startCycle();
          });
        });

        activateMenuItem(currentIndex);
        startCycle();
      });
    </script>
  </head>
  <body>
    <div class="container">
      <div class="menu-panel">
        <div class="menu-item" id="setup">
          <h3>Set up</h3>
          <div class="bar"></div>
        </div>
        <div class="menu-item" id="visualize">
          <h3>Visualize</h3>
          <div class="bar"></div>
        </div>
        <div class="menu-item" id="analysis">
          <h3>Analysis</h3>
          <div class="bar"></div>
        </div>
        <div class="menu-item" id="summary">
          <h3>To Do</h3>
          <div class="bar"></div>
        </div>
      </div>
		
      <div class="preview slide-in-right1">
      <h1>Preivew</h1>
        <img src="./image/2.jpg" alt="" height="250px" />
      </div>
      <div class="login slide-in-right2">
        <div class="login-header">
          <h1>Life Log</h1>
        </div>
        <form action="SignIn_Check.jsp" method="post" class="login-form">
          <label for="email">Email</label>
          <input type="email" name="email" id="email" placeholder="Email" required />

          <label for="password">Password</label>
          <input
            type="password"
            name="password"
            id="password"
            placeholder="Password"
            required
          />

          <button type="submit" class="sign-in">로그인</button>
          <button class="sign-up" onclick="location.href='SignUp.jsp'">
           회원가입
          </button>
        </form>
      </div>
    </div>
  </body>
</html>
