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
            background-color: #1e1e1e;
            color: white;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .container {
            width: 1000px;
            height: auto;
            padding-bottom: 20px;
            margin-top: 30px;
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
            color: white;
            margin: 0;
        }

        .container hr {
            height: 5px;
            border: none;
            background-color: blue;
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

        .info-table input[type="password"] {
            width: 50%;
            padding: 8px;
            background: #222;
            border: 1px solid #555;
            border-radius: 4px;
            color: white;
            box-sizing: border-box;
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

    <script>
        function cancelEdit() {
            window.location.href = "profile.jsp";
        }
    </script>
</head>

<body>
    <%
    
        String userEmail = (String) session.getAttribute("email");

        if (userEmail == null) {
            response.sendRedirect("SignIn.jsp");
            return;
        }

        String currentPassword = request.getParameter("current_password");
        String newPassword = request.getParameter("new_password");
        String confirmPassword = request.getParameter("confirm_password");
        String message = "";

        if (currentPassword != null && newPassword != null && confirmPassword != null) {
            if (!newPassword.equals(confirmPassword)) {
                message = "새 비밀번호가 일치하지 않습니다.";
            } else {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;

                try {
                    String url = "jdbc:mysql://localhost:3306/life_log_db?useSSL=false&serverTimezone=UTC";
                    String dbUsername = "lifelog_admin";
                    String dbPassword = "q1w2e3r4";

                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, dbUsername, dbPassword);

                    String sql = "SELECT password FROM users WHERE id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, userEmail);
                    rs = pstmt.executeQuery();

                    if (rs.next()) {
                        String dbPasswordHash = rs.getString("password");

                        if (!currentPassword.equals(dbPasswordHash)) {
                            message = "현재 비밀번호가 일치하지 않습니다.";
                        } else {
                            sql = "UPDATE users SET password = ? WHERE id = ?";
                            pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, newPassword);
                            pstmt.setString(2, userEmail);
                            int updatedRows = pstmt.executeUpdate();

                            if (updatedRows > 0) {
                                out.println("<script>alert('비밀번호가 성공적으로 변경되었습니다.'); location.href='profile.jsp';</script>");
                            } else {
                                message = "비밀번호 변경에 실패했습니다.";
                            }
                        }
                    } else {
                        message = "사용자를 찾을 수 없습니다.";
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    message = "오류가 발생했습니다. 다시 시도해주세요.";
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) {}
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                    if (conn != null) try { conn.close(); } catch (SQLException e) {}
                }
            }
        }
    %>
    <div class="container">
        <div class="header">
            <img src="<%= request.getContextPath() %>/images/profile-icon.png" alt="Profile Icon">
            <h1>비밀번호 변경</h1>
        </div>
        <hr>
        <form action="" method="post">
            <table class="info-table">
                <tr>
                    <td>현재 비밀번호</td>
                    <td><input type="password" name="current_password" placeholder="현재 비밀번호" required></td>
                </tr>
                <tr>
                    <td>새 비밀번호</td>
                    <td><input type="password" name="new_password" placeholder="새 비밀번호" required></td>
                </tr>
                <tr>
                    <td>새 비밀번호 확인</td>
                    <td><input type="password" name="confirm_password" placeholder="새 비밀번호 확인" required></td>
                </tr>
            </table>
            <div class="button-container">
                <button type="submit" class="button">저장</button>
                <button type="button" class="button" onclick="cancelEdit()">취소</button>
            </div>
        </form>
        <div style="text-align: center; margin-top: 20px;">
            <p><%= message %></p>
        </div>
    </div>
</body>

</html>