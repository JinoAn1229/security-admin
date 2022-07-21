<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="wguard.dao.DaoSensor" %>  
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord" %> 
<%@ page import="wguard.dao.DaoSiren" %>  
<%@ page import="wguard.dao.DaoSiren.DaoSirenRecord" %> 
<%@ page import="common.util.EtcUtils" %>      
<%

HttpSession p_Session = request.getSession(false);
if(p_Session == null)
{
	out.println("FAIL");
	return;
}
String strID = (String)p_Session.getAttribute("ID");
if(strID == null)
{
	strID = request.getParameter("id"); // 세션 유지가 힘들수도...
}

if(strID == null)
{
	out.println("FAIL");
    return;
}
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// 센서 (등록취소) 하는 QUERY이다. ,
//
	

	String strSID = EtcUtils.NullS(request.getParameter("ssid"));
	
	if(strSID.isEmpty())
	{
		out.println("FAIL");
		return;
	}
	// 
	DaoSensor daoSensor = new DaoSensor();
	if(daoSensor.deleteSensor(strSID,true))
	{
		DaoSiren daoSiren = new DaoSiren();
		daoSiren.deleteSiren(strSID);
		out.println("OK");
	}
	else
	{
		out.println("FAIL");
	}
	
%>