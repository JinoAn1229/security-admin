<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Locale"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>

<%@ page import="common.util.EtcUtils" %>
<%@ page import="bsmanager.biz.BizAS" %>
<%@ page import="bsmanager.biz.BizAS.BizASRecord" %>
<%@ page import="bsmanager.dao.DaoASNote.DaoASNoteRecord" %>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord" %>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord" %>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord" %>
<%@ page import="wguard.dao.DaoCamera.DaoCameraRecord" %>
<%@ page import="common.util.UTF8ResourceBundle"%> 

<%@ include file="./include_session_check.jsp" %> 

<%

String p_strID = EtcUtils.NullS(request.getParameter("id"),"");
if(p_strID.isEmpty())
{
	response.sendRedirect("./sorry.jsp");
	return;
}

String p_strWinMode = EtcUtils.NullS(request.getParameter("win"));

JSONObject p_joAS = new JSONObject();

BizAS bizAS = new BizAS();
BizASRecord rAS = bizAS.getBizASRecord(p_strID, true);
if(rAS == null)
{
	response.sendRedirect("./sorry.jsp");
	return;
}


DaoSiteRecord rSITE = null;

//----------------
// user
JSONObject p_joUser = new JSONObject();
p_joUser.put("id",rAS.m_rUser.m_strID);
p_joUser.put("name",rAS.m_rUser.m_strName);
p_joUser.put("birth",rAS.m_rUser.m_strBirth);
p_joUser.put("sex",rAS.m_rUser.m_strSex.equals("man") ? "남" : "여");
p_joUser.put("rdate",EtcUtils.getStrDate(rAS.m_rUser.m_dateReg,"yyyy-MM-dd"));
p_joUser.put("exdate",EtcUtils.getStrDate(rAS.m_rUser.m_dateExpire,"yyyy-MM-dd"));
p_joUser.put("payst",new Date().after(rAS.m_rUser.m_dateExpire) ? "미납" : "");
p_joUser.put("addr1",rAS.m_rUser.m_strAddr1);
p_joUser.put("addr2",rAS.m_rUser.m_strAddr2);

p_joAS.put("user",p_joUser);

//------------------
// sensor
JSONObject joSensor = null;
JSONArray p_jaSensor = new JSONArray();
for(DaoSensorRecord rS : rAS.m_arySensor)
{
	rSITE = rAS.getSite(rS.m_strSTID);
	if(rSITE == null)
		continue;
	joSensor = new JSONObject();
	joSensor.put("sid",rS.m_strSID);
	joSensor.put("stname",rSITE.m_strSTName);
	joSensor.put("sname",rS.m_strSName);
	
	p_jaSensor.put(joSensor);
}
p_joAS.put("sensor",p_jaSensor);
//------------------
// Gate
JSONObject joGate = null;
JSONArray p_jaGate = new JSONArray();
for(DaoSiteRecord rG : rAS.m_arySite)
{
	
	joGate = new JSONObject();
	joGate.put("did",rG.m_strGID);
	joGate.put("stname",rG.m_strSTName);
	
	p_jaGate.put(joGate);
}
p_joAS.put("gate",p_jaGate);
//------------------
// Camera
JSONObject joCamera = null;
JSONArray p_jaCamera = new JSONArray();
for(DaoCameraRecord rC : rAS.m_aryCamera)
{
	rSITE = rAS.getSite(rC.m_strSTID);
	if(rSITE == null)
		continue;
	joCamera = new JSONObject();
	joCamera.put("mid",rC.m_strMID);
	joCamera.put("uid",rC.m_strUID);
	joCamera.put("cname",rC.m_strName);
	joCamera.put("stname",rSITE.m_strSTName);
	
	p_jaCamera.put(joCamera);
}
p_joAS.put("camera",p_jaCamera);

//------------------
// ASNote
JSONObject joASNote = null;
JSONArray p_jaASNote = new JSONArray();
for(DaoASNoteRecord rA : rAS.m_aryASNote)
{
	joASNote = new JSONObject();
	joASNote.put("seqid",rA.m_strSeqID);
	joASNote.put("text",rA.m_strText);
	joASNote.put("rdate",EtcUtils.getStrDate(rA.m_dateReg,"yyyy-MM-dd"));
	joASNote.put("wrid",rA.m_strWriterID);
	
	p_jaASNote.put(joASNote);
}
p_joAS.put("asnote",p_jaASNote);

//삭제하면 안됨. 아래 for문에서 사용 중!!
int i=0;   

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
        <link rel="stylesheet" href="css/view.css">
        <script src="js/jquery-1.12.1.min.js"></script>
        <script src="js/jquery-ui.min.js"></script>
        <script src="js/jquery.mCustomScrollbar.concat.min.js"></script>
        <script src="js/basic_utils.js"></script>
        <script src="js/date_util.js"></script>
<script>
// 화면 출력 개체 로딩
var j_jaASNote = <%=p_jaASNote.toString()%>;
$(document).ready(function(){
    // 팝업
    $('#id_date_asnote').datepicker({
    	dateFormat: "yy-mm-dd",
		changeMonth: true,
		dayNames: ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
		dayNamesMin: ['월', '화', '수', '목', '금', '토', '일'],
		monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],

    });
    $('#id_date_asnote').val(new Date().format('yyyy-MM-dd'));
    
    FnInitAsNote();
    
    //=====================================================
	// 팝업 지원  view.css에 id = popup 인엘리먼트 관련 정의 가 있다.
	/*  스크립트 함수 로 팝업함)
	$(".click-popup").click(function(e){
        e.preventDefault();
        $("#mask").fadeTo("fast",.5);
        $("#popup").fadeIn("fast");

		// init scrollbar
		$("#popup .list").mCustomScrollbar({});
		$("#popup .scrollable").mCustomScrollbar({
			axis:"x",
			scrollbarPosition:"outside"

		});
    });
	*/
	// 팝업 지원 
    $("#close-pop, #mask").click(function(){
        $("#mask").fadeOut("fast");
        $("#popup").fadeOut("fast",function(){
			// destroy scrollbar
			$("#popup .list").mCustomScrollbar("destroy");
			$("#popup .scrollable").mCustomScrollbar("destroy");
		});
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


function FnInitAsNote()
{
	$('#id_list_asnote').empty();
	var elmtUL = $('#id_list_asnote');
	var joA = null;
	var sLI = "";
	var sSeq = "";
	// <li> <div class="asDate">2017-05-06</div> <div class='asText'>텍스트 셈플</div> <button type="button" >수정</button> </li>
	
	for(var i = 0; i < j_jaASNote.length ; i ++)
	{
		joA = j_jaASNote[i];
		sSeq = joA['seqid'];
		
		sLI = "<li> <div class='asDate'>" + joA['rdate'] + "</div> <div class='asText' id='" +sSeq+"'>" 
		      + joA['text'] + "</div> <button type='button' onClick='FnOnClickModifyText(\""+ sSeq +"\")'>" + '<%=p_bundle.getString("asview_btn_mod")%>' + "</button></li>";
		//alert(sLI);      
		elmtUL.append(sLI);	      
	}
}

function FnAddAsNote(joA)
{
	var sLI = "";
	var sSeq = joA['seqid'];
	
	sLI = "<li> <div class='asDate'>" + joA['rdate'] + "</div> <div class='asText' id='" +sSeq+"'>" 
    + joA['text'] + "</div> <button type='button' onClick='FnOnClickModifyText(\""+ sSeq +"\")'>" + '<%=p_bundle.getString("asview_btn_mod")%>' + "</button></li>";
    $('#id_list_asnote').append(sLI);
    j_jaASNote.push(joA);
}

function FnModAsNote(sSeqID, ModText)
{
	var joA = null;
	
	for(var i = 0; i < j_jaASNote.length ; i ++)
	{
		joA = j_jaASNote[i];
		if(joA['seqid'] == sSeqID)
		{
			joA['text'] = ModText;
			j_jaASNote[i] = joA;
            break;
		}
			
	}
	
}

function FnFindAsNote(sSeqID)
{
	var joA = null;
	// <li> <div class="asDate">2017-05-06</div> <div class='asText'>텍스트 셈플</div> <button type="button" >수정</button> </li>
	for(var i = 0; i < j_jaASNote.length ; i ++)
	{
		joA = j_jaASNote[i];
		if(joA['seqid'] == sSeqID)
			return joA;
	}
	return null;
}


// 관리기록 수정 클릭
function FnOnClickModifyText(sSeqID)
{
	var joA = FnFindAsNote(sSeqID)
	if(joA == null)
	{
		alert('NOT FOUND : ' + sSeqID);
		return ;
	}
	
	//---------------------------
	// 팝업창 내용 설정
	$('#id_popup_name').text('<%=p_joUser.optString("name")%>');
	$('#id_popup_id').text('<%=p_joUser.optString("id")%>');
	$('#id_popup_date').text(joA.rdate);
	$('#id_popup_wrid').text(joA.wrid);
	$('#id_popup_text').val(joA.text);
	$('#id_popup_seqid').val(joA.seqid);
    
	
	//-------------------------------
	// 팝업창 띄우기
	$("#mask").fadeTo("fast",.5);
    $("#popup").fadeIn("fast");

	// init scrollbar
	$("#popup .list").mCustomScrollbar({});
	$("#popup .scrollable").mCustomScrollbar({
		axis:"x",
		scrollbarPosition:"outside"
	});	
	
}

// 기록 수정용 POPUP 창에서 수정 버튼을 클릭했다.
function FnOnClickSaveAtPopup()
{
	//-----------------------------------------------------------------------------------추가
	var sText = $('#id_popup_text').val();
	var joReqMod = {};
	joReqMod['cmd'] = 'mod';
	joReqMod['seqid'] = $('#id_popup_seqid').val();
	joReqMod['rdate'] = $('#id_popup_date').val();
	joReqMod['text'] = sText;
	joReqMod['wrid'] = '<%=p_strSessionID%>';
	joReqMod['userid'] = '<%=p_joUser.get("id")%>';
	
	$.ajax(
	{
   		 type: "POST",  
   		 url: './query/query_asview_update.jsp',
   		 data: JSON.stringify(joReqMod),
   		 dataType: 'json',
   		 async: false,
   		 success: function(root,status,xhr)
   		 {
   			if(status == "success")
   			{
    			//var joRoot =  JSON.parse(root);
    			var joRoot = root;
    			if(joRoot.result =="OK")
    			{
    				FnModAsNote(joReqMod['seqid'],joReqMod['text']);
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
	
	//====================================================================================여기까지
	// popup 창 닫기
    $("#mask").fadeOut("fast");
    $("#popup").fadeOut("fast",function(){
		// destroy scrollbar
		$("#popup .list").mCustomScrollbar("destroy");
		$("#popup .scrollable").mCustomScrollbar("destroy");
	});
	
	FnInitAsNote();  //바꾼부분	
}

//기록 수정용 POPUP 창에서 취소  버튼을 클릭했다.
function FnOnClickCancelAtPopup()
{
	// popup 창 닫기
    $("#mask").fadeOut("fast");
    $("#popup").fadeOut("fast",function(){
		// destroy scrollbar
		$("#popup .list").mCustomScrollbar("destroy");
		$("#popup .scrollable").mCustomScrollbar("destroy");
	});
}

//관리기록  신규 입력
function FnOnClickSaveNewText()
{
	var sText = $('#id_textarea_new').val();
	var joReq = {};
	joReq['cmd'] = 'new';
	joReq['seqid'] = '';
	joReq['rdate'] = $('#id_date_asnote').val();
	joReq['text'] = sText;
	joReq['wrid'] = '<%=p_strSessionID%>';
	joReq['userid'] = '<%=p_joUser.get("id")%>';
	
	$.ajax(
	{
   		 type: "POST",  
   		 url: './query/query_asview_update.jsp',
   		 data: JSON.stringify(joReq),
   		 dataType: 'json',
   		 async: false,
   		 success: function(root,status,xhr)
   		 {
   			if(status == "success")
   			{
    			//var joRoot =  JSON.parse(root);
    			var joRoot = root;
    			if(joRoot.result =="OK")
    			{
    				var joA = joRoot.asnote;
    				FnAddAsNote(joA)
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

// 오픈 모드에 따라 (파라메터 win=xxx) 닫는 방법응 달리한다.
function FnBackPage()
{
	<%
		if(p_strWinMode.isEmpty())
		{
			out.println("history.back();");
		}
		else
		{
			out.println("window.close();");
		}
	%>
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
                <div id="contents" style="padding-left:0px;">
                    <div class="container">
                        <h3 class="tit-list"><%=p_bundle.getString("asview_title")%></h3>

                        <div class="list-wrap">
                            <h4 class="dist-list"><%=p_bundle.getString("asview_text_basic_info")%></h4>


							<!-- 상세리스트 -->
                            <div class="list-view">
                              <table class="outer" summary="">
                                <caption>상세 리스트 </caption>
                                <colgroup>
                                <col style="width:120px">
                                <col style="width:*">
                                <col style="width:120px">
                                <col style="width:*">
                                <col style="width:120px">
                                <col style="width:*">
                                </colgroup>
                                <tbody>
                                  <tr>
                                    <th><%=p_bundle.getString("asview_text_name")%></th>
                                    <td><%=p_joUser.optString("name")%></td>
                                    <th><%=p_bundle.getString("asview_text_ID")%></th>
                                    <td><%=p_joUser.optString("id")%></td>
                                    <th><%=p_bundle.getString("asview_text_birth")%></th>
                                    <td><%=p_joUser.optString("birth")%></td>
                                  </tr>
                                  <tr>
                                    <th><%=p_bundle.getString("asview_text_sex")%></th>
                                    <td><%=p_joUser.optString("sex")%></td>
                                    <th><%=p_bundle.getString("asview_text_reg_date")%></th>
                                    <td><%=p_joUser.optString("rdate")%></td>
                                    <th></th>
                                    <td></td>
                                  </tr>
                                  <tr>
                                    <th><%=p_bundle.getString("asview_text_addr")%></th>
                                    <td colspan="3"><%=p_joUser.optString("addr1") + " " + p_joUser.optString("addr2")%></td>
                                    <th>&nbsp;</th>
                                    <td>&nbsp;</td>
                                  </tr>
                                  <tr>
                                    <th><%=p_bundle.getString("asview_text_sensorID")%></th>
                                    <td colspan="5">
									<ul class="file-list type2">
									<li class="file-cont">
									<ul style="margin-left:20px;">
									<%
									// <li>EAFD123123123 (우리집 - 현관1)</li>
									{
										JSONObject joS = null;
										for(i = 0 ; i < p_jaSensor.length(); i ++)
										{
											joS =  (JSONObject)p_jaSensor.get(i);
											out.println("<li>" + joS.optString("sid") + " (" + joS.optString("stname") +" - " +joS.optString("sname") + ")</li>");
										}
									}
									%>
									</ul>	
									</li>	
									</ul>									
									</td>
                                  </tr>

                                  <tr>
                                    <th><%=p_bundle.getString("asview_text_gateID")%></th>
                                    <td colspan="7">
									<ul class="file-list type2">
									<li class="file-cont">
									<ul style="margin-left:20px;">
									<%
									// <li>EAFD123123123 (회사1)</li>
									{
										JSONObject joG = null;
										for(i = 0; i < p_jaGate.length(); i ++)
										{
											joG =  (JSONObject)p_jaGate.get(i);
											out.println("<li>" + joG.optString("did") + " (" + joG.optString("stname") + ")</li>");
										}
									}
									%>
									</ul>	
									</li>	
									</ul>									
									</td>
                                  </tr>
                                  <tr>
                                    <th><%=p_bundle.getString("asview_text_cameraID")%></th>
                                    <td colspan="7"><!-- 파일업로드 type2 -->
                                        <ul class="file-list type2">
                                          <li class="file-cont">
                                            <ul>
                                            	<%
												// <li> <span style="width:50%; text-align:left; margin-left:20px;">BS2135487987654 (거실카메라) </span> <span style="text-align:left">CHINA123123123123</span> </li>
												{
													JSONObject joC = null;
													for(i = 0; i < p_jaCamera.length(); i ++)
													{
														joC =  (JSONObject)p_jaCamera.get(i);
														out.println("<li> <span style='width:50%; text-align:left; margin-left:20px;'>" + joC.optString("mid") + " (" + joC.optString("stname") + " - " + joC.optString("cname") + ")</span>");
													}
												}
												%>
                                            </ul>
                                          </li>
                                        </ul>
                                      <!-- //파일업로드 type2 --></td>
                                  </tr>
                                  <tr>
                                    <th><%=p_bundle.getString("asview_text_management")%></th>
                                    <td colspan="7" class="">
									<ul class="file-list type2">
                                          <li class="file-head"> 
										   <span style="width:120px; text-align:left; margin-left:20px;"><%=p_bundle.getString("asview_text_date")%></span>
										   <span style="text-align:left"><%=p_bundle.getString("asview_text_msg")%></span>										   
										   </li>
                                          <li class="file-cont ">
										  <div class="asliStyle ">
                                            <ul id='id_list_asnote'>
												<!-- //  
												<li> <div class="asDate">2017-05-06</div> <div class="asText" id='ASXXXX_XXXX'>텍스트 셈플</div> <button type="button" >수정</button> </li>
												스크립트  FnInitAsNote()에서 초기화 함
												
												-->

                                            </ul>
											</div>
                                          </li>
                                        </ul>
                                      </td>
                                  </tr>
                                  <tr>
                                    <th><%=p_bundle.getString("asview_text_input")%></th>
                                    <td colspan="7">
									<div style="width:100px; float:left; margin-right:20px;">
										<input type="text" class="datepicker" id='id_date_asnote' readonly placeholder="날짜선택" style="width:100px;">
									</div>
									<div style="width:800px; float:left;" >
										<textarea name="" id="id_textarea_new" maxlength='1024' onkeyup='return checkMaxLength(this)'><%=p_bundle.getString("asview_text_input")%></textarea>
									</div>
									</td>
                                  </tr>
                                </tbody>
                              </table>
                            </div>
							<!-- //상세리스트 -->

                            <div class="list-btn-wrap">
                                <button type="button" class="btn-list gray"  onclick="FnBackPage();"><%=p_bundle.getString("asview_btn_list")%></button>
                                <button type="button" class="btn-list blue" onclick='FnOnClickSaveNewText();'><%=p_bundle.getString("asview_btn_save")%></button>
                            </div>

                        </div>
                        <!-- // 리스트 영역 -->

                    </div>
                    <!-- // container -->

                </div>
                <!-- // contents -->
            </div>
            <!-- //content-wrap -->
            <footer>
                1500*50
            </footer>
            <!-- // footer -->

			<!-- popup 작성 목록 수정 -->
            <div id="mask"></div>
            <div id="popup" style='position:fixed;top=110px;'>
                <div class="pop-head">
                    <p><%=p_bundle.getString("popup_title")%></p>
                    <span id="close-pop"></span>
                </div>
                <div class="pop-cont">
 				<!-- 상세리스트 -->
                            <div class="list-view">
                                <table class="outer" summary="">
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
                                            <input type="hidden" id='id_popup_seqid' value=""> 
                                        </tr>
                                        <tr>
                                            <th><%=p_bundle.getString("popup_text_write_date")%></th>
                                            <td id='id_popup_date'>2016-07-01</td>
                                            <th><%=p_bundle.getString("popup_text_manager")%></th>
                                            <td id='id_popup_wrid'></td>
                                        </tr>

                                        <tr>
                                            <th><%=p_bundle.getString("popup_text_msg")%></th>
                                            <td colspan="3"><textarea name="" id="id_popup_text" maxlength='1024' onkeyup='return checkMaxLength(this)'><%=p_bundle.getString("asview_text_input")%></textarea></td>
                                        </tr>

                                    </tbody>
                                </table>
                                <div class="list-btn-wrap"  style="magin-top:10px">
                                    <button type="button" class="btn-list gray" onclick='FnOnClickCancelAtPopup()'>Cancel</button>
                                	<button type="button" class="btn-list blue" onclick='FnOnClickSaveAtPopup()'><%=p_bundle.getString("asview_btn_save")%></button>
                            	</div>
                            </div>
							<!-- //상세리스트 -->


                </div>
				<!-- //pop-cont -->
            </div>
            <!-- //popup -->
            
        </div>
        <!-- //wrapper -->
    </body>
</html>


