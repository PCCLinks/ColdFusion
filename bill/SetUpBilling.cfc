
<cfcomponent displayname="SetUpBilling">
	<cfsetting requesttimeout="100000">

	<cfobject name="appObj" component="application">

	<cffunction name="getStudents" returntype="query" access="remote">
		<cfargument name="beginDate" required="true">
		<cfargument name="endDate" required="true">
		<cfargument name="bannerGNumber" default="">

		<cfset appObj.logEntry(value="PROCEDURE getStudentsToBill", level=5) >
		<cfset appObj.logDump(label="arguments", value="#arguments#", level=5) >
		<cfstoredproc procedure="getStudentsToBill">
			<cfprocparam value="#arguments.beginDate#" cfsqltype="CF_SQL_DATE">
			<cfprocparam value="#arguments.endDate#" cfsqltype="CF_SQL_DATE">
			<cfprocparam value="#arguments.bannerGNumber#" cfsqltype="CF_SQL_STRING">
			<cfprocresult name="qry">
		</cfstoredproc>
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
			<cfquery dbtype="query" name="final">
				SELECT bannerGNumber, contactId, program, enrolledDate, exitDate, schoolDistrict, districtID, PIDM, firstname, lastname
				FROM qry
				WHERE PIDM is NOT NULL
				UNION
				SELECT bannerGNumber, contactId, program, enrolledDate, exitDate, schoolDistrict, districtID, pidm.PIDM, firstname, lastname
				FROM qry, pidm
				WHERE qry.bannerGNumber = pidm.STU_ID
				AND qry.PIDM IS NULL
			</cfquery>
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

		<cfset appObj.logEntry(value="FUNCTION getBillingStudent #Now()#", level=3) >
		<cfset appObj.logDump(label="arguments", value = arguments, level=3) >

		<!--- get classes during the requested term --->
		<cfquery name="bannerClasses" datasource="bannerpcclinks" timeout="180">
			select distinct CRN, CRSE, SUBJ, Title, Credits
			from swvlinks_course
			where PIDM = <cfqueryparam value="#arguments.contactRow.pidm#">
				and TERM = <cfqueryparam value="#arguments.term#">
		</cfquery>

		<!-------------------------------------------------------------------->
		<!---  BEGIN Determine Program based on Class Registration 		   --->
		<!---- Note that students labeled in SIDNY as YtC that do not have --->
		<!---  GED information are set as YtC Attendance Unverified        --->
		<!-------------------------------------------------------------------->
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

		<!--- create a record if one does not exist --->
		<cfif qry.recordcount EQ 0 >
			<cfset appObj.logDump(label="qry", value=qry, level=3) >
			<cftry>
				<cfquery name="doInsertBillingStudent" result="resultBillingstudent" >
					insert into billingStudent(contactid, bannerGNumber, PIDM, districtid, term, program, enrolleddate, exitdate, billingStartDate, billingEndDate, billingstatus, includeflag, datecreated, datelastupdated, createdby, lastupdatedby)
					<cfoutput>
						values('#arguments.contactRow.contactid#'
								,'#arguments.contactRow.bannerGNumber#'
								,<cfqueryparam value="#arguments.contactRow.PIDM#" null="#not len(arguments.contactRow.PIDM)#">
								,#arguments.contactRow.districtID#
								,#arguments.term#
								,'#program#'
								,'#arguments.contactRow.enrolleddate#'
								,<cfqueryparam value="#DateFormat(arguments.contactRow.exitdate,'yyyy-mm-dd')#" null="#not len(arguments.contactRow.exitdate)#">
								,<cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
								,<cfqueryparam value="#DateFormat(arguments.billingEndDate,'yyyy-mm-dd')#">
								,'IN PROGRESS'
								,1
								,Now()
								,Now()
								,current_user()
								,current_user()
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
								,<cfqueryparam value="#bannerPerson.gender#">
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
						<cfquery name="updateBillingStudentWithError">
							update billingStudent
							set ErrorMessage = 'No Banner Attribute Set for this Student'
							where billingStudentId = <cfqueryparam value=#local.billingstudentid#>
						</cfquery>
					</cfif>
				</cfif>

				<cfcatch type="any">
					<cfset appObj.logDump(label="contactRow", value=arguments.contactRow) >
					<cfset appObj.logEntry(value = DateFormat(arguments.billingStartDate,'yyyy-mm-dd')) >
					<cfrethrow />
				</cfcatch>
			</cftry>
			<cfset appObj.logEntry(value="billingstudentid=#local.billingstudentid#", level=5) >
			<cfset appObj.logDump(label="resultBillingstudent", value=resultBillingstudent, level=5) >
		<!--- else grab the id of the current  record --->
		<cfelse>
			<cfquery name="update">
				UPDATE billingStudent
				SET billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">,
					billingEndDate = <cfqueryparam value="#DateFormat(arguments.billingEndDate,'yyyy-mm-dd')#">,
					exitDate = <cfqueryparam value="#DateFormat(arguments.contactRow.exitdate,'yyyy-mm-dd')#" null="#not len(arguments.contactRow.exitdate)#">
				WHERE billingStudentId = <cfqueryparam value="#qry.billingstudentid#" >
			</cfquery>
			<cfset local.billingstudentid = #qry.billingstudentid#>
		</cfif> <!--- end get billing  student record --->

		<!--- debug code --->
		<cfset appObj.logEntry(value="billingstudentid=#local.billingstudentid#", level=5) >
		<cfset appObj.logDump(label="bannerClasses", value=bannerClasses, level=5) >

		<!--- if no classes for this term - log an message - unusual --->
		<cfif bannerClasses.recordcount EQ 0>
			<cfset appObj.logEntry(value="in banner classes recordcount = 0", level=5) >
			<cfquery name="updateError" >
				update billingStudent
				set ErrorMessage = 'Student is active but has no classes in Banner',
					BillingStatus = 'NO CLASSES'
				where BillingStudentID = <cfqueryparam value="#local.billingstudentid#">
			</cfquery>
		<cfelse>
			<!--- clear error where no longer valid --->
			<cfquery name="updateNoError" >
				update billingStudent
				set ErrorMessage = NULL,
					BillingStatus = 'IN PROGRESS'
				where BillingStudentID = <cfqueryparam value="#local.billingstudentid#">
					and BillingStatus = 'NO CLASSES'
			</cfquery>
		</cfif>

		<!--- return the billing student record, and the collection of classese --->
		<cfreturn [local.billingstudentid, bannerClasses] >
	</cffunction>

	<cffunction name = "populateClassEntries" >
		<!--- arguments --->
		<cfargument name = "billingStudentId" required="true">
		<cfargument name = "bannerGNumber" required="true">
		<cfargument name = "PIDM" required="true">
		<!--- <cfargument name = "billingStartDate" required="true">--->
		<!--- passing in current classes in banner --->
		<cfargument name = "bannerClasses" type="query" required="true">
		<cfargument name="term" required="true">

		<!--- debug code --->
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

		<!--- get rows where there is a row to add --->
		<!--- TODO? Handle classes that were dropped?  At this point difficult to discern those that were added manually vs. generated --->
		<cfquery name="rowsToInsert" dbtype="query">
			select CRN, CRSE, SUBJ, Title, SUM(addOrSubtract*Credits) CREDITS, SUM(addOrSubtract) addOrSubtract
			from unionRows
			group by CRN, CRSE, SUBJ, Title
			having SUM(addOrSubtract) > 0
		</cfquery>
		<cfset appObj.logDump(label="rowsToInsert", value=rowsToInsert, level=5) >

		<!--- if rows to insert --->
		<cfif rowstoInsert.recordcount GT 0>
			<cfquery name="doInsert" result="doInsertResult">
				insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, includeflag, credits, datecreated, datelastupdated, createdby, lastupdatedby)
				<cfoutput query="rowsToInsert">
				select #arguments.billingStudentId#, '#crn#', '#crse#', '#subj#', '#Title#', 1, #Credits*AddOrSubtract#, Now(), Now(), '#Session.username#', '#Session.username#'
	       			<cfif currentrow LT rowsToInsert.recordcount>UNION ALL</cfif>
	       			<cfset appObj.logEntry(label="currentRow", value=currentRow, level=5)>
				</cfoutput>
			</cfquery>
		</cfif> <!--- end rows to insert --->

		<!--- debug code --->
		<cfif IsDefined("doInsertResult")><cfset appObj.logDump(label="doInsertResult", value=doInsertResult) ></cfif>
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
					set includeflag = 0, takenpreviousterm = #qry.term#
					where billingstudentitemid = #qryCurrentCourses.billingstudentitemid#
				</cfquery>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="billingStudentNegativeAdjustment" access="remote" >
		<cfargument name="contactData" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingDate" required="true">

		<!--- debug --->
		<cfset appObj.logEntry(value="FUNCTION billingStudentNegativeAdjustment #Now()#", level=5) >
		<cfset appObj.logDump(label="arguments", value=arguments) >

		<cfquery name="billingStudents">
			select *
			from billingStudent
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfset appObj.logDump(label="QUERY billingStudents:", value=billingStudents) >
		<cfquery name="combined" dbtype="query">
			select CAST(contactId as INTEGER) contactId, CAST(districtId AS INTEGER) districtId, program
			from billingStudents
			union all
			select CAST(contactId as INTEGER) contactId, CAST(districtId AS INTEGER) districtId, program
			from contactData
		</cfquery>
		<cfset appObj.logDump(label="QUERY combined:", value=combined) >
		<cfquery name="missing" dbtype="query">
			select contactId
			from combined
			group by contactId, districtId, program
			having count(contactId) = 1
		</cfquery>
		<cfset appObj.logDump(label="QUERY missing:", value=missing) >
		<cfloop query="missing">
			<cfquery name="bs" dbtype="query">
				select *
				from billingStudents
				where contactId = <cfqueryparam value="#missing.contactId#">
			</cfquery>
			<cfset appObj.logDump(label="QUERY bs", value=bs) >
			<cfquery name="c" dbtype="query">
				select *
				from contactData
				where contactId = <cfqueryparam value="#missing.contactId#">
			</cfquery>
			<cfset appObj.logDump(label="QUERY c:", value=c) >
			<cftry>
				<!--- insert the adjustment reversal record --->
				<cfquery name="doInsertBillingStudent" result="resultBillingstudent" >
					insert into billingStudent(contactid, bannerGNumber, pidm, districtid, term, program, enrolleddate, exitdate, billingdate, billingtype, billingstatus, includeflag, datecreated, datelastupdated, createdby, lastupdatedby)
						values(#bs.contactid#
								,'#c.bannerGNumber#'
								,#c.PIDM#
								,#bs.districtID#
								,#arguments.term#
								,'#bs.program#'
								,'#bs.enrolleddate#'
								,<cfqueryparam value="#bs.exitdate#" null="#not len(bs.exitdate)#">
								,'#DateFormat(arguments.billingDate,"yyyy-mm-dd")#'
								,'CREDIT'
								,'ADJUSTMENT'
								,1
								,Now()
								,Now()
								,current_user()
								,current_user()
								)
				</cfquery>
				<cfset local.billingstudentid = #resultBillingstudent.GENERATED_KEY# >
				<!--- insert the items from the old billing student to be shown up as adjustments --->
				<cfquery name="doInsertBillingStudentItem">
					insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, typecode, includeflag, credits, datecreated, datelastupdated, createdby, lastupdatedby)
					select #local.billingstudentid#, crn, crse, subj, Title, typecode, includeflag, credits, Now(), Now(), '#Session.username#', '#Session.username#'
					from billingStudentItem
					where billingStudentId = <cfqueryparam value="#bs.billingStudentId#">
	       		</cfquery>
				<cfcatch type="any">
					<cfset appObj.logDump(label="resultBillingstudent", value=resultBillingstudent) >
					<cfrethrow />
				</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>

	<cffunction name="setUpBilling" access="remote" returnFormat="json" >
		<!--- arguments --->
		<cfargument name="termBeginDate" type="date" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="billingEndDate" type="date" required="true">
		<cfargument name="termDropDate"type="date" required="true">
		<cfargument name="reconcilePreviousTerm" default="false">
		<cfargument name="bannerGNumber" default="">
		<!---<cfargument name="type" required="true">--->

		<!--- debug --->
		<cfset appObj.logEntry(value="FUNCTION setUpBilling #Now()#", level=5) >
		<cfset appObj.logDump(label="arguments", value=arguments, level=5) >

		<!--- used by UI --->
		<cfset Session.IsDone = 0>

		<cfset var terms = [[arguments.term, arguments.termDropDate, arguments.TermBeginDate]]>
		<cfif arguments.reconcilePreviousTerm>
			<cfquery name="calendar">
				select *
				from bannerCalendar
				where term = (select max(term) from bannerCalendar where term < <cfqueryparam value="#arguments.term#">)
			</cfquery>
			<cfset ArrayAppend(terms, [calendar.term, calendar.termDropDate, calendar.termBeginDate])>
		</cfif>

		<!--- first month of the term - carry on --->
		<cfloop array="#terms#" index="item">
			<cfset local.term = item[1]>
			<cfset local.termDropDate = item[2]>
			<cfset local.termBeginDate = item[3]>

			<!--- get all the students for this criteria--->
			<cfset var studentQry = getStudents(endDate=#local.termDropDate#, beginDate=#local.termBeginDate#, bannerGNumber = #arguments.bannerGNumber#) >


			<cfset appObj.logEntry(value = "getStudents return #studentQry.recordcount#") >
			<!------------------------------------------------>
			<!--- loop through each student                --->
			<!------------------------------------------------>
			<cfloop query = studentQry >
				<!--- debug code --->
				<cfset appObj.logDump(label="studentQryCurrentRow", value= #GetQueryRow(studentQry, CURRENTROW)#) >

				<!--- get the billing student record and the banner classes --->
				<cfset local.returnArray = getBillingStudent(contactrow=#GetQueryRow(studentQry, CURRENTROW)#, billingStartDate=#arguments.billingStartDate#,
																billingEndDate=#arguments.billingEndDate#, term=#local.term#) >
				<cfset local.billingStudentId = returnArray[1]>
				<cfset local.bannerClasses = returnArray[2]>

				<!--- debug code --->
				<cfset appObj.logEntry(value="bannerClasses record count: #local.bannerClasses.recordcount#", level=5) >
				<cfset appObj.logDump(label="bannerClasses:", value= #local.bannerClasses#, level=5) >

				<!--- if there are classes for this student, populate the billing student item table --->
				<cfif local.bannerClasses.recordcount GT 0>
					<cfset var result = populateClassEntries(billingstudentid=#local.billingStudentId#,
													bannerGNumber=#studentQry.bannerGNumber#,
													PIDM = #studentQry.PIDM#,
													billingStartDate=#arguments.billingStartDate#,
													bannerClasses=#local.bannerClasses#,
													term = #local.term#)>

					<!--- for current term only ---------------------->
					<!--- check if class already taken and exclude --->
					<cfif local.term EQ arguments.term>
						<cfset updateIncludeBasedOnPreviousClasses(billingstudentid=#local.billingStudentId#,
																			PIDM = #studentQry.PIDM#,
																			currentterm = #local.term#) >
					</cfif> <!--- end if of index=1, current term --->

				</cfif> <!--- end populate billing entry --->

			</cfloop>
			<!--- end loop per student --->

			<!--- check if any adjustments needed --->
			<cfif arguments.reconcilePreviousTerm>
				<cfset billingStudentNegativeAdjustment(contactData = studentQry, term = local.term, billingDate = #local.termBeginDate#) >
			</cfif>
		</cfloop> <!--- end current and previous term --->
		<cfreturn 1> <!--- to indicate session is done --->
	</cffunction>

	<cffunction name="setUpMonthlyBilling" access="remote" returnFormat="json" >
		<!--- arguments --->
		<cfargument name="termBeginDate" type="date" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="billingEndDate" type="date" required="true">
		<cfargument name="termDropDate"type="date" required="true">
		<cfargument name="bannerGNumber" default="">

		<cfquery name="attendanceStudents">
			select distinct bannerGNumber
			from billingStudent
			where term = <cfqueryparam value="#arguments.term#">
				and program like '%attendance%'
		</cfquery>

		<!------------------------------------------------>
		<!--- loop through each student                --->
		<!------------------------------------------------>
		<cfloop query="attendanceStudents">
			<cfset setUpStudent(billingEndDate=#arguments.billingEndDate#, billingStartDate=#arguments.billingStartDate#,
									term = #arguments.term#, bannerGNumber = #attendanceStudents.bannerGNumber#) >
		</cfloop> <!--- loop through each student --->
		<cfreturn 1> <!--- to indicate session is done --->
	</cffunction>

	<cffunction name="setUpStudent">
		<cfargument name="billingEndDate" required="true">
		<cfargument name="billingStartDate" required="true">
		<cfargument name="term" required="true">
		<cfargument name="bannerGNumber" required="true">

		<cfset var studentQry = getStudents(beginDate = '#arguments.billingStartDate#', endDate='#arguments.billingEndDate#',
										bannerGNumber = '#arguments.bannerGNumber#') >
		<cfset local.billingStudentId = 0>
		<cfset appObj.logDump(label="studentQry.recordcount", value="#studentQry.recordCount#", level=5)>
		<cfif studentQry.recordcount GT 0>
			<cfset appObj.logDump(label="arguments.bannerGNumber", value="#arguments.bannerGNumber#", level=3)>
			<cfset appObj.logDump(label="studentQry", value="#studentQry#", level=3)>

			<cfset contactrow=#GetQueryRow(studentQry, 1)#>
			<!--- get the billing student record and the banner classes --->
			<cfset local.returnArray = getBillingStudent(contactrow=#contactrow#, billingStartDate=#arguments.billingStartDate#,
															billingEndDate=#arguments.billingEndDate#, term=#arguments.term#) >
			<cfset local.billingStudentId = returnArray[1]>
			<cfset local.bannerClasses = returnArray[2]>
			<cfset appObj.logDump(label="billingStudentId", value="#billingStudentId#", level=5)>

			<cfset var result = populateClassEntries(billingstudentid=#local.billingStudentId#,
												bannerGNumber=#studentQry.bannerGNumber#,
												PIDM = #studentQry.PIDM#,
												billingStartDate=#arguments.billingStartDate#,
												bannerClasses=#local.bannerClasses#,
												term = #arguments.term#)>

			<cfquery name = "isCredit" >
				select *
				from billingStudent bs
				where bs.billingstudentid = <cfqueryparam value="#local.billingStudentID#">
					and program not like '%attendance%'
			</cfquery>

			<cfif isCredit.recordcount GT 0>
				<cfset updateIncludeBasedOnPreviousClasses(billingstudentid=#local.billingStudentId#,
																		PIDM = #studentQry.PIDM#,
																		currentterm = #arguments.term#) >
			</cfif>
		</cfif>
		<cfreturn local.billingStudentId>
	</cffunction>

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

	<cffunction name="getBannerPerson" returnformat="json" access="remote">
		<cfargument name="bannerGNumber" required="true">
		<cfquery name="data" datasource="bannerpcclinks" >
				select distinct atts, stu_name, stu_id
				from swvlinks_person
				where stu_id = <cfqueryparam value="#arguments.bannerGNumber#">
		</cfquery>
		<cfreturn data>
	</cffunction>
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
	<cffunction name="createBillingStudent" returnformat="json" access="remote">
		<cfargument name="termBeginDate" type="date" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="billingEndDate" type="date" required="true">
		<cfargument name="termDropDate"type="date" required="true">
		<cfargument name="bannerGNumber" default="" required="true">

		<!--- debug --->
		<cfset appObj.logEntry(value="FUNCTION createBillingStudent #Now()#", level=5) >
		<cfset appObj.logDump(label="arguments", value=arguments, level=5) >

		<cfset setUpBilling(termBeginDate = arguments.termBeginDate
							,term = arguments.term
							,billingStartDate = arguments.billingStartDate
							,billingEndDate = arguments.billingEndDate
							,termDropDate = arguments.termDropDate
							,bannerGNumber = arguments.bannerGNumber)>
		<cfquery name="data">
			select billingStudentId
			from billingStudent
			where bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
			and billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="addBillingStudent" returnformat="json" returntype="numeric" access="remote">
		<cfargument name="bannerGNumber" default="" required="true">
		<cfargument name= "term" required="true">
		<cfargument name = "billingStartDate" type="date" required="true">
		<cfargument name="billingEndDate" type="date" required="true">
		<cfargument name="crn" default="">

		<!---wide range of dates to force getting of student event if has exited --->
		<cfset local.billingStudentId = setUpStudent(billingEndDate='#arguments.billingEndDate#', billingStartDate='#arguments.billingStartDate#',
								term = #arguments.term#, bannerGNumber = #arguments.bannerGNumber#) >

		<cfset appObj.logDump(label="billingStudentId", value=local.billingStudentId, level=5)>
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

			<!--- to do - combine this with the call made to populate classes so only one insert --->
			<cfif findCrn.cnt EQ 0>
				<cfquery name="class">
					select crn, crse, subj, title, Credits
					from billingStudentItem
					where crn = <cfqueryparam value="#arguments.crn#">
					limit 1
				</cfquery>

				<cfquery name="doInsert" >
					insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, includeflag, credits, datecreated, datelastupdated, createdby, lastupdatedby)
					values(#local.billingStudentId#, '#arguments.crn#', '#class.crse#', '#class.subj#', '#class.Title#', 1, #class.Credits#, Now(), Now(), '#Session.username#', '#Session.username#')
				</cfquery>
			</cfif> <!--- end rows to insert --->
		</cfif>

		<cfreturn local.billingStudentId>
	</cffunction>
	<cffunction name="getInsertCount" access="remote" returnFormat = "json">
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" required="true">
		<cfquery name="getCount">
			SELECT count(*) cnt
			FROM billingStudent
			WHERE Term = <cfqueryparam value="#arguments.term#">
				and billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
		</cfquery>
		<cfreturn #getCount.cnt#>
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
