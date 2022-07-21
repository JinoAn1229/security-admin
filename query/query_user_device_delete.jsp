<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList" %> 
<%@ page import="wguard.dao.DaoSite" %> 
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord" %>   
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
DaoSite  daoSite = new DaoSite();
ArrayList<DaoSiteRecord> arySTR = daoSite.selectOwnerSite(strUID);
	
DaoSiteRecord rSTR = null;
for(int i = 0; i < arySTR.size(); i ++ )
{
	rSTR = arySTR.get(i);
	if(i == 0)
		daoSite.clearSite(rSTR.m_strSTID,true);
	else
		daoSite.deleteSite(rSTR.m_strSTID,true);
}

out.println("OK");
return ;

%>