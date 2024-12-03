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
    String diaryContent = request.getParameter("diary_content");
    String dateWritten = request.getParameter("date_written");

    // 입력 검증
    if (diaryContent == null || diaryContent.trim().isEmpty() || dateWritten == null || dateWritten.trim().isEmpty()) {
        out.print("error|모든 필드를 입력해주세요.");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        // MySQL JDBC 드라이버 로드
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        String sql = "INSERT INTO diaries (user_id, diary_content, date_written) VALUES (?, ?, ?)";
        stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        stmt.setString(1, userEmail);
        stmt.setString(2, diaryContent);
        stmt.setDate(3, java.sql.Date.valueOf(dateWritten));

        int rowsInserted = stmt.executeUpdate();

        if (rowsInserted > 0) {
            rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                int entryId = rs.getInt(1);
                out.print("success|" + entryId);
            } else {
                out.print("error|일기 저장 중 오류가 발생했습니다.");
            }
        } else {
            out.print("error|일기 저장에 실패했습니다.");
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
