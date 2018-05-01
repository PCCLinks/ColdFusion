<cfparam name="billingStudentId">
<cfif IsDefined("attributes.billingStudentId")>
	<cfset Variables.billingStudentId = attributes.billingStudentId>
<cfelse>
	<cfset Variables.billingStudentId = url.billingStudentId>
</cfif>

<cfinvoke component="pcclinks.bill.Report" method="getBillingStudentRecord" returnvariable="qryBillingStudentRecord">
	<cfinvokeargument name="billingStudentId" value="#Variables.billingStudentID#">
</cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getExitReasons" returnvariable="exitReasons"></cfinvoke>

<cfoutput query="qryBillingStudentRecord">
<cfset readonly = false>
<cfif BillingStatus EQ 'BILLED'><cfset readonly = true></cfif>


<!---

ARCHITECTURE
Form Inputs have the name of the field in the database, with an id that includes the billingStudentId to keep the id unique.
The billingStudentTabInclude.cfm calls this page multiple times, resulting in multiple copies of the form
on a single page

--->
<form id="frm#Variables.billingStudentID#" action='javascript:saveValues("frm#Variables.billingStudentID#");' method="post">
	<input type="hidden" id="billingStudentId#billingStudentId#" name="billingStudentId" value="#billingStudentId#">
	<cfif qryBillingStudentRecord.includeFlag EQ 0><div class="callout alert">Student Not Included In Billing for this Period.</div></cfif>
	<cfif qryBillingStudentRecord.program DOES NOT CONTAIN 'attendance'>
	<!-- UNITS -->
	<div class="callout">
		<div class="row">
			<div class="small-6 columns">
				<b>Billed Credits</b>
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedBilledUnits,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<input style="max-width:25%;" name="correctedBilledUnits" id="correctedBilledUnits#billingStudentId#" value="#correctedBilledUnits#"
						onInput='javascript:saveValues("frm#billingStudentId#");' onchange='javascript:updateCorrectedBilledAmount("#maxCreditsPerTerm#", "#maxDaysPerYear#", #billingStudentId#);'
						<cfif readonly> readonly </cfif>
					>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledUnits,'_._')#</label>
			</div>
			<div class="small-6 columns">
				<b>Overage Credits</b>
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedOverageUnits,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<input style="max-width:25%;" name="correctedOverageUnits" id="correctedOverageUnits#billingStudentId#" value="#correctedOverageUnits#"
							onInput='javascript:saveValues("frm#billingStudentId#");' onchange='javascript:updateCorrectedOverageAmount("#maxCreditsPerTerm#", "#maxDaysPerYear#", #billingStudentId#);'
							<cfif readonly> readonly </cfif>
					>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalOverageUnits,'_._')#</label>
			</div>
		</div>
	</div> <!-- END UNITS -->
	</cfif>
	<!-- AMOUNT -->
	<div class="callout">
		<div class="row">
			<div class="small-6 columns">
				<b>Billed Amount</b>
				<label>Generated:&nbsp;&nbsp;
					<input style="max-width:25%;" id="generatedBilledAmount#billingStudentId#" name="generatedBilledAmount" value="#NumberFormat(generatedBilledAmount,'_._')#" readonly></label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<input style="max-width:25%;" name="correctedBilledAmount" id="correctedBilledAmount#billingStudentId#" value="#correctedBilledAmount#"
						onInput='javascript:saveValues("frm#billingStudentId#")'
						<cfif readonly> readonly </cfif>
					>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledAmount,'_._')#</label>
			</div>
			<div class="small-6 columns">
				<b>Overage Amount</b>
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedOverageAmount,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<input style="max-width:25%;" name="correctedOverageAmount" id="correctedOverageAmount#billingStudentId#" value="#correctedOverageAmount#"
						onInput='javascript:saveValues("frm#billingStudentId#")'
						<cfif readonly> readonly </cfif>
					>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalOverageAmount,'_._')#</label>
			</div>
			<cfif readonly>
			<div class="small-12 columns">
				<label>Corrected Post Billed Amount:&nbsp;&nbsp;&nbsp;
				<input style="max-width:25%;" name="postBillCorrectedBilledAmount" id="postBillCorrectedBilledAmount#billingStudentId#" value="#postBillCorrectedBilledAmount#"
						onInput='javascript:saveValues("frm#billingStudentId#")'
				>
				</label>
			</div>
			</cfif>
			<div class="small-12 columns">
				<label>Include in Billing:
				<input type="checkbox" id="includeFlag#billingStudentId#" name="includeFlag" <cfif includeFlag EQ 1>checked</cfif>
					onClick='javascript:saveValues("frm#billingStudentId#")'
				>
				<label>
			</div>
		</div>
	</div> <!-- END AMOUNT -->
	<!-- ATTENDANCE -->
	<cfif qryBillingStudentRecord.program CONTAINS 'attendance'>
	<div class="callout">
		<div class="row">
			<div class="small-12 columns">
				<label><b>Max Days:</b> <i>(Same number for both unless a month splits between two terms)</i></label>
			</div>
		</div>
		<div class="row">
			<div class="small-6 columns">
				<label>Billing Period:
					<input style="max-width:25%;" id="maxDaysPerBillingPeriod#billingStudentId#" name="maxDaysPerBillingPeriod" value="#maxDaysPerBillingPeriod#" readonly>
				</label>
			</div>
			<div class="small-6 columns">
				<label>Month:
					<input style="max-width:25%;" id="maxDaysPerMonth#billingStudentId#" name="maxDaysPerMonth" value="#maxDaysPerMonth#" readonly>
				</label>
			</div>
		</div>
		<div class="row">
			<div class="small-12 columns">
				<label>
					Adj Days For Month:
					<input style="max-width:25%;" name="adjustedDaysPerMonth" id="adjustedDaysPerMonth#billingStudentId#" value="#adjustedDaysPerMonth#"
							 onInput="javascript:updateBilledAmountAttendance(#billingStudentId#);"
							<cfif readonly> readonly </cfif>
					>
				</label>
			</div>
		</div>
	</div> <!-- ATTENDANCE NUMBERS -->
	</cfif>
	<!-- EXIT STATUS -->
	<div class="callout">
		<div class="row">
			<div class="small-4 columns">
				<label>Exit Date:
					<input style="max-width:75%" id="exitDate#billingStudentId#" name="exitDate" value="#DateFormat(exitDate,'mm/dd/yyyy')#"
						onChange='javascript:saveValues("frm#billingStudentId#")' class="fdatepicker"
					>
				</label>
			</div>
			<div class="small-8 columns">
				<label>Exit Reason:
				<select name="billingStudentExitReasonCode" id="billingStudentExitReasonCode#billingStudentId#" style="max-width:85%"
						onChange='javascript:saveValues("frm#billingStudentId#")'>
					<option  selected value="" >
						--Select Exit Reason--
					</option>
					<cfloop query="exitReasons">
						<option value="#billingStudentExitReasonCode#" <cfif #qryBillingStudentRecord.billingStudentExitReasonCode# EQ #billingStudentExitReasonCode#> selected </cfif> > #billingStudentExitReasonDescription# </option>
					</cfloop>
				</select>
				</label>
			</div>
		</div>
	</div> <!-- END EXIT STATUS -->
	<!-- PROGRAM --->
	<div class="callout">
		<div class="row">
			<div class="small-12 columns">
				<label>Program:
					<select name="Program" id="Program#billingStudentId#" style="max-width:85%"
						onChange='javascript:saveValues("frm#billingStudentId#")'>
					<option  selected value="" >
						--Select Program--
					</option>
					<cfloop query="programs">
						<option value="#programName#" <cfif #qryBillingStudentRecord.program# EQ #programName#> selected </cfif> > #programName# </option>
					</cfloop>
				</select>
				</label>
			</div>
		</div>
	</div> <!-- END PROGRAM -->
	<div class="callout">
		<div class="row">
			<div class="small-12 columns" >
				<label>Internal Billing Notes:<br/>
					<input style="width:85%;max-width:85%;" name="billingNotes" id="billingNotes#billingStudentId#" value="#billingNotes#" type="text"
						onInput='javascript:saveValues("frm#billingStudentId#")'
					>
				</label>
			</div>
		</div>
	</div>
	<div class="row">
		<div class="small-12 columns" style="color:red">
			#ErrorMessage#
		</div>
	</div>
	<div class="row" >
		<div class="small-12 columns" style="text-align:right">
			<div id="savemessage#billingStudentId#"></div>
		</div>
	</div>
	</form>

	<cfif qryBillingStudentRecord.program CONTAINS 'attendance'>
		<div class="callout"> <!-- attendance detail -->
			<cfmodule template="AttendanceDetailInclude.cfm" billingStudentId = "#Variables.billingStudentId#" >
		</div> <!-- end attendance detail -->
	</cfif>

</cfoutput>

<script>
$(document).ready(function(){
	$('.fdatepicker').fdatepicker({
		format: 'mm/dd/yyyy',
		disableDblClickSelection: true,
		leftArrow:'<<',
		rightArrow:'>>',
		closeIcon:'X',
		closeButton: true
	});
})

</script>



