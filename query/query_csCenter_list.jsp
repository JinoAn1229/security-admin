<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Date"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="common.util.ListPagingUtil" %>
<%@ page import="bsmanager.biz.BizCSNote" %>
<%@ page import="bsmanager.biz.BizCSNote.BizCSNoteRecord" %>

<%@ include file="./include_session_query.jsp" %> 

<%

//-----------------------------	
// 고객관리 , 게시물 목록 쿼리호출이다.
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
	
	String strDateAnd = EtcUtils.NullS(request.getParameter("dtand"));

	BizCSNote bizCN = new BizCSNote();
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
		strWhereDate = " ( CS_DATE >= " + EtcUtils.getSqlDate(dateST,bizCN.m_strDBType) + " and CS_DATE < " + EtcUtils.getSqlDate(dateEnd,bizCN.m_strDBType) + ")";
	}


	strSearchValue = EtcUtils.NullS(request.getParameter("sval"));
	if(!strSearchValue.isEmpty())
	{
		
		if(strSearchType.equals("id"))
		{
			strWhereVal = "b.USER_ID like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("name"))
		{
			strWhereVal = "USER_NAME  like  '%" + strSearchValue + "%'";
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

	strWhere += " and a.USER_ID = b.USER_ID";

	try
	{
	
		if(!bizCN.connection())
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","database connection fail");
			out.println(joReturn.toString());
			return ;	
		}
		int nDispPage = 0;
		int nPageLinkPerDoc = 10;
		int nListPerPage = 10;
		int nTotalRecordCnt = 0;
		int nFirstRecordNo = 0;
		
		nDispPage = EtcUtils.parserInt(request.getParameter("pg"),1);
		nListPerPage = EtcUtils.parserInt(request.getParameter("lpp"),10);
	
		nTotalRecordCnt = (int)bizCN.getQueryCount(strWhere, false);
		ListPagingUtil listPager = new ListPagingUtil("Pager",nPageLinkPerDoc,nListPerPage,nDispPage,nTotalRecordCnt,false);
	
		nFirstRecordNo = listPager.getPageFirstRecordNo();
		
		ArrayList<BizCSNoteRecord> aryCSNote = bizCN.selectCSNoteForList(strWhere,nFirstRecordNo,nFirstRecordNo+nListPerPage-1,false);
		
		bizCN.disConnection();

		
		JSONObject joCN = null;
		JSONArray jaCN = new JSONArray();

		for(BizCSNoteRecord rCN : aryCSNote)
		{
			joCN = new JSONObject();
			joCN.put("no",nFirstRecordNo++);
			joCN.put("seqid",rCN.m_strSeqID);
			joCN.put("name",rCN.m_strName);
			joCN.put("userid",rCN.m_strUserID);
			joCN.put("birth",rCN.m_strBirth);
			joCN.put("sex",rCN.m_strSex);
			
			joCN.put("title",rCN.m_strTitle);
			joCN.put("cstext",rCN.m_strCsText);
			joCN.put("csdate",EtcUtils.NullS(EtcUtils.getStrDate(rCN.m_dateCsReg,"yyyy-MM-dd")));

			joCN.put("respid",rCN.m_strRespID);
			joCN.put("astext",rCN.m_strAsText);
			joCN.put("asdate",EtcUtils.NullS(EtcUtils.getStrDate(rCN.m_dateAsReg,"yyyy-MM-dd")));
			jaCN.put(joCN);
		}
		
		joReturn.put("result","OK");
		joReturn.put("msg","success");
		joReturn.put("tot_count",Integer.toString(nTotalRecordCnt));
		joReturn.put("members",jaCN);
		//-----------------------------------------------------------------------------
		// 페이지 navigation html 만들어서 JSON 개체에 추가함
		joReturn.put("PageNavi",listPager.getPagingStyle04());
		
		System.out.println(joReturn.toString());
		
		out.println(joReturn.toString());
		return ;
	}
	finally
	{
		if(bizCN.isConnected())
			bizCN.disConnection();
	}
%>