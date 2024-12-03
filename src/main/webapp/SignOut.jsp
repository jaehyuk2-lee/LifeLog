<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션 무효화
    HttpSession logout = request.getSession(false); // 기존 세션 가져오기
    if (logout != null) {
    	logout.invalidate(); // 세션 무효화
    }

    // 브라우저 캐싱 방지
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 로그인 페이지로 리디렉션
    response.sendRedirect("SignIn.jsp");
%>
