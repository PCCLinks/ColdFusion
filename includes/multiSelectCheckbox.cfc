<cfcomponent displayname="multiSelectCheckbox" accessors="true" output="false" persistent="false">
	<!---><cffunction name="isChanged" returntype="boolean">
		<cfargument name="checkedOnForm" type="array">
		<cfargument name="checkedinDatabase" type="query">
		<cfset changed="false">
		<cfloop query="checkedinDatabase">
			<cfset exists=false>
			<cfset id = existingIds.Id>
			<cfloop array="#arguments.checkedOnForm#" item="checkedID">
				<cfif id EQ checkedID>
					<cfset exists=true>
					<cfbreak>
				</cfif> <!--- matches a value that is checked --->
			</cfloop> <!--- checked id values --->
			<cfif not exists>
				<cfset idsToDelete = ListAppend(idsToDelete, id)>
			</cfif>
		</cfloop>--->
	<cffunction name="getCheckedCollection" access="public">
	<!--- data is a collection of all fields in the form.
	  The values related to a multi-select checkbox is a collection of
	  fields with the structure of fieldidname+fieldidvalue, i.e.
	  for household it is householdid1, householdid2 etc.
	  However, only the checked values show up, if we parse out the
	  idvalue from the fieldname, we get a collection of the id values
	  checked.
	  This function loops through all the fields and puts together the
	  collection of ids checked for this set --->
		<cfargument name="data" required="true">
		<cfargument name="idFieldName" required="true">
		<cfset lengthIdFieldName = len(#arguments.idFieldName#)>
		<cfset idArray = []>
		<cfset index = 1>
		<cfloop collection="#arguments.data#" item="key">
			<!--- if this is has the fieldid name we are looking for --->
			<cfif left(key,#lengthIdFieldName#) EQ #arguments.idFieldName#>
				<!--- capture the idvalue appended to the end of the field name --->
				<cfset idArray[index] = RIGHT(key,len(key)-lengthIdFieldName)>
				<cfset index=index+1>
			</cfif>
		</cfloop> <!--- form values --->
		<cfreturn idArray>
	</cffunction>

	<cffunction name="getValuesToDelete" access="public">
		<cfargument name="existingIds" type="query">
		<cfargument name="checkedIds" type="Array">
		<!--- this way it is never blank --->
		<cfset idsToDelete="0">
		<cfloop query="existingIds">
			<cfset exists=false>
			<cfset id = existingIds.Id>
			<cfloop array="#arguments.checkedIds#" item="checkedID">
				<cfif id EQ checkedID>
					<cfset exists=true>
					<cfbreak>
				</cfif> <!--- matches a value that is checked --->
			</cfloop> <!--- checked id values --->
			<cfif not exists>
				<cfset idsToDelete = ListAppend(idsToDelete, id)>
			</cfif>
		</cfloop>
		<cfreturn idsToDelete>
	</cffunction>

	<cffunction name = "getValuesToInsert" access="public">
		<cfargument name="existingIds" type="query">
		<cfargument name="checkedIds" type="Array">
		<cfset l = #ArrayToList(checkedIds)#>
		<!--- this way it is never blank --->
		<cfset idsToInsert="0">
		<cfloop array="#arguments.checkedIds#" item="checkedID">
			<cfset exists=false>
			<cfloop query="existingIds">
				<cfif Id EQ checkedID>
					<cfset exists=true>
					<cfbreak>
				</cfif> <!--- matches a value that is checked --->
			</cfloop> <!---existing entries --->
			<cfif not exists>
				<cfset idsToInsert = ListAppend(idsToInsert, checkedID)>
			</cfif>
		</cfloop> <!--- checked id values --->
		<cfreturn idsToInsert>
	</cffunction>
</cfcomponent>