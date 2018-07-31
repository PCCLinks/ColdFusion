<!-- end editable content area -->

<!-- start template footer -->
</div> <!-- end small-12 -->
 </div><!-- end content -->

<!-- scripts -->
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/what-input.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/foundation.min.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/pcc.js"></script>
<script type="text/javascript" src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/datatables.min.js"></script>
<script type="text/javascript" charset="utf8" src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery.blockUI.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery-ui.min.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/foundation-datepicker.min.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/moment.min.js"></script>

<script src="https://cdn.datatables.net/select/1.2.5/js/dataTables.select.min.js"></script>

<script>


$(document).ready(function(){
	$(document).foundation();
	formatDatePicker();
})
/* Search Functions called from Header.cfm */
function search(){
	$('#searchOverlay').fadeIn('fast',function(){
    	$('#search').animate({'top':'100px'},100);
    });
}
function closeSearch(){
	$('#search').animate({'top':'-400px'},100,function(){
    	$('#searchOverlay').fadeOut('fast');
    });
}
function searchBoxDoSearch(){
	closeSearch();
	$.post('DoSearch.cfc', {method: 'setSearchCriteria', searchGNumber:$('#searchGNumber').val(),
							searchFirstName:$('#searchFirstName').val(),
							searchLastName:$('#searchLastName').val()})
		.done(function(){
			window.location = "ProgramStudent.cfm";
		})
}
function getBillingStudent(billingStudentId, newWindow){
	$.post('DoSearch.cfc', {method: 'setBillingStudentId',
						searchBillingStudentId:billingStudentId})
	.done(function(){
		//if(newWindow){
		//	window.open("ProgramStudent.cfm");
		//}else{
			window.location = "ProgramStudent.cfm";
		//}
	})
	.error(function (xhr, textStatus, thrownError) {
	        handleAjaxError(xhr, textStatus, thrownError);
	});
}
function addZero($time) {
	 if ($time < 10) {
	   $time = "0" + $time;
	 }
	 return $time;
}
function formatDatePicker(){
	$('.fdatepicker').fdatepicker({
		format: 'mm/dd/yyyy',
		disableDblClickSelection: true,
		leftArrow:'<<',
		rightArrow:'>>',
		closeIcon:'X',
		closeButton: true
	});
}
function handleAjaxError(jqXHR, exception, thrownError){
	msg = encodeURIComponent(jqXHR.statusText + ' ' + jqXHR.responseText);
	data = {error: msg, exception: exception, throwError: thrownError, errorType: 'ajax'};
	$.post("Error.cfm", data, function(){
	  		window.location	='Error.cfm';
  	});
}

//generic function to save client session object to server session
function saveClientSessionToServer(){
  	var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
 	$.post("saveSession.cfm", data);
}
</script>

<!--- script content created in content pages and referenced here --->
<cfoutput>#pcc_scripts#</cfoutput>


<!-- end template footer -->

<!-- end body and html tags -->
</body>
</html>