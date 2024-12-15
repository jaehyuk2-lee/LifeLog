<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Calendar" %>
<%
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("email") == null) {
        response.sendRedirect("SignIn.jsp");
        return;
    }

    int year = 0;
    int month = 0;

    if (request.getParameter("year") == null || request.getParameter("month") == null) {
        Calendar today = Calendar.getInstance();
        year = today.get(Calendar.YEAR);
        month = today.get(Calendar.MONTH);
    } else {
        year = Integer.parseInt(request.getParameter("year"));
        month = Integer.parseInt(request.getParameter("month"));

        if (month == -1) {
            month = 11;
            year -= 1;
        }
        if (month == 12) {
            month = 0;
            year += 1;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="./images/Logo.png">
    <title>Life Log</title>
    <script>
    document.addEventListener("DOMContentLoaded", function () {
        fetchDiaries();

        function fetchDiaries() {
            fetch('loadDiaries.jsp')
                .then(response => response.json())
                .then(data => {
                    if (data.status === "success") {
                        renderDiaries(data.diaries);
                    } else {
                        console.error("Failed to fetch diaries:", data.message);
                    }
                })
                .catch(error => {
                    console.error("Error fetching diaries:", error);
                });
        }

        function renderDiaries(diaries) {
            const diaryContainer = document.getElementById("diaryEntries");
            if (!diaries || diaries.length === 0) {
                diaryContainer.innerHTML = "<p>작성된 일기가 없습니다.</p>";
                return;
            }
            diaryContainer.innerHTML = "";
            diaries.forEach(diary => {
            	var content = diary.diary_content;
            	var date = diary.date_written;
                const diaryElement = document.createElement("div");
                diaryElement.className = "diary-entry";
                diaryElement.innerHTML =
                    '<div class="diary-entry-date">' + date + '</div>' +
                    '<div class="diary-entry-content">' + content + '</div>';
                diaryContainer.appendChild(diaryElement);
            });
        }
    });
</script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #1e1e1e;
            color: white;
            display: flex;
       	 	margin: 0;
       	 	padding: 0;
        	box-sizing: border-box;
        }
        
        .container {
        	display:flex;
        	height:100vh;
      	}

		.menu-bar {
			width : 200px;
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

        .calendar-container {
            flex:1;
            margin: 100px 10px 10px;
            background-color: #274a8f;
            border-radius: 10px;
           	height: 610px;
        }

        .calendar-header {
            text-align: center;
            margin-bottom: 20px;
        }

        .calendar-header a {
            color: white;
            text-decoration: none;
            margin: 0 10px;
            font-weight: bold;
        }
        
        .side {
            flex: 0.5;
            background-color: #1e1e1e;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .profile {
        	position:absolute;
        	top:30px;
        	right:50px;
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 30px;
        }

        .profile img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            border: 2px solid #007bff;
        }

        .profile .name {
            font-size: 20px;
            font-weight: bold;
        }
		
		.side{
			margin-top:50px;
			padding:0px;
		}
        .summary {
            background-color: #274a8f;
            border-radius: 10px;
            text-align: center;
            height:350px;
        }
        .diary{
        	margin-top:10px;
        	background-color: #274a8f;
            border-radius: 10px;
            text-align: center;
            width:420px;
            height:250px;
        }
        .diary-entries-container {
        	display: flex;
        	gap: 10px;
        	overflow-x: auto;
        	padding: 10px;
    	}

    	.diary-entry {
    		color: black;
        	background-color: white;
        	border: 1px solid #007bff;
        	border-radius: 8px;
        	padding: 10px;
        	width: 200px;
        	height: 100px;
        	flex-shrink: 0;
        	word-wrap: break-word;
    	}

    	.diary-entry-date {
        	font-weight: bold;
        	margin-bottom: 8px;
    	}
    </style>
</head>
<body>
	<div class="container">
      <div class="menu-bar">
      	<div class="logo-container"  onclick="location.href='main.jsp'">
  			<img src="./images/Logo.png" alt="Logo" class="logo" />
  			<div class="logo-text">Life Log</div>
		</div>
        <div class="menu-item active" data-page="main" onclick="location.href='main.jsp'">메인</div>
        <div class="menu-item" data-page="log-analysis" onclick="location.href='log_analyze.jsp'">로그 분석</div>
        <div class="menu-item" data-page="log-record" onclick="location.href='goal_set.jsp'">로그 기록</div>
        <div class="menu-item" data-page="diary" onclick="location.href='diary.jsp'">일기</div>
        <div class="menu-item place-bottom" onclick="location.href='SignOut.jsp'">로그아웃</div>
      </div>
    	<div class="calendar-container">
        <div class="calendar-header">
        	<h3>캘린더</h3>
            <a href="main.jsp?year=<%= (month == 0 ? year - 1 : year) %>&month=<%= (month + 11) % 12 %>">◀</a>
			<span><%= year %>년 <%= month + 1 %>월</span>
			<a href="main.jsp?year=<%= (month == 11 ? year + 1 : year) %>&month=<%= (month + 1) % 12 %>">▶</a>
        </div>

        <jsp:include page="calendar.jsp">
            <jsp:param name="year" value="<%= year %>" />
            <jsp:param name="month" value="<%= month %>" />
        </jsp:include>
    	</div>
    	
    	<div class="side">
    		<div class="summary">
    		<h3>주간 달성률 분석</h3>
    		<jsp:include page="weekly.jsp"></jsp:include>
    		</div>
    		
    		<div class="diary">
    			<h3>일기</h3>
    			<div id="diaryEntries" class="diary-entries-container">
    			</div>
			</div>

    	</div>
    	</div>
   <div class="profile" onclick="location.href='profile.jsp'">
            <div class="name"><%=session.getAttribute("name").toString()%></div>
    		<img src="./images/profile-icon.png" alt="User Icon" />
       	</div>

</body>
</html>