<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    // 세션에서 email 가져오기
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("email") == null) {
        out.print("error|세션이 만료되었습니다. 다시 로그인해주세요.");
        return;
    }

    String userEmail = (String) session.getAttribute("email");

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        // MySQL JDBC 드라이버 로드
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        String sql = "SELECT entry_id, diary_content, date_written FROM diaries WHERE user_id = ? ORDER BY date_written DESC";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, userEmail);
        rs = stmt.executeQuery();

        StringBuilder responseBuilder = new StringBuilder();

        while (rs.next()) {
            int entryId = rs.getInt("entry_id");
            String content = rs.getString("diary_content");
            String date = rs.getDate("date_written").toString();

            // 각 일기를 "entryId|date|content\n" 형식으로 추가
            // content에 포함된 개행 문자는 \n으로 대체
            responseBuilder.append(entryId).append("|")
                           .append(date).append("|")
                           .append(content.replace("\n", "\\n")).append("\n");
        }

        if (responseBuilder.length() > 0) {
            out.print("success\n" + responseBuilder.toString());
        } else {
            out.print("success|no_diaries");
        }
    } catch (Exception e) {
        out.print("error|DB 연동 오류: " + e.getMessage());
    } finally {
        // 리소스 해제
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
