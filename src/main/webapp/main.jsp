<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Calendar" %>
<%
    // 브라우저 캐싱 방지
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 세션 확인: 세션이 없으면 로그인 페이지로 리디렉션
    if (session.getAttribute("email") == null) {
        response.sendRedirect("SignIn.jsp");
        return;
    }
%>
<%
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
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #1e1e1e;
            color: white;
            margin: 0;
            padding: 0;
        }
        
        .container {
        	display: flex;
        	height:100vh;
      	}

		.menu-bar {
        	flex: 0.3;
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
            width: 80%;
            margin: 100px 30px;
            background-color: #274a8f;
            padding: 20px;
            border-radius: 10px;
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

        .summary {
            width: 100%;
            background-color: #274a8f;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
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
        <div class="menu-item" data-page="log-record" onclick="location.href='log_set.jsp'">로그 기록</div>
        <div class="menu-item" data-page="diary" onclick="location.href='diary.jsp'">일기</div>
        <div class="menu-item place-bottom" onclick="location.href='SignOut.jsp'">로그아웃</div>
      </div>
	
    <div class="calendar-container">
        <div class="calendar-header">
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
    	<div class="profile" onclick="location.href='profile.jsp'">
            <div class="name"><%=session.getAttribute("name").toString()%></div>
    		<img src="./images/profile-icon.png" alt="User Icon" />
        </div>
    	<div class="summary">주간 목표 달성률</div>
    </div>
   </div>
</body>
</html>
