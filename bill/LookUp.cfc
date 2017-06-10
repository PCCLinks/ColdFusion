<cfcomponent displayname="LookUp">
	<cffunction name="select" access="remote">
	    <cfargument name="page" type="numeric" required="yes">
	    <cfargument name="pageSize" type="numeric" required="yes">
	    <cfargument name="gridsortcolumn" type="string" required="no">
	    <cfargument name="gridsortdir" type="string" required="no">
		<cfargument name="LookUpType">
		<cfquery datasource="pcclinks" name="data" >
			SELECT LookupID, LookupName
			FROM LookUp
			WHERE LookUpType = <cfqueryparam value="#arguments.LookUpType#">
		</cfquery>
		<cfreturn QueryConvertForGrid(data, ARGUMENTS.page, ARGUMENTS.pageSize)>
	</cffunction>
	<cffunction name="edit" access="remote">
	    <cfargument name="gridaction" required="yes">
	    <cfargument name="gridrow"  required="yes">
	    <cfargument name="gridchanged" required="yes">
	    <cfargument name="LookUpType" type="string" required="yes">
    	<cfset var value = structfind(gridrow,"LookupName")>
    	<cfset var id = structfind(gridrow,"LookupID")>
		<cfif isStruct(gridrow) and isStruct(gridchanged)>
        	<cfif gridaction eq "U">
	            <cfquery name="updateRows" datasource="pcclinks">
	                UPDATE LookUp
	                	SET LookUpName = <cfqueryparam value="#value#" CFSQLType = "CF_SQL_VARCHAR"  >
	                WHERE LookUpID = <cfqueryparam value="#id#" CFSQLType = "CF_SQL_INTEGER">
	            </cfquery>
			<cfelseif gridaction eq "I">
 				<cfquery name="insertRow" datasource="pcclinks">
					INSERT INTO LookUp(LookupName, LookupType)
					VALUES('#value#', '#arguments.LookUpType#')
				</cfquery>
			</cfif>
		</cfif>
	</cffunction>
	<cffunction name="getTerms" access="remote">
		<cfquery name="data" datasource="pcclinks">
			select *
			from pcc_links.BannerCalendar
			order by term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getFilteredTerm" access="remote" >
		<cfargument name="term">
		<cfargument name="displayField">
		<cfquery name="data" datasource="pcclinks" result="r">
			select *
			from pcc_links.BannerCalendar
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfset r=data[#arguments.displayField#] />
		<cfif arguments.displayField CONTAINS "Date"> <cfset r = dateFormat(r, 'mm/dd/yyyy') /></cfif>
		<cfreturn r>
	</cffunction>
	<cffunction name="getprograms" access="remote">
		<cfquery name="data" datasource="pcclinks">
			select programName
			from sidny.keyProgram
			where programName <> 'ytc'
			union
			select statusText
			from sidny.keyStatus
			where statusText like 'ytc%'
		</cfquery>
		<cfreturn data>
	</cffunction>
		<cffunction name="getschools" access="remote">
		<cfquery name="data" datasource="pcclinks">
			select *
			from sidny.keySchoolDistrict
		</cfquery>
		<cfreturn data>
	</cffunction>
<cffunction name="getLastTermBilled" access="remote">
	<cfquery datasource="pcclinks" name="data">
		SELECT ProgramQuarter, ProgramYear, maxTerm.Term MaxTerm
		FROM pcc_links.BannerCalendar c
			JOIN (SELECT MAX(Term) Term
				FROM pcc_links.BillingStudent) maxTerm ON c.Term = maxTerm.Term
	</cfquery>
	<cfreturn data>
</cffunction>
<cffunction name="getNextTermToBill" access="remote">
	<cfquery datasource="pcclinks" name="data">
		SELECT *
		FROM pcc_links.BannerCalendar
		WHERE Term = (SELECT MIN(Term) Term
		FROM pcc_links.BannerCalendar c
		WHERE Term > (SELECT MAX(Term) Term
				FROM pcc_links.BillingStudent))
	</cfquery>
	<cfreturn data>
</cffunction>
<cffunction name="getProgramYearTerms" access="remote">
	<cfargument name="term" required="true">
	<cfquery datasource="pcclinks" name="data">
		SELECT CurrentTerm
			,MAX(CASE ProgramQuarter WHEN 1 THEN Term ELSE NULL END) Term1
			,MAX(CASE ProgramQuarter WHEN 2 THEN Term ELSE NULL END) Term2
			,MAX(CASE ProgramQuarter WHEN 3 THEN Term ELSE NULL END) Term3
			,MAX(CASE ProgramQuarter WHEN 4 THEN Term ELSE NULL END) Term4
		FROM pcc_links.BannerCalendar c
			JOIN (SELECT Term CurrentTerm, ProgramQuarter CurrentQuarter, ProgramYear
					FROM pcc_links.BannerCalendar
					WHERE Term = <cfqueryparam value="#arguments.term#">) current
				ON c.ProgramYear = current.ProgramYear
		GROUP BY CurrentTerm
	</cfquery>
	<cfreturn data>
</cffunction>

</cfcomponent>
