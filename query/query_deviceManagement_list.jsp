<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="common.util.ListPagingUtil" %>
<%@ page import="bsmanager.biz.BizDevice" %>
<%@ page import="bsmanager.biz.BizDevice.BizDeviceRecord" %>

<%@ include file="./include_session_query.jsp" %> 

<%

//-----------------------------	
// 회원 리스트와 회위의 소유 장치를 검색하는  쿼리호출이다.
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
	
	String strSearchValue = "";
	String strSearchType = EtcUtils.NullS(request.getParameter("stype"));
	if(strSearchType.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch (stype)");
		out.println(joReturn.toString());
		return ;
	}
	
	strSearchValue = EtcUtils.NullS(request.getParameter("sval"));
	//if(strSearchValue.isEmpty())
	if(!strSearchType.equals("none") && strSearchValue.isEmpty())
	{
		joReturn.put("msg","parameter mismatch (sval)");
		out.println(joReturn.toString());
		return ;	
	}
	
	BizDevice bizD = new BizDevice();
	String strDateAnd = EtcUtils.NullS(request.getParameter("dtand"));

	String strQuery = "";
	Date dateST = null;
	Date dateEnd = null;
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
	}


	int nQueryType = 0;
	if(strSearchType.equals("id"))
	{
		strWhereVal = "USER_ID like  '%" + strSearchValue + "%'";
		nQueryType = 0;
	}
	else if(strSearchType.equals("name"))
	{
		strWhereVal = "USER_NAME like '%" + strSearchValue + "%'";
		nQueryType = 0;
	}
	else if(strSearchType.equals("sid"))
	{
		strWhereVal = "SENSOR_ID like '%" + strSearchValue + "%'";
		nQueryType = 1;
	}
	else if(strSearchType.equals("gid"))
	{
		strWhereVal = "GATE_ID like '%" + strSearchValue + "%'";
		nQueryType = 1;
	}
	else if(strSearchType.equals("cmid"))
	{
		strWhereVal = "CAMERA_MID like '%" + strSearchValue + "%'";
		nQueryType = 2;
	}
	else if(strSearchType.equals("cuid"))
	{
		strWhereVal = "CAMERA_UID like '%" + strSearchValue + "%'";
		nQueryType = 2;
	}
	else if(strSearchType.equals("none"))
	{
		strWhereVal = "";
		nQueryType = 3;
	}
	else
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch ( stype)");
		out.println(joReturn.toString());
		return ;	
	}

	String strBaseQuery = "";
	switch(nQueryType)
	{
		case 0:
		{
			if(strDateAnd.equals("true"))
				strWhereDate = " and ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,bizD.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,bizD.m_strDBType) + ")";
			else
				strWhereDate = "";
			
			strBaseQuery = "(select USER_ID,USER_NAME,REG_DATE from DM_USER where " + strWhereVal + strWhereDate + ")";
		
			strQuery = "select a.USER_ID as ID, a.USER_NAME as NAME," 
				+ "b.SENSOR_ID as SID , b.SENSOR_NAME as SNAME, b.GATE_ID as GID , b.REG_DATE as SDATE," 
				+ "null as CUID, null as CMID , null as CNAME , null as CDATE,"
				+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
				+ " from " + strBaseQuery + " a , DM_SENSOR b , DM_SITE d where a.USER_ID = b.USER_ID and b.SITE_ID = d.SITE_ID" 
				+ " union "
				+ "select a.USER_ID as ID, a.USER_NAME as NAME," 
				+ "null as SID , null as SNAME,null as GID , null as SDATE," 
				+ "c.CAMERA_UID as CUID, c.CAMERA_MID as CMID , c.CAMERA_NAME as CNAME , c.CODE_DATE as CDATE,"
				+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
				+ " from " + strBaseQuery + " a , DM_CAMERA c , DM_SITE d where a.USER_ID = c.USER_ID and c.SITE_ID = d.SITE_ID" 
				+ " order by ID";
			


			break;
		}
		case 1:
		{
			if(strDateAnd.equals("true"))
				strWhereDate = " and ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,bizD.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,bizD.m_strDBType) + ")";
			else
				strWhereDate = "";
			
			strBaseQuery = "(select USER_ID,SENSOR_ID,GATE_ID,REG_DATE from DM_SENSOR where " + strWhereVal + strWhereDate + ")";
		
			strQuery = "select a.USER_ID as ID, a.USER_NAME as NAME," 
					+ "b.SENSOR_ID as SID ,b.SENSOR_NAME as SNAME, b.GATE_ID as GID , b.REG_DATE as SDATE," 
					+ "null as CUID, null as CMID , null as CNAME , null as CDATE,"
					+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
					+ " from " + strBaseQuery + " a , DM_SENSOR b , DM_SITE d where a.USER_ID = b.USER_ID and b.SITE_ID = d.SITE_ID"; 

			break;
		}
		case 2:
		{
			if(strDateAnd.equals("true"))
				strWhereDate = " and ( CODE_DATE >= " + EtcUtils.getSqlDate(dateST,bizD.m_strDBType) + " and CODE_DATE < " + EtcUtils.getSqlDate(dateEnd,bizD.m_strDBType) + ")";
			else
				strWhereDate = "";
			
			strBaseQuery = "(select USER_ID,CAMERA_UID,CAMERA_MID,CODE_DATE from DM_CAMERA where " + strWhereVal + strWhereDate + ")";
		
			strQuery = "select a.USER_ID as ID, a.USER_NAME as NAME," 
					+ "null as SID , null as SNAME, null as GID , null as SDATE ," 
					+ "c.CAMERA_UID as CUID, c.CAMERA_MID as CMID , c.CAMERA_NAME as CNAME , c.CODE_DATE as CDATE,"
					+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
					+ " from " + strBaseQuery + " a , DM_CAMERA c , DM_SITE d where a.USER_ID = c.USER_ID and c.SITE_ID = d.SITE_ID"; 


			break;
		}
		case 3:
		{
			if(strDateAnd.equals("true"))
				strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,bizD.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,bizD.m_strDBType) + ")";
			else
				strWhereDate = "";
			
			strBaseQuery = "(select USER_ID,USER_NAME,REG_DATE from DM_USER where " + strWhereVal + strWhereDate + ")";
		
			strQuery = "select a.USER_ID as ID, a.USER_NAME as NAME," 
				+ "b.SENSOR_ID as SID , b.SENSOR_NAME as SNAME, b.GATE_ID as GID , b.REG_DATE as SDATE," 
				+ "null as CUID, null as CMID , null as CNAME , null as CDATE,"
				+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
				+ " from " + strBaseQuery + " a , DM_SENSOR b , DM_SITE d where a.USER_ID = b.USER_ID and b.SITE_ID = d.SITE_ID" 
				+ " union "
				+ "select a.USER_ID as ID, a.USER_NAME as NAME," 
				+ "null as SID , null as SNAME,null as GID , null as SDATE," 
				+ "c.CAMERA_UID as CUID, c.CAMERA_MID as CMID , c.CAMERA_NAME as CNAME , c.CODE_DATE as CDATE,"
				+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
				+ " from " + strBaseQuery + " a , DM_CAMERA c , DM_SITE d where a.USER_ID = c.USER_ID and c.SITE_ID = d.SITE_ID" 
				+ " order by ID";

			break;
		}

	}

	try
	{
		if(!bizD.connection())
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
	

		nTotalRecordCnt = (int)bizD.getQueryCount(strQuery, false);
		ListPagingUtil listPager = new ListPagingUtil("Pager",nPageLinkPerDoc,nListPerPage,nDispPage,nTotalRecordCnt,false);
	
		nFirstRecordNo = listPager.getPageFirstRecordNo();
		
		ArrayList<BizDeviceRecord> aryBD = bizD.selectDeviceForList(strQuery, nFirstRecordNo , (nFirstRecordNo+nListPerPage-1),false);
		
		JSONObject joD = null;
		JSONArray jaD = new JSONArray();

		for(BizDeviceRecord rD : aryBD)
		{
			joD = new JSONObject();
			joD.put("no",nFirstRecordNo++);
			joD.put("name",rD.m_strName);
			joD.put("id",rD.m_strID);
			joD.put("sdate",EtcUtils.getStrDate(rD.m_dateSensor,"yyyy-MM-dd",""));
			joD.put("sid",rD.m_strSensorID);
			joD.put("gid",rD.m_strGateID);
			joD.put("stid",rD.m_strSiteID);
			joD.put("cname",rD.m_strCameraName);
			joD.put("sname",rD.m_strSensorName);
			joD.put("stname",rD.m_strSiteName);
			joD.put("cdate",EtcUtils.getStrDate(rD.m_dateCameraCode,"yyyy-MM-dd",""));
			joD.put("cmid",rD.m_strCameraMID);
			joD.put("cuid",rD.m_strCameraUID);
			
			jaD.put(joD);
		}
		
		joReturn.put("result","OK");
		joReturn.put("msg","success");
		//joReturn.put("tot_count",Integer.toString(nTotalRecordCnt));
		joReturn.put("tot_count",Integer.toString(jaD.length()));
		joReturn.put("members",jaD);
		//-----------------------------------------------------------------------------
		// 페이지 navigation html 만들어서 JSON 개체에 추가함
		joReturn.put("PageNavi",listPager.getPagingStyle04());
		
		System.out.println(joReturn.toString());
		
		out.println(joReturn.toString());
		return ;
	}
	finally
	{
		if(bizD.isConnected())
			bizD.disConnection();
	}
%>