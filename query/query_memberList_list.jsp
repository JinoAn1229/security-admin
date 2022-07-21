<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Date"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="common.util.ListPagingUtil" %>
<%@ page import="wguard.dao.DaoUser" %>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord" %>
<%@ page import="wguard.biz.UserExpireCheck" %>

<%@ include file="./include_session_query.jsp" %> 

<%

//-----------------------------	
// 회원 리스트를 검색하는  쿼리호출이다.
// [memberList.jsp , AS.jsp 2곳에서 같이 이용한다. query_AS_list.jsp를 따로 만들어야 하지만 통일한 기능을 하기 때문에 같이 사용함 ]
// pg : 리스트를 보여풀 페이지 번호
// lpp: 한페이지에 보여줄 리스트 갯수
// stype : 검색조건 형식, 
//     name  :   sval 파라메터로 회원 이름 이 전달된다.
//     id       :   sval 파라메터로 회원 ID가 전달된다.
//     addr   :   sval 파라메터로 주소가 전달된다.
// dtend : true 경우 
//             dates로  등록일 시작, datee로  등록일 끝이  파라메터로 전달된다. 
//             dates >=  회원등록일  <= datee 조건으로 이용됨

	JSONObject joReturn = new JSONObject();
	if(!bSessionOK)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}
	
	int i;
	
	
	String strSearchType = EtcUtils.NullS(request.getParameter("stype"));
	if(strSearchType.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch ( stype)");
		out.println(joReturn.toString());
		return ;
	}

	UserExpireCheck bizUEC = new UserExpireCheck();
	DaoUser daoU = new DaoUser();
	
	String strDateAnd = EtcUtils.NullS(request.getParameter("dtand"));

	String strQuery = "";
	Date dateST = null;
	Date dateEnd = null;
	String strSearchValue = "";
	String strWhereDate = "";
	String strWhereVal = "";
	String strWhere = "";		
	if(strDateAnd.equals("true"))
	{  // 기간  and 조건 추가
		String strDateS = EtcUtils.NullS(request.getParameter("dates"));
		String strDateE = EtcUtils.NullS(request.getParameter("datee"));
		if(strDateS.isEmpty() || strDateE.isEmpty())
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","parameter mismatch ( date )");
			out.println(joReturn.toString());
			return ;
		}
		dateST = EtcUtils.getJavaDate(strDateS);
		dateEnd = EtcUtils.getJavaDate(strDateE);
		dateEnd = EtcUtils.addDateDay(dateEnd,1,true);
		strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoU.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoU.m_strDBType) + ")";
	}


	strSearchValue = EtcUtils.NullS(request.getParameter("sval"));
	if(!strSearchValue.isEmpty())
	{
		
		if(strSearchType.equals("id"))
		{
			strWhereVal = "USER_ID like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("name"))
		{
			strWhereVal = "USER_NAME  like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("addr"))
		{
			strWhereVal = "USER_ADDR1  like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("none"))
		{
			strWhereVal = "";
		}
	}
	
	if(!strWhereVal.isEmpty())
	{
		strWhere = strWhereVal;
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
		int nDispPage = 0;
		int nPageLinkPerDoc = 10;
		int nListPerPage = 10;
		int nTotalRecordCnt = 0;
		int nFirstRecordNo = 0;
		
		nDispPage = EtcUtils.parserInt(request.getParameter("pg"),1);
		nListPerPage = EtcUtils.parserInt(request.getParameter("lpp"),10);
	
		nTotalRecordCnt = (int)daoU.getQueryCount(daoU.getTableName(),strWhere, false);
		ListPagingUtil listPager = new ListPagingUtil("Pager",nPageLinkPerDoc,nListPerPage,nDispPage,nTotalRecordCnt,false);
	
		nFirstRecordNo = listPager.getPageFirstRecordNo();
		ArrayList<DaoUserRecord> aryUsers = daoU.selectUserForList(strWhere,"REG_DATE desc",nFirstRecordNo,nFirstRecordNo+nListPerPage-1,false);
		
		daoU.disConnection();
		
		if(!bizUEC.connection())
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","database connection fail");
			out.println(joReturn.toString());
			return ;
		}
		
		JSONObject joU = null;
		JSONArray jaU = new JSONArray();
		Date dateTemp = null;
		for(DaoUserRecord rU : aryUsers)
		{
			joU = new JSONObject();
			joU.put("no",nFirstRecordNo++);
			joU.put("name",rU.m_strName);
			joU.put("id",rU.m_strID);
			joU.put("birth",rU.m_strBirth);
			joU.put("sex",rU.m_strSex);
			joU.put("reg_date",EtcUtils.getStrDate(rU.m_dateReg,"yyyy-MM-dd"));
			dateTemp = bizUEC.getFirstSetupDate(rU.m_strID);
			if(dateTemp.getTime() == 0)
				joU.put("setup_date","0000-00-00");
			else
				joU.put("setup_date",EtcUtils.getStrDate(dateTemp,"yyyy-MM-dd"));
				
			joU.put("addr",rU.m_strAddr1 + " " + rU.m_strAddr2);
			dateTemp = bizUEC.getUserExpireDate(rU);
			joU.put("exp_date",EtcUtils.getStrDate(dateTemp,"yyyy-MM-dd"));
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
		
		System.out.println(joReturn.toString());
		
		out.println(joReturn.toString());
		return ;
	}
	finally
	{
		if(daoU.isConnected())
			daoU.disConnection();
		bizUEC.disConnection();
	}
%>