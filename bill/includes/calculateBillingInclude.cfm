<cfparam name="billingDates" default="#attributes.billingDates#">
<cfparam name="qryTerms" default="#attributes.qryTerms#">
<cfparam name="billingType" default="#attributes.billingType#">
<cfparam name="openBillingStartDate" default="#attributes.openBillingStartDate#">
<cfparam name="divIdName" default="closeBillingCycle">
<cfif isDefined('attributes.divIdName')>
	<cfset divIdName = "#attributes.divIdName#">
</cfif>
<cfset formName = "frmCalculateBilling" & billingType>

<!--- query parameters --->
<form id=<cfoutput>"#formName#"</cfoutput> action="report.cfc?method=calculateBilling" method="post">
	<input type="hidden" name="billingType" id="billingType" value=<cfoutput>"#billingType#"</cfoutput>>
	<div class="row">
		<cfif billingType EQ 'attendance'>
			<div class="small-4 columns">
				<label for="billingStartDate">Month Start Date:
					<select name="billingStartDate" id="billingStartDate">
						<option disabled selected value="" > --Select Month Start Date-- </option>
					<cfoutput query="billingDates">
						<option value="#billingStartDate#" <cfif billingStartDate EQ openBillingStartDate>selected</cfif> > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
					</cfoutput>
					</select>
				</label>
			</div>
			<div class="small-3 columns">
				<label># of Max Days for Billing Period: <input name="maxDaysPerBillingPeriod" id="maxDaysPerBillingPeriod" type="text" /></label>
			</div>
		<cfelse>
			<div class="small-2 columns">
				<label>Term:<br/>
					<select name="term" id="term" >
						<option disabled selected value="" >
							--Select Term--
						</option>
					<cfset i = 1>
					<cfoutput query="qryTerms">
					<option  value="#term#" <cfif i EQ 1>selected</cfif>>#termDescription#</option>
					<cfset i = i + 1>
					</cfoutput>
					</select>
				</label>
			</div>
			<div class="small-3 columns">
				<label># of Max Credits Per Year: <input name="maxCreditsPerYear" id="maxCreditsPerYear" type="text" value="36"/></label>
			</div>
			<div class="small-2 columns">
				<label># of Max Days Per Year: <input name="maxDaysPerYear" id="maxDaysPerYear" type="text" value="175"/></label>
			</div>
		</cfif>
		<div class="small-5 columns">
			<input class="button" value="Calculate Billing" onClick='javascript:saveValues(<cfoutput>"#formName#"</cfoutput>);' />
			<input class="button secondary" value="Cancel" onClick=<cfoutput>'javascript:closeForm("#divIdName#");'</cfoutput> />
			<div id="saveMessage<cfoutput>#formName#</cfoutput>"></div>
		</div>
	</div>
</form>

