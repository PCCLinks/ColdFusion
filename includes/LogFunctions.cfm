<cfparam name="logfilename" default="pcclinks">
<cfif IsDefined("session") && StructKeyExists(session, "logfilename")>
	<cfset logfilename = "#session.logfilename#">
</cfif>

<cffunction name="logEntry" access="remote">
		<cfargument name="label" default="">
		<cfargument name="value" required=true>
		<cfargument name="level" default=0>
		<cfset debuglevel = 2>
		<cfif debuglevel GTE arguments.level>
			<cfif len(label) GT 0>
				<cfset logtext= arguments.label & ":" & arguments.value>
			<cfelse>
				<cfset logtext = value>
			</cfif>
			<cflog file="#logFileName#" text="#logtext#">
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