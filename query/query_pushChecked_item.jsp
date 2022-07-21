<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="bsmanager.biz.item.ItemChecked" %>

<%@ include file="./include_session_query.jsp" %> 

<%
//------------------------------
//로그인 세션 확인
// 응답용 개체
JSONObject joResponse = new JSONObject();
JSONArray  jaResponse = new JSONArray();
	
if(!bSessionOK)
{
	joResponse.put("result","FAIL");
	joResponse.put("msg","session not found");
	joResponse.put("chkPUSH",jaResponse);
	out.println(joResponse.toString());
	return ;
}

//-----------------------------------------------------------------------------
//요약 편집을 위한 선택 진료기록 목록 관리(세션 개체로 관리한다)
HashMap<String,ItemChecked> mapItemChecked = (HashMap<String,ItemChecked>)p_Session.getAttribute("checked_PUSH");
if(mapItemChecked == null)
{
	mapItemChecked = new HashMap<String,ItemChecked>();
	p_Session.setAttribute("checked_PUSH",mapItemChecked);
}

//JSON 문자열로 전송된 진료기록 선택 정보를 파싱해서 , push 할 사용자 ID와 선택상태 여부를 받는다.
// 갱신되는 정보(추가/제거)만 받는다.
//{ "cmd":"update"   // or clear
//	"chkPUSH":[
//           {"id":"aaa@aaa.com","value":"","checked":false},
//           {"id":"ccc@aaa.com","value":"","checked":true}
//           ]
//}

byte[] bytReq = EtcUtils.readFile(request.getInputStream());
String strChkPUSH = new String(bytReq,"utf-8");
if(strChkPUSH == null)
{
	joResponse.put("result","FAIL");
	joResponse.put("msg","parameter invalid");
	joResponse.put("chkPUSH",jaResponse);
	out.println(joResponse.toString());
	return ;	
}

ItemChecked itemPUSH  = null;
JSONObject joChkItem = null;
JSONObject joRequest = new JSONObject(strChkPUSH);

if(joRequest.get("cmd").equals("update"))
{
	JSONArray jaChkPUSH = (JSONArray) joRequest.get("chkPUSH");
	
	String strID = null;
	String strValue = null;
	boolean bChecked = false;
	
	
	for(int i = 0; i < jaChkPUSH.length() ; i ++)
	{
		joChkItem = 	(JSONObject)jaChkPUSH.get(i);
		strID = (String)joChkItem.get("id");
		strValue = (String)joChkItem.get("value");
		bChecked = (Boolean)joChkItem.get("checked");
		itemPUSH = mapItemChecked.get(strID);
		if(itemPUSH == null)
		{
			if(bChecked)
			{  
				itemPUSH = new ItemChecked();
				itemPUSH.m_strID = strID;
				itemPUSH.m_strValue = strValue;
				itemPUSH.m_bChecked = true;
				mapItemChecked.put(strID,itemPUSH);
			}
		}
		else
		{
			if(!bChecked)
			{  
				mapItemChecked.remove(strID)	;
			}
		}
	}
}
else if(joRequest.get("cmd").equals("clear"))
{
	mapItemChecked.clear();	
}

joResponse.put("result","OK");
joResponse.put("msg","success");

for(String strKey : mapItemChecked.keySet())
{
	itemPUSH = mapItemChecked.get(strKey);
	joChkItem = new JSONObject();
	joChkItem.put("id",strKey);
	joChkItem.put("value",itemPUSH.m_strValue);
	joChkItem.put("checked",true);
	jaResponse.put(joChkItem);
	
}
joResponse.put("chkPUSH",jaResponse);

// JSON 개체 전송
String strJson = joResponse.toString();
out.println(strJson);

%>