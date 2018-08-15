<cfoutput>
<form id="frm#FORM.billingStudentID#" >
	<input type="hidden" id="billingStudentId#FORM.billingStudentId#" name="billingStudentId" value="#FORM.billingStudentId#">
	<input type="hidden" id="billingStartDate#FORM.billingStudentId#" name="billingStartDate" value="#FORM.billingStartDate#">
	<input type="hidden" id="billingEndDate#FORM.billingStudentId#" name="billingEndDate" value="#FORM.billingEndDate#">
	<input type="hidden" id="changeMade#FORM.billingStudentId#" name="changeMade" value=false>

	<!-- EXIT STATUS -->
	<div class="callout">
		<div class="row">
			<div class="small-6 columns">
				<label>Exit Date:<br>
					<input id="exitDate#FORM.billingStudentId#" name="exitDate" value="<cfif FORM.exitDate NEQ 'null'>#DateFormat(FORM.exitDate,'yyyy-mm-dd')#</cfif>"
						onChange='javascript:exitStudentInclude_saveExitStudentValues("frm#FORM.billingStudentId#")' class="fdatepicker"
					>
				</label>
			</div>
			<div class="small-6 columns">
				<label>Include in Billing:
				<input type="checkbox" id="includeFlag#FORM.billingStudentId#" name="includeFlag" <cfif FORM.includeFlag EQ 1>checked</cfif>
					onClick='javascript:exitStudentInclude_saveExitStudentValues("frm#FORM.billingStudentId#")'
				>
				</label>
			</div>
		</div>
		<br>
		<div class="row">
			<div class="small-12 columns">
				<label>Exit Reason:<br>
				<select name="billingStudentExitReasonCode" id="billingStudentExitReasonCode#FORM.billingStudentId#" style="max-width:85%"
						onChange='javascript:exitStudentInclude_saveExitStudentValues("frm#FORM.billingStudentId#")'>
					<option  selected value="" >
						--Select Exit Reason--
					</option>
					<cfloop query="#Session.Lookup.GetExitReason#">
						<option value="#billingStudentExitReasonCode#" <cfif #billingStudentExitReasonCode# EQ #FORM.billingStudentExitReasonCode#> selected </cfif> > #billingStudentExitReasonDescription# </option>
					</cfloop>
				</select>
				</label>
			</div>
		</div>
	</div> <!-- END EXIT STATUS -->
	<cfif FORM.program CONTAINS 'Attendance'>
	<div class="callout">
		<div class="row">
			<div class="small-6 columns">
				<label>
					Adj Days For Month:<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="If the student should be billed for less than the whole month, enter the max number of days here." ><img src="/pcclinks/images/tooltip.png" width="25" height="25"></span>
					<br>
					<input  name="adjustedDaysPerMonth" id="adjustedDaysPerMonth#FORM.billingStudentId#" value="<cfif FORM.adjustedDaysPerMonth NEQ 'null'>#FORM.adjustedDaysPerMonth#</cfif>"
							 onChange='javascript:exitStudentInclude_saveExitStudentValues("frm#FORM.billingStudentId#");'
					>
				</label>
			</div>
			<div class="small-6 columns">
			<input class="button small" onclick="javascript:exitStudentInclude_setBillableDays(#FORM.billingStudentId#)" value="Set Billable Days" style="background-color:gray" >
			</div>
		</div>
	</div>
	</cfif>
</form>






</cfoutput>