<cfcomponent extends="pcclinks.Application">
	<!---<cfinclude template="#pcc_source#/includes/ApplicationIncludes.cfc">--->
	<cfset This.name = "PCC Future Connect" />
	<cfset This.sessionManagement = True />
	<cfset This.sessiontimeout=createTimeSpan(0,2,0,0)>
	<cfset This.logfilename = "pcclinks_fc">

    <cffunction name="OnSessionStart">
		<cfset SUPER.OnSessionStart() />
        <CFLOCK SCOPE="SESSION" TYPE="READONLY" TIMEOUT="5">
			<cfset session.logfilename = This.logfilename>
        </CFLOCK>
    </cffunction>
</cfcomponent>