<cfinvoke component="pcclinks.bill.LookUp" method="getLastTermClosed" returnvariable="lastClosedTerm"></cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getOpenTerms" returnvariable="openTerms"></cfinvoke>
<cfif openTerms.recordcount GT 0>
	<cfinvoke component="pcclinks.bill.LookUp" method="getBillingStatusForDate" returnvariable="billingStatusCount">
		<cfinvokeargument name="term" value="#openTerms.term#">
	</cfinvoke>
</cfif>

<cfinvoke component="pcclinks.bill.SetUpBilling" method="getStudentsNeedingBannerAttributes" returnvariable="termStudentsNeedingBannerAttr">
	<cfinvokeargument name="term" value="#openTerms.term#">
	<cfinvokeargument name="billingType" value="term">
</cfinvoke>



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
	<a href="javascript:showMissingAttrTerm()" id="missingAttrLinkTerm">Show Student List Missing Banner Attributes</a>
	<div id="missingAttrTerm">
		<table class="w3-table w3-bordered" id="tableMissingAttrTerm">
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
			<cfoutput query="termStudentsNeedingBannerAttr">
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
	<a href="ReportSIDNYComparison.cfm?billingStartDate=<cfoutput>#openTerms.billingStartDate#</cfoutput>" >Check for SIDNY Differences</a><br>
	<a href="ReportPreviousPeriodComparison.cfm?billingStartDate=<cfoutput>#openTerms.billingStartDate#</cfoutput>&type=term" >Check for Differences from Previous Period</a><br>
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
	<a href="ReportSummary.cfm?type=Term">Generate Billing Reports</a><br>
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
	var linkMissingAttribShowTerm = "<cfif termStudentsNeedingBannerAttr.recordcount GT 0>Show </cfif><cfoutput>#termStudentsNeedingBannerAttr.recordcount#</cfoutput> Student(s) Missing Banner Attributes."
	var linkMissingAttribHideTerm = "Hide Student List Missing Banner Attributes"

	$(document).ready(function() {
		$('#calculateBillingTerm').hide();
		$('#closeBillingCycleTerm').hide();

		$('#missingAttrLinkTerm').text(linkMissingAttribShowTerm);
		$('#missingAttrTerm').hide();

		$('#tableMissingAttrTerm').DataTable({
		    	dom: '<"top"B>rt<"bottom">',
				buttons:[{extend: 'csv',
            	  text: 'export'}],
            	paging:false
			});
	});

	function showMissingAttrTerm(){
		if($('#missingAttrLinkTerm').text() == linkMissingAttribShowTerm){
			$('#missingAttrLinkTerm').text(linkMissingAttribHideTerm);
			$('#missingAttrTerm').show();
		}else{
			$('#missingAttrLinkTerm').text(linkMissingAttribShowTerm);
			$('#missingAttrTerm').hide();
		}
	}
</script>