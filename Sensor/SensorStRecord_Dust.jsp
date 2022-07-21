<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>

<%@ page import="common.util.ListPagingUtil" %>    
<%@ page import="wguard.dao.DaoSensorSt" %>    
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %>  
<%@ page import="java.util.ArrayList" %>    

<%
ListPagingUtil listPager = null;
String strValue = null;
int nTotalRecordCnt = 0;
int nPage = 1;
int nListPerPage = 15;
String strTableHtml = "";

DaoSensorSt  daoSS = new DaoSensorSt();

	strValue = request.getParameter("page_no");
	if(strValue != null)
		nPage = Integer.parseInt(strValue);
	
	//strValue = request.getParameter("record_sum");
	//if(strValue != null)
	//	nTotalRecordCnt = Integer.parseInt(strValue);
	//else
		nTotalRecordCnt = (int)daoSS.getSensorStCount();
	
	listPager = new ListPagingUtil("PagerUtil",10,nListPerPage,nPage,nTotalRecordCnt,false);
	int nFirstRecNo = listPager.getPageFirstRecordNo();
//	ArrayList<DaoSensorStRecord> tableSSR = daoSS.selectSensorStForList(nFirstRecNo,nFirstRecNo+nListPerPage-1);
	ArrayList<DaoSensorStRecord> tableSSR = daoSS.selectUserForList("USEGOAL = 165", "REG_DATE desc", nFirstRecNo, nFirstRecNo+nListPerPage-1, true);

	strTableHtml = daoSS.getTableHtml_Dust(tableSSR,nFirstRecNo);

%> 
<!DOCTYPE html >
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Sensor Record</title>
 <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
<link rel="stylesheet" href="css/page_util.css" type="text/css" />
<link rel="stylesheet" href="css/sensor_table.css" type="text/css" />
<script src="js/page_util.js"></script>
 <script>
  $(function(){

 });
  </script>
<style>
.hCenter{ 
	display: -webkit-flex;
	display: flex; /* 플렉스박스로 지정 */
	-webkit-justify-content: center;
	justify-content: center; /* 가로 중앙정렬 */
}

.vCenter{ 
	display: -webkit-flex;
	display: flex; /* 플렉스박스로 지정 */
     -webkit-align-items: center;
	align-items: center; /* 세로 중앙정렬 */
}
</style>
<script>
	$(function(){
		PagerUtil_SetForm(document.getElementById('id_page_frm'));
	});
</script>
</head>
<body>
<div class="body_wrap" style="width: 800px;  margin: 0 auto;" >
	<div style="width: 100%; color: white; background-color: black; height=30px; ">시설보안</div>
	<div class="vCenter" style="width: 100%; color: white; background-color: #CCCCCC; height=110px;"><img src="images/sysTitle.png"></div>
	
	<div style="width: 100%; color: black; background-color: white;">
	<% 
		out.println(strTableHtml);
	%>
	</div>

	<form  id="id_page_frm" action="SensorStRecord_Dust.jsp">
	<input type="hidden" name="page_no">
	</form>
	<br>
	<% 
	   out.println(listPager.getPagingStyle02());
	%> 	
	</div>
	
</body>
</html>