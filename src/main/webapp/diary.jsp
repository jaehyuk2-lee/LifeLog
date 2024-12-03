<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>일기 추가</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: black;
      color: white;
      margin: 0;
      padding: 0;
      display: flex;
      height: 100vh;
    }

	/* 콘텐츠 컨테이너 스타일 */
    .content-container {
      flex: 0.8; /* 오른쪽 콘텐츠의 크기 비율 */
      display: flex;
      flex-direction: column;
      overflow-y: auto; /* 스크롤을 허용 */
    }
    
    /* 상단 컨트롤 스타일 */
    .controls {
      text-align: left;
      padding: 20px;
      border-bottom: 2px solid #2D488B;
    }

    .controls button {
      background-color: transparent;
      border: none;
      color: white;
      font-size: 18px;
      font-weight: bold;
      cursor: pointer;
    }

    .controls button:hover {
      color: #2D488B;
    }

    /* 컨테이너 스타일 */
    .container {
      display: flex;
      flex-wrap: wrap;
      row-gap: 50px;
      column-gap: 30px;
      padding: 20px;
      justify-content: flex-start;
    }

    /* 다이어리 박스 스타일 */
    .diary-box {
      width: 250px;
      height: 250px;
      background-color: white;
      color: black;
      border: 1px solid #ccc;
      border-radius: 5px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      position: relative;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      opacity: 0;
      transform: scale(0.9);
      transition: opacity 0.5s ease, transform 0.5s ease;
    }

    .diary-box.show {
      opacity: 1;
      transform: scale(1);
    }

    .diary-box.hide {
      opacity: 0;
      transform: scale(0.9);
    }

    .diary-box header {
      background-color: #ccc;
      padding: 5px;
      text-align: center;
      font-weight: bold;
      position: relative;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .diary-box header .date-label {
      flex-grow: 1;
      text-align: center;
    }

    .diary-box header .date-icon {
      cursor: pointer;
      position: relative;
    }

    .diary-box .content {
      flex-grow: 1;
      padding: 10px;
      font-size: 14px;
      overflow-y: auto;
      color: black;
      opacity: 0.7;
      cursor: pointer;
    }

    .diary-box .content.active {
      color: black;
      opacity: 1;
      cursor: text;
    }

    .diary-box .delete-button {
      position: absolute;
      bottom: 10px;
      right: 10px;
      background-color: transparent;
      color: rgba(0, 0, 0, 0.5);
      font-size: 20px;
      font-weight: bold;
      border: none;
      cursor: pointer;
    }

    .diary-box .delete-button:hover {
      color: rgba(0, 0, 0, 0.8);
    }

    header input[type="date"] {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      z-index: 1;
      background: white;
      border: 1px solid #ccc;
      border-radius: 4px;
      padding: 5px;
    }
    
    /* 메뉴 바 스타일 */
    .menu-bar {
      flex: 0.109;
      background-color: #274a8f;
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
    <div class="menu-item" data-page="log-record" onclick="location.href='로그관리.jsp'">로그 기록</div>
    <div class="menu-item" data-page="goal-management" onclick="location.href='goal_set.jsp'">목표 관리</div>
    <div class="menu-item active" data-page="diary" onclick="location.href='일기추가.jsp'">일기</div>
  </div>
	
  <div class="content-container">
    <div class="controls">
      <button id="addDiaryButton">+ 일기 추가</button>
    </div>

  <div class="container" id="diaryContainer">
    <% 
        String url = "jdbc:mysql://localhost:3306/user_logs_db";
        String username = "lifelog_admin";
        String password = "q1w2e3r4";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, username, password);
            stmt = conn.createStatement();
            String query = "SELECT * FROM diary ORDER BY entry_id"; // 모든 일기 가져오기
            rs = stmt.executeQuery(query);

            while (rs.next()) {
                int entryId = rs.getInt("entry_id");
                String dateWritten = rs.getString("date_written");
                String diaryContent = rs.getString("diary_content");
    %>
    <div class="diary-box show" id="diary-<%= entryId %>">
      <header>
        <span class="date-label"><%= dateWritten %></span>
        <span class="date-icon">📅</span>
      </header>
      <div class="content" contenteditable="false"><%= diaryContent %></div>
      <button class="delete-button" onclick="deleteDiary('<%=entryId %>')">×</button>
    </div>
    <% 
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    %>
  </div>
  </div>

  <script>
  document.addEventListener('DOMContentLoaded', () => {
	  const diaryContainer = document.getElementById('diaryContainer');
	  const addDiaryButton = document.getElementById('addDiaryButton');

	  // Add a new diary box
	  addDiaryButton.addEventListener('click', () => {
	    const diaryBox = createDiaryBox();
	    diaryContainer.appendChild(diaryBox);

	    // 애니메이션 효과를 위해 다음 프레임에 .show 클래스 추가
	    setTimeout(() => diaryBox.classList.add('show'), 10);
	  });

	  // Create a new diary box
	  function createDiaryBox() {
	    const diaryBox = document.createElement('div');
	    diaryBox.className = 'diary-box';

	    const header = document.createElement('header');
	    const dateLabel = document.createElement('span');
	    dateLabel.className = 'date-label';
	    dateLabel.textContent = '날짜 선택';

	    const dateIcon = document.createElement('span');
	    dateIcon.className = 'date-icon';
	    dateIcon.textContent = '📅';

	    header.appendChild(dateLabel);
	    header.appendChild(dateIcon);

	    const content = document.createElement('div');
	    content.className = 'content';
	    content.contentEditable = false;
	    content.textContent = '내용';

	    const deleteButton = document.createElement('button');
	    deleteButton.className = 'delete-button';
	    deleteButton.textContent = '×';

	    diaryBox.appendChild(header);
	    diaryBox.appendChild(content);
	    diaryBox.appendChild(deleteButton);

	    // Add functionality
	    addCalendarFunctionality(dateLabel, dateIcon);
	    addContentEditing(content);
	    addDeleteFunctionality(diaryBox, deleteButton);

	    return diaryBox;
	  }

	  // Add calendar functionality
	  function addCalendarFunctionality(dateLabel, dateIcon) {
	    dateIcon.addEventListener('click', () => {
	      const existingInput = dateLabel.querySelector('input[type="date"]');
	      if (existingInput) {
	        dateLabel.removeChild(existingInput);
	        return;
	      }

	      const dateInput = document.createElement('input');
	      dateInput.type = 'date';
	      dateInput.addEventListener('change', () => {
	        if (dateInput.value) {
	          dateLabel.textContent = dateInput.value;
	        }
	      });

	      dateLabel.textContent = ''; // Clear existing text
	      dateLabel.appendChild(dateInput);
	      dateInput.focus();
	    });
	  }

	  // Add content editing functionality
	  function addContentEditing(content) {
	    content.addEventListener('click', () => {
	      content.contentEditable = true;
	      content.focus();
	      content.classList.add('active');
	      if (content.textContent === '내용') {
	        content.textContent = '';
	      }
	    });

	    content.addEventListener('keypress', (event) => {
	      if (event.key === 'Enter') {
	        event.preventDefault();
	        content.contentEditable = false;
	      }
	    });

	    content.addEventListener('blur', () => {
	      if (content.textContent.trim() === '') {
	        content.textContent = '내용';
	        content.classList.remove('active');
	      }
	      content.contentEditable = false;
	    });
	  }

	  // Add delete functionality
	  function addDeleteFunctionality(diaryBox, deleteButton) {
	    deleteButton.addEventListener('click', () => {
	      diaryBox.classList.add('hide'); // Hide 애니메이션 추가
	      setTimeout(() => diaryContainer.removeChild(diaryBox), 500); // DOM에서 삭제
	    });
	  }

	  // Initialize existing diary boxes
	  document.querySelectorAll('.diary-box').forEach((box) => {
	    const header = box.querySelector('header');
	    const dateLabel = header.querySelector('.date-label');
	    const dateIcon = header.querySelector('.date-icon');
	    const content = box.querySelector('.content');
	    const deleteButton = box.querySelector('.delete-button');

	    addCalendarFunctionality(dateLabel, dateIcon);
	    addContentEditing(content);
	    addDeleteFunctionality(box, deleteButton);
	  });
	});

  </script>
</body>
</html>
