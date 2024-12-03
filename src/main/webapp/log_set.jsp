<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>로그 기록</title>
  <style>
  	html, body {
      height: 100%;
      margin: 0;
      padding: 0;
  	}
    body {
      font-family: Arial, sans-serif;
      background-color: #1e1e1e;
      color: white;
      display: flex;
    }

    .content-container {
      flex: 0.8; /* 콘텐츠 영역 비율 */
      margin: 20px;
      width: 100%;
    }

    h1 {
      font-family: Arial;
      margin-bottom: 20px;
      color: #fff;
      border-bottom: 2px solid #2D488B;
      padding-bottom: 10px;
      text-align: left;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 5px;
      border-bottom: 2px solid #2D488B;
    }

    th, td {
      padding: 10px;
      text-align: center;
    }

    thead tr {
      border-bottom: 1px solid #444;
    }

    tbody tr {
      border-bottom: 1px solid #444;
    }

    tbody tr:last-child {
      border-bottom: none;
    }

    input[type="text"] {
      width: 90%;
      padding: 8px;
      background-color: #000;
      color: #fff;
      border: 1px solid #444;
      text-align: center;
    }

    .button-container {
      text-align: left;
      margin-top: 10px;
    }

    button {
      padding: 10px 20px;
      margin: 5px;
      border: none;
      background-color: #2D488B;
      color: white;
      cursor: pointer;
    }

    button:hover {
      background-color: #218838;
    }

    .list-dot {
      font-size: 18px;
      text-align: center;
      }
      
    .menu-bar {
      flex: 0.1; /* 메뉴바 비율 */
      background-color: #274a8f; /* 메뉴바 배경색 */
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 20px 10px;
      gap: 20px;
    }
    
    .menu-bar .logo-container {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 20px;
    }

    .menu-bar .logo {
      height: 50px;
      width: auto;
    }

    .menu-bar .logo-text {
      font-size: 24px;
      font-weight: bold;
      color: white;
    }

    .menu-item {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 15px;
      width: 80%;
      color: white;
      text-align: center;
      background-color: #274a8f;
      border-radius: 5px;
      cursor: pointer;
      transition: background-color 0.3s ease;
    }

    .menu-item:hover,
    .menu-item.active {
      background-color: #007bff;
    }
  </style>
</head>
<body>
<div class="menu-bar">
    <div class="logo-container">
      <img src="./image/Logo.png" alt="Logo" class="logo" />
      <div class="logo-text">Life Log</div>
    </div>
    <div class="menu-item" data-page="main" onclick="location.href='main.jsp'">메인</div>
    <div class="menu-item" data-page="log-analysis" onclick="location.href='log_analyze.jsp'">로그 분석</div>
    <div class="menu-item active" data-page="log-record" onclick="location.href='log_set.jsp'">로그 기록</div>
    <div class="menu-item" data-page="diary" onclick="location.href='일기추가.jsp'">일기</div>
  </div>
  
  <div class="content-container">
    <h1>로그 기록</h1>
    <table id="logTable">
      <thead>
        <tr>
          <th></th>
          <th>로그</th>
          <th>기록</th>
          <th>목표</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td class="list-dot">•</td>
          <td>운동량</td>
          <td><input type="text" placeholder="기록 입력"></td>
          <td>540 kcal</td>
        </tr>
        <tr>
          <td class="list-dot">•</td>
          <td>수면</td>
          <td><input type="text" placeholder="기록 입력"></td>
          <td>-</td>
        </tr>
        <tr>
          <td class="list-dot">•</td>
          <td>물 섭취</td>
          <td><input type="text" placeholder="기록 입력"></td>
          <td>2L</td>
        </tr>
        <tr>
          <td class="list-dot">•</td>
          <td>음주</td>
          <td><input type="text" placeholder="기록 입력"></td>
          <td>3번 이하</td>
        </tr>
        <tr>
          <td class="list-dot">•</td>
          <td>공부</td>
          <td><input type="text" placeholder="기록 입력"></td>
          <td>6H</td>
        </tr>
      </tbody>
    </table>
    <div class="button-container">
      <button id="saveChanges">수정완료</button>
    </div>
  </div>
  <script>
    document.addEventListener("DOMContentLoaded", () => {
      const tableBody = document.getElementById("logTable").querySelector("tbody");
      const saveChangesBtn = document.getElementById("saveChanges");

      // Save changes: Replace filled inputs with text, keep empty inputs
      saveChangesBtn.addEventListener("click", () => {
        const rows = tableBody.querySelectorAll("tr");
        rows.forEach((row) => {
          const inputs = row.querySelectorAll("input");
          inputs.forEach((input) => {
            const value = input.value.trim(); // Get the value of the input
            const cell = input.parentElement; // Get the parent cell of the input
            if (value) {
              cell.textContent = value; // Replace input with its value
            }
          });
        });
      });
    });
  </script>
</body>
</html>
