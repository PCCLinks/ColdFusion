
<cfcomponent displayname="SetUpBilling">
	<cfsetting requesttimeout="10000">

	<cfobject name="appObj" component="application">

	<cffunction name="getStudents" returntype="query" access="remote">
		<cfargument name="beginDate" required="true">
		<cfargument name="endDate" required="true">
		<cfargument name="bannerGNumber" default="">

		<cfset appObj.logEntry(value="PROCEDURE getStudentsToBill #Now()#", level=5) >
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
			<!---<cflog file="pcclinks_bill" text="PROCEDURE getStudentsToBill swvlinks_person #Now()#">--->
			<cfquery datasource="bannerpcclinks" name="pidm">
				SELECT distinct PIDM, STU_ID
				FROM swvlinks_person
				WHERE STU_ID IN (<cfqueryparam value="#local.inList#" list="yes" cfsqltype="String">)
			</cfquery>
			<cfset appObj.logEntry(value="PROCEDURE getStudentsToBill combine query #Now()#", level=5) >
			<!---<cflog file="pcclinks_bill" text="PROCEDURE getStudentsToBill combine query #Now()#">--->
			<cfquery dbtype="query" name="final">
				SELECT bannerGNumber, contactId, program, enrolledDate, lastName, firstName, exitDate, schoolDistrictDate, schoolDistrict, districtID, PIDM
				FROM qry
				WHERE qry.pidm is not null
				UNION
				SELECT bannerGNumber, contactId, program, enrolledDate, lastName, firstName, exitDate, schoolDistrictDate, schoolDistrict, districtID, pidm.PIDM
				FROM qry, pidm
				WHERE qry.bannerGNumber = pidm.STU_ID
				and qry.pidm is null
			</cfquery>
		<cfelse>
			<cfquery dbtype="query" name="final">
				SELECT bannerGNumber, contactId, program, enrolledDate, lastName, firstName, exitDate, schoolDistrictDate, schoolDistrict, districtID, PIDM
				FROM qry
			</cfquery>
		</cfif>
		<cfset appObj.logEntry(value="PROCEDURE getStudentsToBill return final #Now()#", level=5) >
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
		<!--- going to do this here rather than as a separate query but not
		   sure how this works with re-runs and changes and protecting manual
		   entries --->
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
			<cfif ellCredit GTE 2>
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
				and program = <cfqueryparam value="#local.program#">
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
								,<cfqueryparam value="#arguments.contactRow.exitdate#" null="#not len(arguments.contactRow.exitdate)#">
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
					billingEndDate = <cfqueryparam value="#DateFormat(arguments.billingEndDate,'yyyy-mm-dd')#">
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

		<!--- debug code --->
		<cfset appObj.logEntry(value="FUNCTION populateClassEntries #Now()#", level=5) >
		<cfset appObj.logDump(label="arguments", value=arguments, level=5) >

		<!---------------------------------------------------------------->
		<!--- combine classes in billing table with classes in banner  --->
		<!--- in order to determine if any new classes need to be added --->
		<!---------------------------------------------------------------->

		<!--- get classes currently added to bill --->
		<cfquery name = "existingBilling" >
			select *
			from billingStudent bs
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			where bs.billingstudentid = <cfqueryparam value="#arguments.billingStudentID#">
		</cfquery>
		<cfset appObj.logDump(label="existing billing", value=existingBilling) >

		<!--- union with banner data ---->
		<!--- ABE 0744 classes have an additional lab element --->
		<cfquery name="unionRows" dbtype="query">
			select CAST(CRN as varchar) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, Title, CAST(Credits as INTEGER) Credits, 1 addOrSubtract
			from bannerClasses
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

		<!--- get rows where there is a row to add or remove --->
		<cfquery name="rowsToInsert" dbtype="query">
			select CRN, CRSE, SUBJ, Title, SUM(addOrSubtract*Credits) CREDITS, SUM(addOrSubtract) addOrSubtract
			from unionRows
			group by CRN, CRSE, SUBJ, Title
			having SUM(addOrSubtract) <> 0
		</cfquery>
		<cfset appObj.logDump(label="rowsToInsert", value=rowsToInsert) >

		<!--- if rows to insert --->
		<cfif rowstoInsert.recordcount GT 0>
			<cfquery name="doInsert" result="doInsertResult">
				insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, includeflag, credits, datecreated, datelastupdated, createdby, lastupdatedby)
				<cfoutput query="rowsToInsert">
				select #arguments.billingStudentId#, '#crn#', '#crse#', '#subj#', '#Title#', 1, #Credits*AddOrSubtract#, Now(), Now(), '#Session.username#', '#Session.username#'
	       			<cfif currentrow LT rowsToInsert.recordcount>UNION ALL</cfif>
				</cfoutput>
			</cfquery>
		</cfif> <!--- end rows to insert --->

		<!--- debug code --->
		<cfif IsDefined("r")><cfset appObj.logDump(label="doInsertResult", value=doInsertResult) ></cfif>
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
													bannerClasses=#local.bannerClasses#)>

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

		<cfquery name="attendanceClasses">
			select distinct CRN, bs.bannerGNumber, CRSE, SUBJ, Title, Credits
			from billingStudentItem bsi
				join billingStudent bs on bsi.billingStudentId = bs.billingStudentId
			where term = <cfqueryparam value="#arguments.term#">
				and bs.program like '%attendance%'
		</cfquery>
		<cfset appObj.logDump(label="attendanceClasses", value="#attendanceClasses#", level=5)>
			<!------------------------------------------------>
			<!--- loop through each student                --->
			<!------------------------------------------------>
		<cfloop query="attendanceClasses">
			<cfset var studentQry = getStudents(endDate=#arguments.billingEndDate#,
													beginDate=#arguments.billingStartDate#,
													bannerGNumber = #attendanceClasses.bannerGNumber#) >

			<cfif studentQry.recordcount GT 0>
				<cfset appObj.logDump(label="attendanceClasses.bannerGNumber", value="#attendanceClasses.bannerGNumber#", level=3)>
				<cfset appObj.logDump(label="studentQry", value="#studentQry#", level=3)>

				<cfset contactrow=#GetQueryRow(studentQry, 1)#>
				<!--- get the billing student record and the banner classes --->
				<cfset local.returnArray = getBillingStudent(contactrow=#contactrow#, billingStartDate=#arguments.billingStartDate#,
																billingEndDate=#arguments.billingEndDate#, term=#arguments.term#) >
				<cfset local.billingStudentId = returnArray[1]>
				<cfset local.bannerClasses = returnArray[2]>
				<cfset appObj.logDump(label="billingStudentId", value="#billingStudentId#", level=5)>

				<cfquery dbtype="query" name="classes">
					select *
					from attendanceClasses
					where bannerGNumber = '#studentQry.bannerGNumber#'
				</cfquery>

				<cfset var result = populateClassEntries(billingstudentid=#local.billingStudentId#,
													bannerGNumber=#studentQry.bannerGNumber#,
													PIDM = #studentQry.PIDM#,
													billingStartDate=#arguments.billingStartDate#,
													bannerClasses=#classes#)>

				<cfset updateIncludeBasedOnPreviousClasses(billingstudentid=#local.billingStudentId#,
																		PIDM = #studentQry.PIDM#,
																		currentterm = #arguments.term#) >
			</cfif>
		</cfloop> <!--- loop through each student --->
		<cfreturn 1> <!--- to indicate session is done --->
	</cffunction>

	<cffunction name="getSIDNYData" returnformat="json" access="remote">
		<cfargument name="bannerGNumber" required="true">
		<cfset students = getStudents(beginDate = '2000-01-01', endDate='2999-12-31', bannerGNumber="#arguments.bannerGNumber#")>

		<cfquery dbtype="query" name="data">
				select firstname, lastname, bannerGNumber, program, enrolledDate, exitDate, schoolDistrict, bannerGNumber as AddStudent
				from students
		</cfquery>
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

		<cfset var studentQry = getStudents(beginDate = '2000-01-01', endDate='2999-12-31',
													bannerGNumber = #arguments.bannerGNumber#) >
		<cfset appObj.logDump(label="studentQry", value="#studentQry#", level=5)>
		<cfset contactrow=#GetQueryRow(studentQry, 1)#>
		<cfset local.returnArray = getBillingStudent(contactrow=#contactrow#, billingStartDate=#arguments.billingStartDate#,
														billingEndDate=#arguments.billingEndDate#, term=#arguments.term#) >
		<cfset appObj.logDump(label="returnArray", value="#local.returnArray#", level=5)>
		<cfreturn local.returnArray[1]>
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
