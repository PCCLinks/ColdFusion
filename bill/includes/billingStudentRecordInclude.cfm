<cfinvoke component="Report" method="getBillingStudentRecord" returnvariable="qryBillingStudentRecord">
	<cfinvokeargument name="billingStudentId" value="#attributes.billingStudentID#">
</cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getExitReasons" returnvariable="exitReasons"></cfinvoke>

<cfoutput query="qryBillingStudentRecord">
<cfset readonly = false>
<cfif BillingStatus EQ 'BILLED'><cfset readonly = true></cfif>


<form id="frm#attributes.billingStudentID#" action='javascript:saveValues("frm#attributes.billingStudentID#");' method="post">
	<input type="hidden" id="billingStudentId" name="billingStudentId" value="#billingStudentId#">
	<cfif qryBillingStudentRecord.program DOES NOT CONTAIN 'attendance'>
	<!-- UNITS -->
	<div class="callout">
		<div class="row">
			<div class="small-6 columns">
				Billed Credits
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedBilledUnits,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedBilledUnits#
					<cfelse><input style="width:65px;" name="correctedBilledUnits" id="correctedBilledUnits" value="#correctedBilledUnits#"
									onchange='javascript:updateCorrectedBilledAmount("#maxCreditsPerTerm#", "#maxDaysPerYear#");''>
					</cfif>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledUnits,'_._')#</label>
			</div>
			<div class="small-6 columns">
				Overage Credits
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedOverageUnits,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedOverageUnits#
					<cfelse><input style="width:65px;" name="correctedOverageUnits" id="correctedOverageUnits" value="#correctedOverageUnits#"
								onchange='javascript:updateCorrectedOverageAmountTerm("#maxCreditsPerTerm#", "#maxDaysPerYear#");'>
					</cfif>
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
				Billed Amount
				<label>Generated:&nbsp;&nbsp;
					<input style="width:45px;" id="generatedBilledAmount" name="generatedBilledAmount" value="#NumberFormat(generatedBilledAmount,'_._')#" readonly></label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedBilledAmount#
					<cfelse><input style="width:45px;" name="correctedBilledAmount" id="correctedBilledAmount" value="#correctedBilledAmount#">
					</cfif>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledAmount,'_._')#</label>
			</div>
			<div class="small-6 columns">
				Overage Amount
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedOverageAmount,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedOverageAmount#
					<cfelse><input style="width:45px;" name="correctedOverageAmount" id="correctedOverageAmount" value="#correctedOverageAmount#">
					</cfif>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalOverageAmount,'_._')#</label>
			</div>
			<div class="small-12 columns">
				<label>Corrected Post Billed Amount:&nbsp;&nbsp;&nbsp;
				<input style="width:45px;" name="postBillCorrectedBilledAmount" id="postBillCorrectedBilledAmount" value="#postBillCorrectedBilledAmount#">
				</label>
			</div>
		</div>
	</div> <!-- END AMOUNT -->
	<!-- EXIT STATUS / ATTENDANCE -->
	<div class="callout">
		<cfif qryBillingStudentRecord.program CONTAINS 'attendance'>
		<div class="row">
			<div class="small-6 columns">
				<label>Max Days For Month:
					<input style="width:45px;" id="maxDaysPerMonth" name="maxDaysPerMonth" value="#maxDaysPerMonth#" readonly>
				</label>
			</div>
			<div class="small-6 columns">
				<label>
					Adj Days For Month: <input style="width:45px;" name="adjustedDaysPerMonth" id="adjustedDaysPerMonth" value="#adjustedDaysPerMonth#"
												onchange="javascript:updateBilledAmountAttendance();">
				</label>
			</div>
		</div>
		</cfif>
		<div class="row">
			<div class="small-12 columns">
				<label>Exit Reason:
				<cfif readonly>
					#billingStudentExitReasonCode#
				<cfelse>
				<select name="billingStudentExitReasonCode" id="billingStudentExitReasonCode" style="max-width:600px">
					<option disabled selected value="" >
						--Select Exit Reason--
					</option>
					<cfloop query="exitReasons">
						<option value="#billingStudentExitReasonCode#" <cfif #qryBillingStudentRecord.billingStudentExitReasonCode# EQ #billingStudentExitReasonCode#> selected </cfif> > #billingStudentExitReasonDescription# </option>
					</cfloop>
				</select>
				</cfif>
				</label>
			</div>
		</div>
	</div> <!-- END EXIT STATUS / ATTENDANCE NUMBERS -->
	<div class="callout">
		<div class="row">
			<div class="small-12 columns" >
				<label>Internal Billing Notes:<br/>
					<input style="width:300px;" name="billingNotes" value="#billingNotes#" type="text"  >
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
			<input type="submit" value="Save Changes" class="button" ><br/>
			<div id="savemessage"></div>
		</div>
	</div>
	</form>

	<cfif qryBillingStudentRecord.program CONTAINS 'attendance'>
		<div class="callout"> <!-- attendance detail -->
			<cfmodule template="AttendanceDetailInclude.cfm" billingStudentId = "#qryBillingStudentRecord.billingStudentId#" >
		</div> <!-- end attendance detail -->
	</cfif>

</cfoutput>




