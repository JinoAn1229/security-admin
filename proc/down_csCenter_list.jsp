<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="bsmanager.biz.BizCSNote" %>
<%@ page import="bsmanager.biz.BizCSNote.BizCSNoteRecord" %>

<%@ include file="./include_session_proc.jsp" %> 

<%

//-----------------------------	
// 고객관리 , 게시물 목록 쿼리호출이다.
// stype : 검색조건 형식, 
//     name  :   sval 파라메터로 회원 이름 이 전달된다.
//     id       :   sval 파라메터로 회원 ID가 전달된다.
//     addr   :   sval 파라메터로 주소가 전달된다.
// dtend : true 경우 
//             dates로  등록일 시작, datee로  등록일 끝이  파라메터로 전달된다. 
//             dates >=  회원등록일  <= datee 조건으로 이용됨

    response.setContentType("application/octet-stream");
    response.setHeader("Content-Disposition","attachment;filename=csCenter.txt");
    
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
	
	BizCSNote bizCN = new BizCSNote();	
	String strDateAnd = EtcUtils.NullS(request.getParameter("dtand"));

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
			out.println("FAIL\tparameter mismatch (date)");
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
			strWhereVal = "USER_ID like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("name"))
		{
			strWhereVal = "USER_NAME  like  '%" + strSearchValue + "%'";
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
			out.println("FAIL\tparameter mismatch");
			return ;
		}
	}

	strWhere += " and a.USER_ID = b.USER_ID";

	try
	{
	
		if(!bizCN.connection())
		{
			out.println("FAIL\tparameter mismatch ( stype)");
			return ;	
		}
		
		int nRecordCnt = 1;
		ArrayList<BizCSNoteRecord> aryCSNote = bizCN.selectCSNote(strWhere,"CS_DATE desc",false);
		
		bizCN.disConnection();

		
		StringBuffer strbList = new StringBuffer();
		StringBuffer strbLine = new StringBuffer();
		strbLine.append("no\t");
		strbLine.append("seqid\t");
		strbLine.append("name\t");
		strbLine.append("userid\t");
		strbLine.append("birth\t");
		strbLine.append("sex\t");
		strbLine.append("title\t");
		strbLine.append("cstext\t");
		strbLine.append("csdate\t");
		strbLine.append("respid\t");
		strbLine.append("astext\t");
		strbLine.append("asdate\t");
		
		//out.write(strbLine.toString());
		strbList.append(strbLine.toString());
		
		for(BizCSNoteRecord rCN : aryCSNote)
		{
			strbLine.setLength(0);
			strbLine.append("" + nRecordCnt++ + "\t");
			strbLine.append(rCN.m_strName + "\t");
			strbLine.append(rCN.m_strSeqID + "\t");
			strbLine.append(rCN.m_strName + "\t");
			strbLine.append(rCN.m_strUserID + "\t");
			strbLine.append(rCN.m_strBirth + "\t");
			strbLine.append(rCN.m_strSex + "\t");
			
			strbLine.append(rCN.m_strTitle + "\t");
			strbLine.append(rCN.m_strCsText + "\t");
			strbLine.append(EtcUtils.NullS(EtcUtils.getStrDate(rCN.m_dateCsReg,"yyyy-MM-dd")) + "\t");

			strbLine.append(rCN.m_strRespID + "\t");
			strbLine.append(rCN.m_strAsText + "\t");
			strbLine.append(EtcUtils.NullS(EtcUtils.getStrDate(rCN.m_dateAsReg,"yyyy-MM-dd")) + "\t");
			
			//out.write(strbLine.toString());
			strbList.append(strbLine.toString());
		}
		
		out.clear(); 
		EtcUtils.sendResponseData(response , strbList.toString().getBytes("euc-kr")); 
		out.flush();
		return ;
	}
	finally
	{
		if(bizCN.isConnected())
			bizCN.disConnection();
	}
%>