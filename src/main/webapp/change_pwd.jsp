<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">

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
            color: white;
            margin: 0;
        }

        .container hr {
            height: 5px;
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

        .info-table input[type="password"] {
            width: 50%;
            padding: 8px;
            background: #222;
            border: 1px solid #555;
            border-radius: 4px;
            color: white;
            box-sizing: border-box;
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
        <form action="<%= request.getContextPath() %>/change_password" method="post">
            <table class="info-table">
                <tr>
                    <td>현재 비밀번호</td>
                    <td><input type="password" name="current_password" placeholder="현재 비밀번호" required></td>
                </tr>
                <tr>
                    <td>새 비밀번호</td>
                    <td><input type="password" name="new_password" placeholder="새 비밀번호" required></td>
                </tr>
                <tr>
                    <td>새 비밀번호 확인</td>
                    <td><input type="password" name="confirm_password" placeholder="새 비밀번호 확인" required></td>
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