<cfcomponent extends="pcclinks.Application">
	<cfparam name="pcc_source" default='/pcclinks' >
	<!---<cfinclude template="#pcc_source#/includes/ApplicationIncludes.cfc">--->
	<cfset This.name = "PCC Links Billing" />
	<cfset This.application = 'Billing' />
	<cfset This.sessionManagement = True />
	<cfset This.sessiontimeout=createTimeSpan(0,2,0,0)>
	<cfset This.logfilename = "pcclinks_bill">
</cfcomponent>