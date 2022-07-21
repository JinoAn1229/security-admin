<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="wguard.dao.DaoUser" %>    
<%@ page import="wguard.biz.SendHttpMessage" %> 

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	

	String id = request.getParameter("id");
	DaoUser daoUser = new DaoUser();
	DaoUser.DaoUserRecord rUser = daoUser.getUser(id);
	
	if(rUser != null) out.println("OK");
	else
	{
		String strUrl = SendHttpMessage.GetUserServer(id);
		if(strUrl.isEmpty()) 	out.println("FAIL");
		else  out.println("OK");
	}	
%>