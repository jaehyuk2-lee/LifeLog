<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
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

        .content {
            flex: 1;
            padding: 20px;
            padding-left: 40px;
            margin-top: 40px;
            overflow-y: auto;
            box-sizing: border-box;
        }

        .header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }

        .header img {
            width: 40px;
            height: 40px;
            margin-right: 10px;
        }

        .header h1 {
            text-align: left;
            color: white;
            margin: 0;
        }

        .content hr {
            height: 2px;
            width: 100%;
            border: none;
            background-color: #2D488B;
            margin-top: 0px;
        }

        .info-table {
            width: 85%;
            border-collapse: collapse;
        }

        .info-table tr {
            border-bottom: 1px solid #444;
        }

        .info-table td {
            padding: 20px 20px;
            text-align: left;
        }

        .info-table td:first-child {
            width: 30%;
            color: #a0a0a5;
        }

        .button-container {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 40px;
        }

        .button {
            background-color: #1e73e8;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .button:hover {
            background-color: #155bb5;
        }
    </style>
</head>

<body>
    <%

    String userEmail = (String) session.getAttribute("email");

    String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
    String username = "lifelog_admin";
    String password = "q1w2e3r4";
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String name = "", id = "", gender = "",  birthday = "", job = "", org = "";

    if (userEmail != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, username, password);

            String sql = "SELECT * FROM users WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userEmail);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                name = rs.getString("name");
                id = rs.getString("id");
                gender = rs.getString("gender").equals("MALE") ? "남성" : "여성";
                birthday = rs.getString("birthday");
                job = rs.getString("job");
                org = rs.getString("org");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    } else {
        response.sendRedirect("SignIn.jsp");
    }
    %>

    <div class="container">
        <div class="menu-bar">
            <div class="logo-container"  onclick="location.href='main.jsp'">
                <img src="./images/Logo.png" alt="Logo" class="logo" />
                <div class="logo-text">Life Log</div>
            </div>
            <div class="menu-item" data-page="main" onclick="location.href='main.jsp'">메인</div>
            <div class="menu-item" data-page="log-analysis" onclick="location.href='log_analyze.jsp'">로그 분석</div>
            <div class="menu-item" data-page="log-record" onclick="location.href='goal_set.jsp'">로그 기록</div>
            <div class="menu-item" data-page="diary" onclick="location.href='diary.jsp'">일기</div>
            <div class="menu-item place-bottom" onclick="location.href='SignOut.jsp'">로그아웃</div>
        </div>

        <div class="content">
            <div class="header">
                <img src="<%= request.getContextPath() %>/images/profile-icon.png" alt="Profile Icon">
                <h1>회원 정보</h1>
            </div>
            <hr>
            <table class="info-table">
                <tr>
                    <td>이름</td>
                    <td><%= name %></td>
                </tr>
                <tr>
                    <td>아이디</td>
                    <td><%= id %></td>
                </tr>
                <tr>
                    <td>성별</td>
                    <td><%= gender %></td>
                </tr>
                <tr>
                    <td>생일</td>
                    <td><%= birthday %></td>
                </tr>
                <tr>
                    <td>직업</td>
                    <td><%= job %></td>
                </tr>
                <tr>
                    <td>소속</td>
                    <td><%= org %></td>
                </tr>
            </table>
            <div class="button-container">
                <button class="button" onclick="location.href='<%= request.getContextPath() %>/edit_profile.jsp'">수정</button>
                <button class="button" onclick="location.href='<%= request.getContextPath() %>/change_pwd.jsp'">비밀번호 변경</button>
            </div>
        </div>
    </div>
</body>

</html>