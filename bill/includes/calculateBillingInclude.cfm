<cfparam name="qryTerms" default="">
<cfif isDefined('attributes.qryTerms')>
	<cfset qryTerms = attributes.qryTerms>
<cfelse>
	<cfinvoke component="pcclinks.bill.LookUp" method="getOpenTerms" returnvariable="qryTerms"></cfinvoke>
</cfif>

<cfparam name="billingDates" default="">
<cfif isDefined('attributes.billingDates')>
	<cfset billingDates = attributes.billingDates>
<cfelse>
	<cfinvoke component="pcclinks.bill.LookUp" method="getOpenAttendanceDates" returnvariable="billingDates"></cfinvoke>
</cfif>

<cfparam name="billingType" default="">
<cfif isDefined('url.type')>
	<cfset billingType = url.type>
<cfelse>
	<cfset billingType = attributes.billingType>
</cfif>

<cfparam name="openBillingStartDate" default="">
<cfif isDefined('url.openBillingStartDate')><cfset openBillingStartDate = url.openBillingStartDate></cfif>
<cfif isDefined('attributes.openBillingStartDate')><cfset openBillingStartDate = attributes.openBillingStartDate></cfif>

<cfparam name="divIdName" default="closeBillingCycle">
<cfparam name="showCancelButton" default=false>

<cfinvoke component="pcclinks.bill.Report" method="getBillingCycle" returnvariable="billingCycle">
	<cfinvokeargument name="billingStartDate" value="#openBillingStartDate#">
	<cfinvokeargument name="billingType" value="#billingType#">
</cfinvoke>

<cfif isDefined('attributes.divIdName')>
	<cfset divIdName = "#attributes.divIdName#">
	<cfset showCancelButton=true>
</cfif>
<cfset formName = "frmCalculateBilling" & billingType>

<!--- query parameters --->
<form id=<cfoutput>"#formName#"</cfoutput> action="report.cfc?method=calculateBilling" method="post">
	<input type="hidden" name="billingType" id="billingType" value=<cfoutput>"#billingType#"</cfoutput>>
	<div class="row">
		<cfif billingType EQ 'attendance'>
			<div class="small-4 medium-4 columns">
				<label for="billingStartDate">Month Start Date:
					<select name="billingStartDate" id="billingStartDate">
						<option disabled selected value="" > --Select Month Start Date-- </option>
					<cfoutput query="billingDates">
						<option value="#billingStartDate#" <cfif billingStartDate EQ openBillingStartDate>selected</cfif> > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
					</cfoutput>
					</select>
				</label>
			</div>
			<div class="small-3 medium-3 columns">
				<label># of Max Days for Billing Period: <input name="MaxBillableDaysPerBillingPeriod" id="MaxBillableDaysPerBillingPeriod" type="text" value="<cfoutput>#billingCycle.MaxBillableDaysPerBillingPeriod#</cfoutput>"/></label>
			</div>
		<cfelse>
			<div class="small-2 medium-2 columns">
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
			<div class="small-3 medium-3 columns">
				<label># of Max Credits Per Term: <input name="MaxBillableCreditsPerTerm" id="MaxBillableCreditsPerTerm" type="text" value="<cfoutput>#billingCycle.MaxBillableCreditsPerTerm#</cfoutput>"/></label>
			</div>
			<div class="small-2 medium-2 columns">
				<label># of Max Days Per Year: <input name="MaxBillableDaysPerYear" id="MaxBillableDaysPerYear" type="text" value="<cfoutput>#billingCycle.MaxBillableDaysPerYear#</cfoutput>"/></label>
			</div>
		</cfif>
		<div class="small-5 medium-5 columns">
			<input class="button" value="Generate Billing" onClick='javascript:saveValues(<cfoutput>"#formName#"</cfoutput>);' style="margin-top:22px;margin-bottom:0px;"/>
			<cfif showCancelButton><input class="button secondary" value="Cancel" onClick=<cfoutput>'javascript:closeForm("#divIdName#");'</cfoutput> style="margin-top:22px;margin-bottom:0px;" /></cfif>
			<div id="saveMessage<cfoutput>#formName#</cfoutput>"></div>
		</div>
	</div>
</form>