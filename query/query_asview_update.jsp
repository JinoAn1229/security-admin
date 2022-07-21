<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="bsmanager.dao.DaoASNote"%>
<%@ page import="bsmanager.dao.DaoASNote.DaoASNoteRecord"%>

<%@ include file="./include_session_query.jsp" %> 

<%
	JSONObject joReturn = new JSONObject();
	if(!bSessionOK)
	{
		joReturn.put("cmd","");
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}
	
	int i;
	
	byte[] bytRequest = EtcUtils.readFile(request.getInputStream());
	String strRequest = new String(bytRequest,"utf-8");
	JSONObject joReq = new JSONObject(strRequest);
	JSONObject joAsNote = new JSONObject();
	
	String strSeqID = joReq.optString("seqid","");
	String strUserID = joReq.optString("userid","");
	String strWriterID = joReq.optString("wrid","");
	String strAsText = joReq.optString("text","");
	String strCmd = joReq.optString("cmd","");
	String strRegDate = joReq.optString("rdate","");
	if(strRegDate.isEmpty())
		strRegDate=EtcUtils.getStrDate(new Date(),"yyyy-MM-dd");
	DaoASNote daoAN = new DaoASNote();
	DaoASNoteRecord rAN = daoAN.new DaoASNoteRecord();
	
	joReturn.put("cmd",strCmd);
	
	rAN.m_dateReg = EtcUtils.getJavaDate(strRegDate);
	if(strCmd.equals("new"))
	{
		rAN.m_strText = strAsText;
		rAN.m_strWriterID = strWriterID;
		rAN.m_strUserID = strUserID;
		
		daoAN.insertASNote(rAN);
		
		joAsNote.put("seqid",rAN.m_strSeqID);
		joAsNote.put("text",rAN.m_strText);
		joAsNote.put("rdate",EtcUtils.getStrDate(rAN.m_dateReg,"yyyy-MM-dd"));
		joAsNote.put("wrid",rAN.m_strWriterID);				
		joAsNote.put("userid",rAN.m_strUserID);	
		
		joReturn.put("asnote",joAsNote);

	}
	else if(strCmd.equals("mod"))
	{
		rAN.m_strSeqID = strSeqID;
		rAN.m_strText = strAsText;
		rAN.m_strWriterID = strWriterID;
		rAN.m_strUserID = strUserID;
		
		daoAN.updateASNote(rAN);
		
		joAsNote.put("seqid",rAN.m_strSeqID);
		joAsNote.put("text",rAN.m_strText);
		joAsNote.put("rdate",EtcUtils.getStrDate(rAN.m_dateReg,"yyyy-MM-dd"));
		joAsNote.put("wrid",rAN.m_strWriterID);				
		joAsNote.put("userid",rAN.m_strUserID);				

		joReturn.put("asnote",joAsNote);
	}
	else if(strCmd.equals("del"))
	{
		daoAN.deleteASNote(strSeqID);
		
		joAsNote.put("seqid",strSeqID);
		joAsNote.put("text","");
		joAsNote.put("rdate",EtcUtils.getStrDate(new Date(),"yyyy-MM-dd"));
		joAsNote.put("wrid",rAN.m_strWriterID);				
		joAsNote.put("userid",rAN.m_strUserID);					

		joReturn.put("asnote",joAsNote);
	}
	else
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch ( cmd)");
		
		joReturn.put("asnote",joAsNote);
		out.println(joReturn.toString());
		return ;
	}

	joReturn.put("result","OK");
	joReturn.put("msg","success");
	
	out.println(joReturn.toString());
	return ;
%>