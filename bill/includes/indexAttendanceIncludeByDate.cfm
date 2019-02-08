<cfset openAttendanceDate = "#attributes.openAttendanceDate#">
<cfset pageTag = DateFormat(openAttendanceDate, 'yyyymmdd')>

<cfif isDefined("openAttendanceDate") and openAttendanceDate NEQ "">
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
	<cfinvoke component="pcclinks.bill.Report" method="getStudentsNoClasses" returnvariable="studentsNoClasses">
		<cfinvokeargument name="billingStartDate" value="#openAttendanceDate#">
	</cfinvoke>
	<cfinvoke component="pcclinks.bill.LookUp" method="getOpenTerms" returnvariable="qryTerms"></cfinvoke>
	<cfinvoke component="pcclinks.bill.LookUp" method="getOpenAttendanceDates" returnvariable="billingDates"></cfinvoke>
</cfif>

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


<a href="javascript:showMissingAttrAttendance('<cfoutput>#pageTag#</cfoutput>')" id="missingAttrLinkAttendance<cfoutput>#pageTag#</cfoutput>">Show Student List Missing Banner Attributes</a>
<div id="missingAttrAttendance<cfoutput>#pageTag#</cfoutput>">
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
<a href="ReportPreviousPeriodComparison.cfm?Type=Attendance&billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>" >Check for Differences from Previous Month</a><br>
<a href="AddScenario.cfm">Attendance Scenarios</a>

<hr>
<a href="AttendanceEntry.cfm">Enter Attendance</a><br>
<ul class="circle">
	<li># students entered: <cfoutput>#attendanceEnteredByStudent.NumStudentsEntered#</cfoutput></li>
	<li># students with no hours entered: <cfoutput>#attendanceEnteredByStudent.NumStudentsNoHours#</cfoutput>
	<a href="javascript:showStudents(<cfoutput>#pageTag#</cfoutput>)" id="showStudentsMissingHoursLink<cfoutput>#pageTag#</cfoutput>">Show Student List with No Hours Entered</a>
	<div id="studentsMissingHours<cfoutput>#pageTag#</cfoutput>">
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
	<a href="javascript:exportNoHours('<cfoutput>#openAttendanceDate#</cfoutput>')" class="button">Export</a>
	</div>
	</li>
	<li># students with no classes entered: <cfoutput>#attendanceEnteredByStudent.NumStudentsNoClasses#</cfoutput>
	<a href="javascript:showStudentsNoClasses(<cfoutput>#pageTag#</cfoutput>)" id="showStudentsMissingClassesLink<cfoutput>#pageTag#</cfoutput>">Show Student List with No Classes</a>
	<div id="studentsMissingClasses<cfoutput>#pageTag#</cfoutput>">
	<table class="w3-table w3-bordered">
		<thead>
		<tr>
			<th>G Number</th>
			<th>Firstname</th>
			<th>Lastname</th>
		</tr>
		</thead>
		<tbody>
		<cfoutput query="studentsNoClasses">
		<tr>
			<td>#bannerGNumber#</td>
			<td>#firstname#</td>
			<td>#lastname#</td>
		</tr>
		</cfoutput>
		</tbody>
	</table>
	<a href="javascript:exportNoHours(<cfoutput>#pageTag#</cfoutput>)" class="button">Export</a>
	</div>
	</li>
	<li># classes entered: <cfoutput>#attendanceEnteredByClass.NumClassesEntered#</cfoutput></li>
	<li># classes with no hours entered: <cfoutput>#attendanceEnteredByClass.NumClassesNoHours#</cfoutput>
		<a href="javascript:showClasses(<cfoutput>#pageTag#</cfoutput>)" id="showClassesLink<cfoutput>#pageTag#</cfoutput>">Show Class List with No Hours Entered</a>
		<div id="classesMissingHours<cfoutput>#pageTag#</cfoutput>">
			<table class="w3-table w3-bordered">
				<thead>
				<tr>
					<th>Subj</th>
					<th>Crse</th>
					<th>CRN</th>
					<th>Title</th>
					<th># Students</th>
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
			<a href="javascript:exportNoHours(<cfoutput>#pageTag#</cfoutput>)" class="button">Export</a>
		</div>
	</li>
</ul>
<a href="ReportAttendanceEntry.cfm" >Review Attendance - Summary Report</a><br>

<hr>
<a href="SetExit.cfm" >Set Exit Reason and Dates</a><br>

<hr>
<a href=<cfoutput>"ReportSIDNYComparison.cfm?billingStartDate=#openAttendanceDate#"</cfoutput>>Recheck SIDNY Differences</a><br>
<a href="ReportPreviousPeriodComparison.cfm?billingStartDate=<cfoutput>#openAttendanceDate#</cfoutput>&Type=Attendance" >Recheck for Differences from Previous Month</a><br>

<hr>
<a href="javascript:showForm('calculateBillingAttendance');">Generate Calculations</a><br>
<!-- CALCULATE BILLING -->
<div class="callout" id="calculateBillingAttendance<cfoutput>#pageTag#</cfoutput>">
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
<a href="ReportSummary.cfm?type=Attendance">Run Billing Reports</a><br>

<hr>
<a href="javascript:showForm('closeBillingCycleAttendance<cfoutput>#pageTag#</cfoutput>');">Close Billing Cycle for <cfoutput>#DateFormat(openAttendanceDate,'yyyy-mm-dd')#</cfoutput></a><br>
<!-- CLOSE BILLING CYCLE -->
<div class="callout" id="closeBillingCycleAttendance<cfoutput>#pageTag#</cfoutput>">
<cfmodule template="closeBillingCycleInclude.cfm"
	billingDates = "#billingDates#"
	qryTerms = "#qryTerms#"
	billingType = "attendance"
	openBillingStartDate = "#openAttendanceDate#"
	divIdName = "closeBillingCycleAttendance#pageTag#"
	formName = "frmCloseBillingAttendance#pageTag#">
</div>

<script type="text/javascript">
  function getLinkMissingAttribText<cfoutput>#pageTag#</cfoutput>(){
    return "Show <cfoutput>#attendanceStudentsNeedingBannerAttr.recordcount#</cfoutput> Student(s) Missing Banner Attributes.";
  }
  function showMissingAttrAttendance<cfoutput>#pageTag#</cfoutput>(){
		if($('#missingAttrLinkAttendance<cfoutput>#pageTag#</cfoutput>').text() == getLinkMissingAttribText<cfoutput>#pageTag#</cfoutput>()){
			$('#missingAttrLinkAttendance<cfoutput>#pageTag#</cfoutput>').text(linkMissingAttribHideAttendance);
			$('#missingAttrAttendance<cfoutput>#pageTag#</cfoutput>').show();
		}else{
			$('#missingAttrLinkAttendance<cfoutput>#pageTag#</cfoutput>').text(getLinkMissingAttribText<cfoutput>#pageTag#</cfoutput>());
			$('#missingAttrAttendance<cfoutput>#pageTag#</cfoutput>').hide();
		}
	}

</script>

