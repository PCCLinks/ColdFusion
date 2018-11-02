
<cfcomponent displayname="SetUpBilling">
	<cfsetting requesttimeout="100000">

	<cfobject name="appObj" component="application">

	<cffunction name="getStudents" returntype="query" access="remote">
		<cfargument name="beginDate" required="true">
		<cfargument name="endDate" required="true">
		<cfargument name="bannerGNumber" default="">

		<cfset appObj.logEntry(value="PROCEDURE getStudentsToBill", level=5) >
		<cfset appObj.logDump(label="arguments", value="#arguments#", level=5) >
		<cftry>
		<cfstoredproc procedure="getStudentsToBill">
			<cfprocparam value="#arguments.beginDate#" cfsqltype="CF_SQL_DATE">
			<cfprocparam value="#arguments.endDate#" cfsqltype="CF_SQL_DATE">
			<cfprocparam value="#arguments.bannerGNumber#" cfsqltype="CF_SQL_STRING">
			<cfprocresult name="qry">
		</cfstoredproc>
		<cfcatch>
			<cfset msg = "Error with procedure getStudentsToBill for beginDate: #arguments.beginDate#, endDate: #arguments.endDate#, bannerGNumber: #arguments.bannerGNumber#. Error is: #cfcatch.message#.  Could there be two entries in the contact table with the same GNumber?">
			<cfset appObj.emailError(msg)>
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfquery dbtype="query" name="missingPIDM">
			select bannerGNumber
			from qry
			where PIDM is null
		</cfquery>
		<cfif missingPIDM.recordcount GT 0>
			<cfset local.inList =  ValueList(missingPIDM.bannerGNumber,",")>
			<cfset appObj.logDump(label="inList", value=local.inList, level=5) >
			<cfset appObj.logEntry(value="PROCEDURE getStudentsToBill swvlinks_person #Now()#", level=5) >
			<!--- build up dataset to populate pidm where it does not already exist --->
			<cfquery datasource="bannerpcclinks" name="pidm">
				SELECT distinct PIDM, STU_ID
				FROM swvlinks_person
				WHERE STU_ID IN (<cfqueryparam value="#local.inList#" list="yes" cfsqltype="String">)
			</cfquery>
			<cfset appObj.logEntry(value="PROCEDURE getStudentsToBill combine query #Now()#", level=5) >
			<cfquery dbtype="query" name="combined">
				SELECT bannerGNumber, contactId, program, enrolledDate, exitDate, schoolDistrict, districtID, PIDM, firstname, lastname
				FROM qry
				UNION
				SELECT bannerGNumber, contactId, program, enrolledDate, exitDate, schoolDistrict, districtID, pidm.PIDM, firstname, lastname
				FROM qry, pidm
				WHERE qry.bannerGNumber = pidm.STU_ID
				AND qry.PIDM IS NULL
			</cfquery>
			<!---- combine in case row in qry that has null pidm, but attribute added, so also exists in second part of union ---->
			<cfquery dbtype="query" name="final">
				SELECT bannerGNumber, contactId, program, enrolledDate, exitDate, schoolDistrict, districtID, max(PIDM) PIDM, firstname, lastname
				FROM combined
				GROUP BY bannerGNumber, contactId, program, enrolledDate, exitDate, schoolDistrict, districtID, firstname, lastname
			</cfquery>
		<!--- no missing PIDM so simpler query --->
		<cfelse>
			<cfquery dbtype="query" name="final" result="finalResult">
				SELECT bannerGNumber, contactId, program, enrolledDate, exitDate, schoolDistrict, districtID, MAX(PIDM) PIDM, firstname, lastname
				FROM qry
				GROUP BY bannerGNumber, contactId, program, enrolledDate, exitDate, schoolDistrict, districtID, firstname, lastname
			</cfquery>
		</cfif>
		<cfset appObj.logDump(label="getStudents final", value=final, level=5) >
		<cfreturn final>
	</cffunction>

	<cffunction name="getBillingStudent" returntype="Array">
		<!--- parameters --->
		<cfargument name = "contactRow"  type="struct" required="true">
		<cfargument name= "term" required="true">
		<cfargument name = "billingStartDate" type="date" required="true">
		<cfargument name="billingEndDate" type="date" required="true">
		<cfargument name="billingType" required="true">

		<cfset appObj.logEntry(value="FUNCTION getBillingStudent #Now()#", level=3) >
		<cfset appObj.logDump(label="arguments", value = arguments, level=3) >

		<!--- get classes during the requested term --->
		<cfquery name="bannerClasses" datasource="bannerpcclinks" timeout="180">
			select distinct CRN, CRSE, SUBJ, Title, Credits
			from swvlinks_course
			where PIDM = <cfqueryparam value="#arguments.contactRow.pidm#">
				and TERM = <cfqueryparam value="#arguments.term#">
		</cfquery>

		<!----------------------------------------------------------------->
		<!---  BEGIN Determine Program based on Class Registration 		--->
		<!---- Default is program set in SIDNY - will determine if this	--->
		<!---  needs to be overridden									--->
		<!----------------------------------------------------------------->
		<cfset local.program = arguments.contactRow.program>

		<!--- label as YTC Attendance if have 1 or more ABE Classes --->
		<cfquery name="abeCount" dbtype="query">
			select Title
			from bannerClasses
			where SUBJ = 'ABE'
		</cfquery>
		<cfset appObj.logEntry(value="abeCount = #abeCount.recordcount#", level=3) >
		<!------------------------------------------------------->
		<!--- found 1 or more ABE Class so YtC Attendance     --->
		<!------------------------------------------------------->
		<cfif abeCount.recordcount GT 0>
			<cfset local.program = 'YtC Attendance'>
		</cfif> <!--- if abeCount query recordcount  --->

		<!--- label as YTC ELL Attendance or Credit if applicable
		      This will supercede above definition, if needed     --->
		<cfquery name="ellCount" dbtype="query">
			select Title
			from bannerClasses
			where Title LIKE 'Level%' and SUBJ = 'ESOL'
		</cfquery>
		<!------------------------------------------------------->
		<!--- found ELL Class so YtC ELL Credit or Attendance --->
		<!------------------------------------------------------->
		<cfif ellCount.recordcount GT 0>
			<cfset ellAttendance = 0 >
			<cfset ellCredit = 0 >
			<cfloop query="ellCount">
				<cfif MID(Title,7,1) LT 6 >
					<cfset ellAttendance = ellAttendance + 1 >
				<cfelse>
					<cfset ellCredit = ellCredit + 1 >
				</cfif>
			</cfloop>
			<cfif (ellCredit GTE 2)
				OR (ellCredit EQ ellCount.recordcount) >
				<cfset local.ytcProgram = 'YtC ELL Credit'>
			<cfelse>
				<cfset local.ytcProgram = 'YtC ELL Attendance'>
			</cfif>
			<cfset local.program = ytcProgram >
		</cfif> <!--- if ell query recordcount  --->
		<!---------------------------------------------------------------->
		<!--- END Determine Program based on Class Registration -------------->
		<!---------------------------------------------------------------->

		<cfset appObj.logEntry(value="program = #local.program#", level=3)>

		<!---------------------------------------------------------------->
		<!--- IF not the right Billing Type, RETURN -1 --->
		<!---------------------------------------------------------------->
		<cfif (local.program CONTAINS 'attendance' AND arguments.billingType NEQ 'attendance')
			OR (local.program DOES NOT CONTAIN 'attendance' AND arguments.billingType EQ 'attendance')>
			<cfset local.errorMsg = "Student assigned to program = #local.program# which is not valid for #arguments.billingType# billing.">
			<cfset appObj.logEntry(value="#local.errorMsg#  BannerGNumber=#arguments.contactRow.bannerGNumber#")>
			<cfset appObj.logEntry(value="FUNCTION getBillingStudent #Now()#")>
			<cfset appObj.logDump(label="arguments", value = "#arguments#") >
			<cfreturn [-1, '', "#local.errorMsg#"] >

		<!---------------------------------------------------------------->
		<!--- ELSE meets the billing type criteria --->
		<!---------------------------------------------------------------->
		<cfelse>

			<!---------------------------------->
			<!--- get billing student record --->
			<!---------------------------------->
			<cfquery name="qry" result="qryResult" >
				select *
				from billingStudent
				where bannerGNumber = <cfqueryparam value="#arguments.contactRow.bannerGNumber#">
					and Term = <cfqueryparam value="#arguments.term#">
					and billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
					and districtID = <cfqueryparam value="#arguments.contactRow.districtID#">
			</cfquery>
			<cfset appObj.logDump(label="qryResult", value=qryResult, level=3) >

			<!---------------------------------------------------------------->
			<!--- CREATE a record if one does not exist --->
			<!---------------------------------------------------------------->
			<cfif qry.recordcount EQ 0 >
				<cfset appObj.logDump(label="qry", value=qry, level=3) >
				<cfset appObj.logDump(label="program", value="#local.program#", level=3) >
				<cftry>
					<cfquery name="doInsertBillingStudent" result="resultBillingstudent" >
						insert into billingStudent(contactid, bannerGNumber, PIDM, districtid, term, program, enrolleddate, exitdate, billingStartDate, billingEndDate, billingstatus, includeflag, datecreated, datelastupdated, createdby, lastupdatedby)
						<cfoutput>
							values('#arguments.contactRow.contactid#'
									,'#arguments.contactRow.bannerGNumber#'
									,<cfqueryparam value="#arguments.contactRow.PIDM#" null="#not len(arguments.contactRow.PIDM)#">
									,#arguments.contactRow.districtID#
									,#arguments.term#
									,'#local.program#'
									,'#arguments.contactRow.enrolleddate#'
									,<cfqueryparam value="#DateFormat(arguments.contactRow.exitdate,'yyyy-mm-dd')#" null="#not len(arguments.contactRow.exitdate)#">
									,<cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
									,<cfqueryparam value="#DateFormat(arguments.billingEndDate,'yyyy-mm-dd')#">
									,'IN PROGRESS'
									,1
									,Now()
									,Now()
									,'#Session.username#'
									,'#Session.username#'
									)
						</cfoutput>
					</cfquery>
					<cfset appObj.logDump(label="resultBillingstudent", value=resultBillingstudent, level=5) >
					<cfset local.billingstudentid = #resultBillingstudent.GENERATED_KEY# >

					<!--- create profile record if needed --->
					<cfquery name="getProfile">
						select *
						from billingStudentProfile
						where contactId = <cfqueryparam value='#arguments.contactRow.contactid#'>
					</cfquery>
					<cfif getProfile.recordcount EQ 0>
						<cfquery datasource="bannerpcclinks" name="bannerPerson">
							SELECT PIDM, STU_ID, NVL(SUBSTR(stu_name, 0, INSTR(stu_name, ',')-1), stu_name) AS Lastname, NVL(SUBSTR(stu_name, INSTR(stu_name, ',')+2), stu_name) FirstName, birthdate as dob
								,STU_STREET1, STU_ZIP, STU_CITY, STU_STATE, REP_RACE, case gender when 'M' THEN 1 WHEN 'F' THEN 2 ELSE 0 END Gender,
							    case REP_RACE WHEN 'Hispanic/Latino' THEN 'Hispanic American'
									WHEN 'Black or African American' THEN 'African American'
									WHEN 'White' THEN 'European American'
									WHEN 'Race and Ethnicity Unknown' THEN 'Not Specified'
									WHEN 'Asian' THEN 'Asian American'
									WHEN 'Multi-racial (non Hispanic)' THEN 'Not Specified'
									WHEN 'Non-Resident Alien' THEN 'Not Specified'
									WHEN 'American Indian/Alaska Native' THEN 'Native American'
									WHEN 'Native Hawaiian/Pacific Island' THEN 'Native Hawaiian or Other Pacific Islander'
								END Ethnicity
							FROM swvlinks_person
							WHERE PIDM = <cfqueryparam value="#arguments.contactRow.PIDM#">
						</cfquery>
						<cfif bannerPerson.recordcount GT 0>
							<cfset appObj.logEntry(value="No banner record, using  sidny", level=5)>
							<cfquery name="insertIntoProfile">
								INSERT INTO billingStudentProfile (contactID, bannerGNumber, firstName, lastName, dob, gender, ethnicity, address, city, state, zip)
								<cfoutput>
								VALUES(<cfqueryparam value="#arguments.contactRow.contactid#">
									,<cfqueryparam value="#arguments.contactRow.bannerGNumber#">
									,<cfqueryparam value="#bannerPerson.firstname#">
									,<cfqueryparam value="#bannerPerson.lastname#">
									,<cfqueryparam value="#bannerPerson.dob#">
									,<cfif len(bannerPerson.gender) EQ 0>NULL<cfelse><cfqueryparam value="#bannerPerson.gender#"></cfif>
									,<cfqueryparam value="#bannerPerson.ethnicity#">
									,<cfqueryparam value="#bannerPerson.STU_STREET1#">
									,<cfqueryparam value="#bannerPerson.STU_CITY#">
									,<cfqueryparam value="#bannerPerson.STU_STATE#">
									,<cfqueryparam value="#bannerPerson.STU_ZIP#">)
								</cfoutput>
							</cfquery>
						<cfelse>
							<cfquery name="contactPerson">
								SELECT contactid, bannerGNumber, Lastname, FirstName, dob, address
								    ,city, state, zip, ethnicity, gender
								FROM contact
								WHERE contactId = <cfqueryparam value="#arguments.contactRow.contactid#">
							</cfquery>
							<cfquery name="insertIntoProfile">
								INSERT INTO billingStudentProfile (contactID, bannerGNumber, firstName, lastName, dob, gender, ethnicity, address, city, state, zip)
								<cfoutput>
								VALUES(<cfqueryparam value="#arguments.contactRow.contactid#">
									,<cfqueryparam value="#arguments.contactRow.bannerGNumber#">
									,<cfqueryparam value="#contactPerson.firstname#">
									,<cfqueryparam value="#contactPerson.lastname#">
									,<cfqueryparam value="#contactPerson.dob#">
									,<cfqueryparam value="#contactPerson.gender#">
									,<cfqueryparam value="#contactPerson.ethnicity#">
									,<cfqueryparam value="#contactPerson.address#">
									,<cfqueryparam value="#contactPerson.city#">
									,<cfqueryparam value="#contactPerson.state#">
									,<cfqueryparam value="#contactPerson.zip#">)
								</cfoutput>
							</cfquery>
						</cfif>
					</cfif>

					<!---------------------------------------------------------------->
					<!--- ERROR TRAPPING FOR INSERT ---------------------------------->
					<!---------------------------------------------------------------->
					<cfcatch type="any">
						<cfset appObj.logDump(label="contactRow", value=arguments.contactRow) >
						<cfset appObj.logEntry(value = DateFormat(arguments.billingStartDate,'yyyy-mm-dd')) >
						<cfset msg = "Error with SetUpBilling.cfc->getBillingStudent INSERT for billingStartDate: #arguments.billingStartDate#, billingEndDate: #arguments.billingEndDate#, bannerGNumber: #arguments.contactRow.bannerGNumber#. Error is: #cfcatch.message#.  Is School District Populated??">
						<cfset appObj.logEntry(value = msg) >
						<cfset appObj.emailError(msg)>
						<cfreturn [-1, '', "#msg#"] >
					</cfcatch>
				</cftry>
				<cfset appObj.logEntry(value="billingstudentid=#local.billingstudentid#", level=5) >
				<cfset appObj.logDump(label="resultBillingstudent", value=resultBillingstudent, level=5) >
			<!---------------------------------------------------------------->
			<!--- ELSE Record EXISTS									------>
			<!--- GRAB the id of the current  record					------>
			<!---------------------------------------------------------------->
			<cfelse>
				<cftry>
				<cfquery name="update">
					UPDATE billingStudent
					SET billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">,
						billingEndDate = <cfqueryparam value="#DateFormat(arguments.billingEndDate,'yyyy-mm-dd')#">,
						exitDate = <cfqueryparam value="#DateFormat(arguments.contactRow.exitdate,'yyyy-mm-dd')#" null="#not len(arguments.contactRow.exitdate)#">,
						pidm = <cfqueryparam value="#arguments.contactRow.PIDM#" null="#not len(arguments.contactRow.PIDM)#">,
						DateLastUpdated = now(),
						LastUpdatedBy = '#Session.username#'
					WHERE billingStudentId = <cfqueryparam value="#qry.billingstudentid#" >
				</cfquery>
				<!---------------------------------------------------------------->
				<!--- ERROR TRAPPING FOR UPDATE ---------------------------------->
				<!---------------------------------------------------------------->
				<cfcatch type="any">
					<cfset appObj.logDump(label="contactRow", value=arguments.contactRow) >
					<cfset appObj.logEntry(value = DateFormat(arguments.billingStartDate,'yyyy-mm-dd')) >
					<cfset msg = "Error with SetUpBilling.cfc->getBillingStudent UPDATE for beginDate: #arguments.beginDate#, endDate: #arguments.endDate#, bannerGNumber: #arguments.contactRow.bannerGNumber#. Error is: #cfcatch.message#.">
					<cfset appObj.logEntry(value = msg) >
					<cfset appObj.emailError(msg)>
					<cfreturn [-1, '', "#msg#"] >
				</cfcatch>
				</cftry>
				<cfset local.billingstudentid = #qry.billingstudentid#>
			</cfif> <!--- end if billing  student record insert or update --->

			<!--- debug code --->
			<cfset appObj.logEntry(value="billingstudentid=#local.billingstudentid#", level=5) >
			<cfset appObj.logDump(label="bannerClasses", value=bannerClasses, level=5) >

			<!--- return the billing student record, and the collection of classese --->
			<cfreturn [local.billingstudentid, bannerClasses, ""] >
		</cfif> <!--- ends meets the billing type criteria --->
	</cffunction>

	<cffunction name = "populateClassEntries" >
		<cfargument name = "billingStudentId" required="true">
		<cfargument name = "bannerGNumber" required="true">
		<cfargument name = "PIDM" required="true">
		<!--- passing in current classes query to save processing --->
		<cfargument name = "bannerClasses" type="query" required="true">
		<cfargument name="term" required="true">

		<cfset appObj.logEntry(value="FUNCTION populateClassEntries #Now()#", level=5) >
		<cfset appObj.logDump(label="arguments", value=arguments, level=5) >

		<!---------------------------------------------------------------->
		<!--- combine classes in billing table with classes in banner  --->
		<!--- in order to determine if any new classes need to be added --->
		<!---------------------------------------------------------------->

		<!--- for attendance, sometimes add classes other than what is in Banner --->
		<!--- so want to readd them in subsequent months in the same term --->
		<cfquery name="billedInTerm">
			select distinct CRN, CRSE, SUBJ, Title, Credits
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.BillingStudentID
			where bsi.includeFlag = 1
				and term = <cfqueryparam value="#arguments.term#">
				and contactid = (select contactid from billingStudent where billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">)
		</cfquery>

		<cfquery name="bannerAndBilledClassesForTerm" dbtype="query">
			select CAST(CRN as varchar) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, Title, CAST(Credits as INTEGER) Credits
			from bannerClasses
			union
			select CAST(CRN as varchar) CRN, CAST(CRSE as varchar) CRSE, SUBJ, Title, CAST(Credits as INTEGER) Credits
			from billedInTerm
		</cfquery>

		<!--- get classes currently added to bill --->
		<cfquery name = "existingBilling" >
			select *
			from billingStudent bs
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			where bs.billingstudentid = <cfqueryparam value="#arguments.billingStudentID#">
		</cfquery>
		<cfset appObj.logDump(label="existing billing", value=existingBilling, level=5) >

		<!--- union with banner data ---->
		<cfquery name="unionRows" dbtype="query">
			select CAST(CRN as varchar) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, Title, CAST(Credits as INTEGER) Credits, 1 addOrSubtract
			from bannerAndBilledClassesForTerm
			union all
			select CAST(CRN as varchar) CRN, CAST(CRSE as varchar) CRSE, SUBJ, Title, CAST(Credits as INTEGER), -1 addOrSubtract
			from existingBilling
		</cfquery>

		<!--- debug code --->
		<cfset appObj.logEntry(value="UNION ROWS", level=5) >
		<cfif unionRows.recordcount GT 0>
			<cfset appObj.logDump(label="unionRows", value=unionRows, level=5) >
		<cfelse>
			<cfset appObj.logEntry(value="No union rows", level=5) >
		</cfif>

		<!--- get rows where there is a row to add 												--->
		<!--- fyi - not handling where a class is dropped, rather intending that this is first 	--->
		<!--- run after the drop date  															--->
		<cfquery name="rowsToInsert" dbtype="query">
			select CRN, CRSE, SUBJ, Title, SUM(addOrSubtract*Credits) CREDITS, SUM(addOrSubtract) addOrSubtract
			from unionRows
			group by CRN, CRSE, SUBJ, Title
			having SUM(addOrSubtract) > 0
		</cfquery>
		<cfset appObj.logDump(label="rowsToInsert", value=rowsToInsert, level=5) >

		<cfif rowstoInsert.recordcount GT 0>
			<cfset insertIntoBillingStudentItem(billingStudentId = arguments.billingStudentId, rowsToInsert = rowsToInsert)>
		</cfif>

		<!--- debug code --->
		<cfif IsDefined("doInsertResult")><cfset appObj.logDump(label="doInsertResult", value=doInsertResult) ></cfif>
	</cffunction>

	<cffunction name="insertIntoBillingStudentItem">
		<cfargument name="billingStudentId" required=true>
		<cfargument name="rowsToInsert" type="query" required=true>

		<cfquery name="doInsert" result="doInsertResult">
			insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, includeflag, credits, datecreated, datelastupdated, createdby, lastupdatedby)
			<cfoutput query="rowsToInsert">
			select #arguments.billingStudentId#, '#crn#', '#crse#', '#subj#', '#Title#', 1, #Credits*AddOrSubtract#, Now(), Now(), '#Session.username#', '#Session.username#'
	       		<cfif currentrow LT rowsToInsert.recordcount>UNION ALL</cfif>
	       		<cfset appObj.logEntry(label="currentRow", value=currentRow, level=5)>
			</cfoutput>
		</cfquery>
	</cffunction>

	<cffunction name="checkIfClassPreviouslyWithdrawn"  access="remote">
		<cfargument name = "PIDM" required="true">
		<cfargument name="currentterm" required="true">
		<cfargument name="CRSE" required="true">
		<cfargument name="SUBJ" required="true">
		<cfquery name="previouscourses" datasource="bannerpcclinks" timeout="180">
			select distinct Term
			from swvlinks_course
			where PIDM = <cfqueryparam value="#arguments.PIDM#">
				and CRSE = <cfqueryparam value="#arguments.CRSE#">
				and SUBJ = <cfqueryparam value="#arguments.SUBJ#">
				AND TERM < <cfqueryparam value="#arguments.currentterm#">
				and GRADE = 'W'
		</cfquery>
		<cfreturn previouscourses>
	</cffunction>

	<cffunction name="updateIncludeBasedOnPreviousClasses">
		<cfargument name = "billingStudentId" required="true">
		<cfargument name="PIDM" required="true">
		<cfargument name="currentterm" required="true">
		<cfquery name="qryCurrentCourses">
			select *
			from billingStudentItem
			where billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
		</cfquery>
		<cfloop query="qryCurrentCourses">
			<cfset qry=checkIfClassPreviouslyWithdrawn(arguments.PIDM, arguments.currentterm, qryCurrentCourses.CRSE, qryCurrentCourses.SUBJ) >
			<cfif qry.recordcount GT 0>
				<cfquery name="updateitem" >
					update billingStudentItem
					set includeflag = 0, takenpreviousterm = #qry.term#, DateLastUpdated = now(), LastUpdatedBy = '#Session.username#'
					where billingstudentitemid = #qryCurrentCourses.billingstudentitemid#
				</cfquery>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="setUpTermBilling" access="remote" returnFormat="json" >
		<!--- arguments --->
		<cfargument name="termBeginDate" type="date" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="billingEndDate" type="date" required="true">
		<cfargument name="billingType" required="true">
		<cfargument name="termDropDate" type="date" required="true">
		<cfargument name="maxBillableCreditsPerTerm" type="numeric" >
		<cfargument name="maxBillableDaysPerYear" type="numeric" >
		<cfargument name="bannerGNumber" default="">

		<!--- debug --->
		<cfset appObj.logEntry(value="FUNCTION setUpTermBilling #Now()#", level=5) >
		<cfset appObj.logDump(label="arguments", value=arguments, level=5) >

		<!--- used by UI --->
		<cfset Session.IsDone = 0>
		<cfset Session.setupBillingCount = 0>

		<cfset setUpBillingCycle(term = arguments.term
			,billingStartDate = arguments.billingStartDate
			,billingEndDate = arguments.billingEndDate
			,billingType = 'Term'
			,maxBillableCreditsPerTerm = arguments.maxBillableCreditsPerTerm
			,maxBillableDaysPerYear = arguments.maxBillableDaysPerYear)>

		<!--- get all the students for this criteria--->
		<cfset var studentQry = getStudents(endDate=#arguments.termDropDate#, beginDate=#arguments.termBeginDate#, bannerGNumber = #arguments.bannerGNumber#) >

		<cfset appObj.logEntry(value = "getStudents return #studentQry.recordcount#") >

		<!------------------------------------------------>
		<!--- loop through each student                --->
		<!------------------------------------------------>
		<cfloop query = studentQry >
			<cfset contactRow = #GetQueryRow(studentQry, CURRENTROW)# >
			<cfset appObj.logDump(label="studentQryCurrentRow", value= #contactRow#) >

			<cfset setUpStudent(billingEndDate=#arguments.billingEndDate#, billingStartDate=#arguments.billingStartDate#,
						term = #arguments.term#, billingType = 'Term', contactRow = #contactRow#) >

			<cfset Session.setupBillingCount = Session.setupBillingCount + 1>
		</cfloop>
		<!--- end loop per student --->

		<cfset StructDelete(Session,"setupBillingCount")>
		<cfreturn 1> <!--- to indicate session is done --->
	</cffunction>

	<cffunction name="setUpMonthlyAttendanceBilling" access="remote" returnFormat="json" >
		<!--- arguments --->
		<!---><cfargument name="termBeginDate" type="date" required="true">--->
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="billingEndDate" type="date" required="true">
		<cfargument name="termDropDate"type="date" required="true">
		<cfargument name="MaxBillableDaysPerBillingPeriod" type="numeric" >
		<cfargument name="bannerGNumber" default="">

		<!--- debug --->
		<cfset appObj.logEntry(value="FUNCTION setUpMonthlyAttendanceBilling #Now()#", level=5) >
		<cfset appObj.logDump(label="arguments", value=arguments, level=5) >

		<!--- used by UI --->
		<cfset Session.IsDone = 0>
		<cfset Session.setupBillingCount = 0>

		<cfset setUpBillingCycle(term = arguments.term
			,billingStartDate = arguments.billingStartDate
			,billingEndDate = arguments.billingEndDate
			,billingType = 'Attendance'
			,MaxBillableDaysPerBillingPeriod = arguments.MaxBillableDaysPerBillingPeriod)>

		<!--- cleaner to pull from previous month - with program settings all cleaned up --->
		<!--- so test for this option first --->
		<cfset termPreviouslyRun=true>
		<cfquery name="students">
			select distinct bannerGNumber
			from billingStudent
			where term = <cfqueryparam value="#arguments.term#">
				and program like '%attendance%'
				and billingStartDate < <cfqueryparam value="#DateFormat(arguments.billingStartDate, 'yyyy-mm-dd')#">
		</cfquery>

		<!--- first time for the term so run against all active students --->
		<cfif students.recordcount EQ 0>
			<cfset students = getStudents(endDate=#arguments.billingEndDate#, beginDate=#arguments.billingStartDate#, bannerGNumber = #arguments.bannerGNumber#) >
			<cfset termPreviouslyRun = false>
		</cfif>

		<cfset appObj.logEntry(label="termPreviouslyRun", value="#termPreviouslyRun#", level=5)>

		<!------------------------------------------------>
		<!--- loop through each student                --->
		<!------------------------------------------------>
		<cfloop query="students">

			<!--- when getting data from previous month, need to run the getStudent query 	--->
			<!--- and see if the student has exited											--->
			<cfif termPreviouslyRun>
				<cfset studentQry = getStudents(endDate=#arguments.billingEndDate#, beginDate=#arguments.billingStartDate#, bannerGNumber = #students.bannerGNumber#) >
				<!--- check if student exited program --->
				<cfif studentQry.recordcount EQ 0>
					<cfcontinue>
				<cfelse>
					<cfset contactRow = #GetQueryRow(studentQry, 1)# >
				</cfif>

			<!--- can get all the information from the current row 		--->
			<!--- since we already called getStudent to build the list 	--->
			<cfelse>
				<cfset contactRow = #GetQueryRow(students, CURRENTROW)# >
			</cfif>

			<cfset appObj.logDump(label="contactRow", value="#contactRow#", level=5) >

			<!--- build the entry --->
			<cfset setUpStudent(billingEndDate=#arguments.billingEndDate#, billingStartDate=#arguments.billingStartDate#,
									term = #arguments.term#, billingType = 'Attendance',
									contactRow = #contactRow# ) >

			<cfset Session.setupBillingCount = Session.setupBillingCount + 1>
		</cfloop>

		<cfset StructDelete(Session,"setupBillingCount")>
		<cfreturn 1> <!--- to indicate session is done --->
	</cffunction>

	<cffunction name="setUpBillingCycle">
		<cfargument name="term" required = true>
		<cfargument name="billingStartDate" required = true>
		<cfargument name="billingEndDate" required = true>
		<cfargument name="billingType" required = true>
		<cfargument name="maxBillableCreditsPerTerm" type="numeric" >
		<cfargument name="maxBillableDaysPerYear" type="numeric" >
		<cfargument name="MaxBillableDaysPerBillingPeriod" type="numeric" >

		<cfquery name="getProgramYear">
			select ProgramYear
			from bannerCalendar
			where Term = <cfqueryparam value="#arguments.term#">
		</cfquery>

		<cfquery name="checkForBillingCycle">
			select billingCycleId
			from billingCycle
			where Term = <cfqueryparam value="#arguments.term#">
				AND billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate, 'yyyy-mm-dd')#">
				AND billingType = <cfqueryparam value="#arguments.billingType#">
		</cfquery>
		<cfif checkForBillingCycle.recordCount GT 0>
			<cfquery name="updateBillingCycle">
				update billingCycle
				SET BillingEndDate = <cfqueryparam value="#DateFormat(arguments.billingEndDate,'yyyy-mm-dd')#">,
				 ProgramYear = '#getProgramYear.ProgramYear#',
				 MaxBillableCreditsPerTerm = <cfif structKeyExists(arguments, "maxBillableCreditsPerTerm")><cfqueryparam value="#arguments.maxBillableCreditsPerTerm#"><cfelse>NULL</cfif>,
				 MaxBillableDaysPerYear = <cfif structKeyExists(arguments, "maxBillableDaysPerYear")><cfqueryparam value="#arguments.maxBillableDaysPerYear#"><cfelse>NULL</cfif>,
				 MaxBillableDaysPerBillingPeriod = <cfif structKeyExists(arguments, "MaxBillableDaysPerBillingPeriod")><cfqueryparam value="#arguments.MaxBillableDaysPerBillingPeriod#"><cfelse>NULL</cfif>,
				 DateLastUpdated = now(),
				 LastUpdatedBy = '#Session.username#'
				WHERE billingCycleId = #checkForBillingCycle.billingCycleId#
			</cfquery>
		<cfelse>
			<cfquery name="insertBillingCycle">
				INSERT INTO billingCycle
					(BillingType,
					Term,
					BillingStartDate,
					BillingEndDate,
					ProgramYear,
					BillingOpenDate,
					MaxBillableCreditsPerTerm,
					MaxBillableDaysPerYear,
					MaxBillableDaysPerBillingPeriod,
					CreatedBy,
					LastUpdatedBy,
					DateLastUpdated
					)
				VALUES(<cfqueryparam value="#arguments.billingType#">,
					<cfqueryparam value="#arguments.term#">,
					<cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">,
					<cfqueryparam value="#DateFormat(arguments.billingEndDate,'yyyy-mm-dd')#">,
					'#getProgramYear.ProgramYear#',
					now(),
					<cfif structKeyExists(arguments, "maxBillableCreditsPerTerm")><cfqueryparam value="#arguments.maxBillableCreditsPerTerm#"><cfelse>NULL</cfif>,
					<cfif structKeyExists(arguments, "maxBillableDaysPerYear")><cfqueryparam value="#arguments.maxBillableDaysPerYear#"><cfelse>NULL</cfif>,
					<cfif structKeyExists(arguments, "MaxBillableDaysPerBillingPeriod")><cfqueryparam value="#arguments.MaxBillableDaysPerBillingPeriod#"><cfelse>NULL</cfif>,
					'#Session.username#',
					'#Session.username#',
					now()
					)
			</cfquery>
		</cfif>
	</cffunction>
	<cffunction name="setUpStudent">
		<cfargument name="billingEndDate" required="true">
		<cfargument name="billingStartDate" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingType" required="true">
		<!---><cfargument name="bannerGNumber" required="true">--->
		<cfargument name="contactRow" required="true">

			<cfset appObj.logDump(label="contactRow", value="#contactRow#", level=3)>

			<!--- get the billing student record and the banner classes --->
			<cfset local.returnArray = getBillingStudent(contactrow=#contactrow#, billingStartDate=#arguments.billingStartDate#,
															billingEndDate=#arguments.billingEndDate#, term=#arguments.term#,
															billingType = #arguments.billingType#) >
			<cfset local.billingStudentId = returnArray[1]>
			<cfset local.bannerClasses = returnArray[2]>
			<cfset local.errorMsg = returnArray[3]>
			<cfset appObj.logDump(label="billingStudentId", value="#billingStudentId#", level=5)>

			<!--- student is right billing type --->
			<cfif local.billingStudentId NEQ -1>
				<cfset var result = populateClassEntries(billingstudentid=#local.billingStudentId#,
													bannerGNumber=#contactRow.bannerGNumber#,
													PIDM = #contactRow.PIDM#,
													billingStartDate=#arguments.billingStartDate#,
													bannerClasses=#local.bannerClasses#,
													term = #arguments.term#)>

				<cfif arguments.billingType EQ 'Term'>
					<cfset updateIncludeBasedOnPreviousClasses(billingstudentid=#local.billingStudentId#,
																			PIDM = #contactRow.PIDM#,
																			currentterm = #arguments.term#) >
				</cfif>
			</cfif>
		<cfreturn [local.billingStudentId, local.errorMsg]>
	</cffunction>

	<!--- used by AddStudent.cfm --->
	<cffunction name="getSIDNYData" returnformat="json" access="remote">
		<cfargument name="bannerGNumber" required="true">
		<!--- debug --->
		<cfset appObj.logEntry(value="FUNCTION getSIDNYData #Now()#", level=5) >
		<cfset appObj.logDump(label="arguments", value=arguments, level=5)>
		<cfset students = getStudents(beginDate = '2000-01-01', endDate='2999-12-31', bannerGNumber="#arguments.bannerGNumber#")>
		<cfset appObj.logDump(label="students", value=students, level=5)>
		<cfif students.recordcount GT 0>
			<cfquery dbtype="query" name="data">
					select firstname, lastname, bannerGNumber, program, enrolledDate, exitDate, schoolDistrict, bannerGNumber as AddStudent, pidm
					from students
			</cfquery>
		<cfelse>
		<!--- above method does not return when there is no banner attribute, so run it again, to get just SIDNY data --->
			<cfstoredproc procedure="getStudentsToBill">
				<cfprocparam value="2000-01-01" cfsqltype="CF_SQL_DATE">
				<cfprocparam value="2999-12-31" cfsqltype="CF_SQL_DATE">
				<cfprocparam value="#arguments.bannerGNumber#" cfsqltype="CF_SQL_STRING">
				<cfprocresult name="qry">
			</cfstoredproc>
			<cfquery dbtype="query" name="data">
					select firstname, lastname, bannerGNumber, program, enrolledDate, exitDate, schoolDistrict, bannerGNumber as AddStudent, 0 pidm
					from qry
			</cfquery>
		</cfif>
		<cfreturn data>
	</cffunction>

	<!--- used by AddStudent.cfm --->
	<cffunction name="getBannerPerson" returnformat="json" access="remote">
		<cfargument name="bannerGNumber" required="true">
		<cfquery name="data" datasource="bannerpcclinks" >
				select distinct atts, stu_name, stu_id
				from swvlinks_person
				where stu_id = <cfqueryparam value="#arguments.bannerGNumber#">
		</cfquery>
		<cfreturn data>
	</cffunction>

	<!--- used by AddStudent.cfm --->
	<cffunction name="getBannerCourse" returnformat="json" access="remote">
		<cfargument name="bannerGNumber" required="true">
		<cfquery name="data" datasource="bannerpcclinks" >
				select Term, CRN, LEVL, SUBJ, CRSE, Title
				from swvlinks_course
				where stu_id = <cfqueryparam value="#arguments.bannerGNumber#">
				order by Term desc
		</cfquery>
		<cfreturn data>
	</cffunction>


	<!--- used by AddStudent.cfm --->
	<cffunction name="addBillingStudent" returnformat="json" access="remote">
		<cfargument name="bannerGNumber" default="" required="true">
		<cfargument name = "billingStartDate" type="date" >
		<!---><cfargument name = "billingEndDate">--->
		<cfargument name="crn" default="">
		<cfargument name= "term" >
		<cfargument name="billingType" required=true>

		<cfif billingType EQ 'Term'>
			<cfquery name="billingCycle">
				select *
				from billingCycle
				where term = <cfqueryparam value="#arguments.term#">
					and billingType = 'Term'
			</cfquery>
		<cfelse>
			<cfquery name="billingCycle">
				select *
				from billingCycle
				where billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
					and billingType = 'Attendance'
			</cfquery>
		</cfif> <!--- end if billingType eq term or attendance --->

		<cfset arguments.billingStartDate = billingCycle.billingStartDate>
		<cfset arguments.billingEndDate = billingCycle.billingEndDate>
		<cfset arguments.term = billingCycle.term>

		<!---wide range of dates to force getting of student event if has exited --->
		<cfset studentQry = getStudents(endDate="2999-12-31", beginDate="2000-01-01", bannerGNumber = #arguments.bannerGNumber#) >
		<cfquery dbtype="query" name="orderedData">
			select *
			from studentQry
			order by enrolledDate desc
		</cfquery>
		<cfset contactRow = #GetQueryRow(orderedData, 1)# >

		<cfset appObj.logDump(label="contactRow", value="#contactRow#", level=5) >

		<!--- build the entry --->
		<cfset local.returnArray = setUpStudent(billingEndDate=#arguments.billingEndDate#, billingStartDate=#arguments.billingStartDate#,
									term = #arguments.term#, billingType = #arguments.billingType#,
									contactRow = #contactRow# ) >

		<cfset local.billingStudentId = local.returnArray[1]>
		<cfset local.errorMsg = local.returnArray[2]>
		<cfset appObj.logDump(label="billingStudentId", value=local.billingStudentId, level=5)>

		<cfif local.billingStudentId NEQ -1>
			<!--- restore everything to included, if was unflagged --->
			<cfquery>
				UPDATE billingStudentItem
				SET IncludeFlag = 1
				WHERE billingStudentId = <cfqueryparam value="#local.billingStudentId#">
			</cfquery>

			<!--- add crn if not added in above process - will happen when manually added class like GED Test --->
			<cfif arguments.crn NEQ ''>
				<cfquery name="findCrn">
					select count(*) cnt
					from billingStudentItem
					where crn = <cfqueryparam value="#arguments.crn#">
						and billingStudentId = <cfqueryparam value="#local.billingStudentId#">
				</cfquery>

				<cfif findCrn.cnt EQ 0>
					<cfquery name="class">
						select crn, crse, subj, title, Credits, 1 addOrSubtract
						from billingStudentItem bsi
							join billingStudent bs on bsi.billingStudentId = bs.billingStudentId
						where crn = <cfqueryparam value="#arguments.crn#">
							and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
							and bs.program like '%attendance%'
						limit 1
					</cfquery>

					<cfset insertIntoBillingStudentItem(billingStudentId = local.billingStudentId
								,rowsToInsert = class)>

				</cfif> <!--- end rows to insert --->
			</cfif>

			<!--- make sure all is up to date --->
			<cfstoredproc procedure="spBillingUpdateAttendanceBilling">
				<cfprocparam value="#arguments.billingStartDate#" cfsqltype="CF_SQL_DATE">
				<cfprocparam value="#Session.username#" cfsqltype="CF_SQL_STRING">
				<cfprocparam value="#contactRow.contactId#" cfsqltype="CF_SQL_INTEGER">
			</cfstoredproc>

			<cfreturn local.billingStudentId>
		<cfelse>
			<cfreturn [local.billingStudentId, local.errorMsg]>
		</cfif>
	</cffunction>

	<cffunction name="getStudentsNeedingBannerAttributes" access="remote">
		<cfargument name="term" >
		<cfargument name="billingStartDate" type="date">
		<cfargument name="billingType" required=true>

		<cfset appObj.logEntry(value="FUNCTION getStudentsNeedingBannerAttributes #Now()#", level=5) >
		<cfset appObj.logDump(label="arguments", value=arguments, level=5)>

		<cfif arguments.billingType EQ 'Term'>
			<cfset sqlLimitField = "Term">
			<cfset argField = arguments.Term>
		<cfelse>
			<cfset sqlLimitField = "billingStartDate">
			<cfset argField = DateFormat(arguments.billingStartDate, 'yyyy-mm-dd')>
		</cfif>
		<cfset appObj.logDump(label="sqllimit", value="and #sqlLimitField# = #argField#", level=3)>

		<!--- grab all students for current term that have this status --->
		<cfquery name="billing" result="billingResult">
			SELECT bs.bannerGNumber, firstname, lastname, program, fnGetBillingStatus(bs.billingStudentId) status
			FROM billingStudent bs
				join contact c on bs.contactID = c.contactID
			WHERE fnGetBillingStatus(bs.billingStudentId) COLLATE latin1_swedish_ci = 'Missing Banner Attribute' and
				 #sqlLimitField# = <cfqueryparam value="#argField#">
		</cfquery>
		<cfset appObj.logDump(label="billing", value="#billingResult#", level=3)>
		<!--- also grab any entries in contact table that have been recently entered --->
		<cfquery name="contact">
			SELECT bannerGNumber, firstname, lastname, '' program, 'Added to SIDNY after Billing Run' status
			FROM contact
			WHERE length(bannerGNumber) > 0
				and contactId not in (select contactId from billingStudent where #sqlLimitField# = <cfqueryparam value="#argField#">)
				and contactRecordStart > (select min(DateLastUpdated)
											from billingCycle
											where #sqlLimitField# = <cfqueryparam value="#argField#">
												and billingType=<cfqueryparam value="#arguments.billingType#">)
		</cfquery>
		<cfquery name="combined" dbtype="query">
			select bannerGNumber, firstname, lastname, program, status
			from billing
			UNION
			select bannerGNumber, firstname, lastname, program, status
			from contact
		</cfquery>
		<cfquery name="data" dbtype="query">
			select bannerGNumber, firstname, lastname, status, max(Program) Program
			from combined
			group by bannerGNumber, firstname, lastname, status
		</cfquery>
		<cfreturn data>
		<cfreturn billing>
	</cffunction>

	<cffunction name="getInsertCount" access="remote" returnFormat = "json">
		<cfif structKeyExists(Session, "setupBillingCount")>
			<cfreturn #Session.setupBillingCount#>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>

	<cfscript>
		function GetQueryRow(query, rowNumber) {
			var	i = 0;
			var	rowData = StructNew();
			var	cols	= ListToArray(query.columnList);
			for (i = 1; i lte ArrayLen(cols); i = i + 1) {
				rowData[cols[i]] = query[cols[i]][rowNumber];
			}
			appObj.logDump(label="rowdata", value="#rowData#", level=3);
			return rowData;
		}
	</cfscript>



</cfcomponent>
