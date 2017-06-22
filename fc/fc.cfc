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
		<cfset firstYearBeginningTerm = LEFT(arguments.cohort,4) & '04' >
		<cfset firstYearEndingTerm = (VAL(LEFT(arguments.cohort,4))+1) & '03' >
		<!--- note that  for Oracle, select "*" did not work in this query
		  unlike MySql --->
		<cfquery datasource="bannerpcclinks" name="coursesByStudent">
			SELECT STU_ID, TERM, CRN, SUBJ, CRSE, TITLE, CREDITS, GRADE, PASSED
			, case when (TERM >= <cfqueryparam value="#firstYearBeginningTerm#">
							and TERM <= <cfqueryparam value="#firstYearEndingTerm#"> )
						then 1 else 0 end as inFirstYear
			, case when PASSED = 'Y' THEN CREDITS ELSE 0 END AS passedCredits

			, case when GRADE= 'A' then 4*CREDITS
				when GRADE = 'B' then 3*CREDITS
				when GRADE = 'C' then 2*CREDITS
				when GRADE = 'D' then 1*CREDITS
				else 0 end as pointsForGPA

			, case when GRADE= 'A' then CREDITS
				when GRADE = 'B' then CREDITS
				when GRADE = 'C' then CREDITS
				when GRADE = 'D' then CREDITS
				when GRADE = 'F' then CREDITS
				else 0 end as creditsForGPA

			, case when SUBJ = 'CG' AND CRSE = '100' AND PASSED = 'Y' THEN 1 ELSE 0 END AS cg100Passed
			, case when SUBJ = 'CG' AND CRSE = '130' AND PASSED = 'Y' THEN 1 ELSE 0 END AS cg130Passed
			, case when SUBJ = 'CG' AND CRSE = '190' AND PASSED = 'Y' THEN 1 ELSE 0 END AS cg190Passed
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
				, SUM(BannerCourses.pointsForGPA)/SUM(BannerCourses.creditsForGPA) as firstYearGPA
			FROM BannerCourses
			WHERE STU_ID = <cfqueryparam  value="#arguments.id#">
				AND inFirstYear = 1
			GROUP BY STU_ID
			HAVING SUM(BannerCourses.creditsForGPA) > 0
			UNION
			SELECT BannerCourses.STU_ID
				, 0 AS firstYearCredits
				, 0 as firstYearGPA
			FROM BannerCourses
			WHERE STU_ID = <cfqueryparam  value="#arguments.id#">
				AND inFirstYear = 1
			GROUP BY STU_ID
			HAVING SUM(BannerCourses.creditsForGPA) = 0
			</cfquery>
		<cf>
		<cfreturn firstYearMetrics>
	</cffunction>

	<cffunction name="getMaxTermData" access="remote" returntype="query">
		<cfargument name="id" type="string" required="no" default="">
		<cfquery name="MaxTermData" datasource="bannerpcclinks">
			SELECT swvlinks_term.STU_ID
				, TERM
				, P_DEGREE
				, EFC
				, coalesce(OUTGOING_SAP, INCOMING_SAP) AS ASAP_STATUS
			FROM swvlinks_term
				JOIN (
					SELECT STU_ID, MAX(TERM) AS maxTerm
					FROM swvlinks_term
					WHERE 1=1
					<cfif len(#arguments.id#) gt 0>
						and STU_ID = <cfqueryparam  value="#arguments.id#">
					</cfif>

					GROUP BY STU_ID
					) maxs
						ON swvlinks_term.STU_ID = maxs.STU_ID
							and swvlinks_term.TERM = maxs.maxTerm

		</cfquery>
		<cfreturn MaxTermData>
	</cffunction>


	<cffunction name="getMaxRegistration" access="remote" returntype="query">
		<cfargument name="id" type="string" required="yes" default="">
		<cfquery datasource="bannerpcclinks" name="maxRegistration">

			SELECT swvlinks_course.STU_ID
			, swvlinks_course.TERM as maxRegistrationTerm
			, sum(CREDITS) AS maxRegistrationCredits
			FROM swvlinks_course

				JOIN (
					SELECT STU_ID, MAX(TERM) AS maxTerm
					FROM swvlinks_course
					WHERE 1=1
					<cfif len(#arguments.id#) gt 0>
						and STU_ID = <cfqueryparam  value="#arguments.id#">
					</cfif>

					GROUP BY STU_ID
					) maxs
						ON swvlinks_course.STU_ID = maxs.STU_ID
							and swvlinks_course.TERM = maxs.maxTerm

			WHERE swvlinks_course.STU_ID = <cfqueryparam  value="#arguments.id#">

			GROUP BY swvlinks_course.STU_ID
			, swvlinks_course.TERM

		</cfquery>
		<cfreturn maxRegistration >
	</cffunction>



	<cffunction name="getCGPassed" access="remote" returntype="query">
		<cfargument name="id" type="string" required="yes" default="">
		<cfargument name="cohort" type="string" required="yes" default="">
		<cfset BannerCourses = getCoursesByStudent(id=#arguments.id#, cohort=#arguments.cohort#)>
		<cfquery dbtype="query" name="cgPassed">
			SELECT BannerCourses.STU_ID
				, MAX(cg100Passed) as cg100Passed
				, MAX(cg130Passed) as cg130Passed
				, MAX(cg190Passed) as cg190Passed
			FROM BannerCourses
			WHERE STU_ID = <cfqueryparam  value="#arguments.id#">
			GROUP BY STU_ID
		</cfquery>
		<cfreturn cgPassed>
	</cffunction>

	<cffunction name="updateCase" access="remote">
		<cfargument name="data" type="struct">
		<cfquery name="create" result = "r">
			UPDATE futureConnect SET
				cohort = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.cohort)#">,
				preferredName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.preferredName)#">,
				gender = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.gender)#">,
				campus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.campus)#">,
				parentalStatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.parentalStatus)#">,
<!---
				Household = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.household_information)#">,
				LivingSituation = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.living_situation)#">,
				<!---citizen_status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.citizen_status)#">, --->
--->
				careerPlan = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.careerPlan)#">,

				weeklyWorkHours = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.weeklyWorkHours)#">,
				statusInternal = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.statusInternal)#">,
				exitReason = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.exitReason)#">,
				coach = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.coach)#">,
				cellPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.cellPhone)#">,
				phone2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.phone2)#">,
				emailPersonal = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.emailPersonal)#">


			WHERE futureConnect.bannerGNumber =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.bannerGNumber)#">
		  </cfquery>

		<cfif len(trim(arguments.data.notes)) GT 0>
			<cfset insertNote(contactID="#arguments.data.contactID#", noteText="#trim(arguments.data.notes)#")>
		</cfif>
		<cfset saveEnrichmentProgramData(data=arguments.data) >
	</cffunction>

	<cffunction name="saveEnrichmentProgramData" access="private">
		<cfargument name="data" required="true">
		<cfset contactID = "#trim(arguments.data.contactid)#">
		<cfset debug=false>
		<cfquery name="existingEntries">
			SELECT *
			FROM enrichmentProgramContact
			WHERE contactID = <cfqueryparam value="#contactID#">
				AND tableName = 'fc'
		</cfquery>
		<cfloop query="existingEntries">
			<cfset exists=false>
			<cfloop collection="#arguments.data#" item="key">
				<cfif debug>key left,19:<cfdump var="#left(key,19)#"><br></cfif>
				<cfif left(key,19) EQ "enrichmentProgramID">
					<cfset checkedID = RIGHT(key,len(key)-19)>
					<cfif debug>checkedid=<cfdump var="#checkedID#"><br></cfif>
					<cfif debug>existingEntries=<cfdump var="#existingEntries.enrichmentProgramID#"><br></cfif>
					<cfif existingEntries.enrichmentProgramID EQ checkedID>
						<cfset exists=true>
						<cfif debug>found<br></cfif>
					</cfif> <!--- matches a value that is checked --->
				</cfif> <!-- if enrichment field --->
			</cfloop> <!--- form values --->
			<!--- no longer checked, delete it --->
			<cfif exists EQ false>
				<cfif debug>delete entry:<cfdump var="#existingEntries.enrichmentProgramContactID#"></cfif>
				<cfquery name="deleteEntry">
					delete from enrichmentProgramContact
					where enrichmentProgramContactID = <cfqueryparam value="#existingEntries.enrichmentProgramContactID#">
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop collection="#arguments.data#" item="key">
			<cfif left(key,19) EQ "enrichmentProgramID">
				<cfset checkedID = RIGHT(key,len(key)-19)>
				<cfset exists=false>
				<cfloop query="existingEntries">
					<cfif existingEntries.enrichmentProgramID EQ checkedID>
						<cfset exists=true>
					</cfif> <!--- matches a value that is checked --->
				</cfloop> <!---existing entries --->
				<cfif exists EQ false>
					<cfquery name="insertEntry">
						insert into enrichmentProgramContact(contactID, enrichmentProgramID, tableName)
						values(#contactID#, #checkedID#, 'fc')
					</cfquery>
				</cfif>
			</cfif> <!-- if enrichment field --->
		</cfloop> <!--- form values --->
	</cffunction>

	<cffunction name="insertNote" access="private">
		<cfargument name="contactID" required="true">
		<cfargument name="noteText" required="true">
		<cfquery name="insert" >
			INSERT INTO sidny.notes(tableName, contactID, noteText, noteDateAdded, noteAddedBy)
			VALUES('futureConnect','#arguments.contactID#', '#arguments.noteText#', Now(), 'changeme')

		</cfquery>
	</cffunction>


	<cffunction name="getCaseload" access="remote" returntype="query">
		<cfargument name="bannerGNumber" type="string" default="">

		<cfset maxTermData = getMaxTermData(id=#arguments.bannerGNumber#)>


		<!---------------------------------->
		<!--- SIDNY Future Connect Data ---->
		<!---------------------------------->
		<cfquery name="fcTbl">
			SELECT futureConnect.*
			, futureConnectApplication.*
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

			FROM futureConnect
				LEFT JOIN futureConnectApplication
					on futureConnect.bannerGNumber = futureConnectApplication.StudentID
			WHERE 1=1
			<cfif len(#arguments.bannerGNumber#) gt 0>
				and bannerGNumber = <cfqueryparam  value="#arguments.bannerGNumber#">
			</cfif>

		</cfquery>

		<!---  end SIDNY Future Connect Data --->

		<!---------------------------------->
		<!------- Banner Person Data ------->
		<!---------------------------------->
		<cfquery datasource="bannerpcclinks" name="BannerPopulation">
			SELECT distinct STU_ID
		    , STU_NAME
		    , STU_ZIP
		    , STU_CITY
		    , O_GPA
		    , O_ATTEMPTED
		    , O_EARNED
		    , O_EARNED_CAT
		    , GENDER
		    , BIRTHDATE
		    , REP_RACE
		    , ASIAN
		    , NATIVE
		    , BLACK
		    , HISPANIC
		    , ISLANDER
		    , WHITE
		    , HS_CODE
		    , HS_NAME
		    , HS_CITY
		    , HS_STATE
		    , HS_GRAD_DATE
		    , HS_DPLM
		    , TE_MATH
		    , TE_READ
		    , TE_WRITE
		    , RE_HOLD
		    , PCC_EMAIL
			FROM swvlinks_person

			WHERE 1=1
			<cfif len(#arguments.bannerGNumber#) gt 0>
				and STU_ID = <cfqueryparam  value="#arguments.bannerGNumber#">
			</cfif>


		</cfquery>
		<!---- end Banner Person Data ---->




		<!------ Merge SIDNY and Banner Person and Term ----->
		<cfquery dbtype="query" name="futureConnect_bannerPerson">
			SELECT fcTbl.*
				, BannerPopulation.*
			<!--- coalesce the incoming and outgoing asap from the term extract --->
			FROM fcTbl, BannerPopulation
			WHERE fcTbl.bannerGNumber = BannerPopulation.STU_ID
		</cfquery>


		<cfquery dbtype="query" name="caseload_banner">
			SELECT futureConnect_bannerPerson.STU_ID
			, futureConnect_bannerPerson.contactID
			, futureConnect_bannerPerson.bannerGNumber
			, futureConnect_bannerPerson.STU_NAME
			, futureConnect_bannerPerson.preferredName
			, futureConnect_bannerPerson.gender
			, futureConnect_bannerPerson.REP_RACE
			, futureConnect_bannerPerson.HighSchool
			, futureConnect_bannerPerson.parentalStatus
			, futureConnect_bannerPerson.Household
			, futureConnect_bannerPerson.LivingSituation
			, futureConnect_bannerPerson.careerPlan
			, maxTermData.EFC
			, futureConnect_bannerPerson.RE_HOLD
			, futureConnect_bannerPerson.cohort
			, futureConnect_bannerPerson.campus
			, futureConnect_bannerPerson.coach
			, futureConnect_bannerPerson.statusInternal
			, futureConnect_bannerPerson.O_EARNED
			, futureConnect_bannerPerson.O_GPA
			, futureConnect_bannerPerson.te_read
			, futureConnect_bannerPerson.te_write
			, futureConnect_bannerPerson.te_math
			, futureConnect_bannerPerson.exitReason
			, futureConnect_bannerPerson.cellPhone
			, futureConnect_bannerPerson.phone2
			, futureConnect_bannerPerson.PCC_EMAIL
			, futureConnect_bannerPerson.emailPersonal
			, futureConnect_bannerPerson.weeklyWorkHours

			, ASAP_STATUS
			, in_contract
		    , RE_HOLD

			FROM futureConnect_bannerPerson, maxTermData
			WHERE maxTermData.STU_ID = futureConnect_bannerPerson.STU_ID
			<cfif len(#arguments.bannerGNumber#) gt 0>
				and futureConnect_bannerPerson.STU_ID = <cfqueryparam  value="#arguments.bannerGNumber#">
			</cfif>
		</cfquery>



		<!---- add URL link to go to edit screen ---->
		<cfset queryAddColumn(caseload_banner,"editlink","varchar",arrayNew(1))>
		<cfloop query="caseload_banner">
			<cfsavecontent variable="edittext">
				<cfoutput><a href="javascript:goToDetail('#caseload_banner.bannerGNumber#')">Edit</a></cfoutput>
			</cfsavecontent>
			<cfset querySetCell(caseload_banner, "editlink", edittext, currentRow)>
		</cfloop>
		<!--- end add URL ---->

		<cfreturn caseload_banner>
	</cffunction>


	<cffunction name="getStudentTermMetrics" access="remote" returntype="query">
		<cfargument name="id" type="string" required="yes" default="">
		<cfquery datasource="bannerpcclinks" name="StudentTermMetrics">
			SELECT STU_ID
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
		<cfargument name="contactID" required="yes">
		<cfset tableName="futureConnect">
		<cfquery name="comments">
		select *
		from notes
		where tableName = <cfqueryparam value="#tablename#">
			and contactID = <cfqueryparam value="#arguments.contactID#">

		order by noteDateAdded desc
	</cfquery>
		<cfreturn comments>
	</cffunction>

	<cffunction name="getEnrichmentProgramsWithAssignments">
		<cfargument name="contactID" required="yes">
		<cfset tableName="fc">
		<cfquery name="programs">
		select ep.enrichmentProgramID id
			,enrichmentProgramDescription description
			,CASE WHEN contactID IS NULL THEN 0 ELSE 1 END checked
		from enrichmentProgram ep
			left outer join enrichmentProgramContact epc
				on ep.enrichmentProgramID = epc.enrichmentProgramID
					and tableName = <cfqueryparam value="#tablename#">
					and epc.contactID = <cfqueryparam value="#arguments.contactID#">
	</cfquery>
		<cfreturn programs>
	</cffunction>

</cfcomponent>
