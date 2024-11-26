<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<head>
    <meta charset="UTF-8">
    <title>회원 정보</title>
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
            text-align: left;
            color: white;
            margin: 0;
        }

        .container hr {
            height: 5px;
            width: 100%;
            border: none;
            background-color: blue;
            margin-top: 0px;
        }

        .info-table {
            width: 85%;
            border-collapse: collapse;
        }

        .info-table tr {
            border-bottom: 1px solid #444;
        }

        .info-table td {
            padding: 20px 20px;
            text-align: left;
        }

        .info-table td:first-child {
            width: 30%;
            color: #a0a0a5;
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
            <h1>회원 정보</h1>
        </div>
        <hr>
        <table class="info-table">
            <tr>
                <td>이름</td>
                <td><%= "홍길동" %></td>
            </tr>
            <tr>
                <td>아이디</td>
                <td><%= "HogilDong" %></td>
            </tr>
            <tr>
                <td>이메일</td>
                <td><%= "Gil-Dong@gmail.com" %></td>
            </tr>
            <tr>
                <td>성별</td>
                <td><%= "male" %></td>
            </tr>
            <tr>
                <td>국적</td>
                <td><%= "Korea" %></td>
            </tr>
            <tr>
                <td>생일</td>
                <td><%= "2002.01.01" %></td>
            </tr>
            <tr>
                <td>직업</td>
                <td><%= "student" %></td>
            </tr>
            <tr>
                <td>소속</td>
                <td><%= "dongguk" %></td>
            </tr>
        </table>
        <div class="button-container">
            <button class="button" onclick="location.href='<%= request.getContextPath() %>/editProfile.jsp'">수정</button>
            <button class="button" onclick="location.href='<%= request.getContextPath() %>/changePassword.jsp'">비밀번호 변경</button>
        </div>
    </div>
</body>

</html>