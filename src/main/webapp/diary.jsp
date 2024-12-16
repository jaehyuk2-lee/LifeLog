<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="icon" href="./images/Logo.png">
  <title>Life Log</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #1e1e1e;
      color: white;
      margin: 0;
      padding: 0;
      display: flex;
      height: 100vh;
    }

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

    .content-container {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow-y: auto;
    }

    .container {
      display: flex;
      flex-wrap: wrap;
      row-gap: 50px;
      column-gap: 30px;
      padding: 20px;
      justify-content: flex-start;
    }

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
      opacity: 0; /* 초기 상태 */
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
      color: #000000;
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

    .menu-bar {
      width:200px;
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
    
    
    .place-bottom{
      	bottom: 12px;
      	width: 160px;
     	position: absolute;
     }
  </style>
</head>
<body>
  <div class="menu-bar">
    <div class="logo-container"  onclick="location.href='main.jsp'">
      <img src="./images/Logo.png" alt="Logo" class="logo" />
      <div class="logo-text">Life Log</div>
    </div>
    <div class="menu-item" data-page="main" onclick="location.href='main.jsp'">메인</div>
    <div class="menu-item" data-page="log-analysis" onclick="location.href='log_analyze.jsp'">로그 분석</div>
    <div class="menu-item" data-page="log-record" onclick="location.href='goal_set.jsp'">로그 기록</div>
    <div class="menu-item active" data-page="diary" onclick="location.href='diary.jsp'">일기</div>
    <div class="menu-item place-bottom" onclick="location.href='SignOut.jsp'">로그아웃</div>
  </div>

  <div class="content-container">
    <div class="controls">
      <button id="addDiaryButton">+ 일기 추가</button>
    </div>

    <div class="container" id="diaryContainer">
    </div>
  </div>

  <script>
    const diaryContainer = document.getElementById('diaryContainer');
    const addDiaryButton = document.getElementById('addDiaryButton');

    addDiaryButton.addEventListener('click', () => {
      const diaryBox = createDiaryBox();
      diaryContainer.appendChild(diaryBox);

      setTimeout(() => {
        diaryBox.classList.add('show');
      }, 10);
    });

    function createDiaryBox(entry = {}) {
      const diaryBox = document.createElement('div');
      diaryBox.className = 'diary-box';
      diaryBox.setAttribute('data-entry-id', entry.entry_id || '');

      const header = document.createElement('header');
      const dateLabel = document.createElement('span');
      dateLabel.className = 'date-label';
      dateLabel.textContent = entry.date_written || '날짜 선택';

      const dateIcon = document.createElement('span');
      dateIcon.className = 'date-icon';
      dateIcon.textContent = '📅';

      header.appendChild(dateLabel);
      header.appendChild(dateIcon);

      const content = document.createElement('div');
      content.className = 'content';
      content.contentEditable = false;
      content.textContent = entry.diary_content || '내용';

      const deleteButton = document.createElement('button');
      deleteButton.className = 'delete-button';
      deleteButton.textContent = '×';

      diaryBox.appendChild(header);
      diaryBox.appendChild(content);
      diaryBox.appendChild(deleteButton);

      addCalendarFunctionality(dateLabel, dateIcon, diaryBox);

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
          saveDiary(diaryBox);
        }
      });

      content.addEventListener('blur', () => {
        saveDiary(diaryBox);
      });

      deleteButton.addEventListener('click', () => {
        const entryId = diaryBox.getAttribute('data-entry-id');
        if (entryId) {
          deleteDiary(entryId, diaryBox);
        } else {
          diaryBox.classList.add('hide');
          setTimeout(() => {
            diaryContainer.removeChild(diaryBox);
          }, 500);
        }
      });

      return diaryBox;
    }

    function addCalendarFunctionality(dateLabel, dateIcon, diaryBox) {
      dateIcon.addEventListener('click', () => {
        const existingInput = dateLabel.querySelector('input[type="date"]');
        if (existingInput) {
          dateLabel.removeChild(existingInput);
          if (!diaryBox.getAttribute('data-entry-id')) {
            dateLabel.textContent = '날짜 선택';
          }
          return;
        }

        const dateInput = document.createElement('input');
        dateInput.type = 'date';
        dateInput.addEventListener('change', () => {
          if (dateInput.value) {
            dateLabel.textContent = dateInput.value;
            saveDiary(diaryBox);
          }
        });

        dateLabel.textContent = '';
        dateLabel.appendChild(dateInput);
        dateInput.focus();
      });
    }

    function saveDiary(diaryBox) {
      const entryId = diaryBox.getAttribute('data-entry-id');
      const content = diaryBox.querySelector('.content').textContent.trim();
      const dateWritten = diaryBox.querySelector('.date-label').textContent.trim();

      if (!dateWritten || dateWritten === '날짜 선택') {
        alert('날짜를 선택해주세요.');
        return;
      }

      if (!content || content === '내용') {
        alert('내용을 입력해주세요.');
        return;
      }

      const data = {
        entry_id: entryId,
        diary_content: content,
        date_written: dateWritten
      };

      fetch('saveDiaries.jsp', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
        },
        body: new URLSearchParams(data)
      })
      .then(response => response.json())
      .then(result => {
        if (result.status === 'success') {
          if (!entryId) {
            diaryBox.setAttribute('data-entry-id', result.entry_id);
          }
          alert(result.message);
        } else if (result.status === 'session_expired') {
          alert(result.message);
          window.location.href = 'SignIn.jsp';
        } else {
          alert(result.message);
        }
      })
      .catch(error => {
        console.error('Error:', error);
        alert('서버와의 통신 중 오류가 발생했습니다.');
      })
      .finally(() => {
        diaryBox.querySelector('.content').contentEditable = false;
        diaryBox.querySelector('.content').classList.remove('active');
      });
    }

    function deleteDiary(entryId, diaryBox) {
      if (!confirm('정말로 이 일기를 삭제하시겠습니까?')) {
        return;
      }

      fetch('deleteDiary.jsp', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
        },
        body: new URLSearchParams({ entry_id: entryId })
      })
      .then(response => response.json())
      .then(result => {
        if (result.status === 'success') {
          diaryBox.classList.add('hide');
          setTimeout(() => {
            diaryContainer.removeChild(diaryBox);
          }, 500);
        } else if (result.status === 'session_expired') {
          alert(result.message);
          window.location.href = 'SignIn.jsp';
        } else {
          alert(result.message);
        }
      })
      .catch(error => {
        console.error('Error:', error);
        alert('서버와의 통신 중 오류가 발생했습니다.');
      });
    }

    function loadDiaries() {
      console.log('Loading diaries...');
      fetch('loadDiaries.jsp', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json;charset=UTF-8'
        }
      })
      .then(response => {
        console.log('Load Diaries Response:', response);
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(result => {
        console.log('Load Diaries Result:', result);
        if (result.status === 'success') {
          result.diaries.forEach(diary => {
            const diaryBox = createDiaryBox(diary);
            diaryContainer.appendChild(diaryBox);

            setTimeout(() => {
              diaryBox.classList.add('show');
            }, 10);
          });
        } else if (result.status === 'session_expired') {
          alert(result.message);
          window.location.href = 'SignIn.jsp';
        } else {
          alert(result.message);
        }
      })
      .catch(error => {
        console.error('Load Diaries Error:', error);
        alert('서버와의 통신 중 오류가 발생했습니다.');
      });
    }

    window.addEventListener('DOMContentLoaded', loadDiaries);
  </script>
</body>
</html>