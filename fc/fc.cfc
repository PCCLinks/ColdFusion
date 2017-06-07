<cfcomponent displayname="FC">

	<cffunction name="getTermByStudent" returntype="query" access="remote">
		<cfargument name="id" type="string" required="no" default="">
		<cfquery datasource="bannerpcclinks" name="termByStudent">
			SELECT *
			FROM swvlinks_term
			WHERE 1=1
			<cfif len(#arguments.id#) gt 0>
				and STU_ID = <cfqueryparam  value="#arguments.id#">
			</cfif>
		</cfquery>
		<cfreturn termByStudent>
	</cffunction>

	<cffunction name="getCoursesByStudent" returntype="query" access="remote">
		<cfargument name="id" type="string" required="yes" default="">
		<cfargument name="cohort" type="string" required="yes" default="">
		<cfquery datasource="bannerpcclinks" name="coursesByStudent">
			SELECT *
			, case when (TERM >= convert(Concat(CAST(left(<cfqueryparam  value="#arguments.cohort#">,4) as char(50)),'04'), unsigned integer)
							and TERM < convert(Concat(CAST((left(<cfqueryparam  value="#arguments.cohort#">,4)+1) as char(50)),'04'), unsigned integer))
						then 1 else 0 end as inFirstYear
			, case when PASSED = "Y" THEN CREDITS ELSE 0 END AS passedCredits

			, case when GRADE= 'A' then 4*CREDITS
				when GRADE = 'B' then 3*CREDITS
				when GRADE = 'C' then 2*CREDITS
				when GRADE = 'D' then 1*CREDITS
				else 0 end as pointsForGPA

			, case when GRADE= 'A' then CREDITS
				when GRADE = 'B' then CREDITS
				when GRADE = 'C' then CREDITS
				when GRADE = 'D' then CREDITS
				else 0 end as creditsForGPA

			, case when SUBJ = 'CG' AND CRSE = '100' AND PASSED = 'Y' THEN 1 ELSE 0 END AS 'cg100Passed'
			, case when SUBJ = 'CG' AND CRSE = '130' AND PASSED = 'Y' THEN 1 ELSE 0 END AS 'cg130Passed'
			FROM swvlinks_course
			WHERE STU_ID = <cfqueryparam  value="#arguments.id#">
		</cfquery>
		<cfreturn coursesByStudent>
	</cffunction>

	<cffunction name="getFirstYearMetrics" access="remote" returntype="query">
		<cfargument name="id" type="string" required="yes" default="">
		<cfargument name="cohort" type="string" required="yes" default="">
		<cfset BannerCourses = getCoursesByStudent(id=#arguments.id#, cohort=#arguments.cohort#)>
		<cfquery dbtype="query" name="firstYearMetrics">
			SELECT BannerCourses.STU_ID
				, SUM(BannerCourses.passedCredits) AS firstYearCredits
				, SUM(BannerCourses.pointsForGPA) / SUM(BannerCourses.creditsForGPA) as firstYearGPA
			FROM BannerCourses
			WHERE STU_ID = <cfqueryparam  value="#arguments.id#">
				AND inFirstYear = 1
			GROUP BY STU_ID
			</cfquery>
		<cfreturn firstYearMetrics>
	</cffunction>

	<cffunction name="getASAP_Degree" access="remote" returntype="query">
		<cfargument name="id" type="string" required="yes" default="">
		<cfset TermData = getTermByStudent(id=#arguments.id#)>
		<cfquery name="ASAP_Degree" datasource="bannerpcclinks">
			SELECT swvlinks_term.STU_ID
				, TERM
				, P_DEGR
				, INCOMING_SAP
			FROM swvlinks_term
				JOIN (
					SELECT STU_ID, MAX(TERM) AS maxTerm
					FROM swvlinks_term
					WHERE 1=1
					AND STU_ID = <cfqueryparam  value="#arguments.id#">
					GROUP BY STU_ID
					) maxs
						ON swvlinks_term.STU_ID = maxs.STU_ID
							and swvlinks_term.TERM = maxs.maxTerm
			WHERE swvlinks_term.STU_ID = <cfqueryparam  value="#arguments.id#">
		</cfquery>
		<cfreturn ASAP_Degree>
	</cffunction>


	<cffunction name="getCGPassed" access="remote" returntype="query">
		<cfargument name="id" type="string" required="yes" default="">
		<cfargument name="cohort" type="string" required="yes" default="">
		<cfset BannerCourses = getCoursesByStudent(id=#arguments.id#, cohort=#arguments.cohort#)>
		<cfquery dbtype="query" name="cgPassed">
			SELECT BannerCourses.STU_ID
				, MAX(cg100Passed) as cg100Passed
				, MAX(cg130Passed) as cg130Passed
			FROM BannerCourses
			WHERE STU_ID = <cfqueryparam  value="#arguments.id#">
			GROUP BY STU_ID
		</cfquery>
		<cfreturn cgPassed>
	</cffunction>

	<cffunction name="updateCase" access="remote">
		<cfargument name="data" type="struct">
		<cfquery name="create" result = "r">
			UPDATE pcc_links.fc SET cohort = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.cohort)#">,
				<!---gender = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.gender)#">,--->
				campus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.campus)#">,
				parental_status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.parental_status)#">,
				household_information = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.household_information)#">,
				living_situation = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.living_situation)#">,
				<!---citizen_status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.citizen_status)#">, --->
				professional_goal = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.professional_goal)#">,
				work_hours_weekly = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.work_hours_weekly)#">,
				statusabcx = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.statusabcx)#">,
				outcome_exit_reason = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.outcome_exit_reason)#">,
				coach = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.coach)#">,
				phone2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.phone2)#">,
				<!---_personal = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data._personal)#">,--->
				notes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.notes)#">

			WHERE fc.G =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.G)#">
		  </cfquery>
		<cfif len(trim(arguments.data.notes)) GT 0>
			<cfset insertNote(tableID="#arguments.data.G#", noteText="#trim(arguments.data.notes)#")>
		</cfif>
	</cffunction>


	<cffunction name="insertNote" access="private">
		<cfargument name="tableID" required="true">
		<cfargument name="noteText" required="true">
		<cfquery name="insert" >
			INSERT INTO pcc_links.notes(tableName, tableID, noteText)
			VALUES('fc','#arguments.tableID#', '#arguments.noteText#')
		</cfquery>
	</cffunction>


	<cffunction name="getCaseload" access="remote" returntype="query">
		<cfargument name="cohort" type="string" default="">
		<cfargument name="campus" type="string" default="">
		<cfargument name="coach" type="string" default="">
		<cfargument name="G" type="string" default="">
		<cfargument name="last_name" type="string" default="">
		<cfargument name="first_name" type="string" default="">
		<cfargument name="asap_status" type="string" default="">
		<cfargument name="statusabcx" type="string" default="">

		<!---------------------------------->
		<!--- SIDNY Future Connect Data ---->
		<!---------------------------------->
		<cfquery name="fcTbl">
			SELECT *
			, case when CAST(right(cohort,1) as char(50)) = '1' then 'Portland'
				when CAST(right(cohort,1) as char(50)) = '2' then 'Beaverton'
				when CAST(right(cohort,1) as char(50)) = '3' then 'Hillsboro'
				else 'State' end as fund_source

			, case when CAST(right(cohort,1) as char(50)) = '1'
				and CURDATE() >= STR_TO_DATE(CONCAT(9, '/',1,'/',(convert(CAST(left(cohort,4) as char(50)), unsigned integer)+3) ),'%m/%d/%YY')
				then 'No'
				when CAST(right(cohort,1) as char(50)) > '1'
				and CURDATE() >= STR_TO_DATE(CONCAT(9, '/',1,'/',(convert(CAST(left(cohort,4) as char(50)), unsigned integer)+2) ),'%m/%d/%YY')
				then 'No'
				else 'Yes' end as in_contract


			,  convert(Concat(CAST(left(cohort,4) as char(50)),'04'), unsigned integer) as cohortFirstFall
			,  convert(Concat(CAST((left(cohort,4)+1) as char(50)),'04'), unsigned integer) as cohortSecondFall

			FROM pcc_links.fc
			WHERE 1=1
			<cfif len(#arguments.G#) gt 0>
				and G = <cfqueryparam  value="#arguments.G#">
			</cfif>
			<cfif len(trim(arguments.cohort))>
				AND cohort = <cfqueryparam  value="#arguments.cohort#">
			</cfif>
			<cfif len(trim(arguments.campus))>
				AND campus = <cfqueryparam  value="#arguments.campus#">
			</cfif>
			<cfif len(trim(arguments.coach))>
				AND coach = <cfqueryparam  value="#arguments.coach#">
			</cfif>
			<cfif len(trim(arguments.G))>
				AND G = <cfqueryparam  value="#arguments.G#">
			</cfif>
			<cfif len(trim(arguments.last_name))>
				AND last_name = <cfqueryparam  value="#arguments.last_name#">
			</cfif>
			<cfif len(trim(arguments.first_name))>
				AND first_name = <cfqueryparam  value="#arguments.first_name#">
			</cfif>
			<cfif len(trim(arguments.asap_status))>
				AND asap_status = <cfqueryparam  value="#arguments.asap_status#">
			</cfif>
			<cfif len(trim(arguments.statusabcx))>
				AND statusabcx = <cfqueryparam  value="#arguments.statusabcx#">
			</cfif>
		</cfquery>
		<!---  end SIDNY Future Connect Data --->

		<!---------------------------------->
		<!------- Banner Person Data ------->
		<!---------------------------------->
		<cfquery datasource="bannerpcclinks" name="BannerPopulation">
			SELECT *
			FROM swvlinks_person
			WHERE 1=1
			<cfif len(#arguments.G#) gt 0>
				and STU_ID = <cfqueryparam  value="#arguments.G#">
			</cfif>
		</cfquery>
		<!---- end Banner Person Data ---->

		<!------ Merge SIDNY and Banner Data ----->
		<cfquery dbtype="query" name="caseload_banner">
			SELECT fcTbl.*
				, BannerPopulation.*
			FROM fcTbl, BannerPopulation
			WHERE fcTbl.G = BannerPopulation.STU_ID
		</cfquery>

		<!---- add URL link to go to edit screen ---->
		<cfset queryAddColumn(caseload_banner,"editlink","varchar",arrayNew(1))>
		<cfloop query="caseload_banner">
			<cfsavecontent variable="edittext">
				<cfoutput><a href="javascript:goToDetail('#caseload_banner.G#')">Edit</a></cfoutput>
			</cfsavecontent>
			<cfset querySetCell(caseload_banner, "editlink", edittext, currentRow)>
		</cfloop>
		<!--- end add URL ---->

		<cfreturn caseload_banner>
	</cffunction>


	<cffunction name="getStudentTermMetrics" access="remote" returntype="query">
		<cfargument name="id" type="string" required="yes" default="">
		<cfset TermData = getTermByStudent(id=#arguments.id#)>
		<cfquery datasource="bannerpcclinks" name="StudentTermMetrics">
			SELECT STU_ID
				, STU_NAME
				, TERM
				, T_GPA
				, T_EARNED
			FROM swvlinks_term
			WHERE STU_ID = <cfqueryparam  value="#arguments.id#">
			ORDER BY TERM ASC
			</cfquery>
		<cfreturn StudentTermMetrics>
	</cffunction>


	<cffunction name="getNotes">
		<cfargument name="ID" required="yes">
		<cfset tableName="fc">
		<cfquery name="comments">
		select *
		from pcc_links.notes
		where tableName = <cfqueryparam value="#tablename#">
			and tableID = <cfqueryparam value="#arguments.ID#">
		order by noteDateAdded desc
	</cfquery>
		<cfreturn comments>
	</cffunction>


</cfcomponent>
