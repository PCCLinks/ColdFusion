<cfcomponent>
	<cfset This.name = "PCC Future Connect" />
	<cfset This.sessionManagement = True />
	<cfset This.clientmanagement = "yes" />
	<cfset This.setclientcookies = "yes" />
	<cfset This.setdomaincookies = "no" />
	<cfset This.loginstorage = "session" />

	<cffunction name="OnApplicationStart">
        <cfset application.dsn = "pcclinks">
    </cffunction>

    <cffunction name="OnSessionStart">
        <CFLOCK SCOPE="SESSION" TYPE="READONLY" TIMEOUT="5">
	        <cfset SESSION.DateInitialized = Now() />
        </CFLOCK>
    </cffunction>

    <cffunction name="OnRequestStart">

    </cffunction>
</cfcomponent>