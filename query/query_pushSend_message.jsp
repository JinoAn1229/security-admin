<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="wguard.biz.SendPushMessage" %>
<%@ page import="bsmanager.biz.item.ItemChecked" %>

<%@ include file="./include_session_query.jsp" %> 
<%
// 관리자가  push message 를 보내는 곳이다.
JSONObject joReturn = new JSONObject();
if(!bSessionOK)
{
	joReturn.put("result","FAIL");
	joReturn.put("msg","session not found");
	out.println(joReturn.toString());
	return ;
}

byte[] abytReq = EtcUtils.readFile(request.getInputStream());
String strReq = new String(abytReq,"utf-8");
JSONObject joReq = new JSONObject(strReq);

HashMap<String,ItemChecked> mapItemChecked = (HashMap<String,ItemChecked>)p_Session.getAttribute("checked_PUSH");
if(mapItemChecked == null)
{
	joReturn.put("result","FAIL");
	joReturn.put("msg","no user");
	out.println(joReturn.toString());
	return ;
}

ArrayList<String> aryUserIDs = new ArrayList<String>();
ItemChecked itemPUSH = null;
for(String strKey : mapItemChecked.keySet())
{
	itemPUSH = mapItemChecked.get(strKey);
	aryUserIDs.add(itemPUSH.m_strID);
}
SendPushMessage.SendManagementMessage((String)joReq.getString("message"), aryUserIDs,p_strSessionID);

joReturn.put("result","OK");
joReturn.put("msg","success");
out.println(joReturn.toString());

// 보냈으니까 모두 클리어
mapItemChecked.clear();
return ;
%>