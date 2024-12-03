<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
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
        h1 {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("email");
    String pwd = request.getParameter("pwd");
    String name = request.getParameter("name");
    String gender = request.getParameter("gender");
    String dob = request.getParameter("birth");
    String job = request.getParameter("job");
    String org = request.getParameter("org");

    Connection conn = null;
    PreparedStatement checkStmt = null;
    PreparedStatement insertStmt = null;
    ResultSet rs = null;

    boolean isDuplicate = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        
        String checkSql = "SELECT id FROM users WHERE id = ?";
        checkStmt = conn.prepareStatement(checkSql);
        checkStmt.setString(1, id);
        rs = checkStmt.executeQuery();

        if (rs.next()) {
            isDuplicate = true;
        } else {
            
            String insertSql = "INSERT INTO users (id, password, name, gender, birthday, job, org) VALUES (?, ?, ?, ?, ?, ?, ?)";
            insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, id);
            insertStmt.setString(2, pwd);
            insertStmt.setString(3, name);
            insertStmt.setString(4, gender);
            insertStmt.setString(5, dob);
            insertStmt.setString(6, job);
            insertStmt.setString(7, org);
            insertStmt.executeUpdate();
        }
    } catch (Exception e) {
        out.println("DB 연동 오류입니다: " + e.getMessage());
    } finally {
        
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (checkStmt != null) try { checkStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (insertStmt != null) try { insertStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }

    
    if (isDuplicate) {
%>
    <h1>회원가입 실패: ID가 이미 존재합니다.</h1>
    <button type="button" onclick="location.href='SignUp.jsp'">Sign Up</button>
<%
    } else {
%>
    <h1>회원가입이 완료되었습니다.</h1>
    <button type="button" onclick="location.href='SignIn.jsp'">Sign in</button>
<%
    }
%>
</body>
</html>
