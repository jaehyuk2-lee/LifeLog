<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" href="./images/Logo.png">
    <title>Life Log</title>
    <style>
      body,
      html {
        margin: 0;
        padding: 0;
        font-family: Arial, sans-serif;
        background-color: #1e294a;
        color: white;
      }

      .signup-container {
        display: flex;
        height: 100vh;
      }

      .signup-left {
        flex: 1;
        background-color: #274a8f;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 20px;
        animation: slide-in-left1 1s cubic-bezier(0.25, 0.46, 0.45, 0.94) both;
        z-index: 1;
      }
      @keyframes slide-in-left1 {
        0% {
          transform: translateX(-200px);
        }
        100% {
          transform: translateX(0);
        }
      }

      .signup-left h1 {
        position: relative;
        bottom: 100px;
      }

      .signup-form {
        width: 100%;
        max-width: 300px;
        display: flex;
        flex-direction: column;
      }

      .signup-form label {
        margin-bottom: 5px;
        font-size: 14px;
      }

      .signup-form input {
        margin-bottom: 15px;
        padding: 10px;
        border: none;
        border-radius: 5px;
        font-size: 14px;
      }

      .signup-right {
        flex: 2;
        background-color: #1f305e;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 20px;
        opacity: 0;
        transform: translateX(100%);
        z-index: 0;
      }

      .signup-right.slide-in-left2 {
        animation: slide-in-left2 1s cubic-bezier(0.25, 0.46, 0.45, 0.94) both;
      }
      @keyframes slide-in-left2 {
        0% {
          transform: translateX(-400px);
        }
        100% {
          transform: translateX(0);
        }
      }

      .signup-form-right {
        width: 100%;
        max-width: 300px;
        display: grid;
        gap: 20px;
      }
      .signup-right.visible {
        display: flex;
        opacity: 1;
        transform: translateX(0);
      }

      .signup-form-right .form-group {
        display: flex;
        flex-direction: column;
      }

      .signup-form-right input,
      .signup-form-right select {
        padding: 10px;
        border: 1px solid white;
        border-radius: 5px;
        background-color: transparent;
        color: white;
        font-size: 14px;
      }

      .signup-form-right input[type="date"] {
        padding: 10px;
        border: 1px solid white;
        border-radius: 5px;
        color: white;
        font-size: 14px;
        cursor: pointer;
        appearance: none;
      }
      .signup-form-right input[type="date"]::-webkit-calendar-picker-indicator {
        filter: invert(1);
        cursor: pointer;
      }
      
      button {
        padding: 10px;
        border: none;
        color: white;
        border-radius: 5px;
        font-size: 16px;
        cursor: pointer;
      }

      button.next {
        background-color: #007bff;
        margin-bottom: 15px;
      }

      button.complete {
        background-color: #00aaff;
        width: 100%;
      }

      button.reset {
        background-color: transparent;
        border: 1px solid white;
      }
      .empty {
        flex: 2;
      }
      .error {
        color: red;
        font-size: 12px;
        margin-top: -10px;
        margin-bottom: 10px;
      }
    </style>
    <script>
    let isDuplicate = false;
      document.addEventListener("DOMContentLoaded", () => {
        const emailInput = document.getElementById("email");
        const passwordInput = document.getElementById("password");
        const checkPasswordInput = document.getElementById("check-password");
        const nextButton = document.querySelector(".next");
        const rightSection = document.querySelector(".signup-right");

        function showError(input, message) {
          const error = input.nextElementSibling;
          if (error && error.classList.contains("error")) {
            error.textContent = message;
          } else {
            const errorMsg = document.createElement("div");
            errorMsg.className = "error";
            errorMsg.textContent = message;
            input.parentNode.insertBefore(errorMsg, input.nextSibling);
          }
        }

        function clearError(input) {
          const error = input.nextElementSibling;
          if (error && error.classList.contains("error")) {
            error.textContent = "";
          }
        }

        nextButton.addEventListener("click", () => {
          let isValid = true;

          const email = emailInput.value.trim();
          const password = passwordInput.value.trim();
          const checkPassword = checkPasswordInput.value.trim();
          

          if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            showError(emailInput, "이메일 형식이 아닙니다.");
            isValid = false;
          } else {
            clearError(emailInput);
          }

          if (password === "") {
            showError(passwordInput, "패스워드를 입력하세요.");
            isValid = false;
          } else {
            clearError(passwordInput);
          }

          if (password !== checkPassword) {
            showError(checkPasswordInput, "패스워드가 일치하지 않습니다.");
            isValid = false;
          } else {
            clearError(checkPasswordInput);
          }

          if (isValid) {
            rightSection.style.opacity = "1";
            rightSection.style.transform = "translateX(0)";
            rightSection.classList.add("slide-in-left2");
          } else {
            rightSection.style.opacity = "0";
            rightSection.style.transform = "translateX(100%)";
            rightSection.classList.remove("slide-in-left2");
          }
        });
      });
    </script>
  </head>
  <body>
    <form action="SignUp_Check.jsp" method = "post">
      <div class="signup-container">
        <div class="signup-left slide-in-left">
          <h1>Sign up</h1>

          <div class="signup-form">
            <label for="email">Email:</label>
    		<input type="email" id="email" placeholder="Email" name="email" required>
            <label for="password" >Password</label>
            <input
              type="password"
              name = "pwd"
              id="password"
              placeholder="Password"
              required
            />

            <label for="check-password">Check Password</label>
            <input
              type="password"
              id="check-password"
              placeholder="Check Password"
              required
            />

            <button type="button" class="next">다음</button>
            <button
              type="button"
              class="reset"
              onclick="location.href='SignIn.jsp'"
            >
             이전으로
            </button>
          </div>
        </div>

        <div class="signup-right">
          <div class="signup-form-right">
            <div class="form-group">
              <label for="name">이름</label>
              <input type="text" name = "name" id="name" placeholder="이름" required />
            </div>
            <div class="form-group">
              <label for="gender">성별</label>
              <select name ="gender" id="gender" required>
                <option style="color:black;" value="Other">성별</option>
                <option style="color:black;" value="MALE">남성</option>
                <option style="color:black;" value="FEMALE">여성</option>
              </select>
            </div>
            <div class="form-group">
              <label for="dob">생일</label>
              <input type="date" name = "birth" id="dob" required />
            </div>
            <div class="form-group">
              <label for="job">직업</label>
              <input type="text" name = "job" id="job" placeholder="직업" required />
            </div>
            <div class="form-group">
              <label for="organization">소속</label>
              <input
                type="text"
                name = "org"
                id="organization"
                placeholder="소속"
                required
              />
            </div>
            <button type="submit" class="complete">완료</button>
            <button type="reset" class="reset">다시쓰기</button>
          </div>
        </div>
        <div class="empty"></div>
      </div>
    </form>
  </body>
</html>
