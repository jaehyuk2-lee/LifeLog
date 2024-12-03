<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Map, java.util.HashMap" %>
<%@ page import="java.util.Calendar" %>
<%
    int year = Integer.parseInt(request.getParameter("year"));
    int month = Integer.parseInt(request.getParameter("month"));
    Calendar calendar = Calendar.getInstance();
    calendar.set(year, month, 1);
    int firstDayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
    int daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
    int startBlankCount = firstDayOfWeek - 1;
    int totalCells = startBlankCount + daysInMonth;
    int endBlankCount = (7 - (totalCells % 7)) % 7;
    Calendar today = Calendar.getInstance();
    int todayYear = today.get(Calendar.YEAR);
    int todayMonth = today.get(Calendar.MONTH);
    int todayDay = today.get(Calendar.DAY_OF_MONTH);

    // 세션에서 사용자 ID 가져오기
    String userId = (String) session.getAttribute("email");
    if (userId == null) {
        out.println("사용자 ID가 세션에 저장되어 있지 않습니다.");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    Map<String, String> tasks = new HashMap<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");

        // 사용자 ID를 포함한 SQL 쿼리
        String sql = "SELECT task_date, task_description FROM tasks WHERE task_date LIKE ? AND user_id = ?";
        stmt = conn.prepareStatement(sql);
        String formattedMonth = String.format("%02d", month + 1);
        stmt.setString(1, year + "-" + formattedMonth + "%");
        stmt.setString(2, userId); // 사용자 ID 추가
        rs = stmt.executeQuery();
        while (rs.next()) {
            tasks.put(rs.getString("task_date"), rs.getString("task_description"));
        }
    } catch (Exception e) {
        out.println("DB 연동 오류입니다: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
<style>
    .days {
        background-color: #007bff;
        padding: 10px;
    }
    table, th, td {
        border: 1px solid gray;
    }
    td {
        height: 40px;
    }
    .dates {
        padding: 15px;
        background-color: #1e294a;
        color: white;
        position: relative;
    }
    .dates span {
        font-size: 12px;
        position: absolute;
        top: 5px;
        right: 5px;
    }
    .sunday {
        background-color: #1F305E;
        color: red;
    }
    .saturday {
        background-color: #1F305E;
        color: #007bff;
    }
    .today {
        background-color: #7BAFD4;
        color: white;
        font-weight: bold;
    }
</style>
<table style="width: 100%; border-collapse: collapse; text-align: center;">
    <thead>
        <tr>
            <th class="days">일</th>
            <th class="days">월</th>
            <th class="days">화</th>
            <th class="days">수</th>
            <th class="days">목</th>
            <th class="days">금</th>
            <th class="days">토</th>
        </tr>
    </thead>
    <tbody>
        <%
            for (int i = 0; i < (startBlankCount + daysInMonth + endBlankCount) / 7; i++) {
        %>
        <tr>
            <% for (int j = 0; j < 7; j++) {
                int cellIndex = i * 7 + j;
                int currentDay = cellIndex - startBlankCount + 1;
                boolean isToday = currentDay == todayDay && month == todayMonth && year == todayYear;
                boolean isDate = cellIndex >= startBlankCount && cellIndex < startBlankCount + daysInMonth;
                String dayClass = "";
                if (j == 0) {
                    dayClass = "sunday";
                } else if (j == 6) {
                    dayClass = "saturday";
                }
            %>
            <td class="dates <%= isToday ? "today" : "" %> <%= dayClass %>" id="<%= month %><%= currentDay %>">
                <% if (isDate) { %>
                <a href="add_task.jsp?year=<%= year %>&month=<%= month + 1 %>&day=<%= currentDay %>" style="color: inherit; text-decoration: none;">
                    <span><%= currentDay %></span>
                </a>
                <% String taskKey = year + "-" + String.format("%02d", month + 1) + "-" + String.format("%02d", currentDay); %>
                <% if (tasks.containsKey(taskKey)) { %>
                <div style="font-size: 12px; margin-top: 5px; background-color:#00FFFF; color: black; border-radius:40px">
                    <%= tasks.get(taskKey) %>
                </div>
                <% } %>
                <% } else { %>
                <span></span>
                <% } %>
            </td>
            <% } %>
        </tr>
        <% } %>
    </tbody>
</table>
