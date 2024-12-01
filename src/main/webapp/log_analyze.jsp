<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // 데이터베이스 연결 정보
    String dbUrl = "jdbc:mysql://localhost:3306/user_logs_db?serverTimezone=UTC";
    String dbUser = "lifelog_admin";
    String dbPassword = "q1w2e3r4";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // log_name 목록과 데이터를 저장할 맵
    Map<String, double[]> logDataMap = new LinkedHashMap<>();
    Map<String, Double> goalAchievementMap = new LinkedHashMap<>();

    try {
        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

        // log_name 목록 가져오기
        String logNameQuery = "SELECT DISTINCT log_name FROM logs";
        pstmt = conn.prepareStatement(logNameQuery);
        rs = pstmt.executeQuery();
        List<String> logNames = new ArrayList<>();
        while (rs.next()) {
            logNames.add(rs.getString("log_name"));
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
                "WHERE log_name = ? AND WEEK(date_entered, 1) = ( " + "    SELECT MAX(WEEK(date_entered, 1)) FROM logs WHERE log_name = ? " +
                ") " + "GROUP BY day_of_week, goal_value";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, logName);
            pstmt.setString(2, logName);

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

    request.setAttribute("graphData", graphDataJson);
    request.setAttribute("goalAchievementData", goalAchievementJson);
    request.setAttribute("logNames", logDataMap.keySet());


%>
<!DOCTYPE html>
<html>
<head>
    <title>로그 분석</title>
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
            flex: 0.187;
            background-color: #274a8f;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px 10px;
            gap: 20px;
            height: 100%;
            box-sizing: border-box;
        }

        .menu-item {
            padding: 15px;
            width: 80%;
            text-align: center;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .menu-item:hover,
        .menu-item.active {
            background-color: #007bff;
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

        .graph-container {
            margin: 20px auto;
            margin-top: 40px;
            width: 90%;
            text-align: center;
        }

        canvas {
            display: block;
            margin: 0 auto;
        }


        #achievementContainer {
            display: flex;
            flex-wrap: wrap; /* 한 줄에 두 개씩 정렬 */
            justify-content: space-around;
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
                        backgroundColor: 'rgba(255, 255, 255, 0.7)',
                        borderColor: 'rgba(255, 255, 255, 1)',
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
            <div class="logo-container">
                <img src="./image/Logo.png" alt="Logo" class="logo" />
                <div class="logo-text">Life Log</div>
          </div>
          <div class="menu-item active" data-page="main" onclick="location.href='main.jsp'">메인</div>
          <div class="menu-item" data-page="log-analysis" onclick="location.href='log_analyze.jsp'">로그 분석</div>
          <div class="menu-item" data-page="log-record" onclick="location.href='log_set.jsp'">로그 기록</div>
          <div class="menu-item" data-page="goal-management" onclick="location.href='goal_set.jsp'">목표 관리</div>
          <div class="menu-item" data-page="diary" onclick="location.href='diary.jsp'">일기</div>
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
    </div>
</body>
</html>