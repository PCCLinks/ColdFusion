<!--- globals --->
<cfparam name="url.ticket" default="">
<cfparam name="username" default="">
<cfparam name="url.action" default="">

<cfif structKeyExists(url, "debug")>
	<cfset Variables.debug = "#url.debug#">
<cfelse>
	<cfif structKeyExists(Session, "AuthDebug")>
		<cfset Variables.debug = Session.AuthDebug>
	<cfelse>
		<cfset Variables.debug = false>
	</cfif>
</cfif>
<cfif Variables.debug>
	<h1>DEBUG MODE</h1>
</cfif>


<cfscript>
 cas_path = "https://authenticate.pcc.edu/cas/";
 app_path = "https://" & "#CGI.SERVER_NAME#" & "#CGI.SCRIPT_NAME#";
 cas_url = cas_path & "login?" & "service=" & app_path;
</cfscript>
<cfif Variables.debug>
	<cfdump var="#cas_path#"><br>
	<cfdump var="#app_path#"><br>
	<cfdump var="#cas_url#">
</cfif>

<!--- session init --->
<cflock timeout="10" scope="session" type="readonly">
 	<cfparam name="session.username" default="">
 	<cfparam name="session.authorized" default="0">
</cflock>


<!--- does not run when working off of localhost - so skip in that instance --->
<cfif CGI.SERVER_NAME NEQ "localhost">


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

<!--------------------->
<!--- begin LOGIN ----->
<!--------------------->
<cfelse>
	 <!--- auth check --->
	<cfif Variables.debug>
	 	<cfdump var="#session#">
		<cfdump var="#url#">
	</cfif>

	<!--- 1. no username on session --->
 	<cfif not len(trim(session.username))>
		<cflog file="pcclinks_auth" text="1. no username on session">
		<!--- 2. no ticket on the url --->
		<cfif not len(trim(ticket))>
			<cflog file="pcclinks_auth" text="2. no ticket on the url">
			<!--- exit - send to login screen --->
      	  	<cflocation url="#cas_url#" addtoken="no">
		<!--- 2. got ticket now get user info --->
   	  	<cfelse>
			<cflog file="pcclinks_auth" text="2. got ticket now get user info">
		    <cfset cas_url = #cas_path# & "serviceValidate?ticket=" & url.ticket & "&" & "service=" & app_path & "/">
     	    <cfhttp url="#cas_url#" method="get" />

	       	<cfset objXML = xmlParse(cfhttp.filecontent)>
         	<cfset SearchResults = XmlSearch(objXML,"cas:serviceResponse/cas:authenticationSuccess/cas:user")>

			<!--- 3. login returned key information --->
         	<cfif arraylen(SearchResults)>
				<cflog file="pcclinks_auth" text="3. login returned key information">
            	<!---Raw XML:<cfdump var="#cfhttp.filecontent#">
             	<cfdump var="#objXML#" label="CAS Results">
             	<cfdump var="#SearchResults#" label="Parsed CAS Results"> --->
            	<cfset username = SearchResults[1].XmlText>
				<cfset logtext = "3. username = " & #username#>
				<cflog file="pcclinks_auth" text="#logtext#">
				<cftry>
					<!--- validate against valid app users --->
					<cfquery name="qryUser" >
						select *
						from applicationUser
						where username = <cfqueryparam value="#username#">
					</cfquery>
					<cflog file="pcclinks_auth" text="3. queried application user table">
					<!--- 4. find the user as an authorized user --->
					<cfif qryUser.recordcount EQ 1>
						<cfset logtext = "4. found the user " & #username# & " as an authorized user">
						<cflog file="pcclinks_auth" text=#logtext#>
		            	<cflock scope="session" timeout="30" type="exclusive">
		          	    	<cfset session.username = username>
		          	       	<cfset session.authorized = "1">
		          	       	<cfset session.userRole = "#qryUser.role#">
		          	       	<cfset session.userDisplayName = "#qryUser.displayName#">
		          	       	<cfset session.userPosition = "#qryUser.position#">
		          	   	</cflock>
			       	   	<cfif Variables.debug>
							Authenticated.<br/>
						    <cfdump var="#session#" label="ColdFusion Session Object"><br>
						    <cfif Session.DebugCount LT 3>
								<cflocation url="#app_path#">
							</cfif>
							<cfdump var="#app_path#">
				   			<a href="?action=logout">Logout</a><br/>
						</cfif> <!--- end debug --->
		          	 <!--- 4. not valid appication user --->
		         	 <cfelse>
						<cflog file="pcclinks_auth" text="4. not valid appication user">
						<cfset Session.Error = "You are not an authorized user of this application.  Please see your manager if you believe this is in error.">
					</cfif> <!--- end qryUser.rowcount --->
					<cfcatch>
						<cflog file="pcclinks_auth" text="Error querying application user table">
						<cfsavecontent variable="logtext">
							<cfdump var="#cfcatch#" format="text">
						</cfsavecontent>
						<cflog file="pcclinks_auth" text="#logtext#">
					</cfcatch>
				</cftry>
			<!--- 3.expected search results have failed --->
			<cfelse>
				<cflog file="pcclinks_auth" text="3.expected search results have failed">
         	</cfif> <!--- end arraylen(SearchResults --->
   	  	</cfif> <!--- end if ticket --->
	<!--- Session has Username --->
	<cfelse>
		<cfif structKeyExists(url, "accessdenied")>
			<cfset logtext="url contains accessdenied for user " & #session.username#>
			<cflog file="pcclinks_auth" text=#logtext#>
		<cfelse>
		<!--- should just be forwarded on to requested page - rest for debugging purposes --->
			<cfif Variables.debug>
				Authenticated.<br/>
			   	<cfdump var="#session#" label="ColdFusion Session Object"><br>
			    <cfif Session.DebugCount LT 3>
					<cflocation url="#app_path#">
				</cfif>
				<cfdump var="#app_path#">
			   	<a href="?action=logout">Logout</a><br/>
			</cfif> <!--- end debug --->
		</cfif> <!--- url has accessdenied --->
	</cfif> <!--- end if username --->
</cfif> <!--- end if logout --->

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
		</cfquery>
		<cflock scope="session" timeout="30" type="exclusive">
			<cfset session.username = username>
			<cfset session.authorized = "1">
			<cfset session.userRole = "#qryUser.role#">
			<cfset session.userDisplayName = "#qryUser.displayName#">
			<cfset session.userPosition = "#qryUser.position#">
		</cflock>
	</cfif>
</cfif> <!--- end if logout --->
</cfif> <!--- end if not localhost --->


<cfif Session.authorized EQ 0>
	<!---<cflocation url="/pcclinks/Error.cfm">--->
	<cfset urlvalue="#cas_path#logout?service=https://" & "#CGI.SERVER_NAME#/pcclinks/Error.cfm">
	<cflocation url="#urlvalue#">
</cfif>
