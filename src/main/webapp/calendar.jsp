<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
    String userId = (String) session.getAttribute("email");
    if (userId == null) {
        out.println("사용자 ID가 세션에 저장되어 있지 않습니다.");
        return;
    }
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    Map<String, List<String>> tasks = new HashMap<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/life_log_db?serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "lifelog_admin", "q1w2e3r4");
        String sql = "SELECT task_date, task_description FROM tasks WHERE task_date LIKE ? AND user_id = ?";
        stmt = conn.prepareStatement(sql);
        String formattedMonth = String.format("%02d", month + 1);
        stmt.setString(1, year + "-" + formattedMonth + "%");
        stmt.setString(2, userId);
        rs = stmt.executeQuery();
        while (rs.next()) {
            String taskDate = rs.getString("task_date");
            String taskDescription = rs.getString("task_description");
            tasks.computeIfAbsent(taskDate, k -> new ArrayList<>()).add(taskDescription);
        }
    } catch (Exception e) {
        out.println("DB 연동 오류입니다: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Calendar</title>
    <style>
        table, th, td {
            border: 1px solid gray;
        }
        table {
            width: 100%;
            table-layout: fixed;
            border-collapse: collapse;
            text-align: center;
        }
        td {
            height: 87px;
            vertical-align: top;
            position: relative;
            overflow: hidden;
        }
        .task {
            font-size: 12px;
            margin-top: 5px;
            background-color: #00FFFF;
            color: black;
            border-radius: 5px;
            padding: 2px;
            word-wrap: break-word;
            white-space: normal;
            box-sizing: border-box;
        }
        .task-container{
        	overflow-y: auto;
        	max-height: 70px;
        }
        .dates {
            padding-top: 15px;
            background-color: #1e294a;
            color: white;
            position: relative;
            box-sizing: border-box;
            overflow-y: scroll;
            max-height: 100%;
            scrollbar-width: none;
        }
        ::-webkit-scrollbar {
            display: none;
        }
        .dates span {
            font-size: 12px;
            position: absolute;
            top: 2px;
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
        .days {
            background-color: #007bff;
            padding: 10px;
        }
    </style>
</head>
<body>
    <table>
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
                    <a href="add_task.jsp?year=<%= year %>&month=<%= month + 1 %>&day=<%= currentDay %>" style="display: block; color: inherit; text-decoration: none; width: 100%; height: 100%;">
                        <span><%= currentDay %></span>
                        <div class="task-container">
                            <%
                                String taskKey = year + "-" + String.format("%02d", month + 1) + "-" + String.format("%02d", currentDay);
                                if (tasks.containsKey(taskKey)) {
                                    for (String task : tasks.get(taskKey)) {
                            %>
                            <div class="task"><%= task %></div>
                            <%         }
                                }
                            %>
                        </div>
                    </a>
                    <% } else { %>
                    <span></span>
                    <% } %>
                </td>
                <% } %>
            </tr>
            <% } %>
        </tbody>
    </table>
</body>
</html>
