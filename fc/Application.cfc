<cfcomponent extends="pcclinks.Application">
	<cfparam name="pcc_source" default='/pcclinks' />
	<cfset This.name = "PCC Future Connect" />
	<cfset This.sessionManagement = True />
	<!---><cfset This.sessiontimeout=createTimeSpan(0,2,0,0)>--->

	<cfset This.sessiontimeout=createTimeSpan(0,2,0,0)>
	<cfset This.logfilename = "pcclinks_fc">


</cfcomponent>
