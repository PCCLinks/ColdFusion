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

<script>
$(document).foundation();
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