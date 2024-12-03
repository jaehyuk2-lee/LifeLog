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
    String entryIdStr = request.getParameter("entry_id");

    // 입력 검증
    if (entryIdStr == null || entryIdStr.trim().isEmpty()) {
        out.print("error|유효한 entry_id가 필요합니다.");
        return;
    }

    int entryId;
    try {
        entryId = Integer.parseInt(entryIdStr);
    } catch (NumberFormatException e) {
        out.print("error|잘못된 entry_id 형식입니다.");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        // MySQL JDBC 드라이버 로드
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        // 일기가 현재 사용자에게 속해있는지 확인
        String verifySql = "SELECT user_id FROM diaries WHERE entry_id = ?";
        stmt = conn.prepareStatement(verifySql);
        stmt.setInt(1, entryId);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            String userId = rs.getString("user_id");
            if (userId.equals(userEmail)) {
                rs.close();
                stmt.close();

                String deleteSql = "DELETE FROM diaries WHERE entry_id = ?";
                stmt = conn.prepareStatement(deleteSql);
                stmt.setInt(1, entryId);
                int rowsDeleted = stmt.executeUpdate();

                if (rowsDeleted > 0) {
                    out.print("success");
                } else {
                    out.print("error|일기 삭제에 실패했습니다.");
                }
            } else {
                out.print("error|권한이 없습니다.");
            }
        } else {
            out.print("error|일기를 찾을 수 없습니다.");
        }
    } catch (Exception e) {
        out.print("error|DB 연동 오류: " + e.getMessage());
    } finally {
        // 리소스 해제
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>