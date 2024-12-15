<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    response.setContentType("application/json");

    String entry_id = request.getParameter("entry_id");
    String status = "failure";
    String message = "알 수 없는 오류가 발생했습니다.";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        if (session == null || session.getAttribute("email") == null) {
            out.println("{\"status\":\"session_expired\",\"message\":\"세션이 만료되었습니다. 다시 로그인해주세요.\"}");
            return;
        }

        String userEmail = (String) session.getAttribute("email");

        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        if (entry_id != null && !entry_id.isEmpty()) {
            String deleteSQL = "DELETE FROM diaries WHERE entry_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(deleteSQL);
            pstmt.setInt(1, Integer.parseInt(entry_id));
            pstmt.setString(2, userEmail);
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                status = "success";
                message = "일기가 성공적으로 삭제되었습니다.";
            } else {
                message = "삭제할 일기를 찾을 수 없습니다.";
            }
        } else {
            message = "유효하지 않은 일기 ID입니다.";
        }

        out.println("{\"status\":\"" + status + "\",\"message\":\"" + message + "\"}");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("{\"status\":\"failure\",\"message\":\"서버 오류가 발생했습니다.\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>