<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Life Log</title>
    <style type="text/css">
        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            box-sizing: border-box;
            background-color: #1e294a;
            color: white;
            display: flex;
            align-items: center;
            flex-direction: column;
        }
        button {
            width: 200px;
            padding: 10px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            background-color: #007bff;
            color: white;
            margin-top: 20px;
        }
        form{
            display: flex;
            align-items: center;
            flex-direction: column;
        }
    </style>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
    String year = request.getParameter("year");
    String month = request.getParameter("month");
    String day = request.getParameter("day");
    String email = session.getAttribute("email").toString();

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String task = request.getParameter("task");
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
            conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

            String sql = "INSERT INTO tasks (task_date, task_description, user_id) VALUES (?, ?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, year + "-" + month + "-" + day);
            stmt.setString(2, task);
            stmt.setString(3, email);
            stmt.executeUpdate();

            response.sendRedirect("main.jsp?year=" + year + "&month=" + month);
        } catch (Exception e) {
            out.println("DB 연동 오류입니다: " + e.getMessage());
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
<h1><%= year %>-<%= month %>-<%= day %></h1>
<form method="post">
    <textarea name="task" rows="4" cols="50" required></textarea>
    <br>
    <button type="submit">할일 추가</button>
</form>
</body>
</html>