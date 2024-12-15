<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession logout = request.getSession(false);
    if (logout != null) {
    	logout.invalidate();
    }

    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    response.sendRedirect("SignIn.jsp");
%>
