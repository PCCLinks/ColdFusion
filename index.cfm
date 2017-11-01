
<!--- globals --->
<cfparam name="url.ticket" default="">
<cfparam name="username" default="">
<cfparam name="url.action" default="">
<cfscript>
 cas_path = "https://authenticate.pcc.edu/cas/";
 app_path = "https://intranet.pcc.edu/pcclinks/index.cfm";
 cas_url = cas_path & "login?" & "service=" & app_path;
</cfscript>

<!--- session init --->
<cflock timeout="10" scope="session" type="readonly">
 <cfparam name="session.username" default="">
 <cfparam name="session.authorized" default="0">
</cflock>

<!--- logout action --->
<cfif url.action eq "logout">
 <!--- session reset --->
 <cflock scope="session" timeout="30" type="exclusive">
     <cfset session.username = "">
     <cfset session.authorized = "0">
 </cflock>

 <cfset cas_url = cas_path & "logout">
 <cflocation url="#cas_url#" addtoken="false">

<cfelse>
 <!--- auth check --->
 <cfif not len(trim(session.username))>
     <cfif not len(trim(ticket))>
        <cflocation url="#cas_url#" addtoken="no">
     <cfelse>
         <cfset cas_url = #cas_path# & "serviceValidate?ticket=" & url.ticket & "&" & "service=" & app_path & "/">

         <cfhttp url="#cas_url#" method="get" />

         <cfset objXML = xmlParse(cfhttp.filecontent)>
         <cfset SearchResults = XmlSearch(objXML,"cas:serviceResponse/cas:authenticationSuccess/cas:user")>

         <cfif arraylen(SearchResults)>
             Raw XML:<cfdump var="#cfhttp.filecontent#">
             <cfdump var="#objXML#" label="CAS Results">
             <cfdump var="#SearchResults#" label="Parsed CAS Results">
             <cfset username = SearchResults[1].XmlText>
             <cflock scope="session" timeout="30" type="exclusive">
                 <cfset session.username = username>
                 <cfset session.authorized = "1">
             </cflock>
         <cfelse>
                <cflocation url="#cas_url#" addtoken="no">
         </cfif>
     </cfif>
 </cfif>

 <cfif structKeyExists(url, "accessdenied")>
     Access Error
 <cfelse>
     Authenticated.<br/>
     <cfdump var="#session#" label="ColdFusion Session Object">
     <a href="?action=logout">Logout</a><br/>
 </cfif>
</cfif>