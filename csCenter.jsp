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
        <link rel="stylesheet" href="css/view.css">
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
        		
          	    //=====================================================
        		// 팝업 지원  view.css에 id = popup 인엘리먼트 관련 정의 가 있다.

        		/*  스크립트 함수 로 팝업함, click-popup 클래스 설정은 무효
        		$(".click-popup").click(function(e){
                    e.preventDefault();
                    FnViewPopupWindow(true);
                });
        		*/
        		// 팝업 지원 
                $("#close-pop").click(function(){
                    FnViewPopupWindow(false);
                });
               

				// 팝업 내 리스트 hover
                var hoverIdx;
                $("#popup .list table tr").mouseenter(function(){
                    hoverIdx = $(this).index()+1;
                    $("#popup .list table").each(function(){
                        $(this).find("tr").eq(hoverIdx).addClass("focus");
                    });
                });
                $("#popup .list table tr").mouseleave(function(){
                    $("#popup .list table tr").removeClass("focus");
                });
        	});
            
        	//------------------------------
        	// popup  윈도웅 보이기 감추기
    		function FnViewPopupWindow(bShow)
      	    {
                if(bShow)
                {
                    $("#mask").fadeTo("fast",.5);
                    $("#popup").fadeIn("fast");

					// init scrollbar
					$("#popup .list").mCustomScrollbar({});
					$("#popup .scrollable").mCustomScrollbar({
						axis:"x",
						scrollbarPosition:"outside"

					});
                }
                else
                {
                    $("#mask").fadeOut("fast");
                    $("#popup").fadeOut("fast",function(){
						// destroy scrollbar
						$("#popup .list").mCustomScrollbar("destroy");
						$("#popup .scrollable").mCustomScrollbar("destroy");
					});	
                }
      	    }
    		
          	var	j_nDispPageNum = 1;  // 현재 페이지 번호(1base)
          	var j_jaCSNote = [];
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
        		
          		var strQuery = "./query/query_csCenter_list.jsp?" + sPageParam + "&" + sSearchParam;

          		$.getJSON(strQuery, function(root,status,xhr){
          			if(status == "success")
          			{
	          			clearListTable();
	          			
	          			if(root.result =="OK")
	          			{
	          				// 전역변수로 갱신 등록, 목록수정시 같이 갱신
	          				j_jaCSNote =  root.members;
	 	          			$('#id_total_count').text("" + root.tot_count);
		          			for(var i = 0; i < j_jaCSNote.length; i ++)
		          			{
		          				objItem = j_jaCSNote[i];
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
          		 var nCount = $("#id_list_csnote >tbody >tr").length;
          		 for(var i = 0; i < nCount ; i ++)
          		 {  
          			 $('#id_list_csnote > tbody:last > tr:last').remove();
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
	            var sSex = '<%=p_bundle.getString("table_body_man")%>'; 
				if(jM.sex != "unknown")
				{
					if(jM.sex !="woman") sSex = '<%=p_bundle.getString("table_body_man")%>';
					else  sSex= '<%=p_bundle.getString("table_body_woman")%>';
				}
				else sSex= "선택안함";

              var sResp = ""; 
              if(jM.astext.length > 0) sResp = '<button class="btn-list btn-search orange"><%=p_bundle.getString("table_body_resp_ok")%></button>';
              else sResp = '<button class="btn-list btn-search gray"><%=p_bundle.getString("table_body_resp_no")%></button>'
              
              
          	    var tr_html = "<tr class='click-popup'>"
          	                  + "<td>" + jM.no + "</td>"
          	                  + "<td>" + jM.name +"</td>"
          	                  + "<td>" + jM.userid + "</td>"
          	            	  + "<td>" + jM.birth + "</td>"
          	                  + "<td>" + sSex + "</td>"
          	                  + "<td>" + jM.csdate + "</td>"
          	                  + "<td>" + jM.title + "</td>"
          	                  + "<td>" + sResp + "</td>"
          				  + "</tr>";
      				  
          		$('#id_list_csnote > tbody:last').append(tr_html);
          		var elmtTR = $('#id_list_csnote > tbody > tr:last');
          		elmtTR.on('click',FnOnClickMember);
          		elmtTR.data('tag',jM);
          		var elmtIMG = $('#id_list_csnote > tbody > tr:last button');
          		elmtIMG.data('tag',jM);
          	 }
          	 
          	 // list 갱신
          	 function updateListTable(elmtTR,jM)
          	 {
	            var sSex = '<%=p_bundle.getString("table_body_man")%>'; 
				if(jM.sex != "unknown")
				{
					if(jM.sex !="woman") sSex = '<%=p_bundle.getString("table_body_man")%>';
					else  sSex= '<%=p_bundle.getString("table_body_woman")%>';
				}
				else sSex= "선택안함";


                 var sResp = ""; 
		         if(jM.astext.length > 0) sResp = '<button class="btn-list btn-search orange"><%=p_bundle.getString("table_body_resp_ok")%></button>';
                 else sResp = '<button class="btn-list btn-search gray"><%=p_bundle.getString("table_body_resp_no")%></button>'
                 
                 
	           	 var tr_html = "<td>" + jM.no + "</td>"
	           	                  + "<td>" + jM.name +"</td>"
	           	                  + "<td>" + jM.userid + "</td>"
	           	            	  + "<td>" + jM.birth + "</td>"
	           	                  + "<td>" + sSex + "</td>"
	           	                  + "<td>" + jM.csdate + "</td>"
	           	                  + "<td>" + jM.title + "</td>"
	           	                  + "<td>" + sResp + "</td>";
	           	 $(elmtTR).html(tr_html);
	           	 var elmtIMG = $('#id_list_csnote > tbody > tr:eq(' + $(elmtTR).index() + ') button');
	             elmtIMG.data('tag',jM); 
	             // alert("updateListTable:" + $(elmtTR).index());
             	   
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
           	// 엘셀 저장
           	function FnSaveToExcel()
           	{
           		location.href='./proc/down_csCenter_list.jsp?' + j_sLastSearchParam;
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
          	
          	// 회원 리스트를 클릭했다. 기록을 보여준다.
          	function FnOnClickMember(e)
          	{


          		if(e.target.nodeName == 'BUTTON')
          		{
          			FnOnClickModifyAsText(e.target);
          			return ;
          		}
          		
          		// TR CLICK
          		var elmtTR = null;
          		if(e.target.nodeName == 'TD')
          		{
          			elmtTR = e.target.parentNode;
          		}
          		else if(e.target.nodeName == 'TR')
          		{
          			elmtTR = e.target;
          		}
          		if(elmtTR == null)
          			return ;
	      		var tagM = $(elmtTR).data('tag');
	      		
         		//----------------------------------
         		// popup 윈도 내용 채우기
         		$('#id_popup_name').text(tagM.name);
         		$('#id_popup_id').text(tagM.userid);
         		$('#id_popup_csdate').text(tagM.csdate);
         		$('#id_popup_title').text(tagM.title);
         		$('#id_popup_cstext').text(tagM.cstext);
         		
         		var elmtAsText = $('#id_popup_astext_tr');
         		if(elmtAsText != null)
         			elmtAsText.remove();
         		
         		var elmtApplyBtn = $('#id_popup_apply_btn');
         		elmtApplyBtn.css('display','none');
         		
         		if(tagM.astext.length > 0)
         		{
         			var tr_html =  "<tr id='id_popup_astext_tr'><th>" + '<%=p_bundle.getString("popup_text_resp")%>' + "</th><td colspan='3'>" + tagM.astext + "<td></tr>";  
         			$('#id_popup_cstext_tr').after(tr_html)
          		}
                
                // popup 윈도 보이기
         		FnViewPopupWindow(true);
          	}
          	
          	// 답변 수정 이미지 큭릭 
          	var j_joCurEditCSNote = null;
          	function FnOnClickModifyAsText(elmtIMG)
			{
          		var tagM = $(elmtIMG).data('tag');
          		j_joCurEditCSNote = tagM;
         		//----------------------------------
         		// popup 윈도 내용 채우기
         		$('#id_popup_name').text(tagM.name);
         		$('#id_popup_id').text(tagM.userid);
         		$('#id_popup_csdate').text(tagM.csdate);
         		$('#id_popup_title').text(tagM.title);
         		$('#id_popup_cstext').text(tagM.cstext);
         		
         		var elmtAsText = $('#id_popup_astext_tr');
         		if(elmtAsText != null)
         			elmtAsText.remove();

         		var elmtApplyBtn = $('#id_popup_apply_btn');
         		elmtApplyBtn.css('display','inline-block');
         		
				var sAsText = tagM.astext;
				if(sAsText.length == 0)
					sAsText = '내용입력';
        		var tr_html =  "<tr id='id_popup_astext_tr'><th>" + '<%=p_bundle.getString("popup_text_resp")%>' + "</th><td colspan='3'>"
        				+ "<textarea id='id_popup_astext' rows='8' style='width:100%;height:100%; margin-top:5px;' maxlength='1024' onkeyup='return checkMaxLength(this)'>" 
        				+ sAsText + "</textarea></td></tr>";
        		$('#id_popup_cstext_tr').after(tr_html)
                
                // popup 윈도 보이기
         		FnViewPopupWindow(true);
          	}
          	// POPUP 창에서 수정 버튼을 클릭했다
          	function FnEditApply()
          	{
          		var tagM = j_joCurEditCSNote;

          		var strURL = "./query/query_csCenter_update.jsp";
				var joReq = {};
				joReq['cmd'] = 'mod';
				joReq['seqid'] = tagM.seqid;
				joReq['respid'] = '<%=p_strSessionID%>';
				joReq['userid'] = tagM.userid;
				joReq['astext'] = $('#id_popup_astext').val();
				
				// alert(JSON.stringify(joReq));
				
          		$.ajax({
          			type:"POST",  
          			url: strURL,
          			data: JSON.stringify(joReq),
          			async: false,
          			dataType: 'JSON',
        	        success:function(joRoot,status,xhr)
        	        {
        	        	if(status == 'success')
        	        	{
        	        		var joCN = joRoot.csnote;
        	        		if(tagM.seqid != joCN.seqid)
        	        		{
        	        			alert('error: seqid mismatch');
        	        			return;
        	        		}
        	        		tagM.respid = joCN.respid;
        	        		tagM.astext = joCN.astext;
        	        		FnUpdateCsNoteTableList(tagM.seqid);
        	        	}
        	        	else
        	        	{
        	        		$('#id_status').text("[fail] status:"+status+" / "+"message:"+xhr.responseText); 
        	        	}
        	        },   

        	        error:function(request,status,error)
        	        { 
        				//$('#id_status').text("[error] status:"+status+" / "+"message:"+request.responseText+" / "+"error:"+error); 
        				$('#id_status').text("[error] status:"+status+ '/ error:'+error); 
        	        } 
          		});
          		
          		// popup 윈도 닫기
         		FnViewPopupWindow(false);
          	}
          	
          	// 리스트에 수정된 내용 반영
          	function FnUpdateCsNoteTableList(sSeqID)
          	{
          		var aryTR = $('#id_list_csnote > tbody > tr');
          		var tagM = null;
          		for(var i = 0; i < aryTR.length ; i ++)
          		{ 
          			tagM = $(aryTR[i]).data('tag');
          			if(tagM.seqid == sSeqID)
          			{
          				updateListTable(aryTR[i],tagM);
          				return;
          			}
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
                        <h3 class="tit-list"><%=p_bundle.getString("csCenter_title")%></h3>

                      <div class="search-wrap">
                            <ul>
                                <li>
                                    <div class="dist"><%=p_bundle.getString("search_text_Detail")%></div>
                                    <div class="dist-cont">
                                        <select name=""  id="id_search_type">
                                            <option value="name"><%=p_bundle.getString("search_menu_name")%></option>
                                            <option value="id"><%=p_bundle.getString("search_menu_ID")%></option>
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
                                            <col style="width:8%">
                                        </colgroup>

                                        <thead>
                                            <tr>
                                                <th><%=p_bundle.getString("table_header_NO")%></th>
                                                <th><%=p_bundle.getString("table_header_name")%></th>
                                                <th><%=p_bundle.getString("table_header_ID")%></th>
                                                <th><%=p_bundle.getString("table_header_birth")%></th>
                                                <th><%=p_bundle.getString("table_header_Sex")%></th>
                                                <th><%=p_bundle.getString("table_header_write_date")%></th>
                                                <th><%=p_bundle.getString("table_header_title")%></th>
                                                <th><%=p_bundle.getString("table_header_resp")%></th>
                                            </tr>
                                        </thead>
                                    </table>
                                </div>
								<!-- // table-head -->
                                <div class="tbl-body">
                                    <table id='id_list_csnote'>
                                        <caption>리스트body</caption>
                                        <colgroup>
                                            <col style="width:5%">
                                            <col style="width:8%">
                                            <col style="width:15%">
                                            <col style="width:9%">
                                            <col style="width:5%">
                                            <col style="width:9%">
                                            <col style="width:*">
                                            <col style="width:8%">     
                                        </colgroup>
                                        <tbody>
                                          <!-- 셈플 모양 , addListTable() 에서 만등어 진다.
                                            <tr class="btn-search" onClick='FnOnClickMember(this);'>
                                                <td>1266</td>
                                                <td>홍길동</td>
                                                <td>ceo@blakston.co.kr</td>
                                                <td>2016-07-01</td>
                                                <td>남</td>
                                                <td>2016-07-01</td>
                                                <td>게시물 제목이 없습니다.</td>
                                                <td>있음</td>
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
<!-- popup -->
            <div id="mask"></div>
            <div id="popup">
                <div class="pop-head">
                    <p><%=p_bundle.getString("popup_title")%></p>
                    <span id="close-pop"></span>
                </div>
                <div class="pop-cont">
 				<!-- 상세리스트 -->
                            <div class="list-view">
                                <table class='outer' summary="">
                                    <caption>상세 리스트</caption>

                                    <colgroup>
                                        <col style="width:120px">
                                        <col style="width:*">
                                        <col style="width:120px">
                                        <col style="width:*">
                                    </colgroup>

                                    <tbody>
                                        <tr>
                                            <th><%=p_bundle.getString("popup_text_name")%></th>
                                            <td id='id_popup_name'>홍길동</td>
                                            <th><%=p_bundle.getString("popup_text_ID")%></th>
                                            <td id='id_popup_id'>ceo@blakstone.co.kr</td>
                                        </tr>
                                        <tr>
                                            <th><%=p_bundle.getString("popup_text_write_date")%></th>
                                            <td id='id_popup_csdate'>2016-07-01</td>
                                            <th></th>
                                            <td></td>
                                        </tr>

                                        <tr>
                                            <th><%=p_bundle.getString("popup_text_title")%></th>
                                            <td colspan='3' id='id_popup_title'>설치가 잘 안됩니다.</td>
                                            
                                        </tr>
                                        <tr id='id_popup_cstext_tr'>
                                            <th><%=p_bundle.getString("popup_text_msg")%></th>
                                            <td colspan='3' id='id_popup_cstext'>temp<td>
                                        </tr>
                                        <tr id='id_popup_astext_tr'>
                                        <th><%=p_bundle.getString("popup_text_resp")%></th>
                                            <td colspan='3'>test<td>
                                        </tr>                                       
                                    </tbody>
                                </table>
                            </div>
                            <div style='text-align: center; margin-top:10px;' >
                            	<button id='id_popup_apply_btn' class="btn-list btn-search blue" onClick='FnEditApply();'><%=p_bundle.getString("asview_btn_mod")%></button>
                            </div>
							<!-- //상세리스트 -->


                </div>
				<!-- //pop-cont -->
            </div>
            <!-- //popup -->




        </div>
        <!-- //wrapper -->
        </div>
        <!-- //wrapper -->
    </body>
</html>
