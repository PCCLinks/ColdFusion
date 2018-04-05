
<cfinvoke component="pcclinks.bill.LookUp" method="getLastAttendancePeriodClosed" returnvariable="lastClosedAttendance"></cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getFirstOpenAttendanceDate" returnvariable="openAttendanceDate"></cfinvoke>
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
<cfinvoke component="pcclinks.bill.LookUp" method="getOpenAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>


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
	<a href="ReportSIDNYComparison.cfm?billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>" >Check for SIDNY Differences</a><br>
	<a href="ReportPreviousPeriodComparison.cfm?billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>" >Check for Differences from Previous Month</a><br>
	<hr>
	<a href="AttendanceEntry.cfm">Enter Attendance</a><br>
	<ul class="circle">
		<li># students entered: <cfoutput>#attendanceEnteredByStudent.NumStudentsEntered#</cfoutput></li>
		<li># students with no hours entered: <cfoutput>#attendanceEnteredByStudent.NumStudentsNoHours#</cfoutput></li>
		<a href="javascript:showStudents()" id="showStudentsLink">Show Student List with No Hours Entered</a>
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
		</div>
		<li># classes entered: <cfoutput>#attendanceEnteredByClass.NumClassesEntered#</cfoutput></li>
		<li># classes with no hours entered: <cfoutput>#attendanceEnteredByClass.NumClassesNoHours#</cfoutput></li>
		<a href="javascript:showClasses()" id="showClassesLink">Show Class List with No Hours Entered</a>
		<div id="classesMissingHours">
		<table class="w3-table w3-bordered">
			<thead>
			<tr>
				<th>Subj</th>
				<th>Crse</th>
				<th>CRN</th>
				<th>Title</th>
			</tr>
			</thead>
			<tbody>
			<cfoutput query="classesNoHours">
			<tr>
				<td>#subj#</td>
				<td>#crse#</td>
				<td>#crn#</td>
				<td>#Title#</td>
			</tr>
			</cfoutput>
			</tbody>
		</table>
		</div>
	</ul>
	<a href="ReportAttendanceEntry.cfm" >Review Attendance</a><br>
	<hr>
	<a href="SetExit.cfm" >Set Exit Reason and Dates</a><br>
	<hr>
	<a href=<cfoutput>"ReportSIDNYComparison.cfm?billingStartDate=#openAttendanceDate#"</cfoutput>>Recheck SIDNY Differences</a><br>
	<a href="ReportPreviousPeriodComparison.cfm?billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>" >Recheck for Differences from Previous Month</a><br>
	<hr>
	<a href="javascript:showCalculateBilling();">Generate Calculations</a><br>
	<!-- CALCULATE BILLING -->
	<div class="callout" id="calculateBilling">
	<p><b>Calculate Billing</b></p>
	<cfmodule template="calculateBillingInclude.cfm"
		billingDates = "#billingDates#"
		qryTerms = "#qryTerms#"
		billingType = "attendance"
		openAttendanceDate = "#openAttendanceDate#">
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
	<a href="javascript:showCloseBilling();">Close Billing Cycle for <cfoutput>#DateFormat(openAttendanceDate,'yyyy-mm-dd')#</cfoutput></a><br>
	<!-- CLOSE BILLING CYCLE -->
	<div class="callout" id="closeBillingCycle">
	<cfmodule template="closeBillingCycleInclude.cfm"
		billingDates = "#billingDates#"
		qryTerms = "#qryTerms#"
		billingType = "attendance"
		openAttendanceDate = "#openAttendanceDate#">
	</div>
	<hr>
	</cfif>
</ul>

<script type="text/javascript">
	var linkStudentTextShow = "Show Student List with No Hours Entered";
	var linkStudentTextHide = "Hide Student List";
	var linkClassTextShow = "Show Class List with No Hours Entered";
	var linkClassTextHide = "Hide Class List";

	$(document).ready(function() {
		$('#calculateBilling').hide();
		$('#closeBillingCycle').hide();
		$('#studentsMissingHours').hide();
		$('#showStudentsLink').text(linkStudentTextShow);
		$('#classesMissingHours').hide();
		$('#showClassesLink').text(linkClassTextShow);
	});
	function showCalculateBilling(){
		$('#calculateBilling').show();
	}
	function showCloseBilling(){
		$('#closeBillingCycle').show();
	}
	function saveValues(formName){
	 	var $form = $('#'+formName);
	    $.ajax({
	       	url:$form.attr('action'),
	       	type: 'POST',
	       	data: $form.serialize(),
	       	success: function (data, textStatus, jqXHR) {
	       		if(formName == 'frmCalculateBilling'){
					rePopulateBillingInfo();
					closeForm();
	       		}else{
	       			location.reload();
	       		}
	    	},
			error: function (jqXHR, exception) {
	      		handleAjaxError(jqXHR, exception);
			}
	    });
	}
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
	<cfinvoke component="pcclinks.bill.Report" method="getAttendanceBilledInfo" returnvariable="billedInfo">
	<cfinvokeargument name="billingStartDate" value="#openAttendanceDate#">
</cfinvoke>
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
		if($('#showStudentsLink').text() == linkStudentTextShow){
			$('#showStudentsLink').text(linkStudentTextHide);
			$('#studentsMissingHours').show();
		}else{
			$('#showStudentsLink').text(linkStudentTextShow);
			$('#studentsMissingHours').hide();
		}
	}
	function closeForm(){
		$('#calculateBilling').hide();
		$('#closeBillingCycle').hide();
	}
</script>

