
<cffunction name="logEntry" access="remote">
	<cfargument name="label" default="">
	<cfargument name="value" required=true>
	<cfargument name="level" default=0>
	<cfargument name="logfilename" default="pcclinks">
	<cfset debuglevel = 4>

	<cfif IsDefined("session") && StructKeyExists(session, "logfilename")>
		<cfset arguments.logfilename = "#Session.logfilename#">
	</cfif>

	<cfif debuglevel GTE arguments.level>
		<cfif IsDefined("session") && StructKeyExists(session, "username")>
			<cfset logtext = "User:" & session.username & ": ">
		<cfelse>
			<cfset logtext = "No session and/or user yet: ">
		</cfif>
		<cfif len(label) GT 0>
			<cfset logtext= logtext & arguments.label & ":" >
		</cfif>
		<cfset logtext = logtext & arguments.value>
		<cflog file="#arguments.logFileName#" text="#logtext#">
	</cfif>
</cffunction>

<cffunction name="logDump" access="remote">
	<cfargument name="label" default="">
	<cfargument name="value" required=true>
	<cfargument name="level" default=0>
	<cfsavecontent variable="logtext">
		<cfdump var="#arguments.value#" format="text">
	</cfsavecontent>
	<cfset logEntry(label=arguments.label, value=logtext, level=arguments.level)>
</cffunction>