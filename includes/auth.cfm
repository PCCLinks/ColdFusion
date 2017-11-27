
<!--- does not run when working off of localhost - so skip in that instance--->
<cfif CGI.SERVER_NAME NEQ "localhost">

<!--------------------->
<!--- begin LOGIN ----->
<!--------------------->
<!--- no ticket on the url --->
<cfif not len(trim(ticket))>
	<cfset logEntry(value="Auth no ticket", level=2)>
	<!--- exit - send to login screen --->
    <cflocation url="#cas_url#" addtoken="no">
<!--- got ticket now get user info --->
<cfelse>
	<cfset logEntry(value="Auth no ticket", level=2)>
	<cfset cas_url = #cas_path# & "serviceValidate?ticket=" & url.ticket & "&" & "service=" & app_path & "/">
	<cfhttp url="#cas_url#" method="get" />
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
				<cfif This.application EQ 'Billing'>
					and hasBillAccess = 1
				</cfif>
				<cfif This.application EQ 'FC'>
					and hasFCAccess = 1
				</cfif>
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
		<cfset logDump(label="session", value="#session#", level=2)>
		<cfset Session.Error = "Search results from CAS did not provide key informationxxx">
	</cfif> <!--- end arraylen(SearchResults --->
 </cfif> <!--- end if ticket --->

<!--- LOCALHOST --->
<cfelse>
<cfif url.action eq "logout">
	 <!--- session reset --->
	 <cflock scope="session" timeout="30" type="exclusive">
	     <cfset StructClear(Session)>
	     <cfset session.authorized = "0">
	 </cflock>
<cfelse>
	<cfif not len(trim(session.username))>
		<cfset username="arlette.slachmuylder">
		<cfquery name="qryUser" >
			select *
			from applicationUser
			where username = <cfqueryparam value="#username#">
			<cfif This.application EQ 'Billing'>
				and hasBillAccess = 1
			</cfif>
			<cfif This.application EQ 'FC'>
				and hasFCAccess = 1
			</cfif>
		</cfquery>
		<!---<cfset logEntry(value="Search results from CAS did not provide key information")>
		<cfset Session.Error = "Search results from CAS did not provide key information">--->
		<cflock scope="session" timeout="30" type="exclusive">
			<cfset session.username = username>
			<cfset session.authorized = "1">
			<cfset session.userRole = "#qryUser.role#">
			<cfset session.userDisplayName = "#qryUser.displayName#">
			<cfset session.userPosition = "#qryUser.position#">
		</cflock>
	</cfif>
</cfif>
</cfif>  <!--- end if not localhost --->

<cfif Session.authorized NEQ 1>
	<cfset logEntry(value = "Unauthorized session for " & session.username)>
	<cflocation url="../UnauthorizedError.cfm">
</cfif>
