
<cfinvoke component="pcclinks.bill.LookUp" method="getFirstOpenAttendanceDate" returnvariable="openAttendanceDate"></cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getLastAttendancePeriodClosed" returnvariable="lastClosedAttendance"></cfinvoke>

<cfinvoke component="pcclinks.bill.SetUpBilling" method="getStudentsNeedingBannerAttributes" returnvariable="attendanceStudentsNeedingBannerAttr">
	<cfinvokeargument name="billingStartDate" value="#openAttendanceDate#">
	<cfinvokeargument name="billingType" value="attendance">
</cfinvoke>

<cfinvoke component="pcclinks.bill.Report" method="getAttendanceEnteredByStudent" returnvariable="attendanceEnteredByStudent">
	<cfinvokeargument name="billingStartDate" value="#openAttendanceDate#">
</cfinvoke>

<cfinvoke component="pcclinks.bill.Report" method="getAttendanceEnteredByClass" returnvariable="attendanceEnteredByClass">
	<cfinvokeargument name="billingStartDate" value="#openAttendanceDate#">
</cfinvoke>

<cfinvoke component="pcclinks.bill.Report" method="getClassesNoHours" returnvariable="classesNoHours">
	<cfinvokeargument name="billingStartDate" value="#openAttendanceDate#">
</cfinvoke>
<cfinvoke component="pcclinks.bill.Report" method="getStudentsNoHours" returnvariable="studentsNoHours">
	<cfinvokeargument name="billingStartDate" value="#openAttendanceDate#">
</cfinvoke>

<cfinvoke component="pcclinks.bill.LookUp" method="getOpenTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getOpenAttendanceDates" returnvariable="billingDates"></cfinvoke>


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
<ul><li><b><cfif LEN(openAttendanceDate)>
		Billing in Progress: <cfoutput>#DateFormat(openAttendanceDate,'yyyy-mm-dd')#</cfoutput>
		<cfelse>
		No Billing In Progress
		</cfif></b>
	</li>
	<li>Last Month Closed: <cfoutput>#DateFormat(lastClosedAttendance,'yyyy-mm-dd')#</cfoutput></li>
</ul>

<cfif LEN(openAttendanceDate)>

	<hr>
	<a href="javascript:showMissingAttrAttendance()" id="missingAttrLinkAttendance">Show Student List Missing Banner Attributes</a>
	<div id="missingAttrAttendance">
		<table class="w3-table w3-bordered" id="tableMissingAttr">
			<thead>
			<tr>
				<th>G Number</th>
				<th>Firstname</th>
				<th>Lastname</th>
				<th>Program</th>
				<th>Status</th>
			</tr>
			</thead>
			<tbody>
			<cfoutput query="attendanceStudentsNeedingBannerAttr">
			<tr>
				<td>#bannerGNumber#</td>
				<td>#firstname#</td>
				<td>#lastname#</td>
				<td>#program#</td>
				<td>#Status#</td>
			</tr>
			</cfoutput>
			</tbody>
		</table>
	</div>

	<hr>
	<a href="ReportSIDNYComparison.cfm?billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>" >Check for SIDNY Differences</a><br>
	<a href="ReportPreviousPeriodComparison.cfm?billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>" >Check for Differences from Previous Month</a><br>
	<a href="AddScenario.cfm">Attendance Scenarios</a>

	<hr>
	<a href="AttendanceEntry.cfm">Enter Attendance</a><br>
	<ul class="circle">
		<li># students entered: <cfoutput>#attendanceEnteredByStudent.NumStudentsEntered#</cfoutput></li>
		<li># students with no hours entered: <cfoutput>#attendanceEnteredByStudent.NumStudentsNoHours#</cfoutput>
		<a href="javascript:showStudents()" id="showStudentsMissingHoursLink">Show Student List with No Hours Entered</a>
		<div id="studentsMissingHours">
		<table class="w3-table w3-bordered">
			<thead>
			<tr>
				<th>G Number</th>
				<th>Firstname</th>
				<th>Lastname</th>
			</tr>
			</thead>
			<tbody>
			<cfoutput query="studentsNoHours">
			<tr>
				<td>#bannerGNumber#</td>
				<td>#firstname#</td>
				<td>#lastname#</td>
			</tr>
			</cfoutput>
			</tbody>
		</table>
		<a href="javascript:exportNoHours()" class="button">Export</a>
		</div>
		</li>
		<li># classes entered: <cfoutput>#attendanceEnteredByClass.NumClassesEntered#</cfoutput></li>
		<li># classes with no hours entered: <cfoutput>#attendanceEnteredByClass.NumClassesNoHours#</cfoutput>
			<a href="javascript:showClasses()" id="showClassesLink">Show Class List with No Hours Entered</a>
			<div id="classesMissingHours">
				<table class="w3-table w3-bordered">
					<thead>
					<tr>
						<th>Subj</th>
						<th>Crse</th>
						<th>CRN</th>
						<th>Title</th>
						<th>## Students</th>
					</tr>
					</thead>
					<tbody>
					<cfoutput query="classesNoHours">
					<tr>
						<td>#subj#</td>
						<td>#crse#</td>
						<td>#crn#</td>
						<td>#Title#</td>
						<td>#NumOfStudents#</td>
					</tr>
					</cfoutput>
					</tbody>
				</table>
				<a href="javascript:exportNoHours()" class="button">Export</a>
			</div>
		</li>
	</ul>
	<a href="ReportAttendanceEntry.cfm" >Review Attendance - Summary Report</a><br>

	<hr>
	<a href="SetExit.cfm" >Set Exit Reason and Dates</a><br>

	<hr>
	<a href=<cfoutput>"ReportSIDNYComparison.cfm?billingStartDate=#openAttendanceDate#"</cfoutput>>Recheck SIDNY Differences</a><br>
	<a href="ReportPreviousPeriodComparison.cfm?billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>" >Recheck for Differences from Previous Month</a><br>

	<hr>
	<a href="javascript:showForm('calculateBillingAttendance');">Generate Calculations</a><br>
	<!-- CALCULATE BILLING -->
	<div class="callout" id="calculateBillingAttendance">
	<p><b>Calculate Billing</b></p>
	<cfmodule template="calculateBillingInclude.cfm"
		billingDates = "#billingDates#"
		qryTerms = "#qryTerms#"
		billingType = "attendance"
		openBillingStartDate = "#openAttendanceDate#"
		divIdName = "calculateBillingAttendance">
	</div>
	<div id="billedInfo">
	<cfmodule template="attendanceBilledInfoInclude.cfm"
		billingStartDate = "#openAttendanceDate#">
	</div>

	<hr>
	<a href="ReportSummary.cfm?type=Attendance">Review Billing Reports</a><br>

	<hr>
	<a href="ReportSummary.cfm?type=Attendance">Run Billing Reports</a><br>

	<hr>
	<a href="javascript:showForm('closeBillingCycleAttendance');">Close Billing Cycle for <cfoutput>#DateFormat(openAttendanceDate,'yyyy-mm-dd')#</cfoutput></a><br>
	<!-- CLOSE BILLING CYCLE -->
	<div class="callout" id="closeBillingCycleAttendance">
	<cfmodule template="closeBillingCycleInclude.cfm"
		billingDates = "#billingDates#"
		qryTerms = "#qryTerms#"
		billingType = "attendance"
		openBillingStartDate = "#openAttendanceDate#"
		divIdName = "closeBillingCycleAttendance">
	</div>
	<hr>
</cfif>


<script type="text/javascript">
	var linkStudentMissingHoursShow= "Show Student List with No Hours Entered";
	var linkStudentMissingHoursHide = "Hide Student List";
	var linkClassTextShow = "Show Class List with No Hours Entered";
	var linkClassTextHide = "Hide Class List";
	var linkMissingAttribShowAttendance  = "<cfif attendanceStudentsNeedingBannerAttr.recordcount GT 0>Show </cfif><cfoutput>#attendanceStudentsNeedingBannerAttr.recordcount#</cfoutput> Student(s) Missing Banner Attributes."
	var linkMissingAttribHideAttendance  = "Hide Student List Missing Banner Attributes"

	$(document).ready(function() {
		$('#calculateBillingAttendance').hide();
		$('#closeBillingCycleAttendance').hide();
		$('#studentsMissingHours').hide();
		$('#showStudentsMissingHoursLink').text(linkStudentMissingHoursShow);
		$('#classesMissingHours').hide();
		$('#showClassesLink').text(linkClassTextShow);
		$('#missingAttrAttendance').hide();
		$('#missingAttrLinkAttendance').text(linkMissingAttribShowAttendance);

		$('#tableMissingAttr').DataTable({
		    	dom: '<"top"B>rt<"bottom">',
				buttons:[{extend: 'csv',
            	  text: 'export'}],
            	paging:false
			});

	});
	function rePopulateBillingInfo(){
		$.ajax({
	       	url:'includes/attendanceBilledInfoInclude.cfm?billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>',
	       	type: 'get',
	       	success: function (data, textStatus, jqXHR) {
	        	$('#billedInfo').html(data);
	    	},
			error: function (jqXHR, exception) {
	      		handleAjaxError(jqXHR, exception);
			}
	    });
	}
	function showClasses(){
		if($('#showClassesLink').text() == linkClassTextShow){
			$('#showClassesLink').text(linkClassTextHide);
			$('#classesMissingHours').show();
		}else{
			$('#showClassesLink').text(linkClassTextShow);
			$('#classesMissingHours').hide();
		}
	}
	function showStudents(){
		if($('#showStudentsMissingHoursLink').text() == linkStudentMissingHoursShow){
			$('#showStudentsMissingHoursLink').text(linkStudentMissingHoursHide);
			$('#studentsMissingHours').show();
		}else{
			$('#showStudentsMissingHoursLink').text(linkStudentMissingHoursShow);
			$('#studentsMissingHours').hide();
		}
	}
	function exportNoHours(){
		 $.ajax({
		 	url: 'Report.cfc?method=attendanceEntry&billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>&noHoursOnly=true',
		 	type:'get',
		 	cache:false,
		 	success: function(data){
		 		window.open('includes/ReportAttendanceEntryPrintInclude.cfm');
		 	}
		 });
	}
	function showMissingAttr(){
		if($('#missingAttrLink').text() == linkMissingAttribShowAttendance){
			$('#missingAttrLink').text(linkMissingAttribHideAttendance);
			$('#missingAttr').show();
		}else{
			$('#missingAttrLink').text(linkMissingAttribShowAttendance);
			$('#missingAttr').hide();
		}
	}
</script>
