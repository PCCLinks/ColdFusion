<cfinvoke component="pcclinks.bill.LookUp" method="getOpenAttendanceDates" returnvariable="openAttendanceDates"></cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getLastAttendanceDateClosed" returnvariable="lastClosedAttendance"></cfinvoke>

<style>
.checkmark{
	width:30px;
	height:30px;
}
.w3-table,.w3-table-all{
	border-collapse:collapse;
	border-spacing:0;
	width:50%;
	display:table
}
.w3-bordered tr,.w3-table-all tr{
	border-bottom:1px solid #ddd
}
</style>


<hr>
<a href="SetUpBilling.cfm?type=Attendance">Set Up Billing</a><br>
<ul><cfif openAttendanceDates.recordcount GT 0>
	    <cfloop query="#openAttendanceDates#">
		<li><b>Billing in Progress: <cfoutput>#DateFormat(billingStartDate,'yyyy-mm-dd')#</cfoutput></b></li>
		</cfloop>
		<cfelse>
		<b>No Billing In Progress</b>
		</cfif>
	<li>Last Month Closed: <cfoutput>#DateFormat(lastClosedAttendance.billingStartDate,'yyyy-mm-dd')#</cfoutput></li>
</ul>

<cfif openAttendanceDates.recordcount GT 0>
	<!-- Tabs -->
	<ul class="tabs" data-tabs id="attendance-tabs">
	<cfset i = 0>
	<cfloop query="#openAttendanceDates#">
		<li class="tabs-title <cfif i EQ 0>is-active</cfif>">
			<a href="#attendance<cfoutput>#DateFormat(billingStartDate,'yyyy-mm-dd')#</cfoutput>" <cfif i EQ 0>aria-selected="true"</cfif>>Attendance <cfoutput>#DateFormat(billingStartDate,'yyyy-mm-dd')#</cfoutput></a>
		</li>
	    <cfset i = i + 1>
	</cfloop>
	</ul>

	<!-- tab content -->
	<div class="tabs-content" data-tabs-content="attendance-tabs">
	<cfset i = 0>
	<cfloop query="#openAttendanceDates#">
		<div class = "tabs-panel <cfif i EQ 0>is-active</cfif>" id="attendance<cfoutput>#DateFormat(billingStartDate,'yyyy-mm-dd')#</cfoutput>">
    		<cfmodule template="indexAttendanceIncludeByDate.cfm"  openAttendanceDate="#billingStartDate#" >
  		</div>
	    <cfset i = i + 1>
	</cfloop>
	</div>
</cfif>

<!--- build an array object to be used below to build calls
  to specific pages / billingDates in javascript below
--->
<cfset datePageTagArray = []>
<cfloop query="openAttendanceDates">
	<cfset ArrayAppend(datePageTagArray, DateFormat(billingStartDate,"yyyymmdd"))>
</cfloop>

<script type="text/javascript">
	var linkStudentMissingHoursShow= "Show Student List with No Hours Entered";
	var linkStudentMissingHoursHide = "Hide Student List";
	var linkStudentMissingClassesShow= "Show Student List with No Classes";
	var linkStudentMissingClassesHide = "Hide Student No Classes List";
	var linkClassTextShow = "Show Class List with No Hours Entered";
	var linkClassTextHide = "Hide Class List";
	<cfloop array="#datePageTagArray#" item="pageTag">
	var linkMissingAttribShowAttendance<cfoutput>#pageTag#</cfoutput>;
	</cfloop>
	var linkMissingAttribHideAttendance  = "Hide Student List Missing Banner Attributes"

	$(document).ready(function() {
		<cfloop array="#datePageTagArray#" item="pageTag">
			$('#missingAttrLinkAttendance<cfoutput>#pageTag#</cfoutput>').text(getLinkMissingAttribText<cfoutput>#pageTag#</cfoutput>());
		</cfloop>
		<cfloop array="#datePageTagArray#" item="pageTag">
			pageStartUp('<cfoutput>#pageTag#</cfoutput>');
		</cfloop>
	});

	function pageStartUp(pageTag){

		$('#calculateBillingAttendance'+pageTag).hide();
		$('#closeBillingCycleAttendance'+pageTag).hide();
		$('#studentsMissingHours'+pageTag).hide();
		$('#showStudentsMissingHoursLink'+pageTag).text(linkStudentMissingHoursShow);
		$('#studentsMissingClasses'+pageTag).hide();
		$('#showStudentsMissingClassesLink'+pageTag).text(linkStudentMissingClassesShow);
		$('#classesMissingHours'+pageTag).hide();
		$('#showClassesLink'+pageTag).text(linkClassTextShow);
		$('#missingAttrAttendance'+pageTag).hide();

		$('#tableMissingAttr'+pageTag).DataTable({
			dom: '<"top"B>rt<"bottom">',
			buttons:[{extend: 'csv',
            text: 'export'}],
            paging:false
		});

	}
	function rePopulateBillingInfo(openAttendanceDate, pageTag){
		$.ajax({
	       	url:'includes/attendanceBilledInfoInclude.cfm?billingStartDate=openAttendanceDate',
	       	type: 'get',
	       	success: function (data, textStatus, jqXHR) {
	        	$('#billedInfo'+pageTag).html(data);
	    	},
			error: function (jqXHR, exception) {
	      		handleAjaxError(jqXHR, exception);
			}
	    });
	}
	function showClasses(pageTag){
		if($('#showClassesLink'+pageTag).text() == linkClassTextShow){
			$('#showClassesLink'+pageTag).text(linkClassTextHide);
			$('#classesMissingHours'+pageTag).show();
		}else{
			$('#showClassesLink'+pageTag).text(linkClassTextShow);
			$('#classesMissingHours'+pageTag).hide();
		}
	}
	function showStudents(pageTag){
		if($('#showStudentsMissingHoursLink'+pageTag).text() == linkStudentMissingHoursShow){
			$('#showStudentsMissingHoursLink'+pageTag).text(linkStudentMissingHoursHide);
			$('#studentsMissingHours'+pageTag).show();
		}else{
			$('#showStudentsMissingHoursLink'+pageTag).text(linkStudentMissingHoursShow);
			$('#studentsMissingHours'+pageTag).hide();
		}
	}
	function showStudentsNoClasses(pageTag){
		if($('#showStudentsMissingClassesLink'+pageTag).text() == linkStudentMissingClassesShow){
			$('#showStudentsMissingClassesLink'+pageTag).text(linkStudentMissingClassesHide);
			$('#studentsMissingClasses'+pageTag).show();
		}else{
			$('#showStudentsMissingClassesLink'+pageTag).text(linkStudentMissingClassesShow);
			$('#studentsMissingClasses'+pageTag).hide();
		}
	}
	function exportNoHours(openAttendanceDate){
		 $.ajax({
		 	url: 'Report.cfc?method=attendanceEntry&billingStartDate=openAttendanceDate&noHoursOnly=true',
		 	type:'get',
		 	cache:false,
		 	success: function(data){
		 		window.open('includes/ReportAttendanceEntryPrintInclude.cfm');
		 	}
		 });
	}
	function exportNoClasses(openAttendanceDate){
		 $.ajax({
		 	url: 'Report.cfc?method=attendanceEntry&billingStartDate=openAttendanceDate&noClassesOnly=true',
		 	type:'get',
		 	cache:false,
		 	success: function(data){
		 		window.open('includes/ReportAttendanceEntryPrintInclude.cfm');
		 	}
		 });
	}
	function showMissingAttrAttendance(pageTag){
		//dynamic function call to call to specific page
		window['showMissingAttrAttendance'+pageTag]();
	}
</script>
