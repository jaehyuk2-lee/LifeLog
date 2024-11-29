<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Life Log</title>
    <style type="text/css">
      body,
      html {
        margin: 0;
        padding: 0;
        height: 100%;
        box-sizing: border-box;
        background-color: #1e294a;
        color: white;
      }
      button {
        width: 200px;
        padding: 10px;
        border: none;
        border-radius: 5px;
        font-size: 16px;
        cursor: pointer;
        background-color: #007bff;
        color: white;
        margin-bottom: 10px;
      }
    </style>
  </head>
  <body>
    <center>
      <h1>회원가입이 완료되었습니다.</h1>
      <button type="button" onclick="location.href='SignIn.jsp'">
        Sign in
      </button>
    </center>
  </body>
</html>
