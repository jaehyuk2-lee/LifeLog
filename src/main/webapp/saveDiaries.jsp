<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // 'out' 변수는 JSP에서 암시적으로 제공됩니다. 중복 선언하지 마세요.
    response.setContentType("application/json");

    String entry_id = request.getParameter("entry_id");
    String diary_content = request.getParameter("diary_content");
    String date_written = request.getParameter("date_written");

    // JSON 응답을 위한 변수
    String status = "failure";
    String message = "알 수 없는 오류가 발생했습니다.";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // 세션에서 사용자 이메일 가져오기
        if (session == null || session.getAttribute("email") == null) {
            out.println("{\"status\":\"session_expired\",\"message\":\"세션이 만료되었습니다. 다시 로그인해주세요.\"}");
            return;
        }

        String userEmail = (String) session.getAttribute("email");

        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        if (entry_id == null || entry_id.isEmpty()) {
            // 새로운 일기 추가
            String insertSQL = "INSERT INTO diaries (user_id, diary_content, date_written) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, userEmail);
            pstmt.setString(2, diary_content);
            pstmt.setDate(3, java.sql.Date.valueOf(date_written));
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    int newEntryId = rs.getInt(1);
                    status = "success";
                    message = "새로운 일기가 성공적으로 추가되었습니다.";
                    // 새로 추가된 entry_id를 반환하도록 응답에 포함
                    out.println("{\"status\":\"" + status + "\",\"message\":\"" + message + "\",\"entry_id\":" + newEntryId + "}");
                    return;
                }
            }
        } else {
            // 기존 일기 업데이트
            String updateSQL = "UPDATE diaries SET diary_content = ?, date_written = ? WHERE entry_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(updateSQL);
            pstmt.setString(1, diary_content);
            pstmt.setDate(2, java.sql.Date.valueOf(date_written));
            pstmt.setInt(3, Integer.parseInt(entry_id));
            pstmt.setString(4, userEmail);
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                status = "success";
                message = "일기가 성공적으로 업데이트되었습니다.";
            } else {
                message = "일기 업데이트에 실패했습니다. 일기 ID를 확인해주세요.";
            }
        }

        out.println("{\"status\":\"" + status + "\",\"message\":\"" + message + "\"}");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("{\"status\":\"failure\",\"message\":\"서버 오류가 발생했습니다.\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>