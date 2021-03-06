<cfparam name="qryTerms" default="">
<cfif isDefined('attributes.qryTerms')>
	<cfset qryTerms = attributes.qryTerms>
<cfelse>
	<cfinvoke component="pcclinks.bill.LookUp" method="getClosedTerms" returnvariable="qryTerms"></cfinvoke>
</cfif>

<cfparam name="billingDates" default="">
<cfif isDefined('attributes.billingDates')>
	<cfset billingDates = attributes.billingDates>
<cfelse>
	<cfinvoke component="pcclinks.bill.LookUp" method="getClosedAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>
</cfif>

<cfparam name="billingType" default="">
<cfif isDefined('url.type')>
	<cfset billingType = url.type>
<cfelse>
	<cfset billingType = attributes.billingType>
</cfif>

<cfparam name="divIdName" default="closeBillingCycle">
<cfparam name="showCancelButton" default=false>
<cfif isDefined('attributes.divIdName')>
	<cfset divIdName = "#attributes.divIdName#">
	<cfset showCancelButton=true>
</cfif>
<cfset formName = "frmOpenBilling" & billingType>

<form id=<cfoutput>"#formName#"</cfoutput> action="report.cfc?method=openBillingCycle" method="post">
	<input type="hidden" name="billingType" id="billingType" value=<cfoutput>"#billingType#"</cfoutput>>
	<div class="row">
		<cfif billingType EQ "attendance">
		<div class="small-3 medium-3 columns">
			<label for="billingStartDate">Month Start Date:
				<select name="billingStartDate" id="billingStartDate">
					<option disabled selected value="" > --Select Month Start Date-- </option>
				<cfoutput query="billingDates">
					<option value="#billingStartDate#">#DateFormat(billingStartDate,'mm-dd-yy')# </option>
				</cfoutput>
				</select>
			</label>
		</div>
		<cfelse>
		<div class="small-3 medium-3 columns">
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
		<div class="small-6 medium-9 columns">
			<input class="button medium" value="Open Billing Cycle" onClick='javascript:saveValues(<cfoutput>"#formName#"</cfoutput>);' style="margin-top:22px;margin-bottom:0px;"/>
			<cfif showCancelButton><input class="button secondary" value="Cancel" onClick='javascript:closeForm(<cfoutput>"#divIdName#"</cfoutput>);' /></cfif>
			<div id="saveMessage<cfoutput>#formName#</cfoutput>">&nbsp;</div>
		</div>
	</div>
</form>