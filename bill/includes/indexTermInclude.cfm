<cfinvoke component="pcclinks.bill.LookUp" method="getLastTermClosed" returnvariable="lastClosedTerm"></cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getOpenTerms" returnvariable="openTerms"></cfinvoke>
<cfif openTerms.recordcount GT 0>
	<cfinvoke component="pcclinks.bill.LookUp" method="getBillingStatusForDate" returnvariable="billingStatusCount">
		<cfinvokeargument name="term" value="#openTerms.term#">
	</cfinvoke>
</cfif>

<!--->
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
--->




<hr>
<cfif openTerms.recordcount EQ 0>
<b>Before Running a New Billing Period</b>
<ul>
	<li>From SIDNY, generate an enrollment report of all GtC and YtC students who have enrolled since the last term</li>
	<li>Run the Banner Attribute for all newly enrolled students</li>
</ul>
</cfif>
<a href="SetUpBilling.cfm?type=Term">Set Up Billing</a><br>
<ul><li><b><cfif openTerms.recordcount GT 0 >
		Billing in Progress: <cfoutput>#openTerms.TermDescription#</cfoutput>
		<cfelse>
		No Billing In Progress
		</cfif></b>
	</li>
	<li>Last Month Closed: <cfoutput>#lastClosedTerm#</cfoutput></li>
</ul>

<cfif openTerms.recordcount GT 0>
<hr>
<a href="ReportSIDNYComparison.cfm?billingStartDate=<cfoutput>#openTerms.billingStartDate#</cfoutput>" >Check for SIDNY Differences</a><br>
<a href="ReportPreviousPeriodComparison.cfm?billingStartDate=<cfoutput>#openTerms.billingStartDate#</cfoutput>" >Check for Differences from Previous Period</a><br>
<hr>
Program Review of Billing
<table class="w3-table w3-bordered">
<thead>
	<tr>
		<th>Status</th>
		<th>Count</th>
	</tr>
</thead>
<tbody>
<cfoutput query="billingStatusCount">
	<tr>
		<td>#billingStatus#</td>
		<td>#NumRecords#</td>
	</tr>
</cfoutput>
</tbody>
</table>
<hr>
<a href="SetExit.cfm" >Set Exit Reason and Dates</a><br>
<hr>
<a href=<cfoutput>"ReportSIDNYComparison.cfm?billingStartDate=#openTerms.billingStartDate#"</cfoutput>>Recheck SIDNY Differences</a><br>
<a href="ReportPreviousPeriodComparison.cfm?billingStartDate=<cfoutput>#openTerms.billingStartDate#</cfoutput>" >Recheck for Differences from Previous Period</a><br>
<hr>
<a href="javascript:showForm('calculateBillingTerm');">Generate Calculations</a><br>
<!-- CALCULATE BILLING -->
<div class="callout" id="calculateBillingTerm">
	<cfmodule template="calculateBillingInclude.cfm"
		billingDates = "#openTerms#"
		qryTerms = "#openTerms#"
		billingType = "term"
		openBillingStartDate = "#openTerms.billingStartDate#"
		divIdName = "calculateBillingTerm">
</div>
<hr>
<a href="ReportSummary.cfm?type=Term">Review Billing Reports</a><br>
<hr>
<a href="ReportSummary.cfm?type=Term">Run Billing Reports</a><br>
<hr>
<a href="javascript:showForm('closeBillingCycleTerm');">Close Billing Cycle for <cfoutput>#DateFormat(openTerms.billingStartDate,'yyyy-mm-dd')#</cfoutput></a><br>
<!-- CLOSE BILLING CYCLE -->
<div class="callout" id="closeBillingCycleTerm">
<cfmodule template="closeBillingCycleInclude.cfm"
	billingDates = "#openTerms#"
	qryTerms = "#openTerms#"
	billingType = "term"
	openBillingStartDate = "#openTerms.billingStartDate#"
	divIdName = "closeBillingCycleTerm">
</div>
<hr>
</cfif>

<script type="text/javascript">
	$(document).ready(function() {
		$('#calculateBillingTerm').hide();
		$('#closeBillingCycleTerm').hide();
	});
</script>