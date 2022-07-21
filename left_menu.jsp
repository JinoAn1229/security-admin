<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Locale"%>
<%@ page import="common.util.UTF8ResourceBundle"%> 
<%
HttpSession p_Session = request.getSession(false);
String strLang = (String)p_Session.getAttribute("LANG");
if(strLang == null) strLang = "ko";
ResourceBundle p_bundle = UTF8ResourceBundle.getBundle("Res.Resource", new Locale(strLang));
%>

<div id="lnb" class="lnbM">
	<ul>
		<li><a href="./memberList.jsp" class="navi_link"><%=p_bundle.getString("memberList_title")%></a></li>
		<li><a href="./pushHistory.jsp" class="navi_link"><%=p_bundle.getString("pushHistory_title")%></a></li>
		<li><a href="./pushSend.jsp" class="navi_link"><%=p_bundle.getString("pushSend_title")%></a></li>
<!--		<li><a href="./payManagement.jsp" class="navi_link">결제관리</a></li>-->
		<li><a href="./sensorManagement.jsp" class="navi_link"><%=p_bundle.getString("sensorManagement_title")%></a></li>
		<li><a href="./cameraManagement.jsp" class="navi_link"><%=p_bundle.getString("cameraManagement_title")%></a></li>
		<li><a href="./AS.jsp" class="navi_link"><%=p_bundle.getString("AS_title")%></a></li>
		<li><a href="./csCenter.jsp" class="navi_link"><%=p_bundle.getString("csCenter_title")%></a></li>
	</ul>
</div>