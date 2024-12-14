<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="icon" href="./images/Logo.png">
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
        form {
            display: flex;
            align-items: center;
            flex-direction: column;
        }
        .task-list {
            width: 80%;
            margin: 20px 0;
        }
        .task-item {
            display: flex;
            justify-content: space-between;
            background-color: #2e3b55;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 10px;
        }
        .task-item span {
            color: white;
        }
        .delete-btn {
            background-color: red;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            padding: 5px 10px;
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

    // Handle POST request to add new task
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
        } catch (Exception e) {
            out.println("DB 연동 오류입니다: " + e.getMessage());
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    
    String deleteTaskId = request.getParameter("deleteTaskId");
    if (deleteTaskId != null) {
        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
            conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");
            String sql = "DELETE FROM tasks WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(deleteTaskId));
            stmt.executeUpdate();
        } catch (Exception e) {
            out.println("DB 연동 오류입니다: " + e.getMessage());
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // Fetch tasks for the selected date
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    List<Map<String, String>> taskList = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");
        String sql = "SELECT id, task_description FROM tasks WHERE task_date = ? AND user_id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, year + "-" + month + "-" + day);
        stmt.setString(2, email);
        rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, String> task = new HashMap<>();
            task.put("id", rs.getString("id"));
            task.put("description", rs.getString("task_description"));
            taskList.add(task);
        }
    } catch (Exception e) {
        out.println("DB 연동 오류입니다: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

<h1><%= year %>-<%= month %>-<%= day %></h1>

<div class="task-list">
    <% for (Map<String, String> task : taskList) { %>
        <div class="task-item">
            <span><%= task.get("description") %></span>
            <form method="get" style="margin: 0;">
                <input type="hidden" name="year" value="<%= year %>">
                <input type="hidden" name="month" value="<%= month %>">
                <input type="hidden" name="day" value="<%= day %>">
                <input type="hidden" name="deleteTaskId" value="<%= task.get("id") %>">
                <button type="submit" class="delete-btn">X</button>
            </form>
        </div>
    <% } %>
</div>

<form method="post">
    <textarea name="task" rows="4" cols="50" required></textarea>
    <br>
    <button type="submit">할일 추가</button>
</form>
<button type="button" onclick="location.href='main.jsp'">돌아가기</button>
</body>
</html>
