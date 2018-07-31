<cfparam name="billingStudentId" default = "#attributes.billingStudentId#">

<cfinvoke component="pcclinks.bill.Report" method="getBillingStudentRecord" returnvariable="qryBillingStudentRecord">
	<cfinvokeargument name="billingStudentId" value="#Variables.billingStudentId#">
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

	<cfif qryBillingStudentRecord.program CONTAINS 'attendance'>
		<div class="callout"> <!-- attendance detail -->
			<cfmodule template="AttendanceDetailInclude.cfm" billingStudentId = "#Variables.billingStudentId#" >
		</div> <!-- end attendance detail -->
	</cfif>

<form id="frm#Variables.billingStudentID#" action='javascript:saveBillingStudentRecord("frm#Variables.billingStudentID#");' method="post">
	<input type="hidden" id="billingStudentIdB#billingStudentId#" name="billingStudentId" value="#billingStudentId#">
	<cfif qryBillingStudentRecord.includeFlag EQ 0><div class="callout alert">Student Not Included In Billing for this Period.</div></cfif>

	<div class="callout">
		<!-- UNITS -->
		<div class="row">
			<div class="small-12 columns"><b>Billed</b><br></div>
		</div>
		<cfif qryBillingStudentRecord.program DOES NOT CONTAIN 'attendance'>
		<div class="row">
			<div class="small-3 columns">
				<label>Billed Credits:
				<input style="max-width:25%;" value="#NumberFormat(GeneratedBilledUnits,'_._')#" readonly></label>
			</div>
			<div class="small-3 columns">
				<label>Overage Credits:
				<input style="max-width:25%;"  value="#NumberFormat(GeneratedOverageUnits,'_._')#" readonly></label>
			</div>
			<div class="small-6 columns"></div>
		</div>
		<div class="row">
			<div class="small-12 columns">&nbsp;<br></div>
		</div>
		</cfif>
		<!-- AMOUNT -->
		<div class="row">
			<div class="small-3 columns">
				<label>Billed Amount:
				<input style="max-width:25%;"  value="#NumberFormat(GeneratedBilledAmount,'_._')#" readonly></label>
			</div>
			<div class="small-3 columns">
				<label>Overage Amount:
				<input style="max-width:25%;"  value="#NumberFormat(GeneratedOverageAmount,'_._')#" readonly></label>
			</div>
			<div class="small-2 columns">
				<label>Include in Billing:
				<input type="checkbox" id="includeFlagB#billingStudentId#" name="includeFlag" <cfif includeFlag EQ 1>checked</cfif>
					onClick='javascript:saveBillingStudentRecord("frm#billingStudentId#")'
				>
				</label>
			</div>
			<div class="small-4 columns"></div>
		</div>
	</div> <!-- END CALLOUT -->
	<!-- ATTENDANCE -->
	<cfif qryBillingStudentRecord.program CONTAINS 'attendance'>
	<div class="callout">
		<div class="row">
			<div class="small-12 columns">
				<label><b>Max Days:</b> <i>(Same number for both unless a month splits between two terms)</i></label>
			</div>
		</div>
		<div class="row">
			<div class="small-3 columns">
				<label>Billing Period:
					<input style="max-width:25%;" id="maxDaysPerBillingPeriodB#billingStudentId#" name="maxDaysPerBillingPeriod" value="#maxDaysPerBillingPeriod#" readonly>
				</label>
			</div>
			<div class="small-3 columns">
				<label>Month:
					<input style="max-width:25%;" id="maxDaysPerMonthB#billingStudentId#" name="maxDaysPerMonth" value="#maxDaysPerMonth#" readonly>
				</label>
			</div>
			<div class="small-6 columns">&nbsp;<br></div>
		</div>
		<div class="row">
			<div class="small-12 columns">
				<label>
					Adj Days For Month:
					<input style="max-width:25%;" name="adjustedDaysPerMonth" id="adjustedDaysPerMonthB#billingStudentId#" value="#adjustedDaysPerMonth#"
							 onInput="javascript:updateBilledAmountAttendance(#billingStudentId#);"
							<cfif readonly> readonly </cfif>
					>
				</label>
			</div>
		</div>
	</div><!-- ATTENDANCE NUMBERS -->
	</cfif>

	<!-- EXIT STATUS -->
	<div class="callout">
		<div class="row">
			<div class="small-4 columns">
				<label>Exit Date:
					<input style="max-width:75%" id="exitDateB#billingStudentId#" name="exitDate" value="#DateFormat(exitDate,'mm/dd/yyyy')#"
						onChange='javascript:saveBillingStudentRecord("frm#billingStudentId#")' class="fdatepicker"
					>
				</label>
			</div>
			<div class="small-8 columns">
				<label>Exit Reason:
				<select name="billingStudentExitReasonCode" id="billingStudentExitReasonCodeB#billingStudentId#" style="max-width:85%"
						onChange='javascript:saveBillingStudentRecord("frm#billingStudentId#")'>
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
					<select name="Program" id="ProgramB#billingStudentId#" style="max-width:85%"
						onChange='javascript:saveBillingStudentRecord("frm#billingStudentId#")'>
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
					<input style="width:85%;max-width:85%;" name="billingNotes" id="billingNotesB#billingStudentId#" value="#billingNotes#" type="text"
						onInput='javascript:saveBillingStudentRecord("frm#billingStudentId#")'
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



</cfoutput>




