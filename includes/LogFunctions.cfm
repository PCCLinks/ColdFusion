
<cffunction name="logEntry" access="remote">
	<cfargument name="label" default="">
	<cfargument name="value" required=true>
	<cfargument name="level" default=0>
	<cfargument name="logfilename" default="pcclinks">
	<cfset debuglevel = 5>

	<cfif IsDefined("this.logfilename")>
		<cfset arguments.logfilename = "#this.logfilename#">
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

<cffunction name="emailError" access="remote">
	<cfargument name="errorText" required=true>
	<cfif CGI.SERVER_NAME DOES NOT CONTAIN "intranettest" && CGI.SERVER_NAME DOES NOT CONTAIN "localhost">
		<cfmail to="arlette.slachmuylder@pcc.edu" from="arlette.slachmuylder@pcc.edu" subject="PCC Links Future Connect Application Error" type="html">
			#errortext#
		</cfmail>
	<cfelse>
		<cfset logEntry(value=errorText)>
	</cfif>
</cffunction>