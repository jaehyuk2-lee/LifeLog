<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>로그 분석</title>
    <style>
        body {
            margin: 0;
            background-color: black;
            color: white;
            font-family: Arial, sans-serif;
            display: flex;
        }

        .menu-placeholder {
            width: 20%; /* 메뉴바 공간 */
            background-color: black; /* 메뉴바 배경 */
            height: 100vh; /* 화면 전체 높이 */
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .main-content {
            width: 80%; /* 나머지 화면 공간 */
            margin: 0;
            padding: 20px;
            flex:1.5;
        }

        h1 {
            color: white;
            margin-top: 20px;
        }

        .main-content hr {
            height: 2px;
            width: 100%;
            border: none;
            background-color: blue;
            margin: 20px 0; /* 파란 선 위아래 여백 증가 */
        }

        .section {
            margin-bottom: 100px; /* 주간 로그 분석과 일일 로그 분석 간격 증가 */
        }

        .graph-container, .pie-container {
            margin: 20px auto;
            width: 90%;
            text-align: center;
        }

        .selector {
            margin: 20px;
            display: flex;
            align-items: center; /* 세로 정렬을 중앙으로 */
            gap: 10px; /* label과 select 간의 간격 */
        }

        select {
            padding: 10px;
            font-size: 16px;
            background-color: #444;
            color: white;
            border: 1px solid #222;
            border-radius: 5px;
        }

        .pie-container {
            display: flex;
            justify-content: space-around;
            margin-top: 50px; /* 파란 선과 그래프 간 간격 증가 */
        }

        .pie-chart {
            width: 30%;
        }

        .pie-label {
            margin-top: 10px;
            color: white;
            font-size: 14px;
        }

        canvas {
            display: block;
            margin: 0 auto;
        }
        
        .menu-bar {
        	flex:0.28;
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
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        let chart; // Chart.js 인스턴스

        function loadGraph(graphType = "공부시간") {
            const graphData = {
                "운동량": [30, 40, 50, 60, 70, 80, 90],
                "음주": [10, 20, 30, 40, 50, 60, 70],
                "공부시간": [50, 30, 70, 20, 80, 40, 60],
                "수면시간": [70, 60, 50, 40, 30, 20, 10]
            };

            const labels = ["Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"];
            const data = graphData[graphType];

            const ctx = document.getElementById('graphCanvas').getContext('2d');

            // 기존 차트가 있으면 삭제
            if (chart) {
                chart.destroy();
            }

            // 새로운 차트 생성
            chart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: graphType,
                        data: data,
                        backgroundColor: 'rgba(255, 255, 255, 1)', // 막대 내부 색상
                        borderColor: 'rgba(255, 255, 255, 1)',       // 막대 테두리 색상
                        maxBarThickness: 50,
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

        function loadPieCharts() {
            const pieData = {
                labels: ["운동량", "수면", "수분 섭취"],
                values: [78, 78, 78]
            };

            const colors = ["#FF4D4D", "#4DFF4D", "#4D4DFF"];

            const charts = document.querySelectorAll(".pie-chart canvas");

            charts.forEach((canvas, index) => {
                const ctx = canvas.getContext('2d');
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: [pieData.labels[index]],
                        datasets: [{
                            data: [pieData.values[index], 100 - pieData.values[index]],
                            backgroundColor: [colors[index], "rgba(0, 0, 0, 0.2)"]
                        }]
                    },
                    options: {
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                enabled: false
                            }
                        },
                        cutout: "50%"
                    }
                });
            });
        }

        // 페이지 로드 시 기본 그래프 로드
        window.onload = function () {
            loadGraph();
            loadPieCharts();
        };
    </script>
</head>
<body>
	<div class="menu-bar">
      	<div class="logo-container">
  			<img src="./image/Logo.png" alt="Logo" class="logo" />
  			<div class="logo-text">Life Log</div>
		</div>
        <div class="menu-item" data-page="main" onclick="location.href='main.jsp'">메인</div>
        <div class="menu-item active" data-page="log-analysis" onclick="location.href='log_analyze.jsp'">로그 분석</div>
        <div class="menu-item" data-page="log-record" onclick="location.href='log_set.jsp'">로그 기록</div>
        <div class="menu-item" data-page="goal-management" onclick="location.href='goal_set.jsp'">목표 관리</div>
        <div class="menu-item" data-page="diary" onclick="location.href='diary.jsp'">일기</div>
      </div>
    <div class="main-content">
        <div class="section">
            <h1>주간 로그 분석</h1>
            <hr>
            <div class="selector">
                <label for="graphSelector">그래프 종류:</label>
                <select id="graphSelector" onchange="loadGraph(this.value)">
                    <option value="운동량">운동량</option>
                    <option value="음주">음주</option>
                    <option value="공부시간" selected>공부시간</option>
                    <option value="수면시간">수면시간</option>
                </select>
            </div>
            <div class="graph-container">
                <canvas id="graphCanvas" width="900" height="400"></canvas>
            </div>
        </div>

        <!-- 일일 로그 분석 -->
        <div class="section">
            <h1>일일 로그 분석</h1>
            <hr>
            <div class="pie-container">
                <div class="pie-chart">
                    <canvas width="200" height="200"></canvas>
                    <div class="pie-label">운동량</div>
                </div>
                <div class="pie-chart">
                    <canvas width="200" height="200"></canvas>
                    <div class="pie-label">수면</div>
                </div>
                <div class="pie-chart">
                    <canvas width="200" height="200"></canvas>
                    <div class="pie-label">수분 섭취</div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>