<cfcomponent displayname="FC">
<!---<cfinclude template="pcclinks.includes.logfunctions.cfm">--->
<!------- NOTES -------
Queries with bannerpcclinks datasource are views from the Banner system
Banner views have an ATTS attribute that identify what program a student is in.  Since overtime, a student may be in more than one program
all the banner queries need to force a distinct by PIDM
--->

	<cfobject name="mscbCFC" component="includes/multiSelectCheckbox">
	<cfobject name="appObj" component="application">

	<cffunction name="getTermByStudent" returntype="query" access="remote" >
		<cfargument name="bannerGNumber" type="string" required="no" default="">
		<cfquery datasource="bannerpcclinks" name="termByStudent" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			<!--- currently term view works better with GNumber than PIDM in prod --->
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
				and STU_ID = <cfqueryparam  value="#arguments.bannerGNumber#">
			</cfif>
		</cfquery>
		<cfreturn termByStudent>
	</cffunction>

	<cffunction name="getCoursesByStudent" returntype="query" >
		<cfargument name="pidm" type="numeric" required="yes" >
		<cfargument name="cohort" type="string" required="yes" >
		<cfset firstYearBeginningTerm = LEFT(arguments.cohort,4) & '04' >
		<cfset firstYearEndingTerm = (VAL(LEFT(arguments.cohort,4))+1) & '03' >
		<!--- note that  for Oracle, select "*" did not work in this query
		  unlike MySql --->
		<cfquery datasource="bannerpcclinks" name="coursesByStudent" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#" >
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

		<cfset appObj.logEntry(value="finished getCoursesByStudent", level=2)>
		<cfreturn coursesByStudent>
	</cffunction>
	<cffunction name="getCoursesByStudentDashboardList" access="remote" returnformat="json" >
		<cfargument name="pidm" type="numeric" required="yes" >
		<cfargument name="cohort" type="string" required="yes" >
		<cfset data = getCoursesByStudent(pidm=#arguments.pidm#, cohort=#arguments.cohort#)>
		<cfquery name="coursesByStudent" dbtype="query">
			select Term, CRSE, Subj, Title, Credits, Grade, Passed
			from data
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
				, CAST(SUM(BannerCourses.pointsForGPA)/SUM(BannerCourses.creditsForGPA) as varchar) as firstYearGPA
			FROM BannerCourses
			WHERE inFirstYear = 1
				and PIDM = <cfqueryparam value="#arguments.pidm#">
			GROUP BY STU_ID
			HAVING SUM(BannerCourses.creditsForGPA) > 0
			<!---UNION
			SELECT BannerCourses.STU_ID
				, 0 AS firstYearCredits
				,'' as firstYearGPA
			FROM BannerCourses
			WHERE inFirstYear = 1
				and PIDM = <cfqueryparam value="#arguments.pidm#">
			GROUP BY STU_ID
			HAVING SUM(BannerCourses.creditsForGPA) = 0--->
			</cfquery>
		<cfset Session.firstYearMetrics = firstYearMetrics>
		<cfreturn firstYearMetrics>
	</cffunction>

	<cffunction name="getTermData" returntype="query" >
		<cfif NOT isDefined("session.termData")>
			<cfquery name="termData" datasource="bannerpcclinks" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			   SELECT distinct swvlinks_term.STU_ID
					, TERM
					, T_GPA
					, T_EARNED
					, P_DEGREE
					, to_char(EFC,'$99,999') as EFC
					, coalesce(OUTGOING_SAP, INCOMING_SAP) AS ASAP_STATUS
	                ,rank() over (partition by stu_id order by term desc) as rnk
				FROM swvlinks_term
			</cfquery>
			<cfset session.termData = termData>
		</cfif>
		<cfreturn session.termData>
	</cffunction>
	<cffunction name="getMaxTermData" returntype="query" >
		<cfargument name="bannerGNumber" type="string" required="no" default="">
		<cfargument name="bannerPop" type="query" required="yes" default="">
		<cfset appObj.logEntry(value="starting getMaxTermData", level=5)>
		<!--- Banner Prod is having performance issues unless it is done that way - might be able to change back in the future --->
		<!---<cfquery name="maxData" datasource="bannerpcclinks" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT STU_ID, MAX(TERM) AS maxTerm
			FROM swvlinks_term
			<cfif len(#arguments.bannerGNumber#) gt 0>
			WHERE STU_ID = <cfqueryparam  value="#arguments.bannerGNumber#">
			</cfif>
			GROUP BY STU_ID
		</cfquery>
		<cfset logEntry(value="finished maxData")>
		<cfquery name="termData" datasource="bannerpcclinks" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT distinct swvlinks_term.STU_ID
				, TERM
				, P_DEGREE
				, to_char(EFC,'$99,999') as EFC
				, coalesce(OUTGOING_SAP, INCOMING_SAP) AS ASAP_STATUS
			FROM swvlinks_term
			<cfif len(#arguments.bannerGNumber#) gt 0>
			WHERE STU_ID = <cfqueryparam  value="#arguments.bannerGNumber#">
				AND TERM = <cfqueryparam value="#maxData.maxTerm#">
			</cfif>
		</cfquery>--->
		<cfset termData = getTermData()>
		<cfset appObj.logEntry(value="finished termData", level=5)>
		<cfquery name="MaxTermDataUnion" dbType="query" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT termData.STU_ID
				, termData.TERM
				, termData.P_DEGREE
				, termData.EFC
				, termData.ASAP_STATUS
			FROM termData
			WHERE rnk = 1
			UNION
			SELECT STU_ID
				, ''
				, ''
				, ''
				, ''
			FROM bannerPop
		</cfquery>
		<!---<cfquery name="MaxTermDataUnion" dbType="query" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT termData.STU_ID
				, termData.TERM
				, termData.P_DEGREE
				, termData.EFC
				, termData.ASAP_STATUS
			FROM termData, maxData
			WHERE termData.STU_ID = maxData.STU_ID
				and termData.TERM = maxData.maxTerm
			UNION
			SELECT STU_ID
				, ''
				, ''
				, ''
				, ''
			FROM bannerPop
		</cfquery>--->
		<cfset appObj.logEntry(value="finished MaxTermDataUnion", level=2)>
		<cfquery name="MaxTermData" dbType="query" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT STU_ID
				, MAX(TERM) Term
				, MAX(P_DEGREE) P_DEGREE
				, MAX(EFC) EFC
				, MAX(ASAP_STATUS) ASAP_STATUS
			FROM MaxTermDataUnion
			GROUP BY STU_ID
		</cfquery>
		<cfset appObj.logEntry(value="finished MaxTermData", level=2)>
		<!---<cfquery name="MaxTermData" datasource="bannerpcclinks" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
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
					<cfif len(#arguments.bannerGNumber#) gt 0>
						and STU_ID = <cfqueryparam  value="#arguments.bannerGNumber#">
					</cfif>
					GROUP BY STU_ID
					) maxs
						ON swvlinks_term.STU_ID = maxs.STU_ID
							and swvlinks_term.TERM = maxs.maxTerm
		</cfquery>--->
		<cfreturn MaxTermData>
	</cffunction>

	<cffunction name="getMaxRegistration" access="remote" returntype="query" returnformat="json" >
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

		<cfset appObj.logEntry(value="finished getMaxRegistration", level=2)>
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
		<cfset appObj.logEntry(value="finished getCGPassed", level=2)>
		<cfreturn cgPassed>
	</cffunction>
	<cffunction name="updateCase" access="remote" returnformat="json" >
		<cfargument name="data" type="struct">

		<!--- Check to see if any data has changed --->
		<!--- if we have an object for comparison
		<cfif StructKeyExists(session, "fcTbl")>--->

		<cfset caseloaddata = getCaseload()>
		<cfquery name = "fcQuery" dbtype ="query">
			select *
			from caseloaddata
			where contactId = <cfqueryparam value="#arguments.data.contactid#">
		</cfquery>

		<cfset appObj.logDump(label="fcQuery", value="#data#", level=4)>
		<cfset fcTbl = QueryGetRow(fcQuery,1)>
		<cfset appObj.logDump(label="fcTbl", value="#fcTbl#", level=4)>

		<!--- have what is needed to do a compare, start with it set to false --->
		<cfset changeArray = ArrayNew(1)>
		<cfloop collection=#arguments.data# item="key">
			<cfif StructKeyExists(fcTbl, key)>
				<!--- see if difference in data exists --->
				<cfif arguments.data[key] NEQ fcTbl[key]>
					<cfset appObj.logDump(label="key with diff", value="#key#", level=5)>
					<cfset ArrayAppend(changeArray, key)>
				</cfif>
			</cfif>
		</cfloop>

		<cfif NOT ArrayIsEmpty(changeArray)>
			<cfquery name="update" result="output">
				UPDATE futureConnect SET
					preferredName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.preferredName)#">,
					gender = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.gender)#">,
					parentalStatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.parentalStatus)#">,
					careerPlan = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.careerPlan)#">,
					weeklyWorkHours = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.weeklyWorkHours)#">,
					statusInternal = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.statusInternal)#">,
					exitReason = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.exitReason)#">,
					coach = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.coach)#">,
					cellPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.cellPhone)#">,
					phone2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.phone2)#">,
					emailPersonal = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.emailPersonal)#">,
					flagged=<cfqueryparam value=#trim(arguments.data.flagged)#>,
					LastUpdatedBy=<cfqueryparam value=#Session.username#>,
					DateLastUpdated=current_timestamp
				WHERE futureConnect.contactID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.data.contactID)#">
			</cfquery>

			<cfset syncWithSessionData(changeArray, arguments.data)>

			<cfset appObj.logDump(label="update", value="#output#", level=5)>

		</cfif><!--- doUpdate --->

		<cfif len(trim(arguments.data.notes)) GT 0>
			<cfset insertNote(contactID="#arguments.data.contactID#", noteText="#trim(arguments.data.notes)#")>
		</cfif>
		<cfset saveEnrichmentProgramData(data=arguments.data) >
		<cfset savehouseholdData(data=arguments.data) >
		<cfset saveLivingSituationData(data=arguments.data) >
		<cfheader statusCode=200 statustext="success" >
	</cffunction>

	<cffunction name="saveEnrichmentProgramData" access="private">
		<cfargument name="data" required="true">
		<cfset Variables.contactID = trim(arguments.data.contactID)>
		<cfset Variables.checkedIds = mscbCFC.getCheckedCollection(data=arguments.data, idFieldName="enrichmentProgramId")>
		<cfquery name="existingLookupEntries">
			SELECT enrichmentProgramId LookUpTableId
			FROM enrichmentProgramContact
			WHERE contactID = <cfqueryparam value="#Variables.contactID#">
				AND tableName = 'futureConnect'
		</cfquery>
		<cfset lookupTableIdsToDelete = mscbCFC.getValuesToDelete(existingLookupEntries, Variables.checkedIds)>
		<cfset appObj.logEntry(label="lookupTableIdsToDelete", value="#lookupTableIdsToDelete#", level=3)>
		<cfquery name="deleteEntry">
			DELETE FROM enrichmentProgramContact
			WHERE enrichmentProgramID IN (<cfqueryparam value="#lookupTableIdsToDelete#" cfsqltype="CF_SQL_INTEGER" list="yes" >)
				and contactid = <cfqueryparam value="#Variables.contactId#">
		</cfquery>
		<cfset lookupTableIdsToInsert = mscbCFC.getValuesToInsert(existingLookupEntries, Variables.checkedIds)>
		<cfset appObj.logEntry(label="lookupTableIdsToInsert", value="#lookupTableIdsToInsert#", level=3)>
		<cfquery name="insertEntry">
			insert into enrichmentProgramContact(contactID, enrichmentProgramID, tableName, createdBy, dateCreated, lastUpdatedBy, dateLastUpdated)
			select <cfqueryparam value="#Variables.contactID#">, enrichmentProgramID, 'futureConnect', '#Session.username#', current_timestamp, '#Session.username#', current_timestamp
			from enrichmentProgram
			where enrichmentProgramID in (<cfqueryparam value="#lookupTableIdsToInsert#" cfsqltype="CF_SQL_INTEGER" list="yes">)
		</cfquery>
	</cffunction>

	<cffunction name="saveHouseholdData" access="private">
		<cfargument name="data" required="true">
		<cfset Variables.contactID = trim(arguments.data.contactID)>
		<cfset Variables.checkedIds = mscbCFC.getCheckedCollection(data=arguments.data, idFieldName="householdID")>
		<cfquery name="existingLookupEntries">
			SELECT householdID LookUpTableId
			FROM householdContact
			WHERE contactID = <cfqueryparam value="#Variables.contactID#">
				AND tableName = 'futureConnect'
		</cfquery>
		<cfset lookupTableIdsToDelete = mscbCFC.getValuesToDelete(existingLookupEntries, Variables.checkedIds)>
		<cfset appObj.logEntry(label="lookupTableIdsToDelete", value="#lookupTableIdsToDelete#", level=3)>
		<cfquery name="deleteEntry">
			DELETE from householdContact
			WHERE householdID IN (<cfqueryparam value="#lookupTableIdsToDelete#" cfsqltype="CF_SQL_INTEGER" list="yes" >)
				and contactid = <cfqueryparam value="#Variables.contactId#">
		</cfquery>
		<cfset lookupTableIdsToInsert = mscbCFC.getValuesToInsert(existingLookupEntries, Variables.checkedIds)>
		<cfset appObj.logEntry(label="lookupTableIdsToInsert", value="#lookupTableIdsToInsert#", level=3)>
		<cfquery name="insertEntry">
			insert into householdContact(contactID, householdID, tableName, createdBy, dateCreated, lastUpdatedBy, dateLastUpdated)
			select <cfqueryparam value="#Variables.contactId#">, householdID, 'futureConnect', '#Session.username#', current_timestamp, '#Session.username#', current_timestamp
			from household
			where householdID in (<cfqueryparam value="#lookupTableIdsToInsert#" cfsqltype="CF_SQL_INTEGER" list="yes">)
		</cfquery>
	</cffunction>

	<cffunction name="saveLivingSituationData" access="private">
		<cfargument name="data" required="true">
		<cfset Variables.contactID = trim(arguments.data.contactID)>
		<cfset Variables.checkedIds = mscbCFC.getCheckedCollection(data=arguments.data, idFieldName="livingSituationId")>
		<cfset appObj.logEntry(value = "Starting saveLivingSituationData", level=3)>
		<cfset appObj.logDump(label="arguments", value="#arguments#", level=3)>
		<cfquery name="existingLookupEntries">
			SELECT livingSituationId LookUpTableId
			FROM livingSituationContact
			WHERE contactID = <cfqueryparam value="#Variables.contactId#">
				AND tableName = 'futureConnect'
		</cfquery>
		<cfset appObj.logDump(label="existingLookupEntries", value=#existingLookupEntries#, level=3)>
		<cfset lookupTableIdsToDelete = mscbCFC.getValuesToDelete(existingLookupEntries, Variables.checkedIds)>
		<cfset appObj.logEntry(label="lookupTableIdsToDelete", value="#lookupTableIdsToDelete#", level=3)>
		<cfquery name="deleteEntry">
			DELETE from livingSituationContact
			WHERE livingSituationID IN (<cfqueryparam value="#lookupTableIdsToDelete#" cfsqltype="CF_SQL_INTEGER" list="yes" >)
				and contactID = <cfqueryparam value="#Variables.contactId#">
		</cfquery>
		<cfset lookupTableIdsToInsert = mscbCFC.getValuesToInsert(existingLookupEntries, Variables.checkedIds)>
		<cfset appObj.logEntry(label="lookupTableIdsToInsert", value="#lookupTableIdsToInsert#", level=3)>
		<cfquery name="insertEntry">
			insert into livingSituationContact(contactID, livingSituationId, tableName, createdBy, dateCreated, lastUpdatedBy, dateLastUpdated)
			select <cfqueryparam value="#Variables.contactId#">, livingSituationId, 'futureConnect', '#Session.username#', current_timestamp, '#Session.username#', current_timestamp
			from livingSituation
			where livingSituationID in (<cfqueryparam value="#lookupTableIdsToInsert#" cfsqltype="CF_SQL_INTEGER" list="yes">)
		</cfquery>
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

		<!--- return cached copy if exists --->
		<cfif StructKeyExists(session, "caseloaddata")>
			<cfreturn session.caseloaddata>
		</cfif>

		<!---------------------------------->
		<!------- Banner Person Data ------->
		<!---------------------------------->
		<cfset appObj.logEntry(value="starting getCaseload", level=2)>
		<cfquery datasource="bannerpcclinks" name="BannerPopulation" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#">
			SELECT distinct PIDM
			, STU_ID
		    , STU_NAME
		    , ROUND(O_GPA,2) AS O_GPA
		    , O_ATTEMPTED
		    , ROUND(O_EARNED,2) AS O_EARNED
		    , O_EARNED_CAT
		    , GENDER as GENDER_BANNER
		    , BIRTHDATE
		    , REP_RACE
		    , HS_NAME
		    , HS_CITY
		    , HS_STATE
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
		<cfset appObj.logEntry(value="finished BannerPopulation", level=2)>
		<!---- end Banner Person Data ---->

		<!---------------------------------->
		<!--- SIDNY Future Connect Data ---->
		<!---------------------------------->
		<cfquery name="fcTbl" >
			SELECT futureConnect.BannerGNumber
			, futureConnect.preferredName
			, futureConnect.contactID
			, futureConnect.cohort
			, futureConnect.statusInternal
			, futureConnect.exitReason
			, futureConnect.gender
			, futureConnect.coach
			, futureConnect.cellPhone
			, futureConnect.phone2
			, futureConnect.emailPersonal
			, futureConnect.parentalStatus
			, futureConnect.weeklyWorkHours
			, futureConnect.flagged
			, futureConnect.CreatedBy
			, futureConnect.DateCreated
			, futureConnect.LastUpdatedBy
			, futureConnect.DateLastUpdated
			, futureConnect.CareerPlan
			, futureConnect.FundedBy
			, futureConnectApplication.HighSchool
			, futureConnectApplication.parent1EarnedBachelors
			, futureConnectApplication.parent2EarnedBachelors

			, Date_Format(lastContact.lastContactDate,'%m/%d/%Y') lastContactDate
			, case when CAST(right(cohort,1) as char(50)) = '1' then 'Portland'
				when CAST(right(cohort,1) as char(50)) = '2' then 'Beaverton'
				when CAST(right(cohort,1) as char(50)) = '3' then 'Hillsboro'
				else 'State' end as fund_source

			, case when fundedBy = 'City of Portland'
				and CURDATE() >= STR_TO_DATE(CONCAT(9, '/',1,'/',(cohort + 3) ),'%m/%d/%YY')
				then 'No'
				when fundedBy <>  'City of Portland'
				and CURDATE() >= STR_TO_DATE(CONCAT(9, '/',1,'/',(cohort + 2) ),'%m/%d/%YY')
				then 'No'
				when statusInternal like 'X%' then 'No'
				else 'Yes' end as in_contract

			,  convert(Concat(CAST(left(cohort,4) as char(50)),'04'), unsigned integer) as cohortFirstFall
			,  convert(Concat(CAST((left(cohort,4)+1) as char(50)),'04'), unsigned integer) as cohortSecondFall

			FROM futureConnect
				LEFT JOIN futureConnectApplication
					on futureConnect.bannerGNumber = futureConnectApplication.StudentID
						and futureConnectApplication.activeFlag = 1
				LEFT JOIN (
					select contactID, max(noteDateAdded) as lastContactDate
					from notes
					where noteAddedBy != 'system'
					group by contactID) lastContact
						on futureConnect.contactID = lastContact.contactID
			WHERE 1=1
			<cfif len(#arguments.pidm#) gt 0>
				and futureConnect.bannerGNumber = <cfqueryparam  value="#BannerPopulation.stu_id#">
			</cfif>
		</cfquery>
		<cfset appObj.logEntry(value="finished fcTbl", level=2)>

		<!--- if getting a single person, store future connect data in session to use when comparing on update --->
		<cfif len(arguments.pidm) gt 0>
			<cfset Session.fcTbl = QueryGetRow(fcTbl,1)>
		</cfif>

		<!---  end SIDNY Future Connect Data --->

		<!------ Merge SIDNY and Banner Person and Term ----->
		<cfquery dbtype="query" name="futureConnect_bannerPerson" >
			SELECT fcTbl.*
				, BannerPopulation.*
			FROM fcTbl, BannerPopulation
			WHERE fcTbl.bannerGNumber = BannerPopulation.STU_ID
		</cfquery>
		<cfset appObj.logEntry(value="finished futureConnect_bannerPerson", level=2)>

		<cfif len(#arguments.pidm#) gt 0>
			<cfset maxTermData = getMaxTermData(bannerGNumber=#BannerPopulation.stu_id#, bannerPop = #BannerPopulation#)>
		<cfelse>
			<cfset maxTermData = getMaxTermData(bannerPop = #BannerPopulation#)>
		</cfif>
		<cfset appObj.logEntry(value="finished maxTermData", level=2)>

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
			, futureConnect_bannerPerson.careerPlan
			, futureConnect_bannerPerson.RE_HOLD
			, futureConnect_bannerPerson.cohort
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
			, futureConnect_bannerPerson.in_contract
			, futureConnect_bannerPerson.FundedBy

		    , futureConnect_bannerPerson.lastContactDate
		    , maxTermData.P_DEGREE
		    , maxTermData.EFC
			, maxTermData.TERM as MaxTerm
			, maxTermData.ASAP_STATUS

			<!--- for managing deletes --->
			, 0 as deleteStatus

			FROM futureConnect_bannerPerson, maxTermData
			WHERE maxTermData.STU_ID = futureConnect_bannerPerson.STU_ID
			<!--- note this where clause needs to be here for caching purposes --->
			<cfif len(#arguments.pidm#) gt 0>
				and futureConnect_bannerPerson.PIDM = <cfqueryparam  value="#arguments.pidm#">
			</cfif>
		</cfquery>
		<cfset appObj.logEntry(value="finished caseload_banner", level=2)>

		<cfset session.caseloaddata = caseload_banner>
		<cfreturn caseload_banner>
	</cffunction>

	<cffunction name="getReportList" access="remote" returnType="query" returnformat="json">
		<cfset caseloaddata = getCaseload()>

		<cfquery name="fosterCare" >
			select fc.contactID, CASE WHEN lsc.contactID IS NULL THEN 'N' ELSE 'Y' END FosterCareYN
			from futureConnect fc
				left outer join livingSituationContact lsc
					on fc.contactID = lsc.contactID and livingSituationID = 3
		</cfquery>

		<cfquery dbtype="query" name="qryData" >
			select STU_NAME
			,bannerGNumber
			,cohort
			,ASAP_STATUS
			,statusInternal
			,coach
			,MaxTerm
			,lastContactDate
			,O_EARNED
			,gender
			,REP_RACE
			,HighSchool
			,parentalStatus
			,careerPlan
			,RE_HOLD
			,O_GPA
			,te_read
			,te_write
			,te_math
			,exitReason
			,cellPhone
			,phone2
			,PCC_EMAIL
			,emailPersonal
			,preferredName
			,weeklyWorkHours
			,in_contract
			,FundedBy
		    ,P_DEGREE
		    ,EFC
		    ,FosterCareYN
			from caseloaddata, fosterCare
			where caseloaddata.contactID = fosterCare.contactID
		</cfquery>

		<cfreturn qryData>
	</cffunction>

	<cffunction name="getCaseloadList" access="remote" returnformat="json">
		<cfargument name="contactId" default=-1>
		<cfset caseloaddata = getCaseload()>

		<cfquery dbtype="query" name="qryData" >
			select contactID, stu_name, bannerGNumber, Cohort
				,ASAP_status, statusinternal, Coach, maxterm, LastContactDate, O_EARNED
				,pidm, in_contract, pcc_email, flagged, deleteStatus
			from caseloaddata
			<cfif arguments.contactId NEQ -1>
			where contactID = <cfqueryparam value="#arguments.contactId#">
			</cfif>
		</cfquery>
		<cfreturn SerializeJSON(qryData)>
	</cffunction>
	<cffunction name="getEditCase" access="remote" returnType="query" returnformat="json">
		<cfargument name="pidm" type="string" default="">

		<cfset caseloaddata = getCaseload()>
		<cfquery name="data" dbtype="query">
			select *
			from caseloaddata
			where pidm = <cfqueryparam value="#arguments.pidm#">
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getStudentTermMetrics" access="remote" returntype="query">
		<cfargument name="bannerGNumber" required="yes" >
		<cfset termData = getTermData()>
		<cfquery name="StudentTermMetrics" dbtype="query">
			SELECT  STU_ID
				, TERM
				, T_GPA
				, T_EARNED
			FROM termData
			WHERE STU_ID = <cfqueryparam  value="#arguments.bannerGNumber#">
			ORDER BY TERM ASC
		</cfquery>
		<cfset appObj.logEntry(value="finished getStudentTermMetrics", level=2)>
		<cfreturn StudentTermMetrics>
	</cffunction>

	<cffunction name="getStudentTermArray" access="remote" returnType="String" returnFormat="json">
		<cfargument name="bannerGNumber" required="yes" >
		<cfset data = getStudentTermMetrics(arguments.bannerGNumber)>
		<cfset list = ValueList(data.TERM)>
		<cfreturn list>
	</cffunction>
	<cffunction name="getStudentGPAArray" access="remote" returnType="String" returnFormat="json">
		<cfargument name="bannerGNumber" required="yes" >
		<cfset data = getStudentTermMetrics(arguments.bannerGNumber)>
		<cfset list = ValueList(data.T_GPA)>
		<cfreturn list>
	</cffunction>
	<cffunction name="getStudentCreditsEarnedArray" access="remote" returnType="String" returnFormat="json">
		<cfargument name="bannerGNumber" required="yes" >
		<cfset data = getStudentTermMetrics(arguments.bannerGNumber)>
		<cfset list = ValueList(data.T_EARNED)>
		<cfreturn list>
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
		where ep.activeFlag = 1
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
			SET flagged = <cfqueryparam value="#arguments.flagged#">,
				lastUpdatedBy=<cfqueryparam value=#Session.username#>,
				dateLastUpdated=current_timestamp
			WHERE contactid = <cfqueryparam value="#arguments.contactid#">
		</cfquery>
		<cfset changeArray = ArrayNew(1, false)>
		<cfset changeArray[1] = "flagged">
		<cfset data = StructNew()>
		<cfset data.contactID = arguments.contactid>
		<cfset data.flagged = arguments.flagged>
		<cfset syncWithSessionData(changeArray, data)>
	</cffunction>
	<cffunction name="syncWithSessionData">
		<cfargument name="changeArray" type="array" required="true">
		<cfargument name="data" type="struct" required="true">

		<cfset caseloaddata = getCaseload()>
		<cfset appObj.logDump(label="changeArray", value="#changeArray#", level=5)>
		<cfloop query="caseloaddata">
			<cfif arguments.data.contactID EQ contactID>
				<cfloop array=#arguments.changeArray# index="key">
					<cfset appObj.logDump(label="key", value="#key#", level=4)>
					<cfset appObj.logDump(label="caseloaddata pre", value="#caseloaddata.currentRow#", level=5)>
					<cfset QuerySetCell(caseloaddata, key, arguments.data[key], caseloaddata.currentRow)>
					<cfset appObj.logDump(label="caseloaddata post", value="#caseloaddata.currentRow#", level=5)>
				</cfloop>
			</cfif>
		</cfloop>
	</cffunction>
	<cffunction name="checkSessionTimeout" access="remote" returntype="boolean" returnformat="json">
		<cfreturn false>
	</cffunction>

	<cffunction name="importApplicant" access="remote" returnformat="JSON" >
		<cfargument name="BannerGNumber" require=true>
		<cfargument name="Coach" required=true>
		<cfargument name="Cohort" required=true>
		<cfargument name ="FundedBy" required=true>
		<cfargument name ="PreferredName">
		<cfargument name ="Gender">
		<cfargument name ="livingSituationDescription">
		<cfargument name ="CellPhone" >
		<cfargument name ="Phone2">
		<cfargument name ="EmailPersonal">

		<cfset appObj.logDump(label="arguments", value="#arguments#", level=5)>

		<cfset resultStatus = "">
		<cfif LEN(arguments.bannerGNumber) EQ 0>
			<cfset resultStatus = "Missing G Number">
			<cfset contactId = 0>
		<cfelse>
			<cftry>

				<cfquery name="checkForContact">
					select contactId
					from contact
					where bannerGNumber = <cfqueryparam value="#arguments.BannerGNumber#">
				</cfquery>
				<cfif checkForContact.recordCount EQ 0>
					<cfquery name="insertContact" result="inserted">
						insert into contact(bannerGNumber, emailPcc, contactRecordStart, contactRecordLast) values(<cfqueryparam value="#BannerGNumber#">,'', sysdate(), sysdate())
					</cfquery>
					<cfset contactId = inserted.GENERATEDKEY>
				<cfelse>
					<cfset contactId = #checkForContact.contactId#>
				</cfif>

				<cfquery name="checkForApplicant">
					select contactId
					from futureConnect
					where contactId = #contactId#
				</cfquery>

				<cfif checkForApplicant.recordCount GT 0>
					<cfquery name="update">
						update futureConnect
							SET cohort = <cfqueryparam value="#arguments.cohort#">
							, coach = <cfqueryparam value="#arguments.coach#">
							, FundedBy = <cfqueryparam value="#arguments.FundedBy#">
							<!--- GNumber here due to developer errors than needed in production --->
							, BannerGNumber = <cfqueryparam value="#arguments.BannerGNumber#">
							, lastUpdatedBy = '#Session.username#'
							, dateLastupdated = sysdate()
						<cfif structKeyExists(arguments, "PreferredName")>
							, PreferredName = <cfqueryparam value="#arguments.PreferredName#">
						</cfif>
						<cfif structKeyExists(arguments, "Gender")>
							, Gender = <cfqueryparam value="#arguments.Gender#">
						</cfif>
						<cfif structKeyExists(arguments, "CellPhone")>
							, CellPhone = <cfqueryparam value="#arguments.CellPhone#">
						</cfif>
						<cfif structKeyExists(arguments, "Phone2")>
							, Phone2 = <cfqueryparam value="#arguments.Phone2#">
						</cfif>
						<cfif structKeyExists(arguments, "EmailPersonal")>
							, EmailPersonal = <cfqueryparam value="#arguments.EmailPersonal#">
						</cfif>
						where contactId = #contactId#
					</cfquery>
					<cfset result = [#arguments.bannerGNumber#, "updated"]>
					<cfset resultStatus = "updated">
				<cfelse>
					<cfquery name="insert">
						insert into futureConnect(
							contactId
							, bannerGNumber
							, cohort
							, FundedBy
							, coach
							, createdBy
							, dateCreated
							, lastUpdatedBy
							, dateLastUpdated
							<cfif structKeyExists(arguments, "PreferredName")>, preferredName</cfif>
							<cfif structKeyExists(arguments, "Gender")>, Gender</cfif>
							<cfif structKeyExists(arguments, "CellPhone")>, CellPhone</cfif>
							<cfif structKeyExists(arguments, "Phone2")>, Phone2</cfif>
							<cfif structKeyExists(arguments, "EmailPersonal")>, EmailPersonal</cfif>
							)
						values (
							#contactId#
							, <cfqueryparam value="#arguments.BannerGNumber#">
							, <cfqueryparam value="#arguments.cohort#">
							, <cfqueryparam value="#arguments.FundedBy#">
							, <cfqueryparam value="#arguments.Coach#">
							, '#session.username#'
							, sysdate()
							, '#session.username#'
							, sysdate()
							<cfif structKeyExists(arguments, "PreferredName")>, <cfqueryparam value="#arguments.PreferredName#"></cfif>
							<cfif structKeyExists(arguments, "Gender")>, <cfqueryparam value="#arguments.Gender#"></cfif>
							<cfif structKeyExists(arguments, "CellPhone")>, <cfqueryparam value="#arguments.CellPhone#"></cfif>
							<cfif structKeyExists(arguments, "Phone2")>, <cfqueryparam value="#arguments.Phone2#"></cfif>
							<cfif structKeyExists(arguments, "EmailPersonal")>, <cfqueryparam value="#arguments.EmailPersonal#"></cfif>
						)
					</cfquery>
					<cfset result= [#arguments.bannerGNumber#, "inserted"]>
					<cfset resultStatus = "inserted">
				</cfif>

				<cfif structKeyExists(arguments, "livingSituationDescription")>
					<cfset arrayLivSit = arguments.livingSituationDescription.split(",") >
					<cfset appObj.logDump(label="arrayLivSit", value="#arrayLivSit#", level=5)>
					<cfquery name="deleteExistingLivingSit">
						delete from livingSituationContact
						where contactId = #contactId#
					</cfquery>
					<cfloop array="#arrayLivSit#" item="livSitDesc" >
						<cfset appObj.logEntry(value="#Trim(livSitDesc)#", level=5)>
						<cfquery name="insertLivingSit">
							insert into livingSituationContact(tableName, contactId, livingSituationId, activeFlag, createdBy, dateCreated, lastUpdatedBy, dateLastUpdated)
							select 'futureConnect', #contactId#, livingSituationId, 1, '#session.username#', sysdate(), '#session.username#', sysdate()
							from livingSituation
							where livingSituationDescription like '#Trim(livSitDesc)#%'
						</cfquery>
					</cfloop>
				</cfif>
				<cfcatch>
					<cfset resultStatus = "ERROR: #cfcatch.message#">
					<cfset appObj.logDump(label="importApplicantError for #arguments.bannerGNumber#:", value="#cfcatch#") >
				</cfcatch>
			</cftry>
		</cfif>

		<cfquery name="result">
			select d.BannerGNumber, '#resultStatus#' as Status, Coach, FundedBy, PreferredName, Gender, CellPhone, Phone2, EmailPersonal
				, group_concat(livingSituationDescription order by livingSituationDescription) livingSituationDescription
			from
			<!--- built to guarantee return of GNumber,  if nothing inserted due to failure --->
			(select <cfqueryparam value="#arguments.bannerGNumber#"> BannerGNumber) d
				left outer join futureConnect on futureConnect.contactId = #contactId#
				left outer join livingSituationContact on futureConnect.contactId = livingSituationContact.contactId
				left outer join livingSituation on livingSituationContact.livingSituationId = livingSituation.livingSituationId
				left outer join enrichmentProgramContact on futureConnect.contactId = enrichmentProgramContact.contactId
				left outer join enrichmentProgram on enrichmentProgramContact.enrichmentProgramId = enrichmentProgram.enrichmentProgramId
			group by BannerGNumber, PreferredName, Gender, CellPhone, Phone2
		</cfquery>
		<cfreturn result>
	</cffunction>

	<cffunction name="deleteStudent" access="remote">
		<cfargument name="contactId" required=true>

		<cfset appObj.logEntry(value="function deleteStudent", level=5)>

		<cfquery name="insertIntoDeleted">
			insert into futureConnectDeleted(BannerGNumber, contactID, PreferredName, cohort_old, FundedBy
										,StatusInternal ,ExitReason ,Gender, Coach, CellPhone, Phone2
										,EmailPersonal ,ParentalStatus ,WeeklyWorkHours ,flagged
										,CreatedBy ,DateCreated ,LastUpdatedBy, DateLastUpdated
										,CareerPlan ,cohort)
			select BannerGNumber, contactID, PreferredName, cohort_old, FundedBy
					,StatusInternal ,ExitReason ,Gender, Coach, CellPhone, Phone2
					,EmailPersonal ,ParentalStatus ,WeeklyWorkHours ,flagged
					,CreatedBy ,DateCreated ,LastUpdatedBy, DateLastUpdated
					,CareerPlan ,cohort
			from futureConnect
			where contactId = <cfqueryparam value="#arguments.contactId#">
		</cfquery>
		<cfquery name="delete">
			delete from futureConnect
			where contactId = <cfqueryparam value="#arguments.contactId#">
		</cfquery>

		<cfset appObj.logEntry(value="function deleteStudent delete done", level=5)>

		<cfset caseloaddata = getCaseload()>
		<cfloop query="caseloaddata">
			<cfif arguments.contactID EQ caseloaddata.contactID>
				<cfset QuerySetCell(caseloaddata, 'deleteStatus', -1, caseloaddata.currentRow)>
				<cfset appObj.logDump(label="deleted row", value="#caseloaddata.currentRow#",level=5)>
			</cfif>
		</cfloop>

	</cffunction>

</cfcomponent>
