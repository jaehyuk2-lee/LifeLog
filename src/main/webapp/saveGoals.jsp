<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*, java.io.*, java.util.*" %>
<%
    response.setContentType("application/json");
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    Connection conn = null;
    PreparedStatement pstmt = null;
    PreparedStatement checkPstmt = null;
    PrintWriter outWriter = response.getWriter();

    try {
        if (session == null || session.getAttribute("email") == null) {
            outWriter.write("{\"status\":\"error\", \"message\":\"세션이 만료되었습니다. 다시 로그인해주세요.\"}");
            return;
        }

        String userEmail = (String) session.getAttribute("email");
        System.out.println("사용자 이메일: " + userEmail);

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

        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        conn.setAutoCommit(false);

        java.util.Date today = new java.util.Date();
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
        String currentDate = sdf.format(today);

        Set<String> newLogNames = new HashSet<>();
        for (int i = 0; i < total; i++) {
            String logIdStr = (logIds != null && i < logIds.length) ? logIds[i] : null;
            if (logIdStr == null || logIdStr.trim().isEmpty()) {
                String logName = (logNames != null && i < logNames.length) ? logNames[i].trim() : "";
                if (!logName.isEmpty()) {
                    newLogNames.add(logName);
                }
            }
        }

        if (!newLogNames.isEmpty()) {
            StringBuilder inClause = new StringBuilder();
            inClause.append("(");
            for (int i = 0; i < newLogNames.size(); i++) {
                inClause.append("?");
                if (i < newLogNames.size() - 1) {
                    inClause.append(",");
                }
            }
            inClause.append(")");

            String checkSQL = "SELECT log_name FROM logs WHERE user_id = ? AND DATE(date_entered) = ? AND log_name IN " + inClause.toString();
            checkPstmt = conn.prepareStatement(checkSQL);
            checkPstmt.setString(1, userEmail);
            checkPstmt.setString(2, currentDate);
            int index = 3;
            for (String logName : newLogNames) {
                checkPstmt.setString(index++, logName);
            }

            ResultSet checkRs = checkPstmt.executeQuery();
            List<String> existingLogNames = new ArrayList<>();
            while (checkRs.next()) {
                existingLogNames.add(checkRs.getString("log_name"));
            }
            checkRs.close();

            if (!existingLogNames.isEmpty()) {
                conn.rollback();
                outWriter.write("{\"status\":\"error\", \"message\":\"이미 로그가 있습니다. 로그를 수정해주세요!\"}");
                return;
            }
        }

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

            if (logName.isEmpty() || inputValueStr.isEmpty() || unit.isEmpty()) {
                throw new Exception("로그, 입력값, 단위는 필수 항목입니다. (" + (i + 1) + "번째 항목)");
            }

            double inputValue;
            try {
                inputValue = Double.parseDouble(inputValueStr);
            } catch (NumberFormatException e) {
                throw new Exception("입력값은 숫자여야 합니다. (" + (i + 1) + "번째 항목)");
            }

            Double goalValue = null;
            boolean isGoal = false;
            if (isGoalStr != null) {
                isGoal = isGoalStr.equals("1");
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

            if (logIdStr != null && !logIdStr.trim().isEmpty()) {
                int logId;
                try {
                    logId = Integer.parseInt(logIdStr);
                } catch (NumberFormatException e) {
                    throw new Exception("로그 ID는 숫자여야 합니다. (" + (i + 1) + "번째 항목)");
                }

                updatePstmt.setString(1, logName);
                updatePstmt.setDouble(2, inputValue);
                updatePstmt.setString(3, unit);
                updatePstmt.setInt(4, isGoal ? 1 : 0);
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
                String dayOfWeek = new java.text.SimpleDateFormat("EEEE", java.util.Locale.KOREAN).format(today);

                insertPstmt.setString(1, userEmail);
                insertPstmt.setString(2, logName);
                insertPstmt.setDouble(3, inputValue);
                insertPstmt.setString(4, unit);
                insertPstmt.setInt(5, isGoal ? 1 : 0);
                if (goalValue != null) {
                    insertPstmt.setDouble(6, goalValue);
                } else {
                    insertPstmt.setNull(6, java.sql.Types.DECIMAL);
                }
                insertPstmt.setString(7, currentDate);
                insertPstmt.setString(8, dayOfWeek);

                insertPstmt.executeUpdate();
            }
        }

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
        String errorMessage = e.getMessage().replace("\"", "\\\"");
        outWriter.write("{\"status\":\"error\", \"message\":\"오류: " + errorMessage + "\"}");
    } finally {
        if (checkPstmt != null) try { checkPstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        outWriter.close();
    }
%>