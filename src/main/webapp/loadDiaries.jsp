<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    response.setContentType("application/json");

    List<Map<String, Object>> diaries = new ArrayList<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        if (session == null || session.getAttribute("email") == null) {
            out.println("{\"status\":\"session_expired\",\"message\":\"세션이 만료되었습니다. 다시 로그인해주세요.\"}");
            return;
        }

        String userEmail = (String) session.getAttribute("email");

        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        String selectSQL = "SELECT entry_id, diary_content, date_written FROM diaries WHERE user_id = ? ORDER BY date_written ASC";
        pstmt = conn.prepareStatement(selectSQL);
        pstmt.setString(1, userEmail);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> diary = new HashMap<>();
            diary.put("entry_id", rs.getInt("entry_id"));
            diary.put("diary_content", rs.getString("diary_content").replace("\"", "\\\""));
            diary.put("date_written", rs.getDate("date_written").toString());
            diaries.add(diary);
        }

        StringBuilder json = new StringBuilder();
        json.append("{\"status\":\"success\",\"diaries\":[");

        for (int i = 0; i < diaries.size(); i++) {
            Map<String, Object> diary = diaries.get(i);
            json.append("{");
            json.append("\"entry_id\":").append(diary.get("entry_id")).append(",");
            json.append("\"diary_content\":\"").append(diary.get("diary_content")).append("\",");
            json.append("\"date_written\":\"").append(diary.get("date_written")).append("\"");
            json.append("}");
            if (i < diaries.size() - 1) {
                json.append(",");
            }
        }

        json.append("]}");
        out.println(json.toString());
    } catch (Exception e) {
        e.printStackTrace();
        out.println("{\"status\":\"failure\",\"message\":\"서버 오류가 발생했습니다.\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>