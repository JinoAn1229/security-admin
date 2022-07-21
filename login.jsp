<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="bsmanager.dao.DaoManager" %> 

<%!
public DaoManager.DaoManagerRecord checkLogin(String id, String pw) 
{
	DaoManager DaoManager = new DaoManager();
	return DaoManager.checkLogin(id,pw);
 }
%>  

<%
HttpSession loginsession = request.getSession(true); // true : 없으면 세션 새로 만듦

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-------------------------------------

String p_strOKResponse = "memberList.jsp";
String strID = EtcUtils.NullS(request.getParameter("id"));
String strPW = EtcUtils.NullS(request.getParameter("pw"));

DaoManager.DaoManagerRecord rUser = null;
boolean p_bLogin = false;
try
{
	rUser = checkLogin(strID,strPW);
	if (rUser != null )
	{
		loginsession.setAttribute("ID", strID);
		loginsession.setAttribute("NAME",rUser.m_strName);
		p_bLogin = true;
	}
}
catch(Exception e)
{
}

if(p_bLogin)
{
	response.sendRedirect(p_strOKResponse);
	return ;
}
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
        <script src="js/basic_utils.js"></script>
        <script src="js/date_util.js"></script>
     
        <script>

     	$(function()
     	{
     		$("#id_PW").keyup(function(e) {
     			if(e.keyCode == 13)
     				FnLoginManager();
     			});	
     	});
         

     	function FnLoginManager()
     	{
     		var sID = $('#id_ID').val();
     		var sPW = $('#id_PW').val();
     		
   		    if(!checkValue(sID) || !checkValue(sPW))
   			{
   				alert("값을 입력해야 합니다.");
   				return ;
   			}
   			var sData = "id=" + sID + "&pw=" + sPW;
   			$.post("./query/query_login.jsp",sData, function(data, status)
   			{
   				if(status=="success")
   				{
   					var sResponse = "";
   					if(data != null)
   						sResponse = data.trim();
   					if(sResponse.indexOf("OK") >= 0)
   					{
   						location.href="<%=p_strOKResponse%>";
   					}
   					else
   					{
   						alert("ID 또는 PW가 다릅니다.")	
   					}			
   				}
   		  });
     	}
       	</script>  
        
    </head>

    <body>
        <div style='height:100%;min-width:500px;width:100%;'>
            <header style='height:100px;background:#999;color:#fff;padding-top:40px;text-align:center;font-weight:500;'>
                 BLAKSTONE.CO.,LTD. Home Security Solution Management Program
            </header>
            <!-- //  header -->

            <div style='position:relative;min-height:400px'>
 		          	
                <div style='padding-left:220px;'>
                    <div style='padding:20px;'>
                        <h3 style="font-size:25px;font-weight:500;letter-spacing:-1px;margin-bottom:20px;padding-left:30px;background:url('./images/list/bull_title.png') 0 center no-repeat;">Login</h3>

                      	<div class='search-wrap'>
                            <ul>
                                <li>
                                    <div class='dist'>ID </div>
                                    <input type="text"  id="id_ID" class="wide-input">
                                </li>
                                <li>
                                    <div class='dist'>PW </div>
                                    <input type="password"  id="id_PW" class="wide-input">
                                </li>

                            </ul>
                        </div>
						<button class="btn-list btn-search blue" style='margin-top:10px; margin-left:150px;' onClick='FnLoginManager();'>Login</button>
 
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

