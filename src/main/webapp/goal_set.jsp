<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="./images/Logo.png">
    <title>Life Log</title>
    <style>
        /* 기존 CSS 유지 */
        body {
            font-family: Arial, sans-serif;
            background-color: #1e1e1e;
            color: #fff;
            text-align: center;
            margin: 0;
            padding: 0;
            display: flex;
            height: 100vh;
        }

        .container {
            margin-left : 60px;
            margin-top : 21.44px;
            content-align : center; 
        }

        h1 {
            font-family: Arial;
            margin-bottom: 10px;
            color: #fff;
            border-bottom: 2px solid #2D488B;
            padding-bottom: 10px;
            text-align: left;
        }

        table {
        	min-width:700px;
            width: 100%;
            border-collapse: collapse;
            margin-top: 30px;
            margin-bottom: 10px;
            border-bottom: 2px solid #2D488B;
        }

        th, td {
            padding: 10px;
            text-align: center;
            border: none;
        }

        thead tr {
            background-color: #2D488B;
        }

        tbody tr {
            background-color: #1a1a1a;
        }

        tbody tr:nth-child(even) {
            background-color: #333;
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
            border-radius: 5px;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #218838;
        }

        .delete-btn {
            color: red;
            cursor: pointer;
            font-weight: bold;
            font-size: 18px;
        }
		
		.page-container{
			display:flex;
        	height:100vh;
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
      	
        .logo-container {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .logo {
            height: 50px;
            width: auto;
        }

        .logo-text {
            font-size: 24px;
            font-weight: bold;
            color: white;
        }

        /* 목표값 입력 칸 스타일 */
        .goal-input {
          /* 기본적으로 숨김을 설정하지 않음 */
          margin-top: 5px;
          width: 90%;
          padding: 8px;
          background-color: #000;
          color: #fff;
          border: 1px solid #444;
          text-align: center;
          display: inline-block; /* 기본적으로 표시 */
      }

      .goal-input[disabled] {
          display: none; /* 비활성화된 경우 숨김 */
      }
    </style>
</head>
<body>
	<div class="page-container">
    <div class="menu-bar">
        <div class="logo-container">
            <img src="./images/Logo.png" alt="Logo" class="logo" />
            <div class="logo-text">Life Log</div>
        </div>
        <div class="menu-item" data-page="main" onclick="location.href='main.jsp'">메인</div>
        <div class="menu-item" data-page="log-analysis" onclick="location.href='log_analyze.jsp'">로그 분석</div>
        <div class="menu-item active" data-page="log-record" onclick="location.href='goal_set.jsp'">로그 기록</div>
        <div class="menu-item" data-page="diary" onclick="location.href='diary.jsp'">일기</div>
        <div class="menu-item place-bottom" onclick="location.href='SignOut.jsp'">로그아웃</div>
    </div>
    
    <div class="container">
        <h1>로그 기록</h1>
        <table id="goalTable">
            <thead>
                <tr>
                    <th></th>
                    <th>로그</th>
                    <th>입력값</th>
                    <th>단위</th>
                    <th>목표 설정 여부</th>
                </tr>
            </thead>
            <tbody>
                <!-- 테이블 데이터는 JavaScript로 동적으로 추가됩니다 -->
            </tbody>
        </table>
        <div class="button-container">
            <button id="addRow">+</button>
            <button id="saveChanges">수정완료</button>
        </div>
    </div>
   </div>
    <%! 
    // JSON 문자열 내의 특수 문자를 이스케이프하는 함수
    public String escapeJson(String str) {
        if (str == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (char c : str.toCharArray()) {
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '/': sb.append("\\/"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        String hex = Integer.toHexString(c);
                        sb.append("\\u");
                        for(int i = hex.length(); i < 4; i++) {
                            sb.append('0');
                        }
                        sb.append(hex);
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }
%>

<%
    // 정보 불러오기
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String jsonData = "[]";
    
    try {
        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        // 세션에서 사용자 이메일 가져오기
        if (session == null || session.getAttribute("email") == null) {
            out.println("<script>alert('세션이 만료되었습니다. 다시 로그인해주세요.'); location.href='SignIn.jsp';</script>");
            return;
        }

        String userEmail = (String) session.getAttribute("email");

        // 데이터 조회 SQL
        String selectSQL = "SELECT log_id, log_name, input_value, unit, is_goal, goal_value FROM logs WHERE user_id = ?";
        pstmt = conn.prepareStatement(selectSQL);
        pstmt.setString(1, userEmail);
        rs = pstmt.executeQuery();

        // 데이터를 List<Map<String, Object>> 형태로 수집
        List<Map<String, Object>> goals = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> goal = new HashMap<>();
            goal.put("log_id", rs.getInt("log_id"));
            goal.put("log_name", rs.getString("log_name"));
            goal.put("input_value", rs.getDouble("input_value"));
            goal.put("unit", rs.getString("unit"));
            goal.put("is_goal", rs.getBoolean("is_goal"));
            goal.put("goal_value", rs.getObject("goal_value")); // NULL 가능
            goals.add(goal);
        }

        // JSON 문자열로 변환
        StringBuilder jsonBuilder = new StringBuilder("[");
        for (int i = 0; i < goals.size(); i++) {
            Map<String, Object> goal = goals.get(i);
            jsonBuilder.append("{");
            jsonBuilder.append("\"log_id\":").append(goal.get("log_id")).append(",");

            // 이스케이프 함수 사용
            String logName = escapeJson(goal.get("log_name") != null ? (String)goal.get("log_name") : "");
            jsonBuilder.append("\"log_name\":\"").append(logName).append("\",");

            jsonBuilder.append("\"input_value\":").append(goal.get("input_value")).append(",");

            // 이스케이프 함수 사용
            String unit = escapeJson(goal.get("unit") != null ? (String)goal.get("unit") : "");
            jsonBuilder.append("\"unit\":\"").append(unit).append("\",");

            jsonBuilder.append("\"is_goal\":").append(goal.get("is_goal")).append(",");

            // Handle goal_value
            if (goal.get("goal_value") == null) {
                jsonBuilder.append("\"goal_value\":null");
            } else {
                String goalValue = escapeJson(goal.get("goal_value").toString());
                // Check if goal_value is numeric
                boolean isNumeric = true;
                try {
                    Double.parseDouble(goalValue);
                } catch (NumberFormatException e) {
                    isNumeric = false;
                }
                if (isNumeric) {
                    jsonBuilder.append("\"goal_value\":").append(goal.get("goal_value"));
                } else {
                    jsonBuilder.append("\"goal_value\":\"").append(goalValue).append("\"");
                }
            }

            jsonBuilder.append("}");
            if (i < goals.size() - 1) jsonBuilder.append(",");
        }
        jsonBuilder.append("]");
        jsonData = jsonBuilder.toString();
    } catch (Exception e) {
        e.printStackTrace();
        // 사용자에게 오류 메시지 표시
        out.println("<script>alert('데이터를 불러오는 중 오류가 발생했습니다. 관리자에게 문의해주세요.'); location.href='SignIn.jsp';</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

<!-- JSON 데이터를 시각적으로 확인하기 위해 아래 줄을 주석 해제하세요 -->
<!-- <pre><%= jsonData %></pre> -->

<script>
    // 서버에서 전달된 JSON 데이터를 JavaScript 변수로 정의
    var goalsData = <%= jsonData %>;
    console.log("서버에서 가져온 데이터:", goalsData);

    document.addEventListener("DOMContentLoaded", function () {
        console.log("DOMContentLoaded 이벤트 발생");

        const table = document.getElementById("goalTable").querySelector("tbody");
        if (table === null) {
            console.error("tbody 요소를 찾을 수 없습니다.");
            return;
        }
        console.log("Selected tbody:", table); // tbody 요소가 올바르게 선택되었는지 확인

        const addRowBtn = document.getElementById("addRow");
        const saveChangesBtn = document.getElementById("saveChanges");

        // 데이터를 테이블에 표시
        if (Array.isArray(goalsData)) {
            goalsData.forEach((goal, index) => {
                console.log(`Adding row ${index + 1}:`, goal);
                const newRow = document.createElement("tr");
                
                // 데이터-log-id 속성 추가
                newRow.setAttribute("data-log-id", goal.log_id);

                // 삭제 버튼 셀 생성
                const deleteCell = document.createElement("td");
                deleteCell.className = "delete-btn";
                deleteCell.textContent = "-";
                newRow.appendChild(deleteCell);

                // 로그 이름 입력 필드 생성
                const logNameCell = document.createElement("td");
                const logNameInput = document.createElement("input");
                logNameInput.type = "text";
                logNameInput.name = "log_name";
                logNameInput.value = goal.log_name;
                logNameCell.appendChild(logNameInput);
                newRow.appendChild(logNameCell);

                // 입력값 입력 필드 생성
                const inputValueCell = document.createElement("td");
                const inputValueInput = document.createElement("input");
                inputValueInput.type = "text";
                inputValueInput.step = "0.01"; // 소수점 두 자리 입력 허용
                inputValueInput.name = "input_value";
                inputValueInput.value = goal.input_value;
                inputValueCell.appendChild(inputValueInput);
                newRow.appendChild(inputValueCell);

                // 단위 입력 필드 생성
                const unitCell = document.createElement("td");
                const unitInput = document.createElement("input");
                unitInput.type = "text";
                unitInput.name = "unit";
                unitInput.value = goal.unit;
                unitCell.appendChild(unitInput);
                newRow.appendChild(unitCell);

                // 목표 설정 여부 셀 생성
                const isGoalCell = document.createElement("td");
                
                const isGoalCheckbox = document.createElement("input");
                isGoalCheckbox.type = "checkbox";
                isGoalCheckbox.name = "is_goal";
                isGoalCheckbox.className = "goal-checkbox";
                if (goal.is_goal) isGoalCheckbox.checked = true;
                isGoalCheckbox.onclick = function() {
                    toggleGoalValue(this);
                };
                isGoalCell.appendChild(isGoalCheckbox);

                const goalValueInputField = document.createElement("input");
                goalValueInputField.type = "text";
                goalValueInputField.step = "0.01"; // 소수점 두 자리 입력 허용
                goalValueInputField.name = "goal_value";
                goalValueInputField.className = "goal-input";
                goalValueInputField.placeholder = "목표 입력";
                goalValueInputField.value = goal.goal_value != null ? goal.goal_value : '';
                if (!goal.is_goal) {
                    goalValueInputField.disabled = true;
                    goalValueInputField.style.display = "none";
                }
                isGoalCell.appendChild(goalValueInputField);

                newRow.appendChild(isGoalCell);

                table.appendChild(newRow);
                console.log(`Row ${index + 1} appended to table.`); // 추가된 행 확인

                // 삭제 이벤트 연결
                attachDeleteEvent(deleteCell);
            });
        } else {
            console.error("goalsData가 배열이 아닙니다.");
        }

        // 새로운 입력 행 추가
        addRowBtn.addEventListener("click", function () {
            console.log("'+' 버튼 클릭됨");
            const newRow = document.createElement("tr");

            // 삭제 버튼 셀 생성
            const deleteCell = document.createElement("td");
            deleteCell.className = "delete-btn";
            deleteCell.textContent = "-";
            newRow.appendChild(deleteCell);

            // 로그 이름 입력 필드 생성
            const logNameCell = document.createElement("td");
            const logNameInput = document.createElement("input");
            logNameInput.type = "text";
            logNameInput.name = "log_name";
            logNameInput.placeholder = "로그 입력";
            logNameCell.appendChild(logNameInput);
            newRow.appendChild(logNameCell);

            // 입력값 입력 필드 생성
            const inputValueCell = document.createElement("td");
            const inputValueInput = document.createElement("input");
            inputValueInput.type = "text";
            inputValueInput.step = "0.01"; // 소수점 두 자리 입력 허용
            inputValueInput.name = "input_value";
            inputValueInput.placeholder = "입력값";
            inputValueCell.appendChild(inputValueInput);
            newRow.appendChild(inputValueCell);

            // 단위 입력 필드 생성
            const unitCell = document.createElement("td");
            const unitInput = document.createElement("input");
            unitInput.type = "text";
            unitInput.name = "unit";
            unitInput.placeholder = "단위 입력";
            unitCell.appendChild(unitInput);
            newRow.appendChild(unitCell);

            // 목표 설정 여부 셀 생성
            const isGoalCell = document.createElement("td");
            
            const isGoalCheckbox = document.createElement("input");
            isGoalCheckbox.type = "checkbox";
            isGoalCheckbox.name = "is_goal";
            isGoalCheckbox.className = "goal-checkbox";
            isGoalCheckbox.onclick = function() {
                toggleGoalValue(this);
            };
            isGoalCell.appendChild(isGoalCheckbox);

            const goalValueInputField = document.createElement("input");
            goalValueInputField.type = "text";
            goalValueInputField.step = "0.01"; // 소수점 두 자리 입력 허용
            goalValueInputField.name = "goal_value";
            goalValueInputField.className = "goal-input";
            goalValueInputField.placeholder = "목표 입력";
            goalValueInputField.disabled = true;
            goalValueInputField.style.display = "none"; // 숨김 상태
            isGoalCell.appendChild(goalValueInputField);

            newRow.appendChild(isGoalCell);

            table.appendChild(newRow);
            console.log("New row appended via '+' button.");

            // 삭제 버튼 이벤트 연결
            attachDeleteEvent(deleteCell);
        });

        // 변경사항 저장 및 테이블 동적 갱신
        saveChangesBtn.addEventListener("click", function () {
            console.log("'수정완료' 버튼 클릭됨");

            const rows = table.querySelectorAll("tr");
            if (rows.length === 0) {
                alert("저장할 목표가 없습니다.");
                return;
            }

            // 폼 데이터 준비
            let formData = "";
            let isValid = true;

            rows.forEach((row) => {
                const logId = row.getAttribute("data-log-id") || ""; // 기존 로그 ID 또는 빈 문자열
                const logNameInput = row.querySelector("input[name='log_name']");
                const inputValueInput = row.querySelector("input[name='input_value']");
                const unitInput = row.querySelector("input[name='unit']");
                const isGoalInput = row.querySelector("input[name='is_goal']");
                const goalValueInput = row.querySelector("input[name='goal_value']");

                const logName = logNameInput ? logNameInput.value.trim() : "";
                const inputValue = inputValueInput ? inputValueInput.value.trim() : "";
                const unit = unitInput ? unitInput.value.trim() : "";
                const isGoal = isGoalInput ? isGoalInput.checked : false;
                const goalValue = isGoal ? (goalValueInput ? goalValueInput.value.trim() : "") : "";

                if (!logName || !inputValue || !unit) {
                    alert("로그, 입력값, 단위는 필수 항목입니다.");
                    isValid = false;
                    return; // forEach에서는 return false가 동작하지 않음
                }

                if (isGoal && !goalValue) {
                    alert("목표 설정 시 목표 값을 입력해주세요.");
                    isValid = false;
                    return; // forEach에서는 return false가 동작하지 않음
                }

                formData +=
                    "log_id=" + encodeURIComponent(logId) + "&" + // log_id 추가
                    "log_name=" +
                    encodeURIComponent(logName) +
                    "&input_value=" +
                    encodeURIComponent(inputValue) +
                    "&unit=" +
                    encodeURIComponent(unit) +
                    "&is_goal=" +
                    (isGoal ? "1" : "0") + // 1 또는 0으로 전송
                    "&goal_value=" +
                    encodeURIComponent(goalValue) +
                    "&";
            });

            if (!isValid) return;

            // 마지막 '&' 제거
            formData = formData.slice(0, -1);
            console.log("전송할 formData:", formData);

            // AJAX 요청을 통해 서버로 데이터 전송
            const xhr = new XMLHttpRequest();
            xhr.open("POST", "saveGoals.jsp", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            console.log("서버 응답:", response);
                            if (response.status === "success") {
                                alert(response.message || "데이터가 성공적으로 저장되었습니다.");
                                location.reload(); // 페이지 새로고침
                            } else {
                                alert("목표 저장에 실패했습니다: " + (response.message || "알 수 없는 오류"));
                            }
                        } catch (e) {
                            console.error("JSON 파싱 오류:", e);
                            console.error("서버 응답 원본:", xhr.responseText);
                            alert("서버 응답을 처리하는 중 오류가 발생했습니다.");
                        }
                    } else {
                        alert("서버 오류가 발생했습니다.");
                    }
                }
            };

            xhr.send(formData);
        });

        // 목표 설정 여부에 따라 goal_value 입력 필드 표시/숨김 함수
        function toggleGoalValue(checkbox) {
            const goalInput = checkbox.nextElementSibling;
            if (checkbox.checked) {
                goalInput.style.display = "inline-block";
                goalInput.disabled = false;
            } else {
                goalInput.style.display = "none";
                goalInput.value = ""; // 체크 해제 시 입력값 초기화
                goalInput.disabled = true;
            }
        }

        // 테이블 갱신 함수
        function updateTable(data) {
            console.log("테이블 갱신 시작");
            table.innerHTML = ""; // 기존 행 제거
            data.forEach((item) => {
                const newRow = document.createElement("tr");
                newRow.setAttribute("data-log-id", item.log_id);
                newRow.innerHTML = `
                    <td class="delete-btn">-</td>
                    <td><input type="text" name="log_name" value="${item.log_name}"></td>
                    <td><input type="text" name="input_value" value="${item.input_value}"></td>
                    <td><input type="text" name="unit" value="${item.unit}"></td>
                    <td>
                        <input type="checkbox" name="is_goal" class="goal-checkbox" ${item.is_goal ? 'checked' : ''} onclick="toggleGoalValue(this)">
                        <input type="text" name="goal_value" class="goal-input" placeholder="목표 입력" value="${item.goal_value != null ? item.goal_value : ''}" ${item.is_goal ? '' : 'disabled style="display:none;"'}>
                    </td>
                `;
                table.appendChild(newRow);

                // 삭제 이벤트 연결
                attachDeleteEvent(newRow.querySelector(".delete-btn"));
            });
        }

        // 삭제 버튼 이벤트 연결
        function attachDeleteEvent(deleteBtn) {
            deleteBtn.addEventListener("click", function () {
                console.log("삭제 버튼 클릭됨");
                if (confirm("해당 행을 삭제하시겠습니까?")) {
                    const row = deleteBtn.closest("tr");
                    if (row) {
                        const logId = row.getAttribute("data-log-id");
                        if (!logId) {
                            alert("삭제할 로그 ID가 없습니다.");
                            return;
                        }

                        // AJAX 요청을 통해 서버로 삭제 요청 전송
                        const xhr = new XMLHttpRequest();
                        xhr.open("POST", "deleteGoal.jsp", true);
                        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

                        xhr.onreadystatechange = function () {
                            if (xhr.readyState === 4) {
                                if (xhr.status === 200) {
                                    try {
                                        const response = JSON.parse(xhr.responseText);
                                        console.log("서버 응답:", response);
                                        if (response.status === "success") {
                                            alert(response.message || "데이터가 성공적으로 삭제되었습니다.");
                                            row.remove(); // 테이블에서 행 제거
                                        } else {
                                            alert("삭제에 실패했습니다: " + (response.message || "알 수 없는 오류"));
                                        }
                                    } catch (e) {
                                        console.error("JSON 파싱 오류:", e);
                                        console.error("서버 응답 원본:", xhr.responseText);
                                        alert("서버 응답을 처리하는 중 오류가 발생했습니다.");
                                    }
                                } else {
                                    alert("서버 오류가 발생했습니다.");
                                }
                            }
                        };

                        xhr.send("log_id=" + encodeURIComponent(logId));
                    }
                }
            });
        }
    });
</script>
</body>
</html>
