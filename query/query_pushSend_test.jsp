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

SendPushMessage.SendIphonePush("테스트", "ST00000","000","cJ0nRQYfQdY:APA91bEdDOIs0qFbnvwHKZHvXL-6wFhNj9hG-hlgZaGsSAhbDAB2ja-hZnjyXfXIa_aLmRmz8NjP4L8fUmuLbeS9peq0ywW5bkQwDy_hdhnsFPy3Dz-f9fxj8k0wughjZm033bJdTRMo");

joReturn.put("result","OK");
joReturn.put("msg","success");
out.println(joReturn.toString());

return ;
%>