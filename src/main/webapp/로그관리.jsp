<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>로그 기록</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #000;
      color: #fff;
      margin: 0;
      padding: 0;
    }

    .container {
      margin: 20px auto;
      width: 90%;
      max-width: 800px;
    }

    h1 {
      font-family: Arial;
      margin-bottom: 5px;
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
  </style>
</head>
<body>
  <div class="container">
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
