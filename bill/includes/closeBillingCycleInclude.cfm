<cfparam name="billingDates" default="#attributes.billingDates#">
<cfparam name="qryTerms" default="#attributes.qryTerms#">
<cfparam name="billingType" default="#attributes.billingType#">
<cfparam name="openBillingStartDate" default="#attributes.openBillingStartDate#">
<cfparam name="divIdName" default="closeBillingCycle">
<cfif isDefined('attributes.divIdName')>
	<cfset divIdName = "#attributes.divIdName#">
</cfif>
<cfset formName = "frmCloseBilling" & billingType>

<form id=<cfoutput>"#formName#"</cfoutput> action="report.cfc?method=closeBillingCycle" method="post">
	<input type="hidden" name="billingType" id="billingType" value=<cfoutput>"#billingType#"</cfoutput>>
	<div class="row">
		<cfif billingType EQ "attendance">
		<div class="small-3 columns">
			<label for="billingStartDate">Month Start Date:
				<select name="billingStartDate" id="billingStartDate">
					<option disabled selected value="" > --Select Month Start Date-- </option>
				<cfoutput query="billingDates">
					<option value="#billingStartDate#" <cfif billingStartDate EQ openBillingStartDate>selected</cfif> > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
				</cfoutput>
				</select>
			</label>
		</div>
		<cfelse>
		<div class="small-3 columns">
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
		</cfif>
		<div class="small-6 columns">
			<div id="saveMessagefrmCloseBillingCycle">&nbsp;</div>
			<input class="button" value="Close Billing Cycle" onClick='javascript:saveValues(<cfoutput>"#formName#"</cfoutput>);' />
			<input class="button secondary" value="Cancel" onClick='javascript:closeForm(<cfoutput>"#divIdName#"</cfoutput>);' />
		</div>
	</div>
</form>