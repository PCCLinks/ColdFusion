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
			select Term,
				concat(Term, case right(Term,1)
								when 1 then '-Winter'
								when 2 then '-Spring'
			                    when 3 then '-Summer'
			                    when 4 then '-Fall' end) TermDescription
			from bannerCalendar
			where termBeginDate >= date_add(now(), INTERVAL - 1 YEAR)
			order by term
		</cfquery>
		<cfreturn data>
	</cffunction>
		<cffunction name="getOpenTerms" access="remote">
		<cfquery name="data" datasource="pcclinks">
			select distinct Term,
				concat(Term, case right(Term,1)
								when 1 then '-Winter'
								when 2 then '-Spring'
			                    when 3 then '-Summer'
			                    when 4 then '-Fall' end) TermDescription
			from billingStudent
			where billingStatus = 'IN PROGRESS'
				and program not like '%attendance%'
			order by term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getProgramYear" access="remote">
		<cfquery name="data" datasource="pcclinks">
			select distinct ProgramYear
			from bannerCalendar
			where termBeginDate >= date_add(now(), INTERVAL - 1 YEAR)
			order by term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getCurrentProgramYear" access="remote" returntype="string">
		<cfquery name="data">
			SELECT max(ProgramYear) ProgramYear
			FROM bannerCalendar
			WHERE termBeginDate <= now()
		</cfquery>
		<cfreturn data.ProgramYear>
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
			select c.Term,
				concat(c.Term, case right(c.Term,1)
								when 1 then '-Winter'
								when 2 then '-Spring'
			                    when 3 then '-Summer'
			                    when 4 then '-Fall' end) TermDescription,
				c.TermBeginDate,
				c.TermDropDate,
				c.TermEndDate
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
	<cffunction name="getLastTermClosed" access="remote">
		<cfquery datasource="pcclinks" name="data">
			SELECT ProgramQuarter, ProgramYear, maxTerm.Term MaxTerm
			FROM bannerCalendar c
				JOIN (SELECT MAX(Term) Term
					FROM billingStudent
					WHERE billingStatus = 'BILLED') maxTerm ON c.Term = maxTerm.Term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getLastAttendancePeriodClosed" access="remote" returnType="date">
		<cfquery datasource="pcclinks" name="data">
			SELECT MAX(billingStartDate) billingStartDate
			FROM billingStudent
			WHERE billingStatus = 'BILLED'
	        	and program like '%Attendance%'
		</cfquery>
		<cfreturn data.billingStartDate>
	</cffunction>
	<cffunction name="getNextTermToBill" access="remote">
		<cfquery datasource="pcclinks" name="data">
			SELECT *
			FROM bannerCalendar
			WHERE Term = (SELECT MIN(Term) Term
			FROM bannerCalendar c
			WHERE Term > (SELECT MAX(Term) Term
					FROM billingStudent
					WHERE BillingStatus = 'BILLED'))
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getNextAttendanceDatesToBill" access="remote">
		<cfquery datasource="pcclinks" name="data">
			SELECT *
			FROM bannerCalendar bc
				JOIN (SELECT MAX(BillingStartDate) Term
						,Date_Add(MAX(billingEndDate),INTERVAL 1 Day) NextDate
						,DATE_ADD(MAX(billingEndDate), INTERVAL (9 - IF(DAYOFWEEK(MAX(billingEndDate))=1, 8, DAYOFWEEK(CURDATE()))) DAY) Next
						FROM billingStudent
	               		WHERE program like '%Attendance%') d
	               	on d.NextDate between termBeginDate and termEndDate
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
	<cffunction name="getProgramYearForTerm" access="remote" returntype="string">
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
				SELECT * FROM billingScenario
				<cfif len(arguments.billingScenarioName) GT 0>
				WHERE billingScenarioName = <cfqueryparam value="#arguments.billingScenarioName#">
				order by billingScenarioName
				</cfif>
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction  name="getExitReasons" access="remote" returnformat="JSON" >
		<cfquery name="data" >
				SELECT *
				FROM billingStudentExitReason
				ORDER BY billingStudentExitReasonDescription
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction  name="getOpenAttendanceBillingStartDates" access="remote"  >
		<cfquery name="data" >
				SELECT distinct billingStartDate
				FROM billingStudent
				WHERE program like '%attendance%'
					and billingStatus = 'IN PROGRESS'
				ORDER BY billingStartDate desc
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction  name="getAttendanceBillingStartDates" access="remote"  >
		<cfquery name="data" >
				SELECT distinct billingStartDate
				FROM billingStudent
				WHERE program like '%attendance%'
				ORDER BY billingStartDate desc
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getFirstOpenAttendanceDate" access="remote" >
		<cfquery name="data">
			select min(billingStartDate) lastAttendanceBillDate
			FROM billingStudent
			WHERE program like '%attendance%'
				and billingStatus = 'IN PROGRESS'
			ORDER BY billingStartDate desc
		</cfquery>
		<cfreturn data.lastAttendanceBillDate>
	</cffunction>
	<cffunction name="getLatestDateAttendanceMonth" access="remote" returntype="date">
		<cfquery name="data">
			select max(billingStartDate) lastAttendanceBillDate
			from billingStudent
			where program like '%attendance%'
		</cfquery>
		<cfreturn data.lastAttendanceBillDate>
	</cffunction>
	<cffunction name="getMaxBillingStartDateForTerm" access="remote" returnType="date">
		<cfargument name="term" required="true">
		<cfquery name="data">
			select max(billingStartDate) maxBillingStartDate
			from billingStudent
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfreturn data.maxBillingStartDate>
	</cffunction>
	<cffunction name="getAttendanceCRN" access="remote" returnFormat="json">
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data" >
			select distinct CRN,
				CASE WHEN CRN = CRSE THEN CRN ELSE concat(CRN,' - ',SUBJ,CRSE) END CRNDesc
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentID = bsi.billingStudentId
			where billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
			order by CRN
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getLatestAttendanceDates" access="remote">
		<cfquery name="data">
			select max(billingStartDate) billingStartDate
				,max(bs.Term) Term
			    ,max(billingEndDate) billingEndDate
			    ,max(termBeginDate) TermBeginDate
			    ,max(termDropDate) TermDropDate
			    ,max(termEndDate) TermEndDate
			from billingStudent bs
				join bannerCalendar bc on bs.term = bc.Term
			where bs.program like '%attendance%'
		</cfquery>
		<cfreturn data>
	</cffunction>
</cfcomponent>
