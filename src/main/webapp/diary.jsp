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

    /* 수정완료 버튼 스타일 */
    .save-button {
      position: absolute;
      bottom: 10px;
      right: 50px; /* '×' 버튼 옆에 위치하도록 조정 */
      background-color: transparent;
      color: rgba(0, 0, 0, 0.5); /* 불투명한 회색 */
      font-size: 20px;
      font-weight: bold;
      border: none;
      cursor: pointer;
    }

    .save-button:hover {
      color: rgba(0, 0, 0, 0.8); /* 수정완료 버튼 호버 시 색 변경 */
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
      width:220px;
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
    <div class="menu-item active" data-page="diary" onclick="location.href='일기추가.jsp'">일기</div>
  </div>

  <!-- 상단 컨트롤 -->
  <div class="content-container">
    <div class="controls">
      <button type="button" id="addDiaryButton">+ 일기 추가</button>
    </div>

    <!-- 다이어리 박스 컨테이너 -->
    <div class="container" id="diaryContainer">
      <!-- 초기 다이어리 박스는 제거했습니다. -->
    </div>
  </div>

  <script>
    // 디버깅을 위한 콘솔 로그 추가
    console.log('JavaScript 로드됨');

    const diaryContainer = document.getElementById('diaryContainer');
    const addDiaryButton = document.getElementById('addDiaryButton');

    // addDiaryButton이 제대로 가져와졌는지 확인
    if (!addDiaryButton) {
      console.error('addDiaryButton을 찾을 수 없습니다.');
    } else {
      console.log('addDiaryButton 찾음');
    }

    // Add a new diary box
    addDiaryButton.addEventListener('click', () => {
      console.log('일기 추가 버튼 클릭됨');
      const diaryBox = createDiaryBox();
      diaryContainer.appendChild(diaryBox);

      // 애니메이션을 위해 다음 프레임에 .show 클래스 추가
      setTimeout(() => {
        diaryBox.classList.add('show');
        console.log('새로운 다이어리 박스에 show 클래스 추가됨');
      }, 10);
    });

    // Function to create a diary box
    function createDiaryBox(entryId = null, date = '날짜 선택', contentText = '내용') {
      console.log('createDiaryBox 호출됨', entryId, date, contentText);
      const diaryBox = document.createElement('div');
      diaryBox.className = 'diary-box';
      if (entryId) {
        diaryBox.setAttribute('data-entry-id', entryId);
      }

      const header = document.createElement('header');
      const dateLabel = document.createElement('span');
      dateLabel.className = 'date-label';
      dateLabel.textContent = date;

      const dateIcon = document.createElement('span');
      dateIcon.className = 'date-icon';
      dateIcon.textContent = '📅';

      header.appendChild(dateLabel);
      header.appendChild(dateIcon);

      const content = document.createElement('div');
      content.className = 'content';
      content.contentEditable = false;
      content.textContent = contentText;

      const saveButton = document.createElement('button');
      saveButton.className = 'save-button';
      saveButton.textContent = '✔️'; // 수정완료 아이콘

      const deleteButton = document.createElement('button');
      deleteButton.className = 'delete-button';
      deleteButton.textContent = '×';

      diaryBox.appendChild(header);
      diaryBox.appendChild(content);
      diaryBox.appendChild(saveButton);
      diaryBox.appendChild(deleteButton);

      // Add calendar functionality
      addCalendarFunctionality(dateLabel, dateIcon);

      // Handle content click for editing
      content.addEventListener('click', () => {
        console.log('내용 클릭됨');
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
          console.log('Enter 키 눌림, 편집 종료');
        }
      });

      // Save content on blur
      content.addEventListener('blur', () => {
        if (content.textContent.trim() === '') {
          content.textContent = '내용';
          content.classList.remove('active');
          console.log('내용이 비어 있어서 기본 텍스트로 설정됨');
        }
        content.contentEditable = false;
      });

      // Handle save button click
      saveButton.addEventListener('click', () => {
        console.log('수정완료 버튼 클릭됨');
        const date = dateLabel.textContent;
        const diaryContent = content.textContent;
        const entryId = diaryBox.getAttribute('data-entry-id');

        // 유효성 검사
        if (date === '날짜 선택' || diaryContent.trim() === '' || diaryContent === '내용') {
          alert('날짜와 내용을 모두 입력해주세요.');
          console.warn('유효성 검사 실패');
          return;
        }

        if (entryId) {
          // 이미 저장된 일기라면 업데이트
          console.log('일기 업데이트 요청', entryId);
          const xhr = new XMLHttpRequest();
          xhr.open('POST', 'updateDiary.jsp', true);
          xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

          xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
              const response = xhr.responseText.trim();
              console.log('updateDiary.jsp 응답:', response);
              if (response === 'success') {
                alert('일기가 성공적으로 업데이트되었습니다.');
              } else {
                alert('일기 업데이트에 실패했습니다: ' + (response.split('|')[1] || '알 수 없는 오류'));
              }
            }
          };

          // 서버로 전송할 데이터
          const params = `entry_id=${encodeURIComponent(entryId)}&date_written=${encodeURIComponent(date)}&diary_content=${encodeURIComponent(diaryContent)}`;
          xhr.send(params);
        } else {
          // 새 일기라면 저장
          console.log('새 일기 저장 요청');
          const xhr = new XMLHttpRequest();
          xhr.open('POST', 'saveDiary.jsp', true);
          xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

          xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
              const response = xhr.responseText.trim();
              console.log('saveDiary.jsp 응답:', response);
              if (response.startsWith('success')) {
                const parts = response.split('|');
                if (parts.length === 2) {
                  const newEntryId = parts[1];
                  diaryBox.setAttribute('data-entry-id', newEntryId);
                  alert('일기가 성공적으로 저장되었습니다.');
                }
              } else {
                alert('일기 저장에 실패했습니다: ' + (response.split('|')[1] || '알 수 없는 오류'));
              }
            }
          };

          // 서버로 전송할 데이터
          const params = `date_written=${encodeURIComponent(date)}&diary_content=${encodeURIComponent(diaryContent)}`;
          xhr.send(params);
        }
      });

      // Delete diary box
      deleteButton.addEventListener('click', () => {
        console.log('삭제 버튼 클릭됨');
        const entryId = diaryBox.getAttribute('data-entry-id');

        if (entryId) {
          // AJAX 요청으로 서버에 삭제 요청
          console.log('일기 삭제 요청', entryId);
          const xhr = new XMLHttpRequest();
          xhr.open('POST', 'deleteDiary.jsp', true);
          xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

          xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
              const response = xhr.responseText.trim();
              console.log('deleteDiary.jsp 응답:', response);
              if (response === 'success') {
                diaryBox.classList.add('hide'); // Hide 애니메이션 클래스 추가
                setTimeout(() => {
                  diaryContainer.removeChild(diaryBox); // 일정 시간 후 제거
                  console.log('다이어리 박스 제거됨');
                }, 500); // 애니메이션 시간
              } else {
                alert('일기 삭제에 실패했습니다: ' + (response.split('|')[1] || '알 수 없는 오류'));
              }
            }
          };

          // 서버로 전송할 데이터
          const params = `entry_id=${encodeURIComponent(entryId)}`;
          xhr.send(params);
        } else {
          // entry_id가 없는 경우, 단순히 페이지에서 제거
          console.log('entry_id가 없으므로 다이어리 박스 제거됨');
          diaryBox.classList.add('hide');
          setTimeout(() => {
            diaryContainer.removeChild(diaryBox);
            console.log('다이어리 박스 제거됨');
          }, 500);
        }
      });

      return diaryBox;
    }

    // Add calendar functionality to the header
    function addCalendarFunctionality(dateLabel, dateIcon) {
      console.log('addCalendarFunctionality 호출됨');
      dateIcon.addEventListener('click', () => {
        console.log('달력 아이콘 클릭됨');
        const existingInput = dateLabel.querySelector('input[type="date"]');
        if (existingInput) {
          console.log('날짜 입력 필드 제거됨');
          dateLabel.removeChild(existingInput);
          dateLabel.textContent = '날짜 선택';
          return;
        }

        const dateInput = document.createElement('input');
        dateInput.type = 'date';
        dateInput.addEventListener('change', () => {
          if (dateInput.value) {
            console.log('날짜 선택됨:', dateInput.value);
            dateLabel.textContent = dateInput.value;
          }
        });

        dateLabel.textContent = ''; // 기존 텍스트 지우기
        dateLabel.appendChild(dateInput);
        dateInput.focus();
        console.log('날짜 입력 필드 추가됨');
      });
    }

    // Initialize existing diaries on page load
    window.addEventListener('DOMContentLoaded', () => {
      console.log('페이지 로드 완료, 기존 일기 불러오기 시작');
      const xhr = new XMLHttpRequest();
      xhr.open('GET', 'loadDiaries.jsp', true);
      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
          const response = xhr.responseText.trim();
          console.log('loadDiaries.jsp 응답:', response);
          if (response.startsWith('success')) {
            const lines = response.split('\n');
            if (lines.length === 1 && lines[0].includes('no_diaries')) {
              // 일기가 없는 경우 처리 (예: 메시지 표시)
              console.log('저장된 일기가 없습니다.');
            } else {
              // 첫 줄은 'success'이므로 2번째 줄부터 처리
              for (let i = 1; i < lines.length; i++) {
                const parts = lines[i].split('|');
                if (parts.length === 3) {
                  const entryId = parts[0];
                  const date = parts[1];
                  const content = parts[2].replace(/\\n/g, '\n'); // 개행 문자 복원
                  const diaryBox = createDiaryBox(entryId, date, content);
                  diaryContainer.appendChild(diaryBox);
                  // 애니메이션을 위해 다음 프레임에 .show 클래스 추가
                  setTimeout(() => {
                    diaryBox.classList.add('show');
                    console.log('기존 다이어리 박스 show 클래스 추가됨', entryId);
                  }, 10);
                }
              }
            }
          } else if (response.startsWith('error')) {
            const errorMsg = response.split('|')[1];
            alert(errorMsg);
            console.error('loadDiaries.jsp 에러:', errorMsg);
          }
        }
      };
      xhr.send();
    });
  </script>
</body>
</html>
