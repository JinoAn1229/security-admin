<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>

<%@ include file="./include_session_check.jsp" %> 
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Locale"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="common.util.UTF8ResourceBundle"%> 

<%
String strLang = (String)p_Session.getAttribute("LANG");
if(strLang == null) strLang = "ko";
ResourceBundle p_bundle = UTF8ResourceBundle.getBundle("Res.Resource", new Locale(strLang));
%>

<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if lt IE 10]>     <html class="no-js lt-ie10"> <![endif]-->
<!--[if gt IE 10]><!-->
<html class="no-js">
<!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>BSManager</title>

        <link rel="stylesheet" href="css/normalize_custom.css">
        <link rel="stylesheet" href="css/jquery-ui.min.css">
        <link rel="stylesheet" href="css/jquery.mCustomScrollbar.min.css">
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/index.css">
        <script src="js/jquery-1.12.1.min.js"></script>
        <script src="js/jquery-ui.min.js"></script>
        <script src="js/jquery.mCustomScrollbar.concat.min.js"></script>
         <script src="js/basic_utils.js"></script>
        <script src="js/date_util.js"></script>
         
    	<script>
      
      	$(function()
     	{
            $(".datepicker" ).datepicker({
            	dateFormat: "yy-mm-dd",
        		changeMonth: true,
        		dayNames: ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
        		dayNamesMin: ['월', '화', '수', '목', '금', '토', '일'],
        		monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
        		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],

            });
      		$(".tbl-body").mCustomScrollbar();	
      		
     		j_nDispPageNum = 1;
    			clearListTable();

    		// 기본 1개월 검색
    		FnSetSearchDate(30);
    		resetListTable();
			FnSetLeftMenu();
     	});
         
       	var	j_nDispPageNum = 1;  // 현재 페이지 번호(1base) 
			var j_sLastSearchParam = ""; // 마지막 조회 조건문 
       	//==================================
       	// 목록 갱신
       	 function resetListTable()
       	 {
       		var nListPerPage = $('#id_selectbox_count_per_page option:selected').val();
       		
       		// lpp 페이지에 표시할 리스트의 최대 갯수(List Per Page))
       		// pg 현재 페이지 번호(1base)
       		var sPageParam = "pg=" + j_nDispPageNum +"&lpp=" + nListPerPage;
       		
      		var sSearchValParam = "";
      		var sSearchDateParam = "";
      		
      		var sSearchParam = "";

			var sSearchType = $('#id_search_type').val();
      		var sSearchValue = $('#id_value_search').val();
			
      		var bAndDate = $('#id_chkbox_date_and').is(':checked');
			
			var bSearchType = checkValue(sSearchType);
      		var bSearchValue = checkValue(sSearchValue);
      		if(!bSearchValue && !bAndDate)
    		{
      			alert('검색 조건 부족');
      			return; 		
    		}
      		if(bAndDate)
      		{
      	  		var sDateStart = $('#id_date_search_start').val();
      	  		var sDateEnd = $('#id_date_search_end').val();
      			if(!checkValue(sDateStart) || !checkValue(sDateEnd))
      			{
      	  			alert('검색 조건 부족');
      	  			return; 		
      			}
      			sSearchDateParam = "&dtand=true&dates=" + sDateStart + "&datee=" + sDateEnd;
      		}
      		
      		if(bSearchValue)
      		{
          		var sSearchType = $('#id_search_type').val();
          	  	var sSearchValue = $('#id_value_search').val().trim();
      			sSearchValParam = "stype=" + sSearchType + "&sval=" + sSearchValue;
      		}
			else if(bSearchType)
      		{
          		var sSearchType = $('#id_search_type').val();
      			sSearchValParam = "stype=" + sSearchType;
      		}
      		else
      			sSearchValParam = "stype=none";
      		
      		sSearchParam = 	sSearchValParam + sSearchDateParam;
    		
       		// 화일 저장을 위해 마지작 조회 조건문 저장
       		j_sLastSearchParam = sSearchParam;
    		
       		var strQuery = "./query/query_SensorStRecord_list.jsp?" + sPageParam + "&" + sSearchParam;
			
       		$.getJSON(strQuery, function(root,status,xhr){
       			if(status == "success")
       			{
        			clearListTable();
        			
        			if(root.result =="OK")
        			{
          			var aryRecord =  root.members;
          			$('#id_total_count').text("" + root.tot_count);
         			for(var i = 0; i < aryRecord.length; i ++)
         			{
         				objItem = aryRecord[i];
         				addListTable(objItem);
         		 	}
         			// 페이지 네비게이션 
         			$("#id_page_navi").html(root.PageNavi);
        			}
       			}
       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
       			{
       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
       			}
       	    }); 
       	 }
       	
       	
       	 function clearListTable()
       	 {   // table 은 thead, tbody 구분되어 만들어져 있어야 함
       		 var nCount = $("#id_list_sensorRecord >tbody >tr").length;
       		 for(var i = 0; i < nCount ; i ++)
       		 {  
       			 $('#id_list_sensorRecord > tbody:last > tr:last').remove();
       		 }
       		 
     		 $('#id_total_count').text('0');

       		 $("#id_page_navi").html(
                        "<a href='' class='pg-first'></a>"
                      + "<a href='' class='pg-prev'></a>"
                      + "<a href='' class='on'>1</a>"
                      + "<a href='' class='pg-next'></a>"
                      + "<a href='' class='pg-last'></a>"
                      );
       	 }
       	 
       	 function addListTable(jM)
       	 {  
          
		   
/*
   <tr>
      <td>1266</td>
      <td>166</td>
      <td>2016-07-01</td>
      <td>F00200FF</td>
      <td>00000072</td>
      <td>1 or 0</td>
      <td>900</td>
	  <td>0</td>
  </tr>
*/
       	    var tr_html = "<tr>"
       	                  + "<td>" +  jM.no + "</td>"
       	                  + "<td>" + jM.use +"</td>"
       	                  + "<td>" + jM.sdate + "</td>"
       	                  + "<td>" + jM.sid + "</td>"
       	            	  + "<td>" + jM.gid + "</td>"
     	            	  + "<td>" + jM.state + "</td>"
     	            	  + "<td>" + jM.battery + "</td>"
     	            	  + "<td>" + jM.action + "</td>"
     	            	  + "<td>" + jM.expansion + "</td>"
       				  + "</tr>";
   				  
       		$('#id_list_sensorRecord > tbody:last').append(tr_html);
       	 }
       	 //=================================
       	//  페이지 리스트 Navi관련 
       	function Pager_SelectPage(nPage)
       	{
       		j_nDispPageNum = nPage;
       		resetListTable();
       	}
       	//처음으로
       	function Pager_FirstPage()
       	{
       		j_nDispPageNum = 1;
       		resetListTable();
       	}

       	//끝으로
       	function Pager_LastPage(nTotalPage)
       	{
       		j_nDispPageNum = nTotalPage;
       		resetListTable();
       	}
       	
       	//=================================
       	// 검색 기간 설정
       	function FnSetSearchDate(nDay)
       	{
       		var dateToday = new Date();
       		var dateStart =new Date();
    		$('#id_set_search_date_0').removeClass('on');
    		$('#id_set_search_date_2').removeClass('on');
    		$('#id_set_search_date_6').removeClass('on');
      		$('#id_set_search_date_30').removeClass('on');
      		$('#id_set_search_date_60').removeClass('on');
      		$('#id_set_search_date_90').removeClass('on');
			if(nDay == 0 || nDay == 2 || nDay == 6 || nDay == 30 || nDay == 60 || nDay == 90)
			{
				var sIDon = '#id_set_search_date_' + nDay; // nDay = 0, 3, 7 , 30;
				$(sIDon).addClass('on');
			}
       		if(nDay >= 30)
       		{  // 1,2,3,달 전
       			var nYear = dateToday.getFullYear();
       			var nMonth = dateToday.getMonth();
   				nMonth -= Math.floor((nDay/30));	
       			if(nMonth < 0)
       			{
       				nMonth += 12;
       				nYear --;
       			}
       			dateStart.setFullYear(nYear);
       			dateStart.setMonth(nMonth);
       			dateStart.setDate(dateToday.getDate() +1);
       		}
       		else
       			dateStart.setDate(dateToday.getDate() - nDay);
       		
       		$('#id_date_search_start').val(dateStart.format('yyyy-MM-dd'));
       		$('#id_date_search_end').val(dateToday.format('yyyy-MM-dd'));
    		$('#id_chkbox_date_and').attr('checked',true);	
       	}

       	// 등록일 and 조건 검색 책크박스 클릭
       	function FnSearchDateAnd()
       	{
       		
       		var elmtChk = $('#id_chkbox_date_and');
       		if(elmtChk.is(":checked"))
       		{
       			var sDateS = $('#id_date_search_start').val();
       			var sDateE = $('#id_date_search_end').val();
       			if(sDateS =="" || sDateE == "")
       			{
       				FnSetSearchDate(0);
       			}
       		}
       	}
       	
       	//============================ 	
       	// 엘셀 저장
       	function FnSaveToExcel()
       	{
      		location.href='./proc/down_payManagement_list.jsp?' + j_sLastSearchParam;
       	}
       	
       	//============================
       	// 조회버튼을 클릭했다.
       	function FnSearchPaymentList()
       	{
         //  파라메터 리스트
       	// pg : 리스트를 보여풀 페이지 번호
       	// lpp: 한페이지에 보여줄 리스트 갯수
       	// stype : 검색조건 형식, 
     	//  	     name  :   sval 파라메터로 회원 이름 이 전달된다.
     	//  	     id       :   sval 파라메터로 회원 ID가 전달된다.
     	//  	     addr   :   sval 파라메터로 주소가 전달된다.
     	  	// dtand : true 경우 
     	//  	             dates로  등록일 시작, datee로  등록일 끝이  파라메터로 전달된다. 
     	//  	             dates >=  회원등록일  <= datee 조건으로 이용됨	
     	
     		j_nDispPageNum = 1;
     		resetListTable();
       	}
		function selectEvent(selectObj) {
			if(selectObj.value == "battery")
				{
					$('#id_value_search').prop('readonly', true);
					document.getElementById("id_value_search").style.backgroundColor = "#F0F0F0";
					document.getElementById("id_value_search").value="조회버튼을 눌러주세요.";
				}
			else 
				{
					$('#id_value_search').prop('readonly', false);
					document.getElementById("id_value_search").style.backgroundColor = "#FFFFFF";
					document.getElementById("id_value_search").value="";
				}
		}

		function FnSetLeftMenu()
        {
			var sAccount = '<%=p_Session.getAttribute("ACCOUNT")%>';
			if(sAccount == 'admin')
			{
				var sLine = '<ul><li><a href="./SensorStRecord.jsp" class="navi_link">센서상태</a></li></ul>'
				$('#lnb').append(sLine);
			}
        }

       	</script>         
    </head>

    <body>
        <div id="wrapper">
            <header>
                BLAKSTONE.CO.,LTD. Home Security Solution Management Program
            </header>
            <!-- //  header -->

            <div class="content-wrap">
           	<jsp:include page="./left_menu.jsp"></jsp:include>
			          	
                <div id="contents">
                    <div class="container">
                        <h3 class="tit-list"><%=p_bundle.getString("SensorStRecord_title")%></h3>
                      <div class="search-wrap">
                            <ul>
                                <li>
                                    <div class="dist"><%=p_bundle.getString("search_text_Detail")%></div>
                                    <div class="dist-cont">
                                        <select name="select"  id="id_search_type" onChange="javascript:selectEvent(this)">
                                            <option value="usegoal">용도</option>
                                            <option value="sid">센서 ID</option>
                                            <option value="gid">게이트 ID</option>
											<option value="battery">배터리</option>
											
                                        </select>

                                        <input type="text"  id="id_value_search" class="wide-input" />
                                    </div>
                                </li>
                                <li class="period">
                                    <div class="dist">조회기간</div>
                                    <div class="dist-cont">
                                        <p>
                                            <input type="text"  id='id_date_search_start'  class="datepicker" readonly placeholder="날짜선택"> ~ <input type="text"  id='id_date_search_end' class="datepicker" readonly placeholder="날짜선택">
                                        </p>
                                        <p>
                                            <button id='id_set_search_date_0' class="btn-option on"  onClick='FnSetSearchDate(0);' >오늘</button>
                                            <button id='id_set_search_date_2' class="btn-option"  onClick='FnSetSearchDate(2);'>3일</button>
                                            <button id='id_set_search_date_6' class="btn-option"  onClick='FnSetSearchDate(6);'>7일</button>
                                            <button id='id_set_search_date_30' class="btn-option"  onClick='FnSetSearchDate(30);'>1개월</button>
                                            <button id='id_set_search_date_60' class="btn-option"  onClick='FnSetSearchDate(60);'>2개월</button>
                                            <button id='id_set_search_date_90' class="btn-option"  onClick='FnSetSearchDate(90);'>3개월</button>
                                        </p>
                                        <p >
                                        	<input type='checkbox'  id='id_chkbox_date_and'  style='margin-left:40px;' onClick='FnSearchDateAnd()'> <label for='id_chkbox_date_and'>조회기간 AND 조회</label>
                                        </p>
                                    </div>
                                </li>
                            </ul>

                            <button class="btn-list btn-search blue"  onClick='FnSearchPaymentList()'>조회</button>
                        </div>
                        <!-- // 조회영역 -->

                        <div class="list-wrap">
                            <span class="list-count" >총 <em id="id_total_count">0</em>건이 조회되었습니다.</span>
                            <select name="" id="id_selectbox_count_per_page" class="">
                                <option value="10">10건씩보기</option>
                                <option value="20">20건씩보기</option>
                            </select>

							<!-- 상단버튼 -->
                            <div class="util-btn-wrap">
                                <button class="btn-list excel" onClick='FnSaveToExcel();'>엑셀 <i><img src="images/list/bg_down.png" alt=""></i></button>
                            </div>
							<!--// 상단버튼 -->


                            <div class="list-def">
                                <div class="tbl-head">
                                    <table summary="">
                                        <caption>리스트head</caption>
                                        <colgroup>
                                            <col style="width:5%">
                                            <col style="width:6%">
                                            <col style="width:12%">
                                            <col style="width:9%">
                                            <col style="width:9%">
                                            <col style="width:5%">
                                            <col style="width:7%">
                                            <col style="width:5%">
                                            <col style="width:25%">
                                            
                                        </colgroup>

                                        <thead>
                                            <tr>
                                                <th>번호</th>
                                                <th>용도</th>
												<th>날짜</th>
                                                <th>센서 ID</th>
                                                <th>게이트 ID</th>
                                                <th>센서 상태</th>
                                                <th>배터리</th>
                                                <th>센서 동작</th>
                                                <th>확장 필드</th>
                                            
                                            </tr>
                                        </thead>
                                    </table>
                                </div>
								<!-- // table-head -->
                                <div class="tbl-body">
                                    <table id='id_list_sensorRecord'>
                                        <caption>리스트body</caption>
                                        <colgroup>
                                            <col style="width:5%">
                                            <col style="width:6%">
                                            <col style="width:12%">
                                            <col style="width:9%">
                                            <col style="width:9%">
                                            <col style="width:5%">
                                            <col style="width:7%">
                                            <col style="width:5%">
                                            <col style="width:25%">
                                            
                                        </colgroup>
                                        <tbody>
                                            <tr>
                                                <td>1266</td>
                                                <td>166</td>
                                                <td>2016-07-01</td>
                                                <td>F00200FF</td>
                                                <td>00000072</td>
                                                <td>1 or 0</td>
                                                <td>900</td>
	                                            <td>0</td>
	                                            <td>0</td>
                                            </tr>

                                        </tbody>
                                    </table>
                                </div>
								<!-- // table-body -->


                                <div id='id_page_navi' class="paging">
                                    <a href="" class="pg-first"></a>
                                    <a href="" class="pg-prev"></a>
                                    <a href="" class="on">1</a>
                                    <a href="">2</a>
                                    <a href="">3</a>
                                    <a href="">4</a>
                                    <a href="">5</a>
                                    <a href="">6</a>
                                    <a href="">7</a>
                                    <a href="">8</a>
                                    <a href="">9</a>
                                    <a href="">10</a>
                                    <a href="" class="pg-next"></a>
                                    <a href="" class="pg-last"></a>
                                </div>
                                <!-- //페이징 -->

                            </div>
                            <!-- // list-def -->
                        </div>
                        <!-- // 리스트 영역 -->
                    </div>
                    <!-- // container -->


                </div>
                <!-- // contents -->


            </div>
            <!-- //content-wrap -->

            <footer>
                Copyright BLAKSTONE.CO.,LTD. All Right reserved.
            </footer>
            <!-- // footer -->

        </div>
        <!-- //wrapper -->

    </body>
</html>
