<cfcomponent displayname="doSearch">

<cffunction name="setSearchCriteria" access="remote">
	<cfargument name="searchFirstName">
	<cfargument name="searchLastName">
	<cfargument name="searchGNumber">

	<cfset Session.searchFirstName = arguments.searchFirstName>
	<cfset Session.searchLastName = arguments.searchLastName>
	<cfset Session.searchGNumber = arguments.searchGNumber>
</cffunction>

<cffunction name="clearSearchCriteria" access="remote">
	<cfset Session.searchFirstName = ''>
	<cfset Session.searchLastName = ''>
	<cfset Session.searchGNumber = ''>
	<cfset Session.searchBillingStudentId = 0>
</cffunction>

<cffunction name="setBillingStudentId" access="remote">
	<cfargument name="searchBillingStudentId">
	<cfset Session.searchBillingStudentId = arguments.searchBillingStudentId>
</cffunction>

<cffunction name="getMostRecentTermBillingStudentId" access="remote" returnformat="plain" returntype="Numeric" >
	<cfreturn Session.mostRecentTermBillingStudentId>
</cffunction>

</cfcomponent>