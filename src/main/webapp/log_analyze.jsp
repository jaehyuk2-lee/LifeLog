<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="javax.servlet.http.*" %>
<%

String userEmail = (String) session.getAttribute("email"); 

String dbUrl = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
String dbUser = "lifelog_admin";
String dbPassword = "q1w2e3r4";

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

Map<String, double[]> logDataMap = new LinkedHashMap<>();
Map<String, String> unitMap = new LinkedHashMap<>();
Map<String, Double> goalAchievementMap = new LinkedHashMap<>();

try {
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

    String logNameQuery = "SELECT DISTINCT log_name, unit FROM logs WHERE user_id = ?";
    pstmt = conn.prepareStatement(logNameQuery);
    pstmt.setString(1, userEmail);
    rs = pstmt.executeQuery();
    List<String> logNames = new ArrayList<>();
    while (rs.next()) {
        String logName = rs.getString("log_name");
        logNames.add(logName);
        unitMap.put(logName, rs.getString("unit"));
    }
    rs.close();
    pstmt.close();

    for (String logName : logNames) {
        double[] weeklyData = new double[7];
        Arrays.fill(weeklyData, 0.0);
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
            goalValue = rs.getDouble("goal_value");

            totalInput += dayTotalInput;
            activeDays += dayActiveDays;

            if (dayIndexMap.containsKey(day)) {
                int index = dayIndexMap.get(day);
                weeklyData[index] = dayTotalInput;
            }
        }

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
request.setAttribute("unitMap", unitMap);
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
            width: 150px;
            height: 40px;
            background-color: #063a71;
            color: white;
            border: none;
            border-radius: 5px;
            padding: 5px 10px;
            font-size: 16px;
            outline: none;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        select:hover {
            background-color: #0056b3;
        }

        option {
            font-size: 16px;
            padding: 10px;
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

		.graph-container canvas {
		    display: block;
		    margin: 0 auto;
		    width: 900px !important;
		    height: 400px !important;
		}
		
		#achievementContainer {
		    display: grid;
		    grid-template-columns: repeat(2, 1fr);
		    gap: 20px;
		    justify-items: center;
		    padding: 20px;
		}
		
		#achievementContainer div {
		    width: 300px;
		    height: 350px;
		    display: flex;
		    flex-direction: column;
		    align-items: center;
		    justify-content: flex-start;
		    box-sizing: border-box;
		}
		
		#achievementContainer canvas {
		    width: 250px !important;
		    height: 250px !important;
		}

        .info-table {
            width: 70%;
            margin: 10px auto;
            border-collapse: collapse;
        }

        .info-table tr {
            border-bottom: 1px solid #444;
        }

        .info-table th, .info-table td {
            padding: 15px 10px;
            text-align: left;
            color: white;
        }

        .info-table th {
            font-weight: bold;
            text-align: left;
        }

        .info-table td:first-child {
            text-align: left;
        }

    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        let chart;

        const graphData = JSON.parse('<%= request.getAttribute("graphData") %>');
        const goalAchievementData = JSON.parse('<%= request.getAttribute("goalAchievementData") %>');

        console.log("goalAchievementData:", goalAchievementData);


        function drawGraph(logName) {
            const data = graphData[logName];
            const ctx = document.getElementById('graphCanvas').getContext('2d');

        	const colors = [
            	'rgba(255, 99, 132, 0.7)',
            	'rgba(54, 162, 235, 0.7)',
            	'rgba(255, 206, 86, 0.7)',
            	'rgba(75, 192, 192, 0.7)',
            	'rgba(153, 102, 255, 0.7)',
            	'rgba(255, 159, 64, 0.7)',
            	'rgba(199, 199, 199, 0.7)'
       		];

        	const borderColors = [
            	'rgba(255, 99, 132, 1)',
            	'rgba(54, 162, 235, 1)',
            	'rgba(255, 206, 86, 1)',
            	'rgba(75, 192, 192, 1)',
            	'rgba(153, 102, 255, 1)',
            	'rgba(255, 159, 64, 1)',
            	'rgba(199, 199, 199, 1)'
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
            console.log("createPieChartWithTitle logName:", logName);
            
            container.style.width = '48%';
            container.style.margin = '1%';
            container.style.textAlign = 'center';
            container.style.display = 'inline-block';

            const title = document.createElement('h3');
            title.textContent = logName
            title.style.color = 'white';
            title.style.marginBottom = '10px';
            container.appendChild(title);

            const canvasId = `achievementCanvas${index}`;
            const canvasElement = document.createElement('canvas');
            canvasElement.id = canvasId;
            canvasElement.width = 300;
            canvasElement.height = 300;
            container.appendChild(canvasElement);

            const achievementContainer = document.getElementById('achievementContainer');
            achievementContainer.appendChild(container);

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

        window.onload = function () {
            const logSelector = document.getElementById('logSelector');
            drawGraph(logSelector.value);
            logSelector.addEventListener('change', function () {
                drawGraph(this.value);
            });

            const achievementContainer = document.getElementById('achievementContainer');
            achievementContainer.innerHTML = '';
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
                            double total = Arrays.stream(weeklyData).sum();
                            String unit = unitMap.get(logName);
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