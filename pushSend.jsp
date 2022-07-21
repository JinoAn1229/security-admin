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
		  <style> 
		  #id_list_checked div    {display:inline-block;margin-left:5px; width:80%;}
		  #id_list_checked button {display:inline-block;width:30px;height:18px;line-height:15px;padding:0 0;margin-left:10px;color:#666;text-align:center;border:1px solid #aaa;}
		  </style>
		         
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
    	    $(".tbl-checked").mCustomScrollbar();
     		j_nDispPageNum = 1;
     		
     		// 세션 PUSH 후보 리스트 세션 초기화
     		FnClearPushCheckedCache();
    		clearListTable();
    		
			// 기본 1개월 검색
			FnSetSearchDate(30);
			resetListTable();
			FnSetLeftMenu();
     	});
         
       	var	j_nDispPageNum = 1;  // 현재 페이지 번호(1base) 
   		var j_sSearchType = 'param'; // select box에서 선택하지 못한 조건(nopay)이 있어서, 별도로 관리한다 
       	//==================================
       	// 목록 갱신
       	 function resetListTable()
       	 {
       		
        	var joReq = FnMakeCheckedPUSH();
        		
       		var nListPerPage = $('#id_selectbox_count_per_page option:selected').val();
       		
       		// lpp 페이지에 표시할 리스트의 최대 갯수(List Per Page))
       		// pg 현재 페이지 번호(1base)
       		//var sPageParam = "pg=" + j_nDispPageNum +"&lpp=" + nListPerPage;
       		joReq['pg'] = '' + j_nDispPageNum;
       		joReq['lpp'] = '' + nListPerPage;
       		
       		var sSearchParam = "";
       		
 			joReq['qtype'] = j_sSearchType;
     		if(j_sSearchType == 'nopay')
     			joReq['sval'] = "";
     		else // if(j_sSearchType == 'param')
     		{
          		var sSearchValParam = "";
          		var sSearchDateParam = "";

          		var sSearchValue = $('#id_value_search').val().trim();
          		var bAndDate = $('#id_chkbox_date_and').is(':checked');
          		var bSearchValue = checkValue(sSearchValue);
          		if(!bSearchValue && !bAndDate)
        		{
          			alert('검색 조건 부족');
          			return; 		
        		}
      			joReq['dtand'] = 'false';
          		if(bAndDate)
          		{
          	  		var sDateStart = $('#id_date_search_start').val();
          	  		var sDateEnd = $('#id_date_search_end').val();
          			if(!checkValue(sDateStart) || !checkValue(sDateEnd))
          			{
          	  			alert('검색 조건 부족');
          	  			return; 		
          			}

          			joReq['dtand'] = 'true';
          			joReq['dates'] = sDateStart;
          			joReq['datee'] = sDateEnd;
          		}
          		
      			joReq['stype'] = 'none';
          		if(bSearchValue)
          		{
              		var sSearchType = $('#id_search_type').val();
              	  	var sSearchValue = $('#id_value_search').val().trim();
          			sSearchValParam = "stype=" + sSearchType + "&sval=" + sSearchValue;
          			joReq['stype'] = sSearchType;
          			joReq['sval'] = sSearchValue;
          		}
          		
     		}
       		
       		var strQuery = "./query/query_pushSend_list.jsp"
 
       		$.ajax(
       		{
	       		 type: "POST",  
	       		 url: strQuery,
	       		 data: JSON.stringify(joReq),
	       		 dataType: 'json',
	       		 async: false,
	       		 success: function(root,status,xhr)
	       		 {
	       			if(status == "success")
	       			{
	        			clearListTable();
	        			
	        			//var joRoot =  JSON.parse(root);
	        			joRoot = root;
	        			if(joRoot.result =="OK")
	        			{
		          			var aryRecord =  joRoot.members;
		          			$('#id_total_count').text("" + root.tot_count);
		         			for(var i = 0; i < aryRecord.length; i ++)
		         			{
		         				objItem = aryRecord[i];
		         				addListTable(i,objItem);
		         		 	}
		         			
		         			// 이전 업로드된 파일 리스트 삭제 지원 속성 설정
		         			$("#id_list_member tr").mouseover(function(){
		         				j_nMemberTableCurRowIdx = $(this).index(); 
		         			});
		         			
		         			// 멤버의 push 선택 상태 설정 
		          			var aryChkPush =  root.chkPUSH;
		            		for(var i = 0; i < aryChkPush.length; i ++)
		         			{
		         				objItem = aryChkPush[i];
		         				FnSetPushCheckedView(objItem.id,objItem.checked,true);
		         		 	}
		         			// 페이지 네비게이션 
		         			$("#id_page_navi").html(root.PageNavi);
	        			}
	       			}
	       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
	       			{
	       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
	       			}
	       	    },
	       	    error:function(data,status,error)
	       	    {
	   				alert('[fail] status:'+status+ '  / error:' + error + ' / message:' + data.responseText); 	
	       	    }
	       	    
       		}); 
       	
       	 }
       	
       	
       	 function clearListTable()
       	 {   // table 은 thead, tbody 구분되어 만들어져 있어야 함
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
       		 

       		 $('#id_list_checked').html("");
           	 FnUpdatePushCandiCount();
       	 }
       	 
       	 
       	 var j_nMemberTableCurRowIdx = 0;
       	 function addListTable(nIdx,jM)
       	 {  
           var sSex = "남"; 
           if(jM.sex !="woman") sSex = "남";
/*
      <tr>
       <td><input name="checkbox10" type="checkbox"></td>
         <td>1266</td>
         <td>홍길동</td>
         <td>aaa@aaa.com</td>
         <td>경기도 부천시 XXX구 XXX로 888 (XXX1동) XXX-85 </td>
     </tr>
*/
			var sChkID = "id_chkpush_" + nIdx;
       	    var tr_html = "<tr>"
       	                  + "<td><input id='" + sChkID + "' type='checkbox' onClick='FnMemberPushCheckClicked(this);'></td>"
       	                  + "<td>" + jM.no +"</td>"
       	                  + "<td>" + jM.name +"</td>"
       	                  + "<td>" + jM.id + "</td>"
       	            	  + "<td>" + jM.addr + "</td>"
       				  + "</tr>";
   				  
       		$('#id_list_member >tbody:last').append(tr_html);

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
       	// 조회버튼을 클릭했다.
       	function FnSearchMemberList()
       	{
         //  파라메터 리스트
       	// pg : 리스트를 보여풀 페이지 번호
       	// lpp: 한페이지에 보여줄 리스트 갯수
       	// stype : 검색조건 형식, 
     	//  	     name  :   sval 파라메터로 회원 이름 이 전달된다.
     	//  	     id       :   sval 파라메터로 회원 ID가 전달된다.

       		j_sSearchType = 'param';
     		j_nDispPageNum = 1;
     		resetListTable();
       	}
       	//--------------------------
       	// 미납자 조회를 클릭했다.
       	function FnSearchNoPayMemberList()
       	{
         //  파라메터 리스트
       	// pg : 리스트를 보여풀 페이지 번호
       	// lpp: 한페이지에 보여줄 리스트 갯수
       	// stype : nopay 전달
     	    j_sSearchType = 'nopay';		
     		j_nDispPageNum = 1;
     		resetListTable();
       	}
       	
       	//===============================
       	// push 선택 관리
       	function FnMemberPushCheckClicked(elmtChk)
       	{  // 화면의 회원 리스트에서 , push 후보 선택여부  checkbox를 틀릭했다.
      	
			//var sChkID =  "#id_chkpush_" + (j_nMemberTableCurRowIdx);
			//var bChecked = $(sChkID).is(":checked");
			//var elmtTR = $('#id_list_member >tbody>tr:eq(' + j_nMemberTableCurRowIdx + ')');
			
			var bChecked = $(elmtChk).is(":checked");
			var elmtTR = $(elmtChk).parent().parent();
       		var jM = elmtTR.data('tag');
       		//alert("elmtTR index() : " +  elmtTR.index() + " CurRow:" + j_nMemberTableCurRowIdx);
       		//alert(JSON.stringify(jM));
			
       		if(bChecked)
			{
				 FnAddPushCandidate(jM);
			}
			else
			{
				FnRemovePushCandidateByTagID(jM.id);	
			}

       	}
       	
       	//-----------------------------------
       	// 페이지 가 변경되거나 할 때, 리스트를 재요청 하기 전에 
       	// 먼저 호출할 필요가 있다.
       	// 세션과 화면과의 PUSH 후보리스트를 동기화 한다.
       	function FnUpdateSessionCheckedPUSH()
       	{
       		var sURL = './query/query_pushChecked_item.jsp';
       		var joChkPUSH = FnMakeCheckedPUSH();
       		var sData = JSON.stringify(joChkPUSH);
       		$.ajax({
          		 type: "POST",  
          		 url: sURL,
          		 data: sData,
          		 dataType: 'json',
          		 async: false,
          		 success: function(root,status,xhr)
	       		 {
	       			if(status == "success")
	       			{
	         			// 멤버의 push 선택 상태 설정 
	         			//var joRoot = JSON.parse(data);
	         			
	         			
	         			var joRoot = root;
	          			var aryChkPush =  joRoot.chkPUSH;
	         			var objItem = null;
	            		for(var i = 0; i < aryChkPush.length; i ++)
	         			{
	         				objItem = aryChkPush[i];
	         				FnSetPushCheckedView(objItem.id,objItem.checked,true);
	         		 	}
	            		
	       			}
	       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
	       			{
	       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
	       			}
	       		},
		        error:function(request,status,error)
		        { 
					//$('#id_status').text("[error] status:"+status+" / "+"message:"+request.responseText+" / "+"error:"+error); 
					alert("[error] status:"+status+ '/ error:'+error); 
		        } 
       		});
       	}
       	
       	// 현재 회원 리스트에서 checked 상태 값을 JSON개체로 로드한다.
       	// 이개테는 세션상태를 갱신하기위해 이용 할 것이다.
       	function FnMakeCheckedPUSH()
       	{
       		var aryMember = $('#id_list_member >tbody>tr');
       		var sChkID = "";
       		var elmtCB = null;
       		var bChecked = null;
       		var tagM = null;
       		
       		var joChkReqCmd = {};
       		var jaChkPUSH = [];
       		var joChkPUSH = null;
       		joChkReqCmd['cmd'] ='update';
       		for(var i = 0; i < aryMember.length ; i ++)
       		{
       			sChkID =  "#id_chkpush_" + i;
       			elmtCB = $(sChkID);
       			bChecked = elmtCB.is(':checked');
       			tagM = $(aryMember[i]).data('tag');
       			joChkPUSH = {};
       			joChkPUSH['id'] = tagM.id;
       			joChkPUSH['value'] = "";
       			joChkPUSH['checked'] = bChecked;
       			jaChkPUSH.push(joChkPUSH);
       		}
       		joChkReqCmd['chkPUSH'] = jaChkPUSH;
       		
       		return joChkReqCmd;
       	}
       	
       	// push후보  모두 취소 요청 ( session에서 제거)
       	function FnClearPushCheckedCache()
       	{
    		// 선택사례 취소 요청 ( session에서 제거)
    		var jaChkPUSH = [];
    		var joReq = new Object();
			joReq['cmd'] = "clear";
			joReq['chkPUSH'] = jaChkPUSH;
    		var sURL = "./query/query_pushChecked_item.jsp";
    		var sData =  JSON.stringify(joReq);
			
    		// alert(sData);
       		$.ajax({
          		 type: "POST",  
          		 url: sURL,
          		 data: sData,
          		 dataType: 'json',
          		 async: false,
          		 success: function(root,status,xhr)
	       		 {
	       			if(status == "success")
	       			{
	       	    		// 화면 Checked 모두 클리어 
	       	     		FnClearPushCheckedView();
	       			}
	       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
	       			{
	       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
	       			}
	       		},
		        error:function(request,status,error)
		        { 
					//$('#id_status').text("[error] status:"+status+" / "+"message:"+request.responseText+" / "+"error:"+error); 
					alert("[error] status:"+status+ '/ error:'+error); 
		        } 
       		});
       	}
       	
        // push후보  전체 취소 요청 ( 브라우저 화면에서 제거)
       	function FnClearPushCheckedView()
       	{
       	   // Push후보 목록 (id_list_checked) 모두 제거
       		$('#id_list_checked').html("");
       		
       		var aryMember = $('#id_list_member >tbody>tr');
       		var sChkID = "";
       		for(var i = 0; i < aryMember.length ; i ++)
       		{
       			sChkID =  "#id_chkpush_" + i;
       			var elmtCB = $(sChkID);
       			elmtCB.attr('checked',false);
       		}
          	FnUpdatePushCandiCount();
       	}
        
        // push후보 선택 지정( 회원 목록 checked 결정, push 후보 목록으로 추가 / 삭제)
        // bUpdatePushCandi 는 호보목록 테이블 에도 반영할지 여부
       	function FnSetPushCheckedView(sID,bChecked,bUpdatePushCandi)
       	{
        	// Push후보 목록 (id_list_checked) 에서 
       		if(!bChecked && bUpdatePushCandi)
       		{  // 만약 있다면 제거
       			FnRemovePushCandidateByTagID(sID);
       		}
       		
        	var tagM = null;
			// 선택 상태 설정/해제	
       		var aryMember = $('#id_list_member >tbody>tr');
       		var sChkID = "";
       		var elmtMemberTR = null;
       		for(var i = 0; i < aryMember.length ; i ++)
       		{
       			tagM = $(aryMember[i]).data('tag');

	   			if(tagM.id == sID)
    			{
    				sChkID =  "#id_chkpush_" + i;
    				$(sChkID).attr('checked',bChecked);
    				elmtMemberTR = aryMember[i];
    				break;
    			}
       		}
       		
        	// Push후보 목록 (id_list_checked) 
       		if(bChecked && elmtMemberTR != null && bUpdatePushCandi)
       		{  // 만약 없다면 추가
       			var bFound = false;
       			var aryChecked = $('#id_list_checked >li').html("");
	       		for(var i = aryChecked.length-1; i >= 0 ; i --)
	       		{
	       			if($(aryChecked[i]).data('tag').id == sID)
	       			{
	       				bFound = true;
	       				break;
	       			}
	       		}
	       		
	       		if(!bFound)
	       		{
	       			FnAddPushCandidate(tagM);
	       		}
       		}
       	}
        
    	// Push후보 목록 (id_list_checked) 에 추가
        function FnAddPushCandidate(tagM)
        {
        	//alert(JSON.stringify(tagM));
        	// button 속성은   #id_list_checked button {} 스타일 참조
//        	var li_html = "<li><div>" + tagM.name + "(" + tagM.id+ ")</div><button type='button' onClick='FnRemovePushCandidateByClick(this);'>x</button></li>"; 
        	var li_html = "<li><div>" + tagM.name + "(" + tagM.id+ ")</div><button type='button' style='margin-left:30px;width:30px; color:red; vertical-align:middle;' onClick='FnRemovePushCandidateByClick(this);'>x</button></li>"; 


        	$("#id_list_checked").append(li_html);
        	var elmtLI = $("#id_list_checked >li:last");
        	
        	elmtLI.data('tag',tagM);
          	FnUpdatePushCandiCount();
        }
        
    	// Push후보 목록 (id_list_checked)에서 클릭된 TR 삭제
        function FnRemovePushCandidateByClick(btnLI)
        {
        	var elmtLI = $(btnLI).parent();
			var tagM = elmtLI.data('tag');
			elmtLI.remove();
        	FnUpdatePushCandiCount();

        	FnSetPushCheckedView(tagM.id,false,false);
        }
    	
    	// Push후보 목록 (id_list_checked)에서 ID로 TR 삭제
       	function FnRemovePushCandidateByTagID(sID)
       	{
       		var aryLI = $('#id_list_checked >li');
       		var tagM = null;
       		for(var i = aryLI.length-1; i >= 0; i -- )
       		{
       			tagM = $(aryLI[i]).data('tag');
				if(tagM.id == sID)
				{
					aryLI[i].remove();	
					break;	
				}
       		}
       		FnUpdatePushCandiCount();
       	}
    	
    	// PUSH 후보자 목록 갯수 표시 갱신
    	function FnUpdatePushCandiCount()
    	{
       		var aryLI = $('#id_list_checked >li');
		   	$('#id_pushcandi_count').text('' + aryLI.length);
    	}
    	
    	//---------------------------------------
    	// 목록 초기화 버튼을 클릭했다.
    	function FnClearCheckedPushList()
    	{
    		// 세션 초기화
     		FnClearPushCheckedCache();

    	}
    	
    	//----------------------------
    	// 메시지  전송 버튼을 클릭했다.
    	function FnSendPushMessage()	
    	{
    		// PUSH 전송 목록 세션 동기화 시키고
    		FnUpdateSessionCheckedPUSH();
    		
       		var joReq = {};
       		var sMessage = $('#id_push_msg').val();
       		
       		if(!checkValue(sMessage))
       		{
       			alert("보낼 메시지를 입력하세요");
       			return ;
       		}
       		joReq['message'] = sMessage;
			alert(JSON.stringify(joReq));
      		var sURL = "./query/query_pushSend_message.jsp";
       		var sData = JSON.stringify(joReq);
       		$.ajax({
          		 type: "POST",  
          		 url: sURL,
          		 data: sData,
          		 dataType: 'json',
          		 async: false,
          		 success: function(root,status,xhr)
	       		 {
	       			if(status == "success")
	       			{
	       				if(root.result == "OK")
	       				{  // 모두 보냈으므로, 기존 선택 상태 모두 해제
	       					FnClearPushCheckedView();
	       				}
	       			}
	       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
	       			{
	       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
	       			}
	       		},
		        error:function(request,status,error)
		        { 
					//$('#id_status').text("[error] status:"+status+" / "+"message:"+request.responseText+" / "+"error:"+error); 
					alert("[error] status:"+status+ '/ error:'+error); 
		        } 
       		});

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
                        <h3 class="tit-list"><%=p_bundle.getString("pushSend_title")%></h3>
						<div style="width:65%;float:left;">
                        <div class="search-wrap">
                            <ul>
                                <li>
                                    <div class="dist"><%=p_bundle.getString("search_text_Detail")%></div>
                                    <div class="dist-cont">
										<div style="float:left;">
                                        <select name="" id="id_search_type">
                                            <option value="name"><%=p_bundle.getString("search_menu_name")%></option>
                                            <option value="id"><%=p_bundle.getString("search_menu_ID")%></option>
                                        </select>

                                        <input type="text" id='id_value_search' value='' class="wide-input">
										</div>
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
                                        <p>
                                        	<input type='checkbox'  id='id_chkbox_date_and'  style='margin-left:40px;' onClick='FnSearchDateAnd()'> <label for='id_chkbox_date_and'><%=p_bundle.getString("search_check_text_and")%></label>
                                        </p>
                                    </div>
                                </li>
                                <li style="text-align:center;">
									<button class="btn-list btn-search blue" style="margin-left:300px;" onClick='FnSearchMemberList();'><%=p_bundle.getString("search_btn_text")%></button>
                                </li>
<!--		                                <li>
                                    <div class="dist">미납회원조회</div>
                                    <div class="dist-cont">
										<button class="btn-list btn-rowsearch blue" onClick='FnSearchNoPayMemberList();'>미납회원 조회</button>
                                    </div>
                                </li>-->
                            </ul>
                        </div>
                        <!-- // 조회영역 -->

                        <div class="list-wrap" style="margin-top:30px;">
                            <span class="list-count" ><em id="id_total_count">0</em><%=p_bundle.getString("search_text_count")%></span>
                            <select name="" id="id_selectbox_count_per_page" class="">
                                <option value="10"><%=p_bundle.getString("search_text_view_count_10")%></option>
                                <option value="20"><%=p_bundle.getString("search_text_view_count_20")%></option>
                            </select>


                            <div class="list-def">
                                <div class="tbl-head">
                                    <table summary="">
                                        <caption>리스트head</caption>
                                        <colgroup>
                                            <col style="width:6%">
                                            <col style="width:8%">
                                            <col style="width:15%">
                                            <col style="width:20%">
                                            <col style="width:*">
                                        </colgroup>

                                        <thead>
                                            <tr>
                                              	<th><input name="checkbox11" type="checkbox"></th>
                                                <th><%=p_bundle.getString("table_header_NO")%></th>
                                                <th><%=p_bundle.getString("table_header_name")%></th>
                                                <th><%=p_bundle.getString("table_header_ID")%></th>
                                                <th><%=p_bundle.getString("table_header_addr")%></th>
                                            </tr>
                                        </thead>
                                    </table>
                                </div>
								<!-- // table-head -->
                                <div class="tbl-body">
                                    <table id='id_list_member'>
                                        <caption>리스트body</caption>
                                        <colgroup>
                                            <col style="width:6%">
                                            <col style="width:8%">
                                            <col style="width:15%">
                                            <col style="width:20%">
                                            <col style="width:*">
                                        </colgroup>
                                        <tbody>
                                             <tr>
                                              <td><input name="checkbox10" type="checkbox"></td>
                                                <td>1266</td>
                                                <td>기본값</td>
                                                <td>aaa@aaa.com</td>
                                                <td>경기도 부천시 XXX구 XXX로 888 (XXX1동) XXX-85 </td>
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
						<div style="width:33%;float:right;">
						<span class="list-count"><em id="id_pushcandi_count">1266</em><%=p_bundle.getString("pushsend_text_user_selete")%></span>
							<div style="overflow:auto;height:110px; border:#CCCCCC 1px solid; padding:10px; margin-bottom:20px;">
								<ul id='id_list_checked'>
									<!--  셈플 ( id_list_checked 로 접근하는 스크립트 함수를 살표 볼것 
									  li><div style='display:inline;'>홍길동(ceo@blakston.co.kr)</div><button type='button' style='margin-left:30px;width:30px; color:red; vertical-align:middle;'>x</button></li -->
								</ul>	
							</div>	
								
						 <div style="margin:auto 0; float:right;" class="search-wrap">
						 	<div class="dist-cont"><button class="btn-list btn-rowsearch blue" onClick='FnClearCheckedPushList()'><%=p_bundle.getString("pushsend_btn_list_del")%></button></div>
						 </div>
						 <textarea id='id_push_msg' rows="8" style="width:100%;height:100%; margin-top:20px;" maxlength='64' onkeyup='return checkMaxLength(this)'><%=p_bundle.getString("pushsend_text_send_msg")%></textarea>
						 <div style="margin:auto 0; float:right;" class="search-wrap">
						 	<div class="dist-cont"><button class="btn-list btn-rowsearch blue" onClick='FnSendPushMessage()'><%=p_bundle.getString("pushsend_btn_send_msg")%></button></div>
						 </div>
						 
						</div>
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
