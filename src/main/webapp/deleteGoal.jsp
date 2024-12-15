<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String status = "";
    String message = "";

    String logIdParam = request.getParameter("log_id");
    if (logIdParam == null || logIdParam.trim().isEmpty()) {
        status = "error";
        message = "로그 ID가 제공되지 않았습니다.";
    } else {
        int logId;
        try {
            logId = Integer.parseInt(logIdParam);
            Connection conn = null;
            PreparedStatement pstmt = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String url = "jdbc:mysql://localhost:3306/life_log_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
                conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

                String deleteSQL = "DELETE FROM logs WHERE log_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, logId);
                int affectedRows = pstmt.executeUpdate();

                if (affectedRows > 0) {
                    status = "success";
                    message = "데이터가 성공적으로 삭제되었습니다.";
                } else {
                    status = "error";
                    message = "해당 로그 ID에 대한 데이터가 존재하지 않습니다.";
                }
            } catch (Exception e) {
                e.printStackTrace();
                status = "error";
                message = "데이터 삭제 중 오류가 발생했습니다.";
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        } catch (NumberFormatException e) {
            status = "error";
            message = "유효하지 않은 로그 ID입니다.";
        }
    }

    String jsonResponse = "{\"status\":\"" + status + "\", \"message\":\"" + message + "\"}";
    out.print(jsonResponse);
%>
