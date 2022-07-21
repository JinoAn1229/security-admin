
var PageUtil_objForm=null;

function PagerUtil_SetForm(objForm)
{
	PageUtil_objForm = objForm;
}

// 페이지 번호 클릭 시
function PagerUtil_SelectPage(nPage)
{
	//var form = document.listForm;
	PageUtil_objForm.page_no.value = nPage;
	PageUtil_objForm.submit();
}


//처음으로
function PagerUtil_FirstPage()
{
	PageUtil_objForm.page_no.value = 1;
	PageUtil_objForm.submit();
}

//끝으로
function PagerUtil_EndPage(nTotalPage)
{
	//var form = document.listForm;
	PageUtil_objForm.page_no.value = nTotalPage;
	PageUtil_objForm.submit();
}
