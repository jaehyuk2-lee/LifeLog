<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <title>회원 정보 수정</title>
    <style>
        body {
            background-color: #000;
            color: white;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .container {
            width: 1000px;
            height: auto;
            padding-bottom: 20px;
            margin-top: 30px;
            margin-left: 100px;
        }

        .header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }

        .header img {
            width: 40px;
            height: 40px;
            margin-right: 10px;
        }

        .header h1 {
            color: white;
            margin: 0;
        }

        .container hr {
            height: 5px;
            border: none;
            background-color: blue;
            margin-top: 10px;
        }

        .info-table {
            width: 85%;
            border-collapse: collapse;
        }

        .info-table tr {
            border-bottom: 1px solid #444;
        }

        .info-table td {
            padding: 15px 10px;
            text-align: left;
            vertical-align: middle;
        }

        .info-table td:first-child {
            width: 30%;
            color: #a0a0a5;
        }

        .info-table input[type="text"],
        .info-table input[type="email"],
        .info-table input[type="date"],
        .info-table select {
            width: 50%;
            padding: 8px;
            background: #222;
            border: 1px solid #555;
            border-radius: 4px;
            color: white;
            box-sizing: border-box;
        }

        .info-table input[type="date"]::-webkit-calendar-picker-indicator {
            filter: invert(1);
            opacity: 0.6;
            cursor: pointer;
        }

        .button-container {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 40px;
        }

        .button {
            background-color: #1e73e8;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .button:hover {
            background-color: #155bb5;
        }
    </style>
</head>

<body>
    <div class="container">
        <div class="header">
            <img src="<%= request.getContextPath() %>/images/profile.png" alt="Profile Icon">
            <h1>회원 정보 수정</h1>
        </div>
        <hr>
        <form action="<%= request.getContextPath() %>/submit_profile" method="post">
            <table class="info-table">
                <tr>
                    <td>이름</td>
                    <td><input type="text" name="name" value="<%= request.getAttribute("name") != null ? request.getAttribute("name") : "홍길동" %>" required></td>
                </tr>
                <tr>
                    <td>아이디</td>
                    <td><%= request.getAttribute("id") != null ? request.getAttribute("id") : "Hong_Gil" %></td>
                </tr>
                <tr>
                    <td>이메일</td>
                    <td><input type="email" name="email" value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "HONG@dgu.ac.kr" %>" required></td>
                </tr>
                <tr>
                    <td>성별</td>
                    <td>
                        <select name="gender" required>
                            <option value="남성" <%= "남성".equals(request.getAttribute("gender")) ? "selected" : "" %>>남성</option>
                            <option value="여성" <%= "여성".equals(request.getAttribute("gender")) ? "selected" : "" %>>여성</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>국적</td>
                    <td><input type="text" name="nationality" value="<%= request.getAttribute("nationality") != null ? request.getAttribute("nationality") : "대한민국" %>" required></td>
                </tr>
                <tr>
                    <td>생일</td>
                    <td><input type="date" name="birthdate" value="<%= request.getAttribute("birthdate") != null ? request.getAttribute("birthdate") : "2002-01-01" %>" required></td>
                </tr>
                <tr>
                    <td>직업</td>
                    <td><input type="text" name="occupation" value="<%= request.getAttribute("occupation") != null ? request.getAttribute("occupation") : "학생" %>" required></td>
                </tr>
                <tr>
                    <td>소속</td>
                    <td><input type="text" name="organization" value="<%= request.getAttribute("organization") != null ? request.getAttribute("organization") : "동국대학교" %>" required></td>
                </tr>
            </table>
            <div class="button-container">
                <button type="submit" class="button">저장</button>
                <button type="reset" class="button">취소</button>
            </div>
        </form>
    </div>
</body>

</html>