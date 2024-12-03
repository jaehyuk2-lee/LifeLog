<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    request.setCharacterEncoding("UTF-8");
%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <title>Lifelog</title>
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
            margin-left: 100px;
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
            margin-top: 10px;
        }

        .info-table {
            width: 85%;
            border-collapse: collapse;
        }

        .info-table tr {
            border-bottom: 1px solid #444;
        }

        .info-table td {
            padding: 15px 10px;
            text-align: left;
            vertical-align: middle;
        }

        .info-table td:first-child {
            width: 30%;
            color: #a0a0a5;
        }

        .info-table input[type="text"],
        .info-table input[type="email"],
        .info-table input[type="date"],
        .info-table select {
            width: 50%;
            padding: 8px;
            background: #222;
            border: 1px solid #555;
            border-radius: 4px;
            color: white;
            box-sizing: border-box;
        }

        .info-table input[type="date"]::-webkit-calendar-picker-indicator {
            filter: invert(1);
            opacity: 0.6;
            cursor: pointer;
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
        // 세션에서 사용자 ID 가져오기
        String userId = (String) session.getAttribute("email");

        if (userId == null) {
            // 로그인되지 않은 경우 로그인 페이지로 리다이렉트
            response.sendRedirect("login.jsp");
            return;
        }

        // 데이터베이스 연결 설정
        String url = "jdbc:mysql://localhost:3306/life_log_db?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8";
        String dbUsername = "lifelog_admin";
        String dbPassword = "q1w2e3r4";
        Connection conn = null;
        PreparedStatement pstmt = null;

        // POST 요청 처리
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String name = request.getParameter("name");
            String gender = request.getParameter("gender");
            String birthday = request.getParameter("birthday");
            String job = request.getParameter("job");
            String org = request.getParameter("org");

            try {
                // 데이터베이스 연결
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, dbUsername, dbPassword);

                // gender 값 변환
                if ("남성".equals(gender)) {
                    gender = "MALE";
                } else if ("여성".equals(gender)) {
                    gender = "FEMALE";
                } else {
                    gender = null; // 예외 처리 (필요 시)
                }

                // 사용자 정보 업데이트 쿼리
                String sql = "UPDATE users SET name = ?, gender = ?, birthday = ?, job = ?, org = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name);
                pstmt.setString(2, gender); // 변환된 gender 값 사용
                pstmt.setString(3, birthday);
                pstmt.setString(4, job);
                pstmt.setString(5, org);
                pstmt.setString(6, userId);

                int rowsUpdated = pstmt.executeUpdate();
                if (rowsUpdated > 0) {
                    out.println("<script>alert('회원정보가 성공적으로 변경되었습니다.'); location.href='profile.jsp';</script>");
                } else {
                    out.println("<p style='color: red;'>회원 정보 수정에 실패했습니다.</p>");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<p style='color: red;'>오류가 발생했습니다. 다시 시도해주세요.</p>");
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        }

        // GET 요청: 기존 데이터 불러오기
        String name = "";
        String gender = "";
        String birthday = "";
        String job = "";
        String org = "";
        ResultSet rs = null;

        try {
            // 데이터베이스 연결
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUsername, dbPassword);

            // 사용자 정보 조회 쿼리
            String sql = "SELECT name, gender, birthday, job, org FROM users WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            // 데이터 가져오기
            if (rs.next()) {
                name = rs.getString("name");
                gender = "MALE".equals(rs.getString("gender")) ? "남성" : "여성";
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
    %>

    <div class="container">
        <div class="header">
            <img src="<%= request.getContextPath() %>/images/profile-icon.png" alt="Profile Icon">
            <h1>회원 정보 수정</h1>
        </div>
        <hr>
        <form action="" method="post">
            <table class="info-table">
                <tr>
                    <td>이름</td>
                    <td><input type="text" name="name" value="<%= name %>" required></td>
                </tr>
                <tr>
                    <td>성별</td>
                    <td>
                        <select name="gender" required>
                            <option value="남성" <%= "남성".equals(gender) ? "selected" : "" %>>남성</option>
                            <option value="여성" <%= "여성".equals(gender) ? "selected" : "" %>>여성</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>생일</td>
                    <td><input type="date" name="birthday" value="<%= birthday %>" required></td>
                </tr>
                <tr>
                    <td>직업</td>
                    <td><input type="text" name="job" value="<%= job %>" required></td>
                </tr>
                <tr>
                    <td>소속</td>
                    <td><input type="text" name="org" value="<%= org %>" required></td>
                </tr>
            </table>
            <div class="button-container">
                <button type="submit" class="button">저장</button>
                <button type="button" class="button" onclick="cancelEdit()">취소</button>
            </div>
        </form>
    </div>
</body>

</html>