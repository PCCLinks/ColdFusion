<cfcomponent displayname="FC">
<!------- NOTES -------
Queries with bannerpcclinks datasource are views from the Banner system
Banner views have an ATTS attribute that identify what program a student is in.  Since overtime, a student may be in more than one program
all the banner queries need to force a distinct by PIDM
--->

	<cfobject name="mscbCFC" component="pcclinks.includes.multiSelectCheckbox">

	<cffunction name="getTermByStudent" returntype="query" access="remote" >
		<cfargument name="pidm" type="string" required="no" default="">
		<cfquery datasource="bannerpcclinks" name="termByStudent" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT distinct PIDM
				, TERM
 				, f_pcc_id(PIDM) STU_ID
 				, SAP_CAST INCOMING_SAP
 				, OUTGOING_SAP
			     , SGBSTDN_CAMP_CODE  P_CAMPUS
			     , STVCAMP_DESC  P_CAMPUS_DESC
			     , SGBSTDN_DEGC_CODE_1 P_DEGREE
			     , STVDEGC_DESC  P_DEGREE_DESC
			     , SGBSTDN_MAJR_CODE_1 P_MAJOR
			     , STVMAJR_DESC P_MAJOR_DESC
			     , trunc(SHRTGPA_GPA,3) T_GPA
			     , SHRTGPA_HOURS_ATTEMPTED T_ATTEMPTED
			     , SHRTGPA_HOURS_EARNED T_EARNED
			     , to_char(EFC, '$99,999') as EFC
			FROM swvlinks_term
			WHERE 1=1
			<cfif len(#arguments.id#) gt 0>
				and PIDM = <cfqueryparam  value="#arguments.pidm#">
			</cfif>
		</cfquery>
		<cfreturn termByStudent>
	</cffunction>

	<cffunction name="getCoursesByStudent" returntype="query" access="remote" >
		<cfargument name="pidm" type="numeric" required="yes" >
		<cfargument name="cohort" type="string" required="yes" >
		<cfset firstYearBeginningTerm = LEFT(arguments.cohort,4) & '04' >
		<cfset firstYearEndingTerm = (VAL(LEFT(arguments.cohort,4))+1) & '03' >
		<!--- note that  for Oracle, select "*" did not work in this query
		  unlike MySql --->
		<cfquery datasource="bannerpcclinks" name="coursesByStudent" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT distinct PIDM, STU_ID, TERM, CRN, SUBJ, CRSE, TITLE, CREDITS, GRADE, PASSED
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
			WHERE PIDM = <cfqueryparam  value="#arguments.pidm#">
		</cfquery>
		<cfreturn coursesByStudent>
	</cffunction>

	<cffunction name="getFirstYearMetrics" access="remote" returntype="query" >
		<cfargument name="pidm" type="numeric" required="yes" >
		<cfargument name="cohort" type="string" required="yes" >
		<cfset BannerCourses = getCoursesByStudent(pidm=#arguments.pidm#, cohort=#arguments.cohort#)>
		<cfquery dbtype="query" name="firstYearMetrics" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT BannerCourses.STU_ID
				, SUM(BannerCourses.passedCredits) AS firstYearCredits
				, SUM(BannerCourses.pointsForGPA)/SUM(BannerCourses.creditsForGPA) as firstYearGPA
			FROM BannerCourses
			WHERE inFirstYear = 1
				and PIDM = <cfqueryparam value="#arguments.pidm#">
			GROUP BY STU_ID
			HAVING SUM(BannerCourses.creditsForGPA) > 0
			UNION
			SELECT BannerCourses.STU_ID
				, 0 AS firstYearCredits
				, 0 as firstYearGPA
			FROM BannerCourses
			WHERE inFirstYear = 1
				and PIDM = <cfqueryparam value="#arguments.pidm#">
			GROUP BY STU_ID
			HAVING SUM(BannerCourses.creditsForGPA) = 0
			</cfquery>
		<cf>
		<cfreturn firstYearMetrics>
	</cffunction>

	<cffunction name="getMaxTermData" access="remote" returntype="query" >
		<cfargument name="pidm" type="string" required="no" default="">
		<cfquery name="MaxTermData" datasource="bannerpcclinks" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT distinct swvlinks_term.STU_ID
				, TERM
				, P_DEGREE
				, to_char(EFC,'$99,999') as EFC
				, coalesce(OUTGOING_SAP, INCOMING_SAP) AS ASAP_STATUS
			FROM swvlinks_term
				JOIN (
					SELECT STU_ID, MAX(TERM) AS maxTerm
					FROM swvlinks_term
					WHERE 1=1
					<cfif len(#arguments.pidm#) gt 0>
						and PIDM = <cfqueryparam  value="#arguments.pidm#">
					</cfif>
					GROUP BY STU_ID
					) maxs
						ON swvlinks_term.STU_ID = maxs.STU_ID
							and swvlinks_term.TERM = maxs.maxTerm
		</cfquery>
		<cfreturn MaxTermData>
	</cffunction>
	<cffunction name="getMaxRegistration" access="remote" returntype="query" >
		<cfargument name="pidm" type="numeric" required="yes" >
		<cfargument name="maxterm" type="string" required="yes">
		<cfquery datasource="bannerpcclinks" name="maxRegistration" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT STU_ID
				, TERM as maxRegistrationTerm
				, sum(CREDITS) AS maxRegistrationCredits
			FROM (select distinct STU_ID, TERM, CRN, CREDITS
			      from swvlinks_course
				  where PIDM = <cfqueryparam  value="#arguments.pidm#">
						and Term = <cfqueryparam  value="#arguments.maxterm#">) data
			GROUP BY STU_ID, TERM
		</cfquery>
		<cfreturn maxRegistration >
	</cffunction>
	<cffunction name="getCGPassed" access="remote" returntype="query" >
		<cfargument name="pidm" type="numeric" required="yes" >
		<cfargument name="cohort" type="string" required="yes" >
		<cfset BannerCourses = getCoursesByStudent(pidm=#arguments.pidm#, cohort=#arguments.cohort#)>
		<cfquery dbtype="query" name="cgPassed" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT BannerCourses.STU_ID
				, MAX(cg100Passed) as cg100Passed
				, MAX(cg130Passed) as cg130Passed
				, MAX(cg190Passed) as cg190Passed
			FROM BannerCourses
			WHERE PIDM = <cfqueryparam  value="#arguments.pidm#">
			GROUP BY BannerCourses.STU_ID
		</cfquery>
		<cfreturn cgPassed>
	</cffunction>

	<cffunction name="updateCase" access="remote" returnformat="json" >
		<cfargument name="data" type="struct">

		<cfquery name="create" result = "r">
			UPDATE futureConnect SET
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
				emailPersonal = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.emailPersonal)#">,
				flagged=<cfqueryparam value=#trim(arguments.data.flagged)#>
			WHERE futureConnect.contactID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.contactID)#">
		  </cfquery>

		<cfif len(trim(arguments.data.notes)) GT 0>
			<cfset insertNote(contactID="#arguments.data.contactID#", noteText="#trim(arguments.data.notes)#")>
		</cfif>
		<cfset saveEnrichmentProgramData(data=arguments.data, contactid=#trim(arguments.data.contactID)#) >
		<cfset savehouseholdData(data=arguments.data) >
		<cfset saveLivingSituationData(data=arguments.data) >
		<cfheader statusCode=200 statustext="success" >
	</cffunction>

	<cffunction name="saveEnrichmentProgramData" access="private">
		<cfargument name="data" required="true">
		<cfargument name="contactID" required="true">
		<cfset checkedIds = mscbCFC.getCheckedCollection(data=data, idFieldName="enrichmentProgramId")>
		<cfquery name="existingEntries">
			SELECT enrichmentProgramId Id
			FROM enrichmentProgramContact
			WHERE contactID = <cfqueryparam value="#contactID#">
				AND tableName = 'futureConnect'
		</cfquery>
		<cfset idsToDelete = mscbCFC.getValuesToDelete(existingEntries, checkedIds)>
		<cflog file="pcclinks_fc" text="idsToDelete:#idsToDelete#">
		<cfquery name="deleteEntry">
			DELETE FROM enrichmentProgramContact
			WHERE enrichmentProgramID IN (<cfqueryparam value="#idsToDelete#" cfsqltype="CF_SQL_INTEGER" list="yes" >)
				and contactid = <cfqueryparam value="#contactId#">
		</cfquery>
		<cfset idsToInsert = mscbCFC.getValuesToInsert(existingEntries, checkedIds)>
		<cflog file="pcclinks_fc" text="idsToInsert:#idsToInsert#">
		<cfquery name="insertEntry">
			insert into enrichmentProgramContact(contactID, enrichmentProgramID, tableName)
			select <cfqueryparam value=#contactID#>, enrichmentProgramID, 'futureConnect'
			from enrichmentProgram
			where enrichmentProgramID in (<cfqueryparam value="#idsToInsert#" cfsqltype="CF_SQL_INTEGER" list="yes">)
		</cfquery>
	</cffunction>

	<cffunction name="savehouseholdData" access="private">
		<cfargument name="data" required="true">
		<cfset contactID = "#trim(arguments.data.contactid)#">
		<cfset debug=false>
		<cfquery name="existingEntries">
			SELECT *
			FROM householdContact
			WHERE contactID = <cfqueryparam value="#contactID#">
				AND tableName = 'futureConnect'
		</cfquery>
		<cfloop query="existingEntries">
			<cfset exists=false>
			<cfloop collection="#arguments.data#" item="key">
				<cfif debug>key left,11:<cfdump var="#left(key,11)#"><br></cfif>
				<cfif left(key,11) EQ "householdID">
					<cfset checkedID = RIGHT(key,len(key)-11)>
					<cfif debug>checkedid=<cfdump var="#checkedID#"><br></cfif>
					<cfif debug>existingEntries=<cfdump var="#existingEntries.householdID#"><br></cfif>
					<cfif existingEntries.householdID EQ checkedID>
						<cfset exists=true>
						<cfif debug>found<br></cfif>
					</cfif> <!--- matches a value that is checked --->
				</cfif> <!--- if enrichment field --->
			</cfloop> <!--- form values --->
			<!--- no longer checked, delete it --->
			<cfif exists EQ false>
				<cfif debug>delete entry:<cfdump var="#existingEntries.householdContactID#"></cfif>
				<cfquery name="deleteEntry">
					delete from householdContact
					where householdContactID = <cfqueryparam value="#existingEntries.householdContactID#">
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop collection="#arguments.data#" item="key">
			<cfif left(key,11) EQ "householdID">
				<cfset checkedID = RIGHT(key,len(key)-11)>
				<cfset exists=false>
				<cfloop query="existingEntries">
					<cfif existingEntries.householdID EQ checkedID>
						<cfset exists=true>
					</cfif> <!--- matches a value that is checked --->
				</cfloop> <!---existing entries --->
				<cfif exists EQ false>
					<cfquery name="insertEntry">
						insert into householdContact(contactID, householdID, tableName)
						values(#contactID#, #checkedID#, 'futureConnect')
					</cfquery>
				</cfif>
			</cfif> <!--- if enrichment field --->
		</cfloop> <!--- form values --->
	</cffunction>

	<cffunction name="savelivingSituationData" access="private">
		<cfargument name="data" required="true">
		<cfset contactID = "#trim(arguments.data.contactid)#">
		<cfset debug=false>
		<cfquery name="existingEntries">
			SELECT *
			FROM livingSituationContact
			WHERE contactID = <cfqueryparam value="#contactID#">
				AND tableName = 'futureConnect'
		</cfquery>
		<cfloop query="existingEntries">
			<cfset exists=false>
			<cfloop collection="#arguments.data#" item="key">
				<cfif debug>key left,11:<cfdump var="#left(key,11)#"><br></cfif>
				<cfif left(key,17) EQ "livingSituationID">
					<cfset checkedID = RIGHT(key,len(key)-17)>
					<cfif debug>checkedid=<cfdump var="#checkedID#"><br></cfif>
					<cfif debug>existingEntries=<cfdump var="#existingEntries.livingSituationID#"><br></cfif>
					<cfif existingEntries.livingSituationID EQ checkedID>
						<cfset exists=true>
						<cfif debug>found<br></cfif>
					</cfif> <!--- matches a value that is checked --->
				</cfif> <!--- if enrichment field --->
			</cfloop> <!--- form values --->
			<!--- no longer checked, delete it --->
			<cfif exists EQ false>
				<cfif debug>delete entry:<cfdump var="#existingEntries.livingSituationContactID#"></cfif>
				<cfquery name="deleteEntry">
					delete from livingSituationContact
					where livingSituationContactID = <cfqueryparam value="#existingEntries.livingSituationContactID#">
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop collection="#arguments.data#" item="key">
			<cfif left(key,17) EQ "livingSituationID">
				<cfset checkedID = RIGHT(key,len(key)-17)>
				<cfset exists=false>
				<cfloop query="existingEntries">
					<cfif existingEntries.livingSituationID EQ checkedID>
						<cfset exists=true>
					</cfif> <!--- matches a value that is checked --->
				</cfloop> <!---existing entries --->
				<cfif exists EQ false>
					<cfquery name="insertEntry">
						insert into livingSituationContact(contactID, livingSituationID, tableName)
						values(#contactID#, #checkedID#, 'futureConnect')
					</cfquery>
				</cfif>
			</cfif> <!--- if enrichment field --->
		</cfloop> <!--- form values --->
	</cffunction>


	<cffunction name="insertNote" access="private">
		<cfargument name="contactID" required="true">
		<cfargument name="noteText" required="true">
		<cfquery name="insert" >
			INSERT INTO sidny.notes(tableName, contactID, noteText, noteDateAdded, noteAddedBy)
			VALUES('futureConnect','#arguments.contactID#', '#arguments.noteText#', Now(), '#session.username#')
		</cfquery>
	</cffunction>

	<cffunction name="getCaseload" access="remote" returntype="query" returnformat="json" >
		<cfargument name="pidm" type="string" default="">
		<cfargument name="in_contract" type="string" default="No">

		<!---------------------------------->
		<!------- Banner Person Data ------->
		<!---------------------------------->
		<cfquery datasource="bannerpcclinks" name="BannerPopulation" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT distinct PIDM
			, STU_ID
		    , STU_NAME
		    , STU_ZIP
		    , STU_CITY
		    , ROUND(O_GPA,2) AS O_GPA
		    , O_ATTEMPTED
		    , ROUND(O_EARNED,2) AS O_EARNED
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
			<cfif len(#arguments.pidm#) gt 0>
				and PIDM = <cfqueryparam  value="#arguments.pidm#">
			</cfif>
		</cfquery>
		<!---- end Banner Person Data ---->

		<!---------------------------------->
		<!--- SIDNY Future Connect Data ---->
		<!---------------------------------->
		<cfquery name="fcTbl" >
			SELECT futureConnect.*
			, futureConnectApplication.*
			, Date_Format(lastContact.lastContactDate,'%m/%d/%Y') lastContactDate
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
				LEFT JOIN (
					select contactID, max(noteDateAdded) as lastContactDate
					from notes
					where noteAddedBy != 'system'
					group by contactID) lastContact
						on futureConnect.contactID = lastContact.contactID

			WHERE 1=1
			<cfif len(#arguments.pidm#) gt 0>
				and bannerGNumber = <cfqueryparam  value="#BannerPopulation.stu_id#">
			</cfif>
		</cfquery>

		<!---  end SIDNY Future Connect Data --->

		<!------ Merge SIDNY and Banner Person and Term ----->
		<cfquery dbtype="query" name="futureConnect_bannerPerson" >
			SELECT fcTbl.*
				, BannerPopulation.*
			<!--- coalesce the incoming and outgoing asap from the term extract --->
			FROM fcTbl, BannerPopulation
			WHERE fcTbl.bannerGNumber = BannerPopulation.STU_ID
		</cfquery>

		<cfif len(arguments.pidm) gt 0>
			<cfset maxTermData = getMaxTermData(pidm=#arguments.pidm#)>
		<cfelse>
			<cfset maxTermData = getMaxTermData()>
		</cfif>

		<!--- merge in maxTermData --->
		<cfquery dbtype="query" name="caseload_banner" >
			SELECT futureConnect_bannerPerson.PIDM
			, futureConnect_bannerPerson.STU_ID
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
			, maxTermData.TERM as MaxTerm
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
			, futureConnect_bannerPerson.flagged

			, ASAP_STATUS
			, in_contract
		    , RE_HOLD
		    , P_DEGREE
		    , lastContactDate

			FROM futureConnect_bannerPerson, maxTermData
			WHERE maxTermData.STU_ID = futureConnect_bannerPerson.STU_ID
			<!--- note this where clause needs to be here for caching purposes --->
			<cfif len(#arguments.pidm#) gt 0>
				and futureConnect_bannerPerson.PIDM = <cfqueryparam  value="#arguments.pidm#">
			</cfif>
		</cfquery>

		<cfreturn caseload_banner>
	</cffunction>
	<cffunction name="getCaseloadList" access="remote" returnType="query" returnformat="json">
		<cfset caseloaddata = getCaseload()>

		<cfquery dbtype="query" name="qryData" >
			select LastContactDate, Coach, Cohort, bannerGNumber
				, stu_name, ASAP_status, statusinternal, contactID, pidm
				, in_contract, pcc_email, maxterm, flagged
			from caseloaddata
		</cfquery>
		<cfreturn qryData>
	</cffunction>

	<cffunction name="getStudentTermMetrics" access="remote" returntype="query">
		<cfargument name="pidm" type="numeric" required="yes" default="">
		<cfquery datasource="bannerpcclinks" name="StudentTermMetrics">
			SELECT distinct STU_ID
				, TERM
				, T_GPA
				, T_EARNED
			FROM swvlinks_term
			WHERE pidm = <cfqueryparam  value="#arguments.pidm#">
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
		<cfset tableName="futureConnect">
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

	<cffunction name="getHouseholdWithAssignments">
		<cfargument name="contactID" required="yes">
		<cfset tableName="futureConnect">
		<cfquery name="household">
		select h.householdID id
			,householdDescription description
			,CASE WHEN contactID IS NULL THEN 0 ELSE 1 END checked
		from household h
			left outer join householdContact hc
				on h.householdID = hc.householdID
					and tableName = <cfqueryparam value="#tablename#">
					and hc.contactID = <cfqueryparam value="#arguments.contactID#">
	</cfquery>
		<cfreturn household>
	</cffunction>

	<cffunction name="getLivingSituationWithAssignments" access="remote">
		<cfargument name="contactID" required="yes">
		<cfset tableName="futureConnect">
		<cfquery name="livingSituation">
		select ls.livingSituationID id
			,livingSituationDescription description
			,CASE WHEN contactID IS NULL THEN 0 ELSE 1 END checked
		from livingSituation ls
			left outer join livingSituationContact lsc
				on ls.livingSituationID = lsc.livingSituationID
					and tableName = <cfqueryparam value="#tablename#">
					and lsc.contactID = <cfqueryparam value="#arguments.contactID#">
	</cfquery>
		<cfreturn livingSituation>
	</cffunction>

	<cffunction name="updateFlagContact" access="remote">
		<cfargument name="contactid" required="true">
		<cfargument name="flagged" type="numeric" required="true">
		<cfquery>
			UPDATE futureConnect
			SET flagged = <cfqueryparam value="#arguments.flagged#">
			WHERE contactid = <cfqueryparam value="#arguments.contactid#">
		</cfquery>
	</cffunction>

</cfcomponent>
