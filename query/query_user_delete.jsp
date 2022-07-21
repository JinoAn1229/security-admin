<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList" %> 
<%@ page import="wguard.dao.DaoUser" %>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord" %>
<%@ page import="common.util.EtcUtils" %>  
 
  <%@ include file="./include_session_query.jsp" %>    
<%
//-----------------------------	
// 사용자의 설정상태를 초기화 한다(센서,카메라,사이트,패밀리등...)
// uid : 사용자 ID
String strUID = EtcUtils.NullS(request.getParameter("uid"));
if(strUID == null)
{
	response.sendRedirect("sorry_manager.jsp");
	return;
}
DaoUser  daoUser = new DaoUser();

if(daoUser.deleteUser(strUID,true))
{
	out.println("OK");
}
else
{
	out.println("error");
}

return ;

%>