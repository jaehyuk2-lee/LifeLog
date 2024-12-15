<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
    <title>주간 달성률 분석</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        #achievementContainer {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            justify-items: center;
        }
        #achievementContainer div {
            text-align: center;
        }
        #achievementContainer canvas {
            width: 200px !important;
            height: 200px !important;
        }
    </style>
</head>
<body>
    <div id="achievementContainer"></div>

    <script>
        // 전달된 데이터 가져오기
        const goalAchievementData = JSON.parse('<%= request.getAttribute("goalAchievementData") %>');
        
        // 원그래프 생성 함수
        function createPieChart(logName, achievementRate) {
            const container = document.createElement('div');
            const canvas = document.createElement('canvas');
            canvas.width = 300;
            canvas.height = 300;

            container.appendChild(canvas);
            const ctx = canvas.getContext('2d');
            const remainingRate = 100 - achievementRate;

            new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: [`${logName} 달성`, `${logName} 미달성`],
                    datasets: [{
                        data: [achievementRate, remainingRate],
                        backgroundColor: ['rgba(75, 192, 192, 0.7)',
                            'rgba(255, 99, 132, 0.7)']
                    }]
                },
                options: {
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                color: 'white'
                            }
                        }
                    }
                }
            });

            const achievementContainer = document.getElementById('achievementContainer');
            const title = document.createElement('h3');
            title.innerText = logName;
            title.style.color = 'white';
            container.insertBefore(title, canvas);
            achievementContainer.appendChild(container);
        }

        // 데이터로 그래프 생성
        Object.entries(goalAchievementData).forEach(([logName, achievementRate]) => {
            createPieChart(logName, parseFloat(achievementRate));
        });
    </script>
</body>
</html>
