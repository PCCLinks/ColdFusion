<cfcomponent displayname="LookUp">
	<cfobject name="appObj" component="application">

	<cffunction name="getTerms" access="remote">
		<cfquery name="data" datasource="pcclinks">
			select Term,
				fnGetTermDescription(Term) TermDescription
			from bannerCalendar
			where termBeginDate >= date_add(now(), INTERVAL - 1 YEAR)
			order by term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getOpenTerms" access="remote">
		<cfquery name="data" datasource="pcclinks">
			select Term Term,
				fnGetTermDescription(Term) TermDescription,
			     billingStartDate
			from billingCycle
			where billingCloseDate IS NULL
				AND billingType = 'Term'
			order by Term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getClosedTerms" access="remote">
		<cfset programYear = getCurrentProgramYear()>
		<cfquery name="data" datasource="pcclinks">
			select Term Term,
				fnGetTermDescription(Term) TermDescription,
			     billingStartDate
			from billingCycle
			where billingCloseDate IS NOT NULL
				AND billingType = 'Term'
				and ProgramYear = '#programYear#'
			order by Term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getProgramYear" access="remote">
		<!--- billing system started in 2017/2018 year --->
		<cfquery name="data" datasource="pcclinks">
			select distinct ProgramYear
			from bannerCalendar
			where termBeginDate >= '2017-06-01'
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

	<cffunction name="getCurrentYearTerms" access="remote" >
		<cfquery name="data" >
			select c.Term,
				fnGetTermDescription(c.Term) TermDescription,
				c.TermBeginDate,
				c.TermDropDate,
				c.TermEndDate
			from bannerCalendar c
				join bannerCalendar c1 on c.ProgramYear = c1.ProgramYear
			where c1.Term = (select min(Term) from bannerCalendar where termBeginDate >= now() )
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

	<cffunction name="getLastAttendancePeriodClosed" access="remote" returnType="date">
		<cfquery datasource="pcclinks" name="data">
			SELECT MAX(billingStartDate) billingStartDate
			FROM billingCycle
			WHERE billingCloseDate IS NOT NULL
	        	and billingType = 'Attendance'
		</cfquery>
		<cfreturn data.billingStartDate>
	</cffunction>
	<cffunction name="getLastTermClosed" access="remote" >
		<cfquery datasource="pcclinks" name="data">
			select fnGetTermDescription(Term) TermDescription
			FROM (
			SELECT MAX(Term) Term
			FROM billingCycle
			WHERE billingCloseDate IS NOT NULL
	        	and billingType = 'Term'
	        ) data
		</cfquery>
		<cfreturn data.TermDescription>
	</cffunction>
	<cffunction name="getNextTermToBill" access="remote" >
		<cfquery datasource="pcclinks" name="data">
			SELECT MIN(Term) Term
			FROM bannerCalendar c
			WHERE Term > (SELECT MAX(Term) Term
					FROM billingCycle
					WHERE billingCloseDate IS NOT NULL
						AND billingType = 'Term')
		</cfquery>
		<cfreturn data.Term>
	</cffunction>
	<cffunction name="getBannerCalendarEntry" access="remote" returnformat="JSON">
		<cfargument name="term" required=true>
		<cfquery datasource="pcclinks" name="data">
			SELECT Term
				,Date_Format(TermBeginDate, '%m/%d/%Y') TermBeginDate
				,Date_Format(TermEndDate, '%m/%d/%Y') TermEndDate
				,Date_Format(TermDropDate, '%m/%d/%Y') TermDropDate
			FROM bannerCalendar
			WHERE Term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getNextAttendanceDatesToBill" access="remote" >
		<cfquery datasource="pcclinks" name="data">
			SELECT MAX(billingStartDate) billingStartDate, max(Term) Term
		  	FROM billingCycle
		  	WHERE billingType = 'Attendance'
				and billingCloseDate IS NOT NULL
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getAttendanceDatesToBill" access="remote" returnformat="JSON">
		<cfargument name="term" required=true>
		<cfargument name="billingStartDate" >

		<cfif not structKeyExists(arguments, "billingStartDate")>
			<cfquery name="getBillingStartDate">
				select termBeginDate
				FROM bannerCalendar
				WHERE Term = <cfqueryparam value="#arguments.term#">
			</cfquery>
			<cfset arguments.billingStartDate = getBillingStartDate.TermBeginDate>
		</cfif>
		<cfquery datasource="pcclinks" name="data">
			SELECT bc.Term
				,Date_Format(bc.TermBeginDate, '%m/%d/%Y') TermBeginDate
				,Date_Format(bc.TermEndDate, '%m/%d/%Y') TermEndDate
				,Date_Format(bc.TermDropDate, '%m/%d/%Y') TermDropDate
				,bc.ProgramYear
				,Date_Format(COALESCE(cycleInProgress.billingStartDate, proposedNextDate.NextBeginDate, bc.TermBeginDate), '%m/%d/%Y') NextBeginDate
			    ,Date_Format(COALESCE(cycleInProgress.billingEndDate, LAST_DAY(NextBeginDate), LAST_DAY(bc.TermBeginDate)), '%m/%d/%Y') NextEndDate
			    ,IFNULL(cycleInProgress.MaxBillableDaysPerBillingPeriod, '') MaxBillableDaysPerBillingPeriod
			FROM bannerCalendar bc
				LEFT JOIN (SELECT billingCycleId
						,Term
						,Date_Add(billingEndDate,INTERVAL 1 Day) NextDate
						,DATE_ADD(billingEndDate, INTERVAL (8 - IF(DAYOFWEEK(MAX(billingEndDate))=1, 8, DAYOFWEEK(CURDATE()))) DAY) NextBeginDate
						FROM billingCycle
						WHERE billingStartDate = <cfqueryparam value="#arguments.billingStartDate#">
							and billingType = 'Attendance') proposedNextDate
					on proposedNextDate.NextDate between termBeginDate and termEndDate
				 LEFT OUTER JOIN billingCycle cycleInProgress on bc.Term  = cycleInProgress.Term
					and billingCloseDate is null
			        and billingType = 'Attendance'
			WHERE bc.Term = <cfqueryparam value="#arguments.term#">
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
				SELECT billingStartDate
				FROM billingCycle
				WHERE billingCloseDate IS NULL
					AND billingType = 'attendance'
				ORDER BY billingStartDate desc
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction  name="getClosedAttendanceBillingStartDates" access="remote"  >
		<cfset programYear = getCurrentProgramYear()>
		<cfquery name="data" >
				SELECT billingStartDate
				FROM billingCycle
				WHERE billingCloseDate IS NULL
					AND billingType = 'attendance'
					AND ProgramYear = '#programYear#'
				ORDER BY billingStartDate desc
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction  name="getOpenBillingStartDates" access="remote"  >
		<cfquery name="data" >
				SELECT distinct billingStartDate
				FROM billingStudent
				WHERE billingStatus IN ('IN PROGRESS', 'REVIEWED')
					and includeFlag = 1
				ORDER BY billingStartDate desc
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getLatesBillingStartDate" access="remote" returntype="date">
		<cfquery name="data">
			select max(billingStartDate) billingStartDate
			from billingStudent
			where includeFlag = 1
		</cfquery>
		<cfreturn data.billingStartDate>
	</cffunction>
	<cffunction  name="getAttendanceBillingStartDates" access="remote"  >
		<cfargument name="programYear" default="">
		<cfif arguments.programYear EQ "">
			<cfset  arguments.programYear = getCurrentProgramYear()>
		</cfif>
		<cfquery name="data" >
				SELECT billingStartDate, billingEndDate
				FROM billingCycle
				WHERE billingType = 'attendance'
					and ProgramYear = <cfqueryparam value="#arguments.programYear#">
				ORDER BY billingStartDate desc
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getFirstOpenAttendanceDate" access="remote" >
		<cfquery name="data">
			SELECT min(billingStartDate) attendanceBillDate
			FROM billingCycle
			WHERE billingType = 'attendance'
				and billingCloseDate IS NULL
		</cfquery>
		<!---><cfif LEN(data.attendanceBillDate) EQ 0>
			<cfquery name="data">
				SELECT max(billingStartDate) attendanceBillDate
				FROM billingCycle
				WHERE billingType = 'attendance'
			</cfquery>
		</cfif>--->
		<cfreturn data.attendanceBillDate>
	</cffunction>
	<cffunction name="getLatestDateAttendanceMonth" access="remote" returntype="date">
		<cfquery name="data">
				SELECT max(billingStartDate) lastAttendanceBillDate
				FROM billingCycle
				WHERE billingType = 'attendance'
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
	<cffunction name="getFirstOpenAttendanceDates" access="remote">
		<cfquery name="data">
			select min(billingStartDate) billingStartDate
				,min(bs.Term) Term
			    ,min(billingEndDate) billingEndDate
			    ,min(termBeginDate) TermBeginDate
			    ,min(termDropDate) TermDropDate
			    ,min(termEndDate) TermEndDate
			from billingStudent bs
				join bannerCalendar bc on bs.term = bc.Term
			WHERE program like '%attendance%'
				and billingStatus IN ('IN PROGRESS', 'REVIEWED')
				and includeFlag = 1
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getBillingStatusForDate" access="remote" >
		<cfargument name="term" required="true">
		<cfquery name="data" >
            select fnGetBillingStatus(billingStudentId) billingStatus, count(*) NumRecords
            from billingStudent
            where term = <cfqueryparam value="#arguments.term#">
				and program not like '%attendance%'
			group by fnGetBillingStatus(billingStudentId)
			order by fnGetBillingStatus(billingStudentId)
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="convertTerm">
		<cfargument name="term" required="true">
		<cfset d = "">
		<cfswitch expression = "#right(arguments.Term,1)#">
			<cfcase value = 1>
				<cfset d = '-Winter'>
			</cfcase>
			<cfcase value = 2>
				<cfset d = '-Spring'>
			</cfcase>
			<cfcase value = 3>
				<cfset d = '-Summer'>
			</cfcase>
			<cfcase value = 4>
				<cfset d = '-Fall'>
			</cfcase>
		</cfswitch>
		<cfset d = "#arguments.term##d#">
		<cfreturn d>
	</cffunction>
</cfcomponent>
