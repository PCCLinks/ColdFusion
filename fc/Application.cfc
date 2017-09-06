<cfcomponent>
	<cfset This.name = "PCC Future Connect" />
	<cfset This.sessionManagement = True />
	<cfset This.clientmanagement = "yes" />
	<cfset This.setclientcookies = "yes" />
	<cfset This.setdomaincookies = "no" />
	<cfset This.loginstorage = "session" />
	<cfset This.datasource = "pcclinks" />
	<cfset This.sessiontimeout=createTimeSpan(0,2,0,0)>

	<cffunction name="OnApplicationStart"></cffunction>

    <cffunction name="OnSessionStart">
        <CFLOCK SCOPE="SESSION" TYPE="READONLY" TIMEOUT="5">
	        <cfset SESSION.DateInitialized = Now() />
        </CFLOCK>
    </cffunction>

	<!---<cffunction name="OnRequestStart">
		<cfargument name="req">
		<cfset logEntry(value="OnRequestStart")>
		 <cfset logDump(label="req", value="#req#")>
		<cfif not structKeyExists(session, "username") >
		 	<cfset logDump(label="missingusername", value="#session#")>
    		<!---for ajax requests, throw an error --->
			<cfset Variables.reqData = getHTTPRequestData() >
		 	<!---<cfset logDump(label="reqData", value="#Variables.reqData#")>--->
    		<cfif structKeyExists(Variables.reqData.headers,"X-Requested-With")
					&& reqData.headers["X-Requested-With"] eq "XMLHttpRequest">
				<cfset logEntry(value="SessionTimeout")>
				<cfheader statusCode=600 statustext="SessionTimeout" >
		 	<cfelse>
			 	<cfset StructClear(Session)>
		     	<cfset session.authorized = "0">
		     	<cfset sessionInvalidate() >
		 	</cfif>
		 </cfif>
		<cfreturn "true">
	</cffunction>--->


	<cffunction name="onError">
		<cfargument name="exception" >
		<cfargument name="thrownError" default="">
		<cfargument name="eventname" type="string" >

		<cfset var errortext = "">

		<cfset logentry(value="-------------BEGIN ENTRY------------") >
		<cfset logentry(value="#arguments.exception#") >
		<cfif StructkeyExists(arguments.exception, "cause")>
		    <cfset logEntry(label="Message", value="#arguments.exception.cause.message#")>
		    <cfset msg = arguments.exception.cause.message>
		    <cfset logEntry(label="StackTrace", value="#arguments.exception.cause.StackTrace#")>
		    <cfif StructKeyExists(arguments.exception.cause, "TagContext")>
			    <cfset tag = arguments.exception.cause.TagContext>
			 </cfif>
		<cfelse>
		    <cfset logEntry(label="Message", value="#arguments.exception.message#")>
		    <cfset msg = arguments.exception.message>
		    <cfset logEntry(label="StackTrace", value="#arguments.exception.StackTrace#")>
		    <cfif StructKeyExists(arguments.exception, "TagContext")>
			    <cfset tag = arguments.exception.TagContext>
			 </cfif>
		</cfif>
		<cfif len(arguments.thrownError) GT 0>
			<cfset logEntry(label="ThrownError", value="#arguments.thrownError#")>
		</cfif>
		<cfif IsDefined("tag")>
		   	<cfif IsArray(tag) and arrayLen(tag) EQ 1>
			    <cfset tg = tag[1]>
				<cfset tagContext = "Column:" & tg.Column
		   			& " ID: "& tg.ID & " LINE: " & tg.Line & " RAW_TRACE: " & tg.Raw_Trace
		   			& " TEMPLATE: " & tg.Template & " TYPE: " & tg.Type >
		    </cfif>
		</cfif>
		<cfif StructKeyExists(arguments.exception, "DataSource") >
		    <cfset logEntry(label="DataSource", value="#arguments.exception.DataSource#")>
		</cfif>
		<cfif StructKeyExists(arguments.exception, "Detail") >
		   	<cfset logEntry(label="Detail", value="#arguments.exception.Detail#")>
		   </cfif>
		<cfif StructKeyExists(arguments.exception, "Sql") >
		   	<cfset logEntry(label="Sql", value="#arguments.exception.Sql#")>
		   </cfif>
		   <cfset logentry(value="-------------END ENTRY------------") >

		<cfset Session.Exception = arguments.exception >
		<cfset Session.ThrownError = arguments.thrownError>
		<cfset Session.Error = "#msg#<br/>
			    http://#cgi.server_name##cgi.script_name#?#cgi.query_string#<br />
			    Time: #dateFormat(now(), 'short')# #timeFormat(now(), 'short')#<br /><br/>" >

		<cfsavecontent variable="errortext">
			<cfoutput>
			    An error occurred:<br/>
			    http://#cgi.server_name##cgi.script_name#?#cgi.query_string#<br />
			    Time: #dateFormat(now(), "short")# #timeFormat(now(), "short")#<br /><br/>

			    <cfdump var="#arguments.exception#" >
		    </cfoutput>
		</cfsavecontent>
		<cfmail to="arlette.slachmuylder@pcc.edu" from="arlette.slachmuylder@pcc.edu" subject="PCC Links Future Connect Application Error" type="html">
			#errortext#
		</cfmail>

		<cfif StructKeyExists(Form, 'isAjax')>
			<cfheader statusCode=600 statustext="#msg#" >
		<cfelse>
		   	<cflocation url="error.cfm">
		</cfif>

	</cffunction>
	<cffunction name="logEntry">
		<cfargument name="label" default="">
		<cfargument name="value" required=true>
		<cfif len(label) GT 0>
			<cfset logtext= arguments.label & ":" & arguments.value>
		<cfelse>
			<cfset logtext = value>
		</cfif>
		<cflog file="pcclinks_fc" text="#logtext#">
	</cffunction>
</cfcomponent>