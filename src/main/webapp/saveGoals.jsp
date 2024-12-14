<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*, java.io.*" %>
<%
    response.setContentType("application/json");
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    Connection conn = null;
    PreparedStatement pstmt = null;
    PrintWriter outWriter = response.getWriter();

    try {
        // 세션 확인
        if (session == null || session.getAttribute("email") == null) {
            outWriter.write("{\"status\":\"error\", \"message\":\"세션이 만료되었습니다. 다시 로그인해주세요.\"}");
            return;
        }

        String userEmail = (String) session.getAttribute("email");
        System.out.println("사용자 이메일: " + userEmail);

        // 다중 파라미터 가져오기
        String[] logIds = request.getParameterValues("log_id");
        String[] logNames = request.getParameterValues("log_name");
        String[] inputValues = request.getParameterValues("input_value");
        String[] units = request.getParameterValues("unit");
        String[] isGoals = request.getParameterValues("is_goal");
        String[] goalValues = request.getParameterValues("goal_value");

        if (logNames == null || inputValues == null || units == null) {
            outWriter.write("{\"status\":\"error\", \"message\":\"필수 파라미터가 누락되었습니다.\"}");
            return;
        }

        int total = logNames.length;

        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        // 트랜잭션 시작
        conn.setAutoCommit(false);

        // 업데이트 및 삽입을 위한 SQL 준비
        String updateSQL = "UPDATE logs SET log_name = ?, input_value = ?, unit = ?, is_goal = ?, goal_value = ? WHERE log_id = ? AND user_id = ?";
        String insertSQL = "INSERT INTO logs (user_id, log_name, input_value, unit, is_goal, goal_value, date_entered, day_of_week) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement updatePstmt = conn.prepareStatement(updateSQL);
        PreparedStatement insertPstmt = conn.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS);

        for (int i = 0; i < total; i++) {
            String logIdStr = (logIds != null && i < logIds.length) ? logIds[i] : null;
            String logName = (logNames != null && i < logNames.length) ? logNames[i].trim() : "";
            String inputValueStr = (inputValues != null && i < inputValues.length) ? inputValues[i].trim() : "";
            String unit = (units != null && i < units.length) ? units[i].trim() : "";
            String isGoalStr = (isGoals != null && i < isGoals.length) ? isGoals[i] : null;
            String goalValueStr = (goalValues != null && i < goalValues.length) ? goalValues[i].trim() : null;

            // 필수 항목 검증
            if (logName.isEmpty() || inputValueStr.isEmpty() || unit.isEmpty()) {
                throw new Exception("로그, 입력값, 단위는 필수 항목입니다. (" + (i + 1) + "번째 항목)");
            }

            // 입력값 숫자 검증
            double inputValue;
            try {
                inputValue = Double.parseDouble(inputValueStr);
            } catch (NumberFormatException e) {
                throw new Exception("입력값은 숫자여야 합니다. (" + (i + 1) + "번째 항목)");
            }

            // 목표 값 처리
            Double goalValue = null;
            boolean isGoal = false;
            if (isGoalStr != null) {
                isGoal = isGoalStr.equals("1"); // 수정된 부분: "1"일 때 true
                // 추가적으로 "true"도 true로 처리할 수 있습니다.
                if (!isGoal && (isGoalStr.equalsIgnoreCase("true"))) {
                    isGoal = true;
                }
            }
            if (isGoal) {
                if (goalValueStr == null || goalValueStr.isEmpty()) {
                    throw new Exception("목표 설정 시 목표 값을 입력해야 합니다. (" + (i + 1) + "번째 항목)");
                }
                try {
                    goalValue = Double.parseDouble(goalValueStr);
                } catch (NumberFormatException e) {
                    throw new Exception("목표 값은 숫자여야 합니다. (" + (i + 1) + "번째 항목)");
                }
            }

            if (logIdStr != null && !logIdStr.isEmpty()) {
                // 업데이트 처리
                int logId;
                try {
                    logId = Integer.parseInt(logIdStr);
                } catch (NumberFormatException e) {
                    throw new Exception("로그 ID는 숫자여야 합니다. (" + (i + 1) + "번째 항목)");
                }

                updatePstmt.setString(1, logName);
                updatePstmt.setDouble(2, inputValue);
                updatePstmt.setString(3, unit);
                updatePstmt.setInt(4, isGoal ? 1 : 0); // is_goal을 1 또는 0으로 설정
                if (goalValue != null) {
                    updatePstmt.setDouble(5, goalValue);
                } else {
                    updatePstmt.setNull(5, java.sql.Types.DECIMAL);
                }
                updatePstmt.setInt(6, logId);
                updatePstmt.setString(7, userEmail);

                int rowsUpdated = updatePstmt.executeUpdate();
                if (rowsUpdated == 0) {
                    throw new Exception("해당 로그 ID를 가진 데이터를 찾을 수 없습니다. (" + (i + 1) + "번째 항목)");
                }
            } else {
                // 삽입 처리
                java.sql.Date currentDate = new java.sql.Date(new java.util.Date().getTime());
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("EEEE", java.util.Locale.KOREAN);
                String dayOfWeek = sdf.format(currentDate);

                insertPstmt.setString(1, userEmail);
                insertPstmt.setString(2, logName);
                insertPstmt.setDouble(3, inputValue);
                insertPstmt.setString(4, unit);
                insertPstmt.setInt(5, isGoal ? 1 : 0); // is_goal을 1 또는 0으로 설정
                if (goalValue != null) {
                    insertPstmt.setDouble(6, goalValue);
                } else {
                    insertPstmt.setNull(6, java.sql.Types.DECIMAL);
                }
                insertPstmt.setDate(7, currentDate);
                insertPstmt.setString(8, dayOfWeek);

                insertPstmt.executeUpdate();
            }
        }

        // 커밋
        conn.commit();
        outWriter.write("{\"status\":\"success\", \"message\":\"모든 목표가 성공적으로 저장되었습니다.\"}");
    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        // 에러 메시지 JSON 이스케이프 처리
        String errorMessage = e.getMessage().replace("\"", "\\\"");
        outWriter.write("{\"status\":\"error\", \"message\":\"오류: " + errorMessage + "\"}");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        outWriter.close();
    }
%>
