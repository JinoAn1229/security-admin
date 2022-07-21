<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="bsmanager.biz.BizPay" %>
<%@ page import="bsmanager.biz.BizPay.BizPayRecord" %>

<%@ include file="./include_session_proc.jsp" %> 

<%

//-----------------------------	
// 저장응 위해 회원 리스트를 검색하는  쿼리호출이다.
// stype : 검색조건 형식, 
//     name  :   sval 파라메터로 회원 이름 이 전달된다.
//     id       :   sval 파라메터로 회원 ID가 전달된다.
//     addr   :   sval 파라메터로 주소가 전달된다.
// dtend : true 경우 
//             dates로  등록일 시작, datee로  등록일 끝이  파라메터로 전달된다. 
//             dates >=  회원등록일  <= datee 조건으로 이용됨

    response.setContentType("application/octet-stream");
    response.setHeader("Content-Disposition","attachment;filename=payManagement.txt");

	if(!bSessionOK)
	{
		out.println("FAIL\tsession not found");
		return ;
	}
	
	int i;
	
	
	String strSearchType = EtcUtils.NullS(request.getParameter("stype"));
	if(strSearchType.isEmpty())
	{
		out.println("FAIL\tparameter mismatch ( stype)");
		return ;
	}
	
	BizPay bizP = new BizPay();
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
			out.println("FAIL\tparameter mismatch ( date)");
			return ;
		}
		dateST = EtcUtils.getJavaDate(strDateS);
		dateEnd = EtcUtils.getJavaDate(strDateE);
		dateEnd = EtcUtils.addDateDay(dateEnd,1,true);
		strWhereDate = " ( P_AUTH_DT >= " + EtcUtils.getSqlDate(dateST,bizP.m_strDBType) + " and P_AUTH_DT < " + EtcUtils.getSqlDate(dateEnd,bizP.m_strDBType) + ")";
	}


	strSearchValue = EtcUtils.NullS(request.getParameter("sval"));
	if(!strSearchValue.isEmpty())
	{
		
		if(strSearchType.equals("id"))
		{
			strWhereVal = "a.USER_ID like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("name"))
		{
			strWhereVal = "a.USER_NAME  like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("addr"))
		{
			strWhereVal = "a.USER_ADDR1  like  '%" + strSearchValue + "%'";
		}
	}
	
	strWhere = " a.USER_ID = b.USER_ID";
	if(!strWhereVal.isEmpty())
	{
		strWhere +=  " and " + strWhereVal;
		if(!strWhereDate.isEmpty())
		{
			strWhere += " and " + strWhereDate;
		}
	}
	else
	{
		if(!strWhereDate.isEmpty())
		{
			strWhere += " and " + strWhereDate;
		}
		else
		{
			out.println("FAIL\tparameter mismatch");
			return ;
		}
	}

	try
	{
		if(!bizP.connection())
		{
			out.println("FAIL\tdatabase connection fail");
			return ;	
		}


		int nRecordCnt = 1;
		ArrayList<BizPayRecord> aryBP = bizP.selectPay(strWhere,false);
		
		StringBuffer strbList = new StringBuffer();
		StringBuffer strbLine = new StringBuffer();
		strbLine.append("no\t");
		strbLine.append("name\t");
		strbLine.append("id\t");
		strbLine.append("sex\t");
		strbLine.append("birth\t");
		strbLine.append("addr\t");
		strbLine.append("date\t");
		strbLine.append("auth_no\t");
		strbLine.append("money\r\n");

		//out.write(strbLine.toString());
		strbList.append(strbLine.toString());
		for(BizPayRecord rP : aryBP)
		{
			strbLine.setLength(0);
			strbLine.append("" + nRecordCnt++ + "\t");
			strbLine.append(rP.m_strName);
			strbLine.append(rP.m_strID);
			strbLine.append(rP.m_strSex);
			strbLine.append(rP.m_strBirth);

			strbLine.append(rP.m_strAddr1 + " " + rP.m_strAddr2);
			strbLine.append(EtcUtils.getStrDate(rP.m_datePay,"yyyy-MM-dd"));
			strbLine.append(rP.m_strAuthNO);	
			strbLine.append(rP.m_strMoney);
			
			//out.write(strbLine.toString());
			strbList.append(strbLine.toString());
		}
		
		out.clear(); 
		EtcUtils.sendResponseData(response , strbList.toString().getBytes("euc-kr")); 
		out.flush();
	}
	finally
	{
		if(bizP.isConnected())
			bizP.disConnection();
	}
%>