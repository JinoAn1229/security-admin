<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="wguard.dao.DaoCamera" %>  
<%@ page import="wguard.dao.DaoCamera.DaoCameraRecord" %>  
<%@ page import="wguard.dao.DaoSite" %>  
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord" %>  
<%@ page import="common.util.EtcUtils" %>      
<%

boolean bError = false;

HttpSession p_Session = request.getSession(false);
if(p_Session == null)
{
	bError = true;
}

String strID = (String)p_Session.getAttribute("ID");
if(strID == null)
{
	strID = request.getParameter("id"); // ���� ������ �������...
}

if(strID == null)
{
	bError = true;
}

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// ī�޶��� ���������� ����(������) �ϴ� QUERY�̴�. ,
//strCamUID : CAMERA_UID �Ķ���� ( cid :  ī�޶� ������ �ڵ�  )
	String strCamUID = EtcUtils.NullS(request.getParameter("cid"));
	if(strCamUID.isEmpty())
	{
		bError = true;
	}

	JSONObject joReturn = new JSONObject();
	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}

	DaoCamera daoCamera = new DaoCamera();
	

	// ī�޶� ������ �ʱ�ȭ  
	if(daoCamera.releaseCameraFromUID(strCamUID))
	{
		joReturn.put("result","OK");
		joReturn.put("msg","success");
	}
	else
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","delete fail");
	}


	out.println(joReturn.toString());
%>