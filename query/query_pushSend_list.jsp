<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Date"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="common.util.ListPagingUtil" %>
<%@ page import="wguard.dao.DaoUser" %>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord" %>
<%@ page import="wguard.biz.UserExpireCheck" %>
<%@ page import="bsmanager.biz.item.ItemChecked" %>

<%@ include file="./include_session_query.jsp" %> 

<%

//-----------------------------	
// 회원 리스트를 검색하는  쿼리호출이다.
// json 형테의 개체로 호출된다.

	JSONObject joReturn = new JSONObject();
	if(!bSessionOK)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}
	
	int i;
	int nDispPage = 0;
	int nPageLinkPerDoc = 10;
	int nListPerPage = 10;
	int nTotalRecordCnt = 0;
	int nFirstRecordNo = 0;
	ListPagingUtil listPager = null;
	ArrayList<DaoUserRecord> aryUsers = null;	
	
	DaoUser daoU = new DaoUser();
	
	byte[] bytRequest = EtcUtils.readFile(request.getInputStream());
	String strRequest = new String(bytRequest,"utf-8");
	JSONObject joReq = new JSONObject(strRequest);
	
	String strQueryType = EtcUtils.NullS((String)joReq.get("qtype"));
	if(strQueryType.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch ( stype)");
		out.println(joReturn.toString());
		return ;
	}
	
//--------------------------------------------
//  세션 CHECKED PUSH 설정
	HashMap<String,ItemChecked> mapItemChecked = (HashMap<String,ItemChecked>)p_Session.getAttribute("checked_PUSH");
	if(mapItemChecked == null)
	{
		mapItemChecked = new HashMap<String,ItemChecked>();
		p_Session.setAttribute("checked_PUSH",mapItemChecked);
	}

	ItemChecked itemPUSH  = null;
	JSONObject joChkItem = null;
	
	if(joReq.get("cmd").equals("update"))
	{
		JSONArray jaChkPUSH = (JSONArray) joReq.get("chkPUSH");
		
		String strID = null;
		String strValue = null;
		boolean bChecked = false;
		
		
		for(i = 0; i < jaChkPUSH.length() ; i ++)
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
	else if(joReq.get("cmd").equals("clear"))
	{
		mapItemChecked.clear();	
	}

//------------------------------------------------	
	nDispPage = EtcUtils.parserInt((String)joReq.get("pg"),1);
	nListPerPage = EtcUtils.parserInt((String)joReq.get("lpp"),10);
	
	
	if(strQueryType.equals("nopay"))
	{
		UserExpireCheck bizUEC = new UserExpireCheck();	
		try
		{
			if(!bizUEC.connection())
			{
				joReturn.put("result","FAIL");
				joReturn.put("msg","database connection fail");
				out.println(joReturn.toString());
				return ;	
			}


			ArrayList<DaoUserRecord> aryAllUsers = bizUEC.selectNoPayUser();
			nTotalRecordCnt = aryAllUsers.size();
			listPager = new ListPagingUtil("Pager",nPageLinkPerDoc,nListPerPage,nDispPage,nTotalRecordCnt,false);
			
			nFirstRecordNo = listPager.getPageFirstRecordNo();
			// nFirstRecordNo 는 1 base이다.
			aryUsers = new ArrayList<DaoUserRecord>();
			for(i = 0; i < nListPerPage; i ++)
			{
				if((nFirstRecordNo + i-1) < aryAllUsers.size())
					aryUsers.add(aryAllUsers.get(nFirstRecordNo + i-1));
			}
			aryAllUsers.clear();
		}
		finally
		{
			bizUEC.disConnection();
		}	
	}
	else if(strQueryType.equals("param"))
	{
		String strQuery = "";
		String strSearchType = "";
		String strSearchValue = "";
		String strWhere = "";		
		String strWhereDate = "";
		String strWhereVal = "";
		
		String strDateAnd = joReq.optString("dtand","false");
		if(strDateAnd.equals("true"))
		{  // 기간  and 조건 추가
			String strDateS = EtcUtils.NullS(joReq.optString("dates"));
			String strDateE = EtcUtils.NullS(joReq.optString("datee"));
			if(strDateS.isEmpty() || strDateE.isEmpty())
			{
				joReturn.put("result","FAIL");
				joReturn.put("msg","parameter mismatch ( date )");
				out.println(joReturn.toString());
				return ;
			}
			Date dateST = EtcUtils.getJavaDate(strDateS);
			Date dateEnd = EtcUtils.getJavaDate(strDateE);
			dateEnd = EtcUtils.addDateDay(dateEnd,1,true);
			strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoU.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoU.m_strDBType) + ")";
		}
		
		strSearchType = EtcUtils.NullS(joReq.optString("stype",""));
		if(strSearchType.equals("id"))
		{
			strSearchValue = EtcUtils.NullS(joReq.optString("sval",""));
			strWhereVal = "USER_ID like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("name"))
		{
			strSearchValue = EtcUtils.NullS(joReq.optString("sval",""));	
			strWhereVal = "USER_NAME  like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("none"))
		{
			strSearchValue = "";
			strWhereVal = "";
		}
		else
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","unknown parameter value(stype)");
			out.println(joReturn.toString());	
			return ;	
		}		
	
		if(!strWhereVal.isEmpty())
		{
			strWhere =  strWhereVal;
			if(!strWhereDate.isEmpty())
			{
				strWhere += " and " + strWhereDate;
			}
		}
		else
		{
			if(!strWhereDate.isEmpty())
			{
				strWhere = strWhereDate;
			}
			else
			{
				joReturn.put("result","FAIL");
				joReturn.put("msg","parameter is empty");
				out.println(joReturn.toString());
				return ;
			}
		}
		
		try
		{
			if(!daoU.connection())
			{
				joReturn.put("result","FAIL");
				joReturn.put("msg","database connection fail");
				out.println(joReturn.toString());
				return ;	
			}
			
			strQuery = "select * from DM_USER where " + strWhere;
			
			nTotalRecordCnt = (int)daoU.getQueryCount(daoU.getTableName(),strWhere, false);
			listPager = new ListPagingUtil("Pager",nPageLinkPerDoc,nListPerPage,nDispPage,nTotalRecordCnt,false);
		
			nFirstRecordNo = listPager.getPageFirstRecordNo();
			aryUsers = daoU.selectUserForList(strWhere,"USER_ID asc",nFirstRecordNo,nFirstRecordNo+nListPerPage-1,false);
		}
		finally
		{
			if(daoU.isConnected())
				daoU.disConnection();
		}
	}


	JSONObject joU = null;
	JSONArray jaU = new JSONArray();
	for(DaoUserRecord rU : aryUsers)
	{
		joU = new JSONObject();
		joU.put("no",nFirstRecordNo++);
		joU.put("name",rU.m_strName);
		joU.put("id",rU.m_strID);
		joU.put("birth",rU.m_strBirth);
		joU.put("sex",rU.m_strSex);
		joU.put("reg_date",EtcUtils.getStrDate(rU.m_dateReg,"yyyy-MM-dd"));
		joU.put("addr",rU.m_strAddr1 + " " + rU.m_strAddr2);
		joU.put("dev_info",rU.m_strDeviceModel);
		jaU.put(joU);
	}
	
	joReturn.put("result","OK");
	joReturn.put("msg","success");
	joReturn.put("tot_count",Integer.toString(nTotalRecordCnt));
	joReturn.put("members",jaU);
	//-----------------------------------------------------------------------------
	// 페이지 navigation html 만들어서 JSON 개체에 추가함
	joReturn.put("PageNavi",listPager.getPagingStyle04());
	
	// PUSH 현재 선택 상태를 리턴한다.
	JSONArray jaChkItem = new JSONArray();
	for(String strKey : mapItemChecked.keySet())
	{
		itemPUSH = mapItemChecked.get(strKey);
		joChkItem = new JSONObject();
		joChkItem.put("id",strKey);
		joChkItem.put("value",itemPUSH.m_strValue);
		joChkItem.put("checked",itemPUSH.m_bChecked); // 당연  true
		jaChkItem.put(joChkItem);
	}
	joReturn.put("chkPUSH",jaChkItem);
	
	System.out.println(joReturn.toString());
	
	out.println(joReturn.toString());
	return ;

%>