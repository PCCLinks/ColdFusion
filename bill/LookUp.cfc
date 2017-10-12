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
			select Term
			from bannerCalendar
			order by term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getFilteredTerm" access="remote" >
		<cfargument name="term">
		<cfargument name="displayField">
		<cfquery name="data" datasource="pcclinks" result="r">
			select *
			from bannerCalendar
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfset r=data[#arguments.displayField#] />
		<cfif arguments.displayField CONTAINS "Date"> <cfset r = dateFormat(r, 'mm/dd/yyyy') /></cfif>
		<cfreturn r>
	</cffunction>
	<cffunction name="getCurrentYearTerms" access="remote" >
		<cfquery name="data" >
			select c.*
			from bannerCalendar c
				join bannerCalendar c1 on c.ProgramYear = c1.ProgramYear
			where c1.Term = (select max(Term) from billingStudent)
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getprograms" access="remote">
		<cfquery name="data" datasource="pcclinks">
			select programName
			from keyProgram
			where programName in ('gtc','ytc')
			union
			select statusText
			from keyStatus
			where statusText like 'ytc%'
			union
			select 'YtC Attendance Unverified'
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getschools" access="remote">
		<cfquery name="data" datasource="pcclinks">
			select *
			from keySchoolDistrict
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getLastTermBilled" access="remote">
		<cfquery datasource="pcclinks" name="data">
			SELECT ProgramQuarter, ProgramYear, maxTerm.Term MaxTerm
			FROM bannerCalendar c
				JOIN (SELECT MAX(Term) Term
					FROM billingStudent) maxTerm ON c.Term = maxTerm.Term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getNextTermToBill" access="remote">
		<cfquery datasource="pcclinks" name="data">
			SELECT *
			FROM bannerCalendar
			WHERE Term = (SELECT MIN(Term) Term
			FROM bannerCalendar c
			WHERE Term > (SELECT MAX(Term) Term
					FROM billingStudent))
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getProgramYearTerms" access="remote">
	<cfargument name="term" default="">
	<cfif len(arguments.term) EQ 0>
		<cfquery name="maxTerm">
			SELECT max(Term) term
			FROM billingStudent
		</cfquery>
		<cfset arguments.term = maxTerm.Term>
	</cfif>
	<cfquery name="data">
		SELECT CurrentTerm, c.ProgramYear
			,MAX(CASE ProgramQuarter WHEN 1 THEN Term ELSE NULL END) Term1
			,MAX(CASE ProgramQuarter WHEN 2 THEN Term ELSE NULL END) Term2
			,MAX(CASE ProgramQuarter WHEN 3 THEN Term ELSE NULL END) Term3
			,MAX(CASE ProgramQuarter WHEN 4 THEN Term ELSE NULL END) Term4
		FROM bannerCalendar c
			JOIN (SELECT Term CurrentTerm, ProgramQuarter CurrentQuarter, ProgramYear
					FROM bannerCalendar
					WHERE Term = <cfqueryparam value="#arguments.term#">) current
				ON c.ProgramYear = current.ProgramYear
		GROUP BY CurrentTerm, c.ProgramYear
	</cfquery>
	<cfreturn data>
</cffunction>
	<cffunction name="getMaxTerm" access="remote" returntype="string">
		<cfquery name="maxTermQuery">
			SELECT MAX(Term) Term
			FROM billingStudent
		</cfquery>
		<cfreturn maxTermQuery.Term>
	</cffunction>
	<cffunction name="getProgramYear" access="remote" returntype="string">
		<cfargument name="term" required="true">
		<cfquery name="programYearQuery">
			SELECT ProgramYear
			FROM bannerCalendar
			WHERE term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfreturn programYearQuery.ProgramYear>
	</cffunction>
	<cffunction  name="getCoursesForTerm" access="remote">
		<cfargument name="term" required="true">
		<cfquery name="data" datasource="bannerpcclinks">
			select distinct crn, subj, crse, title
			from swvlinks_course
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>
	</cffunction>
	<cffunction  name="getScenarios" access="remote" returnformat="JSON" >
		<cfargument name="billingScenarioName" default="">
		<cfquery name="data" >
				SELECT * FROM sidny.billingScenario
				<cfif len(arguments.billingScenarioName) GT 0>
				WHERE billingScenarioName = <cfqueryparam value="#arguments.billingScenarioName#">
				</cfif>
		</cfquery>
		<cfreturn data>
	</cffunction>


</cfcomponent>
