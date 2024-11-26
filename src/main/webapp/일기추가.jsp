<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
      color: #aaa; /* 기본 텍스트 회색 */
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
  </style>
</head>
<body>
  <!-- 상단 컨트롤 -->
  <div class="controls">
    <button id="addDiaryButton">+ 일기 추가</button>
  </div>

  <!-- 다이어리 박스 컨테이너 -->
  <div class="container" id="diaryContainer">
    <!-- 기본 다이어리 박스 -->
    <div class="diary-box show">
      <header>
        <span class="date-label">날짜 선택</span>
        <span class="date-icon">📅</span>
      </header>
      <div class="content" contenteditable="false">내용</div>
      <button class="delete-button">×</button>
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

      // Add calendar functionality
      addCalendarFunctionality(dateLabel, dateIcon);

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
          content.contentEditable = false;
        }
      });

      // Save content on blur
      content.addEventListener('blur', () => {
        if (content.textContent.trim() === '') {
          content.textContent = '내용';
          content.classList.remove('active');
        }
        content.contentEditable = false;
      });

      // Delete diary box
      deleteButton.addEventListener('click', () => {
        diaryBox.classList.add('hide'); // Hide 애니메이션 클래스 추가
        setTimeout(() => {
          diaryContainer.removeChild(diaryBox); // 일정 시간 후 제거
        }, 500); // 애니메이션 시간
      });

      return diaryBox;
    }

    // Add calendar functionality to the header
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

    // Initialize the first diary box
    document.querySelectorAll('.diary-box').forEach((box) => {
      const header = box.querySelector('header');
      const dateLabel = header.querySelector('.date-label');
      const dateIcon = header.querySelector('.date-icon');
      addCalendarFunctionality(dateLabel, dateIcon);

      const content = box.querySelector('.content');
      const deleteButton = box.querySelector('.delete-button');

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
          content.contentEditable = false;
        }
      });

      // Save content on blur
      content.addEventListener('blur', () => {
        if (content.textContent.trim() === '') {
          content.textContent = '내용';
          content.classList.remove('active');
        }
        content.contentEditable = false;
      });

      // Delete diary box
      deleteButton.addEventListener('click', () => {
        box.classList.add('hide'); // Hide 애니메이션 클래스 추가
        setTimeout(() => {
          diaryContainer.removeChild(box); // 일정 시간 후 제거
        }, 500); // 애니메이션 시간
      });
    });
  </script>
</body>
</html>