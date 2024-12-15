<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="javax.servlet.RequestDispatcher" %>
<%
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="icon" href="./images/Logo.png">
    <title>Life Log</title>
    <style>
        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            box-sizing: border-box;
            background-color: #1e294a;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
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
        h1 {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
    String email = request.getParameter("email");
    String pwd = request.getParameter("password");

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        String sql = "SELECT name, password FROM users WHERE id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, email);
        rs = stmt.executeQuery();

        if (rs.next()) {
            String pwd_db = rs.getString("password");
            if (pwd.equals(pwd_db)) {
                String name = rs.getString("name");

                HttpSession usr_session = request.getSession(true);
                usr_session.setAttribute("email", email);
                usr_session.setAttribute("name", name);

                RequestDispatcher dispatcher = request.getRequestDispatcher("main.jsp");
                dispatcher.forward(request, response);
            } else {
%>
                <h1>비밀번호가 일치하지 않습니다.</h1>
                <button type="button" onclick="location.href='SignIn.jsp'">Sign In</button>
<%
            }
        } else {
%>
            <h1>존재하지 않는 회원입니다.</h1>
            <button type="button" onclick="location.href='SignIn.jsp'">Sign In</button>
<%
        }
    } catch (Exception e) {
        out.println("DB 연동 오류입니다: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
</body>
</html>
