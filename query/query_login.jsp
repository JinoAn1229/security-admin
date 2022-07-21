<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="bsmanager.dao.DaoManager" %>  
<%@ page import="common.util.EtcUtils" %>      
<%!
public DaoManager.DaoManagerRecord checkLogin(String id, String pw) 
{
	DaoManager daoMan = new DaoManager();
	return daoMan.checkLogin(id,pw);
 }
%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
	
	String strID = EtcUtils.NullS(request.getParameter("id"));
	String strPW = EtcUtils.NullS(request.getParameter("pw"));
	DaoManager.DaoManagerRecord rUser = null;
	boolean bLogin = false;
	try
	{
		rUser = checkLogin(strID,strPW);
		if (rUser != null )
		{
			HttpSession loginsession = request.getSession(true); // true : 없으면 세션 새로 만듦
			loginsession.setAttribute("ID", strID);
			loginsession.setAttribute("NAME",rUser.m_strName);
			loginsession.setAttribute("LANG",rUser.m_strLang);
			loginsession.setAttribute("ACCOUNT",rUser.m_strAccount);
			bLogin = true;
		}
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
	if(bLogin)
		out.println("OK");
	else
		out.println("FAIL");
%>