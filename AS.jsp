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
          		
          		if($('#id_prevent_onload').val() == '0')
          		{
       				//history.back로 페이지가 로딩되면 여기는 싱행 안된다.
       				//$('#id_prevent_onload').val('1');  괜한짓...
       				
       				j_nDispPageNum = 1;
      				clearListTable();
      				
      				// 기본 1개월 검색
      				FnSetSearchDate(30);
      				resetListTable();
					FnSetLeftMenu();
           		}
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

          		var sSearchValue = $('#id_value_search').val();
          		var bAndDate = $('#id_chkbox_date_and').is(':checked');
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
          		else
          			sSearchValParam = "stype=none";
          		
          		sSearchParam = 	sSearchValParam + sSearchDateParam;
        		// 화일 저장을 위해 마지작 조회 조건문 저장
           		j_sLastSearchParam = sSearchParam;
        		
          		// query_as_list.jsp 를 따로 만들지 안았다. 거의 같아서 따로 만들지 안았다.  
          		var strQuery = "./query/query_memberList_list.jsp?" + sPageParam + "&" + sSearchParam;

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
          	 {   
          		 // table 은 thead, tbody 구분되어 만들어져 있어야 함
          		 var nCount = $("#id_list_member >tbody >tr").length;
          		 for(var i = 0; i < nCount ; i ++)
          		 {  
          			 $('#id_list_member > tbody:last > tr:last').remove();
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
              var sSex = "남"; 
              if(jM.sex !="woman") sSex = "남";
              
              var sPay = "";
              if(jM.exp_date < new Date())
            	  sPay = "미납";
              
          	    var tr_html = "<tr  onclick='FnOnClickMember(this);'>"
          	                  + "<td>" +  jM.no + "</td>"
          	                  + "<td>" + jM.name +"</td>"
          	                  + "<td>" + jM.id + "</td>"
          	            	  + "<td>" + jM.birth + "</td>"
          	                  + "<td>" + sSex + "</td>"
          	                  + "<td>" + jM.reg_date + "</td>"
          	                  + "<td>" + jM.addr + "</td>"
//          	                  + "<td>" + sPay + "</td>"
          	                  + "<td><a href=\"javascript:FnInitUserDevice('" +  jM.id + "')\" class='shape-btn'>" + '<%=p_bundle.getString("table_btn_InitUserDevice")%>' + "</a></td>"
          	                  + "<td>" + jM.dev_info + "</td>"
          				  + "</tr>";
      				  
          		$('#id_list_member > tbody:last').append(tr_html);
           		// 정보를 쉼게 접근하기위해 tag로 개체를 등록 
           		var elmtTR = $('#id_list_member > tbody>tr:last');
           		elmtTR.data('tag',jM);
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
				if(nDay == 0 || nDay == 2 || nDay == 6 || nDay == 30)
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
          	// 장비 초기화 버튼 클릭
          	// sID  = USER ID
          	function FnInitUserDevice(sID)
          	{
          		var sURL = './query/query_user_device_delete.jsp?uid=' + sID;
          		$.get(sURL, function(data, status)
          		{
          			if(status=="success")
          			{
          				var sResponse = data.trim();
          				if(sResponse.indexOf("OK") >= 0)
          				{
          					alert('사용자의 장비 설정이 초기화 되었습니다.');
          				}
          				else
          					oTd.text('FAIL');
          			}
          			else
          			{  // "notmodified", "error", "timeout", "parsererror"
          				oTd.text('ERROR');
          			}
          		 });
          	}
           	// 엘셀 저장
           	function FnSaveToExcel()
           	{ 
           		// 회원 관리와 같아서 따로 만들지 안았음
           		location.href='./proc/query_memberList_list.jsp?' + j_sLastSearchParam;
           	} 
           	
           	//회원 목록 테이믈에서 클릭 발생 
           	function FnOnClickMember(elmtTR)
           	{
           		var tagM = $(elmtTR).data('tag');
				//location.href = './ASView.jsp?id=' + tagM.id;
           		var sURL = './ASView.jsp?id=' + tagM.id + '&win=popup';
           		var sOpt = 'width=' + $(window).width() + ',height=' + $(window).height() + ',menubar=no ,status=no,top=0,left=0' 
           		window.open(sURL,'_blank','width=1400 height=800 menubar=no status=no');				
           	}
          	//============================
          	// 조회버튼을 클릭했다.
          	function FnSearchMemberList()
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
			<!--  history.back()시  $(function(){}); 스크립트 수행 제어용 - --> 
			<input id='id_prevent_onload' type='hidden' value='0'>
			
            <div class="content-wrap">
            	<jsp:include page="./left_menu.jsp"></jsp:include>
			          	
                <div id="contents">
                    <div class="container">
                        <h3 class="tit-list"><%=p_bundle.getString("AS_title")%></h3>

                      <div class="search-wrap">
                            <ul>
                                <li>
                                    <div class="dist"><%=p_bundle.getString("search_text_Detail")%></div>
                                    <div class="dist-cont">
                                        <select name=""  id="id_search_type">
                                            <option value="name"><%=p_bundle.getString("search_menu_name")%></option>
                                            <option value="id"><%=p_bundle.getString("search_menu_ID")%></option>
                                            <option value="addr"><%=p_bundle.getString("search_menu_addr")%></option>
                                        </select>

                                        <input type="text"  id="id_value_search" class="wide-input">
                                    </div>
                                </li>
                                <li class="period">
                                    <div class="dist"><%=p_bundle.getString("search_text_date")%></div>
                                    <div class="dist-cont">
                                        <p>
                                            <input type="text"  id='id_date_search_start'  class="datepicker" readonly placeholder="날짜선택"> ~ <input type="text"  id='id_date_search_end' class="datepicker" readonly placeholder="날짜선택">
                                        </p>
                                        <p>
                                            <button id='id_set_search_date_0' class="btn-option on"  onClick='FnSetSearchDate(0);' ><%=p_bundle.getString("search_date_today")%></button>
                                            <button id='id_set_search_date_2' class="btn-option"  onClick='FnSetSearchDate(2);'><%=p_bundle.getString("search_date_3day")%></button>
                                            <button id='id_set_search_date_6' class="btn-option"  onClick='FnSetSearchDate(6);'><%=p_bundle.getString("search_date_7day")%></button>
                                            <button id='id_set_search_date_30' class="btn-option"  onClick='FnSetSearchDate(30);'><%=p_bundle.getString("search_date_30day")%></button>
                                        </p>
                                        <p >
                                        	<input type='checkbox'  id='id_chkbox_date_and'  style='margin-left:40px;' onClick='FnSearchDateAnd()'> <label for='id_chkbox_date_and'><%=p_bundle.getString("search_check_text_and")%></label>
                                        </p>
                                    </div>
                                </li>
                            </ul>

                            <button class="btn-list btn-search blue"  onClick='FnSearchMemberList()'><%=p_bundle.getString("search_btn_text")%></button>
                        </div>
                        <!-- // 조회영역 -->

                        <div class="list-wrap">
                            <span class="list-count" ><em id="id_total_count">0</em><%=p_bundle.getString("search_text_count")%></span>
                            <select name="" id="id_selectbox_count_per_page" class="">
                                <option value="10"><%=p_bundle.getString("search_text_view_count_10")%></option>
                                <option value="20"><%=p_bundle.getString("search_text_view_count_20")%></option>
                            </select>

							<!-- 상단버튼 -->
                            <div class="util-btn-wrap">
                                <button class="btn-list excel" onClick='FnSaveToExcel();'><%=p_bundle.getString("excle_save_text")%> <i><img src="images/list/bg_down.png" alt=""></i></button>
                            </div>
							<!--// 상단버튼 -->


                            <div class="list-def">
                                <div class="tbl-head">
                                    <table summary="">
                                        <caption>리스트head</caption>
                                        <colgroup>
                                            <col style="width:5%">
                                            <col style="width:8%">
                                            <col style="width:15%">
                                            <col style="width:9%">
                                            <col style="width:5%">
                                            <col style="width:9%">
                                            <col style="width:*">
<!--                                            <col style="width:5%"> -->
                                            <col style="width:8%">
                                            <col style="width:10%">
                                        </colgroup>

                                        <thead>
                                            <tr>
                                                <th><%=p_bundle.getString("table_header_NO")%></th>
                                                <th><%=p_bundle.getString("table_header_name")%></th>
                                                <th><%=p_bundle.getString("table_header_ID")%></th>
                                                <th><%=p_bundle.getString("table_header_birth")%></th>
                                                <th><%=p_bundle.getString("table_header_Sex")%></th>
                                                <th><%=p_bundle.getString("table_header_reg_date")%></th>
                                                <th><%=p_bundle.getString("table_header_addr")%></th>
<!--                                                <th>미납</th>-->
                                                <th><%=p_bundle.getString("table_header_InitUserDevice")%></th>
                                                <th><%=p_bundle.getString("table_header_dev_info")%></th>
                                            </tr>
                                        </thead>
                                    </table>
                                </div>
								<!-- // table-head -->
                                <div class="tbl-body">
                                    <table id='id_list_member'>
                                        <caption>리스트body</caption>
                                        <colgroup>
                                            <col style="width:5%">
                                            <col style="width:8%">
                                            <col style="width:15%">
                                            <col style="width:9%">
                                            <col style="width:5%">
                                            <col style="width:9%">
                                            <col style="width:*">
<!--                                            <col style="width:5%"> -->
                                            <col style="width:8%">
                                            <col style="width:10%">
                                        </colgroup>
                                        <tbody>
                                        <!-- addListTable() 함수에서 구성함 -->
                                        <!--  셈플 
                                        	<tr onclick="location.href='ASView.html'">
                                                <td>1266</td>
                                                <td>홍길동</td>
                                                <td>aaa@aaa.co.kr</td>
                                                <td>2016-07-01</td>
                                                <td>남</td>
                                                <td>2016-07-01</td>
                                                <td>경기도 XX시 XXX구 XXX 888 (XXX1동) XXX-85 </td>
                                                <td>미납</td>
                                                <td><a href="" class="shape-btn">초기화</a></td>
                                                <td>아이폰</td>
                                            </tr>
                                        -->
                                        
                                        </tbody>
                                    </table>
                                </div>
								<!-- // table-body -->

                                <div id='id_page_navi' class="paging">
                                    <a href="" class="pg-first"></a>
                                    <a href="" class="pg-prev"></a>
                                    <a href="" class="on">1</a>
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

