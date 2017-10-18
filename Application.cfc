<!---<cfcomponent>
	<cfset This.name = "PCC Links Applications" />
	<cfset This.sessionManagement = "yes" />
	<cfset This.clientmanagement = "yes" />
	<cfset This.setclientcookies = "yes" />
	<cfset This.setdomaincookies = "no" />
	<cfset This.loginstorage = "session" />
	<cfset This.datasource = "pcclinks" />
</cfcomponent>--->

<cfcomponent>

<cfparam name="pcc_source" default='/pcclinks' />

	<cfset This.name = "PCC Links" />
	<cfset This.sessionManagement = True />
	<cfset This.clientmanagement = "yes" />
	<cfset This.setclientcookies = "yes" />
	<cfset This.setdomaincookies = "no" />
	<cfset This.loginstorage = "session" />
	<cfset This.datasource = "pcclinks" />
	<cfset This.sessiontimeout=createTimeSpan(0,2,0,0)>

	<cfset Variables.cas_path="https://authenticate.pcc.edu/cas/">
 	<cfset Variables.app_path="https://" & "#CGI.SERVER_NAME#" & "#CGI.SCRIPT_NAME#">
 	<cfset Variables.cas_url=cas_path & "login?" & "service=" & app_path>

	<cfparam name="url.ticket" default="">
	<cfparam name="url.action" default="">
	<cfparam name="pcc_source" default='/pcclinks' />

	<cfinclude template="#pcc_source#/includes/logfunctions.cfm">

    <cffunction name="OnSessionStart">
		<cfset logEntry(value="OnSessionStart", level=2)>
        <CFLOCK SCOPE="SESSION" TYPE="READONLY" TIMEOUT="5">
	        <cfset SESSION.DateInitialized = Now() />
 			<cfset session.username = "">
 			<cfset session.authorized = "">
			<cfset session.error = "">
        </CFLOCK>
    </cffunction>

	<cffunction name="OnRequestStart">
		<cfargument name="req">
		<cfset logEntry(value="OnRequestStart", level=2)>
		<cfset logEntry(value="req=" & arguments.req, level=2)>
		<CFLOCK SCOPE="SESSION" TYPE="READONLY" TIMEOUT="5">
	        <cfset session.pccsource = Variables.pcc_source>
        </CFLOCK>

		<cfif structKeyExists(url, "accessdenied")>
			<cfset logEntry(value="url contains accessdenied for user " & #session.username#)>
			<cfset Session.Error = "Access denied on login">
			<cflocation url="UnauthorizedError.cfm">
		</cfif>

		<!--- logout action --->
		<cfif url.action eq "logout">
			 <!--- session reset --->
			 <cflock scope="session" timeout="30" type="exclusive">
	 		    <cfset StructClear(Session)>
	   		 	<cfset session.authorized = "0">
	     		<cfset sessionInvalidate() >
	 		</cflock>
	 		<cfset cas_url = cas_path & "logout">
	 		<cflocation url="#cas_url#" addtoken="false">
	 	</cfif>

		<cfif CGI.SCRIPT_NAME CONTAINS "error.cfm">
			<cfreturn "true">
		</cfif>

		<cfset logEntry(value="username=" & session.username, level=2)>
		<cfset logEntry(value="sessionid=" & session.sessionid, level=2)>
	 	<cfif not len(trim(session.username)) or session.authorized EQ 0>
		 	<cfset isAjax = isAjaxCall()>
		 	<cfif isAjax>
			 	<cfset logEntry(value="Ajax call", level=2)>
			 	<cflocation url="SessionTimeoutError.cfm">
			<cfelse>
			 	<cfset logEntry(value="Not Ajax call", level=2)>
	 			<cfinclude template="#pcc_source#/includes/auth.cfm">
	 		</cfif>
	 	</cfif>
		<cfreturn "true">
	</cffunction>

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
		<cfif CGI.SERVER_NAME DOES NOT CONTAIN "intranettest" && CGI.SERVER_NAME DOES NOT CONTAIN "localhost">
			<cfmail to="arlette.slachmuylder@pcc.edu" from="arlette.slachmuylder@pcc.edu" subject="PCC Links Future Connect Application Error" type="html">
				#errortext#
			</cfmail>
		</cfif>

		<cfset Variables.isAjax = isAjaxCall()>
		<cfif Variables.isAjax>
			<cfheader statusCode=700 statustext="#msg#" >
		<cfelse>
		   	<cflocation url="error.cfm">
		</cfif>

	</cffunction>



	<cffunction name="isAjaxCall" returntype="boolean">
		<cfset Variables.reqData = getHTTPRequestData() >
    	<cfif structKeyExists(Variables.reqData.headers,"X-Requested-With")
					&& reqData.headers["X-Requested-With"] eq "XMLHttpRequest">
			<cfset logEntry(value="IsAjaxCall", level=2)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
</cfcomponent>