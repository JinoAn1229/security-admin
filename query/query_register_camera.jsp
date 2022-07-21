<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="wguard.dao.DaoCamera" %>  
<%@ page import="wguard.dao.DaoCamera.DaoCameraRecord" %>  
<%@ page import="wguard.dao.DaoSite" %>  
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord" %>  
<%@ page import="common.util.EtcUtils" %>      
<%
// 카메라를 등록하는 과정이다. 출하전에 등록되어 있어야 사용가능하기 때문에 등록을 해야 한다.
// 전용 APP로 등록을 요청한다.
// 세션 검사는  하지 않는다.
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	

	String strCamUID = EtcUtils.NullS(request.getParameter("uid"));
	if(strCamUID.isEmpty())
	{
		out.println("UID");
		return;
	}
	
	String strCamMID = EtcUtils.NullS(request.getParameter("mid"));
	if(strCamMID.isEmpty())
	{
		out.println("MID");
		return;
	}
	// 등록가능한 카메라인지 확인 

	DaoCamera daoCamera = new DaoCamera();
	DaoCamera.DaoCameraRecord rCamera = null;
	rCamera = daoCamera.existCamera(strCamUID,strCamMID);
	if(rCamera != null)
	{   // 이미 등록된 카메라이다.
		out.println("EXIST");
		return ;
	}
	
	rCamera = daoCamera.new DaoCameraRecord();
	rCamera.m_strMID = strCamMID;
	rCamera.m_strUID = strCamUID;
	
	daoCamera.insertCamera(rCamera);
	
	out.println("OK");
%>