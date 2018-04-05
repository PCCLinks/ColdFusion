<cfparam name="billingStartDate" default="">
<cfif isDefined("attributes.billingStartDate")>
	<cfset billingStartDate = attributes.billingStartDate>
<cfelse>
	<cfset billingStartDate = url.billingStartDate>
</cfif>
<cfinvoke component="pcclinks.bill.Report" method="getAttendanceBilledInfo" returnvariable="billedInfo">
	<cfinvokeargument name="billingStartDate" value="#billingStartDate#">
</cfinvoke>

	<ul>
		<li id="currentBillingAmount">Current Billing Amount: <cfoutput>#billedInfo.BilledAmount#</cfoutput></li>
		<li>Days Per Month to be billed: <cfoutput>#billedInfo.MaxDaysPerMonth#</cfoutput></li>
	</ul>