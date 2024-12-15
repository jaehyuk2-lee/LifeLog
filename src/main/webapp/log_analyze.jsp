<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="javax.servlet.http.*" %>
<%
// 세션에서 사용자 이메일 가져오기
String userEmail = (String) session.getAttribute("email"); // 세션에서 이메일 값 가져오기

// 데이터베이스 연결 정보
String dbUrl = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
String dbUser = "lifelog_admin";
String dbPassword = "q1w2e3r4";

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

// log_name 목록, 단위 및 데이터를 저장할 맵
Map<String, double[]> logDataMap = new LinkedHashMap<>();
Map<String, String> unitMap = new LinkedHashMap<>();
Map<String, Double> goalAchievementMap = new LinkedHashMap<>();

try {
    // 세션 이메일 확인
    if (userEmail == null) {
        response.sendRedirect("login.jsp"); // 세션 정보가 없으면 로그인 페이지로 이동
        return;
    }

    // 데이터베이스 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

    // 특정 사용자의 log_name 목록 및 단위 가져오기
    String logNameQuery = "SELECT DISTINCT log_name, unit FROM logs WHERE user_id = ?";
    pstmt = conn.prepareStatement(logNameQuery);
    pstmt.setString(1, userEmail);
    rs = pstmt.executeQuery();
    List<String> logNames = new ArrayList<>();
    while (rs.next()) {
        String logName = rs.getString("log_name");
        logNames.add(logName);
        unitMap.put(logName, rs.getString("unit")); // 단위 저장
    }
    rs.close();
    pstmt.close();

    // 요일별 데이터 및 달성률 계산
    for (String logName : logNames) {
        double[] weeklyData = new double[7];
        Arrays.fill(weeklyData, 0.0); // 기본값 0으로 초기화
        double totalInput = 0.0;
        int activeDays = 0;
        double goalValue = 0.0;

        String query = 
            "SELECT day_of_week, SUM(input_value) AS total_input, COUNT(DISTINCT date_entered) AS active_days, goal_value " +
            "FROM logs " +
            "WHERE user_id = ? AND log_name = ? AND WEEK(date_entered, 1) = ( " +
            "    SELECT MAX(WEEK(date_entered, 1)) FROM logs WHERE user_id = ? AND log_name = ? " +
            ") GROUP BY day_of_week, goal_value";
        pstmt = conn.prepareStatement(query);
        pstmt.setString(1, userEmail);
        pstmt.setString(2, logName);
        pstmt.setString(3, userEmail);
        pstmt.setString(4, logName);

        rs = pstmt.executeQuery();

        Map<String, Integer> dayIndexMap = Map.of(
            "월요일", 0,
            "화요일", 1,
            "수요일", 2,
            "목요일", 3,
            "금요일", 4,
            "토요일", 5,
            "일요일", 6
        );

        while (rs.next()) {
            String day = rs.getString("day_of_week");
            double dayTotalInput = rs.getDouble("total_input");
            int dayActiveDays = rs.getInt("active_days");
            goalValue = rs.getDouble("goal_value"); // 동일 log_name이므로 goal_value는 동일

            totalInput += dayTotalInput;
            activeDays += dayActiveDays;

            if (dayIndexMap.containsKey(day)) {
                int index = dayIndexMap.get(day);
                weeklyData[index] = dayTotalInput;
            }
        }

        // 달성률 계산: (totalInput / (activeDays * goalValue)) * 100
        if (activeDays > 0 && goalValue > 0) {
            double achievementRate = (totalInput / (activeDays * goalValue)) * 100;
            goalAchievementMap.put(logName, achievementRate);
        }

        logDataMap.put(logName, weeklyData);
        rs.close();
    }

} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();
    if (conn != null) conn.close();
}

// JSON 데이터를 생성
StringBuilder graphDataJsonBuilder = new StringBuilder();
graphDataJsonBuilder.append("{");
int logIndex = 0;
for (Map.Entry<String, double[]> entry : logDataMap.entrySet()) {
    graphDataJsonBuilder.append("\"").append(entry.getKey()).append("\": [");
    double[] data = entry.getValue();
    for (int i = 0; i < data.length; i++) {
        graphDataJsonBuilder.append(data[i]);
        if (i < data.length - 1) {
            graphDataJsonBuilder.append(", ");
        }
    }
    graphDataJsonBuilder.append("]");
    if (logIndex < logDataMap.size() - 1) {
        graphDataJsonBuilder.append(", ");
    }
    logIndex++;
}
graphDataJsonBuilder.append("}");
String graphDataJson = graphDataJsonBuilder.toString();

StringBuilder goalAchievementJsonBuilder = new StringBuilder();
goalAchievementJsonBuilder.append("{");
int achievementIndex = 0;
for (Map.Entry<String, Double> entry : goalAchievementMap.entrySet()) {
    goalAchievementJsonBuilder.append("\"").append(entry.getKey()).append("\": ").append(entry.getValue());
    if (achievementIndex < goalAchievementMap.size() - 1) {
        goalAchievementJsonBuilder.append(", ");
    }
    achievementIndex++;
}
goalAchievementJsonBuilder.append("}");
String goalAchievementJson = goalAchievementJsonBuilder.toString();

// JSP로 데이터 전달
request.setAttribute("graphData", graphDataJson);
request.setAttribute("goalAchievementData", goalAchievementJson);
request.setAttribute("logNames", logDataMap.keySet());
request.setAttribute("unitMap", unitMap); // 단위 데이터 전달
%>


<!DOCTYPE html>
<html>
<head>
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
        }

        .container {
            display: flex;
            height: 100vh;
            width: 100%;
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

          select {
            width: 150px; /* 선택 창 너비 */
            height: 40px; /* 선택 창 높이 */
            background-color: #063a71; /* 선택 창 배경색 */
            color: white; /* 선택 창 글자 색상 */
            border: none; /* 테두리 제거 */
            border-radius: 5px; /* 모서리를 둥글게 */
            padding: 5px 10px; /* 내부 여백 */
            font-size: 16px; /* 글자 크기 */
            outline: none; /* 포커스 시 외곽선 제거 */
            cursor: pointer; /* 커서를 포인터로 변경 */
            transition: background-color 0.3s ease;
        }

        select:hover {
            background-color: #0056b3; /* 마우스 오버 시 배경색 */
        }

        option {
            font-size: 16px; /* 옵션 글자 크기 */
            padding: 10px; /* 옵션 내부 여백 */
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

        .main-content {
            flex: 1;
            padding-left: 40px;
            box-sizing: border-box;
            overflow-y: auto;
        }

        .section1 {
            margin-top: 40px;
        }

        .section2 {
            margin-top: 60px;
        }

        hr {
            height: 5px;
            border: none;
            background-color: blue;
            margin-top: 10px;
            margin-bottom: 30px;
        }

		/* 막대그래프 캔버스 */
		.graph-container canvas {
		    display: block;
		    margin: 0 auto;
		    width: 900px !important; /* 막대그래프 너비 고정 */
		    height: 400px !important; /* 막대그래프 높이 고정 */
		}
		
		/* 원그래프 컨테이너 */
		#achievementContainer {
		    display: grid; /* 그리드 레이아웃 사용 */
		    grid-template-columns: repeat(2, 1fr); /* 한 줄에 2개의 그래프 */
		    gap: 20px; /* 그래프 간 간격 */
		    justify-items: center; /* 그래프를 중앙에 정렬 */
		    padding: 20px; /* 컨테이너 내부 여백 */
		}
		
		/* 원그래프 개별 컨테이너 */
		#achievementContainer div {
		    width: 300px; /* 원그래프 컨테이너 너비 */
		    height: 350px; /* 제목 포함 높이 */
		    display: flex;
		    flex-direction: column;
		    align-items: center;
		    justify-content: flex-start;
		    box-sizing: border-box;
		}
		
		/* 원그래프 캔버스 */
		#achievementContainer canvas {
		    width: 250px !important; /* 원그래프 너비 */
		    height: 250px !important; /* 원그래프 높이 */
		}

        .info-table {
            width: 70%; /* 테이블 전체 너비를 조정 */
            margin: 10px auto; /* 중앙 정렬 */
            border-collapse: collapse; /* 테두리 간격 제거 */
        }

        .info-table tr {
            border-bottom: 1px solid #444; /* 하단 경계선 */
        }

        .info-table th, .info-table td {
            padding: 15px 10px;
            text-align: left; /* 텍스트를 가운데 정렬 */
            color: white;
        }

        .info-table th {
            font-weight: bold;
            text-align: left; /* 헤더 가운데 정렬 */
        }

        .info-table td:first-child {
            text-align: left; /* 첫 번째 열은 왼쪽 정렬 */
        }

    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        let chart;

        // 전체 데이터
        const graphData = JSON.parse('<%= request.getAttribute("graphData") %>');
        const goalAchievementData = JSON.parse('<%= request.getAttribute("goalAchievementData") %>');

        console.log("goalAchievementData:", goalAchievementData);

        // 그래프 그리기
        function drawGraph(logName) {
            const data = graphData[logName];
            const ctx = document.getElementById('graphCanvas').getContext('2d');

                    // 막대그래프 색상 배열 생성
        const colors = [
            'rgba(255, 99, 132, 0.7)',  // Monday
            'rgba(54, 162, 235, 0.7)', // Tuesday
            'rgba(255, 206, 86, 0.7)', // Wednesday
            'rgba(75, 192, 192, 0.7)', // Thursday
            'rgba(153, 102, 255, 0.7)', // Friday
            'rgba(255, 159, 64, 0.7)',  // Saturday
            'rgba(199, 199, 199, 0.7)'  // Sunday
        ];

        const borderColors = [
            'rgba(255, 99, 132, 1)',  // Monday
            'rgba(54, 162, 235, 1)', // Tuesday
            'rgba(255, 206, 86, 1)', // Wednesday
            'rgba(75, 192, 192, 1)', // Thursday
            'rgba(153, 102, 255, 1)', // Friday
            'rgba(255, 159, 64, 1)',  // Saturday
            'rgba(199, 199, 199, 1)'  // Sunday
        ];

            
            


            if (chart) {
                chart.destroy();
            }

            chart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                    datasets: [{
                        label: logName,
                        data: data,
                        backgroundColor: colors,
                        borderColor: borderColors,
                        borderWidth: 1
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                color: 'white'
                            }
                        },
                        x: {
                            ticks: {
                                color: 'white'
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        }
                    }
                }
            });
        }

        function createPieChartWithTitle(logName, index) {
            const container = document.createElement('div');
            console.log("createPieChartWithTitle logName:", logName); // 디버깅 추가
            
            container.style.width = '48%'; // 한 줄에 두 개씩 정렬
            container.style.margin = '1%'; // 그래프 간 간격
            container.style.textAlign = 'center';
            container.style.display = 'inline-block'; // Flex 정렬에 포함되도록 설정

            // 제목 추가
            const title = document.createElement('h3');
            title.textContent = logName
            title.style.color = 'white';
            title.style.marginBottom = '10px';
            container.appendChild(title);

            // 캔버스 추가
            const canvasId = `achievementCanvas${index}`;
            const canvasElement = document.createElement('canvas');
            canvasElement.id = canvasId;
            canvasElement.width = 300; // 그래프 크기 축소
            canvasElement.height = 300;
            container.appendChild(canvasElement);

            // 컨테이너에 추가
            const achievementContainer = document.getElementById('achievementContainer');
            achievementContainer.appendChild(container);

            // 그래프 생성
            const ctx = canvasElement.getContext('2d');
            new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: [logName + " 달성", logName + " 미달성"],
                    datasets: [{
                        data: [
                            goalAchievementData[logName],
                            100 - goalAchievementData[logName]
                        ],
                        backgroundColor: [
                            'rgba(75, 192, 192, 0.7)',
                            'rgba(255, 99, 132, 0.7)'
                        ]
                    }]
                },
                options: {
                    plugins: {
                        legend: {
                            display: true,
                            position: 'bottom'
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    let label = context.label || '';
                                    if (label) {
                                        label += ': ';
                                    }
                                    label += context.raw.toFixed(2) + '%';
                                    return label;
                                }
                            }
                        }
                    }
                }
            });
        }

        // 페이지 로드 시 실행
        window.onload = function () {
            const logSelector = document.getElementById('logSelector');
            drawGraph(logSelector.value);
            logSelector.addEventListener('change', function () {
                drawGraph(this.value);
            });

            

            // 원그래프 생성
            const achievementContainer = document.getElementById('achievementContainer');
            achievementContainer.innerHTML = ''; // 기존 그래프 초기화
            Object.keys(goalAchievementData).forEach((logName, index) => {
                createPieChartWithTitle(logName, index);
            });
        };

</script>
</head>
<body>
    <div class="container">
        <div class="menu-bar">
            <div class="logo-container"  onclick="location.href='main.jsp'">
                <img src="./images/Logo.png" alt="Logo" class="logo" />
                <div class="logo-text">Life Log</div>
          </div>
          <div class="menu-item" data-page="main" onclick="location.href='main.jsp'">메인</div>
          <div class="menu-item active" data-page="log-analysis" onclick="location.href='log_analyze.jsp'">로그 분석</div>
          <div class="menu-item" data-page="log-record" onclick="location.href='goal_set.jsp'">로그 기록</div>
          <div class="menu-item" data-page="diary" onclick="location.href='diary.jsp'">일기</div>
          <div class="menu-item place-bottom" onclick="location.href='SignIn.jsp'">로그아웃</div>
        </div>


        <div class="main-content">
            <h1 class="section1">주간 로그 분석</h1>
            <hr>
            <div>
                <label for="logSelector">로그 선택:</label>
                <select id="logSelector">
                    <% for (String logName : (Set<String>) request.getAttribute("logNames")) { %>
                        <option value="<%= logName %>"> <%= logName %></option>
                    <% } %>
                </select>
            </div>
            <div class="graph-container">
                <canvas id="graphCanvas" width="900" height="400"></canvas>
            </div>
            <h1 class="section2">주간 달성률 분석</h1>
            <hr>
            <div id="achievementContainer" class="graph-container">
                <!-- 개별 원그래프가 동적으로 추가됩니다. -->
            </div>
            <h1 class="section2">주간 로그 통계</h1>
            <hr>
            <table class="info-table">
                <thead>
                    <tr>
                        <th>항목</th>
                        <th>값</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        for (String logName : logDataMap.keySet()) {
                            double[] weeklyData = logDataMap.get(logName);
                            double total = Arrays.stream(weeklyData).sum(); // 총합 계산
                            String unit = unitMap.get(logName); // 해당 log_name의 단위 가져오기
                    %>
                    <tr>
                        <td><%= logName %></td>
                        <td style="text-align: middle;"><%= total %> <%= unit %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        
    </div>
</body>
</html>