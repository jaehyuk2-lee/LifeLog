<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="icon" href="./images/Logo.png">
  <title>Life Log</title>
  <style>
    /* 기존 CSS 스타일 유지 */
    body {
      font-family: Arial, sans-serif;
      background-color: #1e1e1e;
      color: white;
      margin: 0;
      padding: 0;
      display: flex;
      height: 100vh;
    }

    /* 상단 컨트롤 스타일 */
    .controls {
      text-align: left; /* 왼쪽 정렬 */
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
      flex: 1; /* 남은 모든 공간을 차지하도록 설정 */
      display: flex;
      flex-direction: column;
      overflow-y: auto; /* 스크롤 가능 */
    }

    /* 컨테이너 스타일 */
    .container {
      display: flex;
      flex-wrap: wrap;
      row-gap: 50px; /* 카드 위아래 간격 */
      column-gap: 30px; /* 카드 좌우 간격 */
      padding: 20px;
      justify-content: flex-start;
    }

    /* 다이어리 박스 스타일 */
    .diary-box {
      width: 250px; /* 카드 너비 */
      height: 250px; /* 카드 높이 */
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
      color: #000000; /* 기본 텍스트 검정 */
      opacity: 0.7; /* 기본 텍스트 투명도 */
      cursor: pointer; /* 커서 스타일 추가 */
    }

    .diary-box .content.active {
      color: black; /* 입력 후 글자 색 */
      opacity: 1; /* 입력 후 투명도 제거 */
      cursor: text; /* 수정 시 텍스트 커서 */
    }

    .diary-box .delete-button {
      position: absolute;
      bottom: 10px;
      right: 10px;
      background-color: transparent;
      color: rgba(0, 0, 0, 0.5); /* 불투명한 회색 */
      font-size: 20px;
      font-weight: bold;
      border: none;
      cursor: pointer;
    }

    .diary-box .delete-button:hover {
      color: rgba(0, 0, 0, 0.8); /* 삭제 버튼 호버 시 색 변경 */
    }

    /* 달력 입력 필드 위치 조정 */
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
    <div class="logo-container">
      <img src="./images/Logo.png" alt="Logo" class="logo" />
      <div class="logo-text">Life Log</div>
    </div>
    <div class="menu-item" data-page="main" onclick="location.href='main.jsp'">메인</div>
    <div class="menu-item" data-page="log-analysis" onclick="location.href='log_analyze.jsp'">로그 분석</div>
    <div class="menu-item" data-page="log-record" onclick="location.href='goal_set.jsp'">로그 기록</div>
    <div class="menu-item active" data-page="diary" onclick="location.href='diary.jsp'">일기</div>
    <div class="menu-item place-bottom" onclick="location.href='SignOut.jsp'">로그아웃</div>
  </div>

  <!-- 상단 컨트롤 -->
  <div class="content-container">
    <div class="controls">
      <button id="addDiaryButton">+ 일기 추가</button>
    </div>

    <!-- 다이어리 박스 컨테이너 -->
    <div class="container" id="diaryContainer">
      <!-- 기본 다이어리 박스는 초기 로드 시 비워둡니다 -->
    </div>
  </div>

  <script>
    const diaryContainer = document.getElementById('diaryContainer');
    const addDiaryButton = document.getElementById('addDiaryButton');

    // Add a new diary box
    addDiaryButton.addEventListener('click', () => {
      const diaryBox = createDiaryBox();
      diaryContainer.appendChild(diaryBox);

      // 애니메이션을 위해 다음 프레임에 .show 클래스 추가
      setTimeout(() => {
        diaryBox.classList.add('show');
      }, 10);
    });

    // Function to create a diary box
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

      // Add calendar functionality
      addCalendarFunctionality(dateLabel, dateIcon, diaryBox);

      // Handle content click for editing
      content.addEventListener('click', () => {
        content.contentEditable = true;
        content.focus();
        content.classList.add('active');
        if (content.textContent === '내용') {
          content.textContent = '';
        }
      });

      // Save content on Enter
      content.addEventListener('keypress', (event) => {
        if (event.key === 'Enter') {
          event.preventDefault();
          saveDiary(diaryBox);
        }
      });

      // Save content on blur
      content.addEventListener('blur', () => {
        saveDiary(diaryBox);
      });

      // Delete diary box
      deleteButton.addEventListener('click', () => {
        const entryId = diaryBox.getAttribute('data-entry-id');
        if (entryId) {
          deleteDiary(entryId, diaryBox);
        } else {
          // If entry_id가 없으면 단순히 UI에서 제거
          diaryBox.classList.add('hide');
          setTimeout(() => {
            diaryContainer.removeChild(diaryBox);
          }, 500);
        }
      });

      return diaryBox;
    }

    // Add calendar functionality to the header
    function addCalendarFunctionality(dateLabel, dateIcon, diaryBox) {
      dateIcon.addEventListener('click', () => {
        const existingInput = dateLabel.querySelector('input[type="date"]');
        if (existingInput) {
          dateLabel.removeChild(existingInput);
          // Reset 날짜가 선택되지 않은 경우
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

        dateLabel.textContent = ''; // Clear existing text
        dateLabel.appendChild(dateInput);
        dateInput.focus();
      });
    }

    // Function to save diary (add or update)
    function saveDiary(diaryBox) {
      const entryId = diaryBox.getAttribute('data-entry-id');
      const content = diaryBox.querySelector('.content').textContent.trim();
      const dateWritten = diaryBox.querySelector('.date-label').textContent.trim();

      // Validation
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
            // 새로운 일기인 경우 entry_id를 설정
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

    // Function to delete diary
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

 // Function to load existing diaries
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

            // 애니메이션을 위해 다음 프레임에 .show 클래스 추가
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

    // 페이지 로드 시 기존 일기 로드
    window.addEventListener('DOMContentLoaded', loadDiaries);
  </script>
</body>
</html>