<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoCSNote"%>
<%@ page import="wguard.dao.DaoCSNote.DaoCSNoteRecord"%>

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
	JSONObject joCN = new JSONObject();
	
	String strCmd = joReq.optString("cmd","");
	String strSeqID = joReq.optString("seqid","");
	String strUserID = joReq.optString("userid","");
	if(strUserID.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch ( userid)");	
		return ;
	}
	String strTitle = joReq.optString("title","");
	String strCsText = joReq.optString("cstext","");
	String strRespID = joReq.optString("respid","");
	String strAsText = joReq.optString("astext","");

	String strCsDate = joReq.optString("csdate","");
	if(strCsDate.isEmpty())
		strCsDate=EtcUtils.getStrDate(new Date(),"yyyy-MM-dd");
	
	String strAsDate = joReq.optString("asdate","");
	if(strAsDate.isEmpty())
		strAsDate=EtcUtils.getStrDate(new Date(),"yyyy-MM-dd");
	
	joReturn.put("cmd",strCmd);
	
	DaoCSNote daoCN = new DaoCSNote();
	DaoCSNoteRecord rCN = daoCN.new DaoCSNoteRecord();
	
	rCN.m_dateCsReg = EtcUtils.getJavaDate(strCsDate);
	if(strCmd.equals("new"))
	{

		rCN.m_strUserID = strUserID;
		rCN.m_strTitle = strTitle;
		rCN.m_strCsText = strCsText;
		
		daoCN.insertCSNote(rCN);
		joReturn.put("csnote",joCN);

	}
	else if(strCmd.equals("mod"))
	{
		if(strRespID.isEmpty() || strSeqID.isEmpty())
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","parameter mismatch ( respid or seqid)");	
			return ;
		}
		rCN.m_strSeqID = strSeqID;
		rCN.m_strAsText = strAsText;
		rCN.m_strRespID = strRespID;

		
		daoCN.updateCSNoteResponse(rCN);
		
		joCN.put("seqid",rCN.m_strSeqID);
		joCN.put("userid",rCN.m_strUserID);	
		
		joCN.put("respid",rCN.m_strRespID);		
		joCN.put("astext",rCN.m_strAsText);
		joCN.put("asdate",EtcUtils.getStrDate(rCN.m_dateAsReg,"yyyy-MM-dd"));
		
			
		joCN.put("title",rCN.m_strTitle);
		joCN.put("cstext",rCN.m_strCsText);
		joCN.put("csdate",EtcUtils.NullS(EtcUtils.getStrDate(rCN.m_dateCsReg,"yyyy-MM-dd")));
		
		joReturn.put("csnote",joCN);
	}
	else if(strCmd.equals("del"))
	{
		daoCN.deleteCSNote(strSeqID);
		joCN.put("seqid",strSeqID);
		joReturn.put("csnote",joCN);
	}
	else
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch ( cmd)");
		
		joReturn.put("asnote",joCN);
		out.println(joReturn.toString());
		return ;
	}

	joReturn.put("result","OK");
	joReturn.put("msg","success");
	
	System.out.println(	joReturn.toString());
	
	out.println(joReturn.toString());
	return ;
%>