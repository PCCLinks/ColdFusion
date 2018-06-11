<cfcomponent>
	<cfset This.name = "PCC Links" />
	<cfset This.application = "" />
	<cfset This.sessionManagement = false />
	<cfset This.setclientcookies = "yes" />
	<cfset This.setdomaincookies = "no" />
	<cfset This.loginstorage = "session" />
	<cfset This.datasource = "pcclinks" />
	<cfset This.sessiontimeout=createTimeSpan(0,2,0,0)>

	<cfset Variables.cas_path="https://authenticate.pcc.edu/cas/">
 	<cfset Variables.app_path="https://" & CGI.SERVER_NAME & CGI.SCRIPT_NAME & "?" & CGI.QUERY_STRING>
 	<cfset Variables.cas_url=cas_path & "login?" & "service=" & app_path>

	<cfparam name="url.ticket" default="">
	<cfparam name="url.action" default="">
	<cfparam name="pcc_source" default='/pcclinks' />

	<cfinclude template="#pcc_source#/includes/logfunctions.cfm">

    <cffunction name="OnSessionStart">
		<cfset logEntry(value="Global Application.cfc OnSessionStart", level=2)>
        <CFLOCK SCOPE="SESSION" TYPE="READONLY" TIMEOUT="5">
	        <cfset SESSION.DateInitialized = Now() />
 			<cfset session.username = "">
 			<cfset session.authorized = "">
			<cfset session.error = "">
        </CFLOCK>
    </cffunction>

	<cffunction name="OnRequestStart">
		<cfargument name="req">
		<cfset logEntry(value="Global Application.cfc OnRequestStart", level=2)>
		<cfset logEntry(value="req=" & arguments.req, level=2)>
		<cfif structKeyExists(url, "method")>
			<cfset logEntry(value="method=" & url.method, level=2)>
		</cfif>
		<cfif structKeyExists(FORM, "method")>
			<cfset logEntry(value="method=" & FORM.method, level=2)>
		</cfif>

		<cfif structKeyExists(url, "accessdenied")>
			<cfset logEntry(value="url contains accessdenied for user " & #session.username#)>
			<cfset Session.Error = "Access denied on login">
			<cflocation url="UnauthorizedError.cfm">
		</cfif>

		<!--- logout action --->
		<cfif url.action eq "logout">
			 <!--- session reset --->
			 <cflock scope="session" timeout="30" type="exclusive">
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
	 	<cfif not len(trim(session.username)) or session.authorized NEQ 1>
	 		<!--->or (This.application NEQ 'Billing' and This.application NEQ 'FutureConnect')>--->
		 	<cfset isAjax = isAjaxCall()>
		 	<cfif isAjax>
			 	<cfset logEntry(value="Ajax call", level=2)>
			 	<cflocation url="SessionTimeoutError.cfm">
			 	<cfset logEntry(value="Ajax call complete", level=2)>
			<cfelse>
			 	<cfset logEntry(value="Not Ajax call", level=2)>
	 			<cfset casLogin()>
			 	<cfset logEntry(value="Not Ajax call complete", level=2)>
	 		</cfif>
	 	</cfif>

		<cfreturn "true">
	</cffunction>


	<cffunction name="onError">
		<cfargument name="exception" >
		<cfargument name="thrownError" default="">
		<cfargument name="eventname" type="string" >

		<cfset var errortext = "">

		<cfset logEntry(value="-------------BEGIN ENTRY------------") >
		<cfif IsDefined("session.username")>
			<cfset logEntry(label="USER:", value="#Session.username#") >
		<cfelse>
			<cfset logEntry(value="No Username Defined")>
		</cfif>
		<cfset logEntry(value="#arguments.exception#") >
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
		<cfset logDump(label="HTTPRequestData", value="#Variables.reqData#", level=2)>
		<cfset logDump(label="Session", value="#Session#", level=2)>
    	<cfif structKeyExists(Variables.reqData.headers,"X-Requested-With")
					&& reqData.headers["X-Requested-With"] eq "XMLHttpRequest">
			<cfset logEntry(value="IsAjaxCall", level=2)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="casLogin">
		<!--- does not run when working off of localhost - so skip in that instance--->
		<cfif CGI.SERVER_NAME NEQ "localhost">

		<!--------------------->
		<!--- begin LOGIN ----->
		<!--------------------->
		<!--- no ticket on the url --->
		<cfif not len(trim(url.ticket))>
			<cfset logEntry(value="Auth no ticket", level=2)>
			<!--- exit - send to login screen --->
			<cfhttp url="#cas_url#" method="get" />
		    <cflocation url="#cas_url#" addtoken="no">
		<!--- got ticket now get user info --->
		<cfelse>
			<cfset logEntry(value="Auth with ticket", level=2)>
			<cfset cas_url = #cas_path# & "serviceValidate?ticket=" & url.ticket & "&" & "service=" & app_path & "/">
			<cfhttp url="#cas_url#" method="get" />
			<cfset logEntry(label="cas_url", value="#cas_url#", level=5)>
		    <cfset objXML = xmlParse(cfhttp.filecontent)>
		    <cfset SearchResults = XmlSearch(objXML,"cas:serviceResponse/cas:authenticationSuccess/cas:user")>

			<!--- login returned key information --->
		    <cfif arraylen(SearchResults)>
				<cfset username = SearchResults[1].XmlText>
				<cfset logEntry(value="Auth got search results", level=2)>
				<cftry>
					<!--- validate against valid app users --->
					<cfquery name="qryUser" >
						select *
						from applicationUser
						where username = <cfqueryparam value="#username#">
					</cfquery>
					<!--- find the user as an authorized user --->
					<cfif qryUser.recordcount EQ 1>
						<cfset logEntry(value=#username# & " logged in at " & #now()#)>
		            	<cflock scope="session" timeout="30" type="exclusive">
		          	    	<cfset session.username = username>
		          	       	<cfset session.authorized = "1">
		          	       	<cfset session.userRole = "#qryUser.role#">
		          	       	<cfset session.userDisplayName = "#qryUser.displayName#">
		          	       	<cfset session.userPosition = "#qryUser.position#">
		          	   	</cflock>
		          	 <!--- not valid application user --->
		         	 <cfelse>
						<cfset logEntry(value=#username# & " not a valid user: " & #now()#)>
						<cfset Session.Error = "You are not an authorized user of this application.  Please see your manager if you believe this is in error.">
					</cfif> <!--- end qryUser.rowcount --->
					<cfcatch>
						<cfset logEntry(value="Error querying application user table")>
						<cfset logDump(label="cfcatch", value="#cfcatch#")>
					</cfcatch>
				</cftry>
			<!--- expected search results have failed --->
			<cfelse>
				<cfset logEntry(value="Search results from CAS did not provide key informationxx")>
				<cfset logDump(label="Search Results", value="#SearchResults#")>
				<cfset logDump(label="session", value="#session#")>
				<cfset Session.Error = "Search results from CAS did not provide key information">
			</cfif> <!--- end arraylen(SearchResults --->
		 </cfif> <!--- end if ticket --->

		<!--- LOCALHOST --->
		<cfelse>
		<cfset logEntry(value = "LOCALHOST")>
		<cfset logEntry(label="url.action", value="#url.action#")>
		<cfif IsDefined("session.username")>
			<cfset logEntry(label="session.username", value="#session.username#")>
		<cfelse>
			<cfset logEntry(value="session does not have username")>
		</cfif>
		<cfif not len(trim(session.username))>
			<cfset username="arlette.slachmuylder">
			<cfset logEntry(label="username", value="#username#")>
			<cfquery name="qryUser" >
				select *
				from applicationUser
				where username = <cfqueryparam value="#username#">
			</cfquery>
			<!---<cfset logEntry(value="Search results from CAS did not provide key information")>
			<cfset Session.Error = "Search results from CAS did not provide key information">--->
			<cfif qryUser.recordcount EQ 1>
				<cfset logEntry(value=#username# & " logged in at " & #now()#)>
		          	<cflock scope="session" timeout="30" type="exclusive">
		        	    	<cfset session.username = username>
		        	       	<cfset session.authorized = "1">
		        	       	<cfset session.userRole = "#qryUser.role#">
		        	       	<cfset session.userDisplayName = "#qryUser.displayName#">
		        	       	<cfset session.userPosition = "#qryUser.position#">
		        	 </cflock>
		        	 <!--- not valid application user --->
		       <cfelse>
				<cfset logEntry(value=#username# & " not a valid user: " & #now()#)>
				<cfset Session.Error = "You are not an authorized user of this application.  Please see your manager if you believe this is in error.">
			</cfif> <!--- end qryUser.rowcount --->
		</cfif>
		</cfif>  <!--- end if not localhost --->

		<cfif IsDefined("session.authorized")>
			<cfset logEntry(label="session.authorized", value="#session.authorized#")>
		<cfelse>
			<cfset logEntry(value="session does not have authorized")>
		</cfif>

		<cfif Session.authorized NEQ 1>
			<cfset logEntry(value = "Unauthorized session for " & session.username)>
			<cflocation url="UnauthorizedError.cfm">
		</cfif>
		<cfset logEntry(value="auth.cfm complete")>
	</cffunction>
</cfcomponent>