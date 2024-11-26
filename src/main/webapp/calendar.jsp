<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

<table class="" style="width: 100%; border-collapse: collapse; text-align: center;">
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
                <td class="dates <%= isToday ? "today" : "" %> <%= dayClass %>" id = "<%= month %><%= currentDay %>">
                    <% if (isDate) { %>
                        <span><%= currentDay %></span>
                    <% } else { %>
                        <span></span>
                    <% } %>
                </td>
            <% } %>
        </tr>
        <% } %>
    </tbody>
</table>
