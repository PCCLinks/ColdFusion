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
 cas_path = "https://authenticate-test.pcc.edu/cas/";
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
<cfelse>
	 <!--- auth check --->
	<cfif Variables.debug>
	 	<cfdump var="#session#">
		<cfdump var="#url#">
	</cfif>
	<!--- no username on session --->
 	<cfif not len(trim(session.username))>
		<!--- no ticket on the url --->
		<cfif not len(trim(ticket))>
      	  	<cflocation url="#cas_url#" addtoken="no">
		<!--- got ticket now get user info --->
   	  	<cfelse>
		    <cfset cas_url = #cas_path# & "serviceValidate?ticket=" & url.ticket & "&" & "service=" & app_path & "/">
     	    <cfhttp url="#cas_url#" method="get" />

	       	<cfset objXML = xmlParse(cfhttp.filecontent)>
         	<cfset SearchResults = XmlSearch(objXML,"cas:serviceResponse/cas:authenticationSuccess/cas:user")>

         	<cfif arraylen(SearchResults)>
            	<!---Raw XML:<cfdump var="#cfhttp.filecontent#">
             	<cfdump var="#objXML#" label="CAS Results">
             	<cfdump var="#SearchResults#" label="Parsed CAS Results"> --->
            	 <cfset username = SearchResults[1].XmlText>
				<!--- validate against valid app users --->
				<cfquery name="qryUser" >
					select *
					from applicationUser
					where username = <cfqueryparam value="#username#">
				</cfquery>
				<cfif qryUser.recordcount EQ 1>
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
					<cfelse>
						<!---<cflocation url="#app_path#">--->
						<!---<cfdump var="#app_path#">--->
				    	<!---<a href="?action=logout">Logout</a><br/>--->
					</cfif> <!--- end debug --->
	          	 <!--- not valid appication user --->
	         	 <cfelse>
				     No Application Access
				</cfif> <!--- end qryUser.rowcount --->
         	</cfif> <!--- end arraylen(SearchResults --->
   	  	</cfif> <!--- end if ticket --->
	<!--- Session has Username --->
	<cfelse>
		<cfif structKeyExists(url, "accessdenied")>
		     Access Error
		<cfelse>
			<cfif Variables.debug>
				Authenticated.<br/>
			   	<cfdump var="#session#" label="ColdFusion Session Object"><br>
			    <cfif Session.DebugCount LT 3>
					<cflocation url="#app_path#">
				</cfif>
				<cfdump var="#app_path#">
			   	<a href="?action=logout">Logout</a><br/>
			<cfelse>
				<!---<cflocation url="#app_path#">
			   	<a href="?action=logout">Logout</a><br/>--->
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