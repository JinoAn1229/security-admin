<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>

<%@ page import="common.util.EtcUtils" %>
<%@ page import="bsmanager.biz.BizAS" %>
<%@ page import="bsmanager.biz.BizAS.BizASRecord" %>
<%@ page import="bsmanager.dao.DaoASNote.DaoASNoteRecord" %>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord" %>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord" %>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord" %>
<%@ page import="wguard.dao.DaoGate.DaoGateRecord" %>
<%@ page import="wguard.dao.DaoCamera.DaoCameraRecord" %>

<%@ include file="./include_session_query.jsp" %> 

<%
//------------------------------
//로그인 세션 확인 , ASView.jsp 페이지표시를 위해 query용으로 만들었으나, 
// ASView.jsp페이지에서 직접 구현시켰다. ( 현재 사용되지는 않는다)
// 응답용 개체
JSONObject joResponse = new JSONObject();
	
if(!bSessionOK)
{
	joResponse.put("result","FAIL");
	joResponse.put("msg","session not found");
	out.println(joResponse.toString());
	return ;
}

String strUserID = EtcUtils.NullS(request.getParameter("id"));
if(strUserID.isEmpty())
{
	joResponse.put("result","FAIL");
	joResponse.put("msg","where do you put the id parameter?");
	out.println(joResponse.toString());
	return ;
}

BizAS bizAS = new BizAS();
BizASRecord rAS = bizAS.getBizASRecord(strUserID, true);
if(rAS == null)
{
	joResponse.put("result","FAIL");
	joResponse.put("msg","id not found");
	out.println(joResponse.toString());
	return ;	
}


int i;
DaoSiteRecord rSITE = null;

joResponse.put("result","OK");
joResponse.put("msg","success");

//----------------
// user
JSONObject joUser = new JSONObject();
joUser.put("id",rAS.m_rUser.m_strID);
joUser.put("name",rAS.m_rUser.m_strName);
joUser.put("birth",rAS.m_rUser.m_strBirth);
joUser.put("sex",rAS.m_rUser.m_strSex);
joUser.put("rdate",EtcUtils.getStrDate(rAS.m_rUser.m_dateReg,"yyyy-MM-dd"));
joUser.put("exdate",EtcUtils.getStrDate(rAS.m_rUser.m_dateExpire,"yyyy-MM-dd"));
joUser.put("addr1",rAS.m_rUser.m_strAddr1);
joUser.put("addr2",rAS.m_rUser.m_strAddr2);

joResponse.put("user",joUser);

//------------------
// sensor
JSONObject joSensor = null;
JSONArray jaSensor = new JSONArray();
for(DaoSensorRecord rS : rAS.m_arySensor)
{
	rSITE = rAS.getSite(rS.m_strSTID);
	if(rSITE == null)
		continue;
	joSensor = new JSONObject();
	joSensor.put("sid",rS.m_strSID);
	joSensor.put("stname",rSITE.m_strSTName);
	joSensor.put("sname",rS.m_strSName);
	
	jaSensor.put(joSensor);
}
joResponse.put("sensor",jaSensor);
//------------------
// Gate
JSONObject joGate = null;
JSONArray jaGate = new JSONArray();
for(DaoGateRecord rG : rAS.m_aryGate)
{
	rSITE = rAS.getSite(rG.m_strSTID);
	if(rSITE == null)
		continue;
	joGate = new JSONObject();
	joGate.put("did",rG.m_strDID);
	joGate.put("stname",rSITE.m_strSTName);
	
	jaGate.put(joGate);
}
joResponse.put("gate",jaGate);
//------------------
// Camera
JSONObject joCamera = null;
JSONArray jaCamera = new JSONArray();
for(DaoCameraRecord rC : rAS.m_aryCamera)
{
	rSITE = rAS.getSite(rC.m_strSTID);
	if(rSITE == null)
		continue;
	joCamera = new JSONObject();
	joCamera.put("mid",rC.m_strMID);
	joCamera.put("uid",rC.m_strUID);
	joCamera.put("stname",rSITE.m_strSTName);
	
	jaCamera.put(joCamera);
}
joResponse.put("camera",jaCamera);

//------------------
//ASNote
JSONObject joASNote = null;
JSONArray jaASNote = new JSONArray();
for(DaoASNoteRecord rA : rAS.m_aryASNote)
{
	joASNote = new JSONObject();
	joASNote.put("seqid",rA.m_strSeqID);
	joASNote.put("text",rA.m_strText);
	joASNote.put("rdate",EtcUtils.getStrDate(rA.m_dateReg,"yyyy-MM-dd"));
	joASNote.put("wrid",rA.m_strWriterID);
	jaASNote.put(joASNote);
}
joResponse.put("asnote",jaASNote);

out.println(joResponse.toString());
%>