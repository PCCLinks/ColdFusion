
<!-- start template footer -->
</div> <!-- end small-12 -->
 </div><!-- end content -->

<!-- scripts -->
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/what-input.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/foundation.min.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/pcc.js"></script>
<script type="text/javascript" src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/datatables.min.js"></script>
<script type="text/javascript" src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery.blockUI.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery-ui.min.js"></script>

<script src="https://cdn.datatables.net/select/1.2.5/js/dataTables.select.min.js"></script>

<script>

const STUDENT_DIV = "student";
const REPORT_DIV = "report";
const DASHBOARD_DIV = "dashboard";
const CASELOAD_DIV = "caseload";
const IMPORT_PAGE = "import";

const DT_TABLE = "dt_table_caseload";

var loaded = [];
var loadedScreen = '';
var screens = [CASELOAD_DIV, STUDENT_DIV, REPORT_DIV, DASHBOARD_DIV];
var doSave;

$(document).ready(function() {
	$(document).foundation();

	//check that login valid every 2 hours
	checkLoginInterval = 1000*60*120;
	setInterval(checkLogin, checkLoginInterval);
});

function checkLogin(){
	$.ajax({
		url: "fc.cfc?method=checkSessionTimeout",
		type:'GET',
		error:function(jqXHR, exception, thrownError){
			handleAjaxError(jqXHR, exception, thrownError);
		}
	});
}

//NAVIGATION SHOWSCREEN
function showScreen(screen){
	var url;
	$("body").css("cursor", "wait");

	$.ajax({
		url: "fc.cfc?method=checkSessionTimeout",
		type:'GET',
		error:function(jqXHR, exception, thrownError){
			handleAjaxError(jqXHR, exception, thrownError);
		},
		success:function(data){
			url = screen + '.cfm';

			if(loaded.indexOf(screen) == -1){
				if(screen == REPORT_DIV){
					loadReport();
				}
				if(screen == DASHBOARD_DIV || screen == IMPORT_PAGE){
					$.ajax({
						type: "GET",
						url: url,
						success: function(data){
							$('#'+screen).html(data);
						}
		  			});
				}
			    loaded.push(screen);
			}

			if(loadedScreen == STUDENT_DIV){
				unloadStudent(doSave, refreshCaseload);
		    }
			if(screen == STUDENT_DIV){
				loadStudent(selectedPidm, selectedPidmMaxTerm, doSave);
			}

			$('#' + screen).delay(500).fadeIn( 1000 );
			$('#' + loadedScreen).css("display", "none");
			loadedScreen = screen;
			$("body").css("cursor", "default");
		}
	});
}

function handleAjaxError(jqXHR, exception, thrownError){
	if(jqXHR.status == 600){
		window.location = "SessionTimeout.cfm";
	}else{
		msg = encodeURIComponent(jqXHR.statusText + ' ' + jqXHR.responseText);
		data = {error: msg, exception: exception, throwError: thrownError, errorType: 'ajax'};
		$.post("Error.cfm", data, function(){
		  		window.location	='Error.cfm';
		 });
	}
}

</script>

<!--- script content created in content pages and referenced here --->
<cfoutput>#pcc_scripts#</cfoutput>


<!-- end template footer -->

<!-- end body and html tags -->

</body>
</html>