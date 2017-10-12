
<cfcomponent displayname="SetUpBilling">
	<cfsetting requesttimeout="10000">
	<cfset logFileName = "pcclinks_bill_#DateFormat(Now(),'yyyymmdd_hhmmss')#" >

	<cffunction name="getStudents" returntype="query" access="remote">
		<cfargument name="termDropDate" required="true">
		<cfargument name="termBeginDate" required="true">
		<cfargument name="bannerGNumber" default="">

		<cfset logEntry(value="PROCEDURE getStudentsToBill #Now()#") >
		<!---<cflog file="pcclinks_bill" text="PROCEDURE getStudentsToBill #Now()#">--->
		<cfstoredproc procedure="getStudentsToBill">
			<cfprocparam value="#arguments.termBeginDate#" cfsqltype="CF_SQL_DATE">
			<cfprocparam value="#arguments.termDropDate#" cfsqltype="CF_SQL_DATE">
			<cfprocparam value="#arguments.bannerGNumber#" cfsqltype="CF_SQL_STRING">
			<cfprocresult name="qry">
		</cfstoredproc>
		<cfquery dbtype="query" name="missingPIDM">
			select bannerGNumber
			from qry
			where PIDM is null
		</cfquery>
		<cfset local.inList =  ValueList(missingPIDM.bannerGNumber,",")>
		<cfset logDump(label="inList", value=local.inList) >
		<cfset logEntry(value="PROCEDURE getStudentsToBill swvlinks_person #Now()#") >
		<!---<cflog file="pcclinks_bill" text="PROCEDURE getStudentsToBill swvlinks_person #Now()#">--->
		<cfquery datasource="bannerpcclinks" name="pidm">
			SELECT distinct PIDM, STU_ID
			FROM swvlinks_person
			WHERE STU_ID IN (<cfqueryparam value="#local.inList#" list="yes" cfsqltype="String">)
		</cfquery>
		<cfset logEntry(value="PROCEDURE getStudentsToBill combine query #Now()#") >
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
		<cfset logEntry(value="PROCEDURE getStudentsToBill return final #Now()#") >
		<cfreturn final>
	</cffunction>

	<cffunction name="getBillingStudent" returntype="Array">
		<!--- parameters --->
		<cfargument name = "contactRow"  type="struct" required="true">
		<cfargument name= "term" required="true">
		<cfargument name = "billingStartDate" type="date" required="true">
		<cfargument name = "billingType" required="true" >

		<cfset logEntry(value="FUNCTION getBillingStudent #Now()#") >
		<cfset logDump(label="arguments", value = arguments) >

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
		<cfset logEntry(value="abeCount = #abeCount.recordcount#") >
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

		<cfset logEntry(value="program = #local.program#")>

		<!--- if we are doing attendance do not continue --->
		<cfif arguments.type EQ "attendance" && local.program DOES NOT CONTAIN "attendance">
			<cfreturn [0, ""] >
		</cfif>

		<!---------------------------------->
		<!--- get billing student record --->
		<!---------------------------------->
		<cfquery name="qry" result="qryResult" >
			select *
			from billingStudent
			where GNumber = <cfqueryparam value="#arguments.contactRow.bannerGNumber#">
				and Term = <cfqueryparam value="#arguments.term#">
				and billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and districtID = <cfqueryparam value="#arguments.contactRow.districtID#">
				and program = <cfqueryparam value="#local.program#">
		</cfquery>
		<cfset logDump(label="qryResult", value=qryResult) >

		<!--- create a record if one does not exist --->
		<cfif qry.recordcount EQ 0 >
			<cfset logDump(label="qry", value=qry) >
			<cftry>
				<cfquery name="doInsertBillingStudent" result="resultBillingstudent" >
					insert into billingStudent(contactid, gnumber, PIDM, districtid, term, program, enrolleddate, exitdate, billingStartDate, billingtype, billingstatus, includeflag, datecreated, datelastupdated, createdby, lastupdatedby)
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
								,'CREDIT'
								,'IN PROGRESS'
								,1
								,Now()
								,Now()
								,current_user()
								,current_user()
								)
					</cfoutput>
				</cfquery>
				<cfset logDump(label="resultBillingstudent", value=resultBillingstudent) >
				<cfset local.billingstudentid = #resultBillingstudent.GENERATED_KEY# >
				<cfcatch type="any">
					<cfset logDump(label="contactRow", value=arguments.contactRow) >
					<cfset logEntry(value = DateFormat(arguments.billingStartDate,'yyyy-mm-dd')) >
					<cfrethrow />
				</cfcatch>
			</cftry>
			<cfset logEntry(value="billingstudentid=#local.billingstudentid#") >
			<cfset logDump(label="resultBillingstudent", value=resultBillingstudent) >
		<!--- else grab the id of the current  record --->
		<cfelse>
			<cfset local.billingstudentid = #qry.billingstudentid#>
		</cfif> <!--- end get billing  student record --->

		<!--- debug code --->
		<cfset logEntry(value="billingstudentid=#local.billingstudentid#") >
		<cfset logDump(label="bannerClasses", value=bannerClasses) >

		<!--- if no classes for this term - log an message - unusual --->
		<cfif bannerClasses.recordcount EQ 0>
			<cfset logEntry(value="in banner classes recordcount = 0") >
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
		<cfargument name = "GNumber" required="true">
		<cfargument name = "PIDM" required="true">
		<!--- <cfargument name = "billingStartDate" required="true">--->
		<!--- passing in current classes in banner --->
		<cfargument name = "bannerClasses" type="query" required="true">

		<!--- debug code --->
		<cfset logEntry(value="FUNCTION populateClassEntries #Now()#") >
		<cfset logDump(label="arguments", value=arguments) >

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
		<cfset logDump(label="existing billing", value=existingBilling) >

		<!--- union with banner data ---->
		<!--- ABE 0744 classes have an additional lab element --->
		<cfquery name="unionRows" dbtype="query">
			select CAST(CRN as INTEGER) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, Title, CAST(Credits as INTEGER) Credits, 1 addOrSubtract
			from bannerClasses
			union all
			select CAST(CRN as INTEGER) CRN, CAST(CRSE as varchar) CRSE, SUBJ, Title, CAST(CourseValue as INTEGER), -1 addOrSubtract
			from existingBilling
		</cfquery>

		<!--- debug code --->
		<cfset logEntry(value="UNION ROWS") >
		<cfif unionRows.recordcount GT 0>
			<cfset logDump(label="unionRows", value=unionRows) >
		<cfelse>
			<cfset logEntry(value="No union rows") >
		</cfif>

		<!--- get rows where there is a row to add or remove --->
		<cfquery name="rowsToInsert" dbtype="query">
			select CRN, CRSE, SUBJ, Title, SUM(addOrSubtract*Credits) CREDITS, SUM(addOrSubtract) addOrSubtract
			from unionRows
			group by CRN, CRSE, SUBJ, Title
			having SUM(addOrSubtract) <> 0
		</cfquery>
		<cfset logDump(label="rowsToInsert", value=rowsToInsert) >

		<!--- if rows to insert --->
		<cfif rowstoInsert.recordcount GT 0>
			<cfquery name="doInsert" result="doInsertResult">
				insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, typecode, includeflag, coursevalue, multiplier, billedamount, datecreated, datelastupdated, createdby, lastupdatedby)
				<cfoutput query="rowsToInsert">
				select #arguments.billingStudentId#, #crn#, '#crse#', '#subj#', '#Title#', 'CREDIT', 1, #Credits*AddOrSubtract#, 4.8, #Credits*AddOrSubtract#*4.8, Now(), Now(), current_user(), current_user()
	       			<cfif currentrow LT rowsToInsert.recordcount>UNION ALL</cfif>
				</cfoutput>
			</cfquery>
		</cfif> <!--- end rows to insert --->

		<!--- get any classes that were manually added in the same term but differnt billing (would only affect attendance) --->
		<cfquery name="manualAddRowsToInsert">
			select CRN, CRSE, SUBJ, Title
			from (select distinct CRN, CRSE, SUBJ, Title, 1 AddOrSubtract
			from billingStudent bs
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
				join billingStudent bsCurrent on bs.term = bsCurrent.term
					and bs.contactId = bsCurrent.contactId
					and bs.billingStartDate < bsCurrent.billingStartDate
			where bsCurrent.billingStudentId = <cfqueryparam value="#arguments.billingStudentID#">
			union
			select CRN, CRSE, SUBJ, Title, -1 AddOrSubtract
			from billingStudent bs
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			where bs.billingStudentId = <cfqueryparam value="#arguments.billingStudentID#">) data
			group by CRN, CRSE, SUBJ, Title
			having sum(AddOrSubtract) > 0
		</cfquery>

		<!--- if rows to insert --->
		<cfif manualAddRowsToInsert.recordcount GT 0>
			<cfquery name="doInsert" result="doInsertResult">
				insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, typecode, includeflag, coursevalue, multiplier, billedamount, datecreated, datelastupdated, createdby, lastupdatedby)
				<cfoutput query="manualAddRowsToInsert">
				select #arguments.billingStudentId#, #crn#, '#crse#', '#subj#', '#Title#', 'ATTENDANCE', 1, 0, 0, 0, Now(), Now(), current_user(), current_user()
	       			<cfif currentrow LT manualAddRowsToInsert.recordcount>UNION ALL</cfif>
				</cfoutput>
			</cfquery>
		</cfif> <!--- end rows to insert --->
		<!--- debug code --->
		<cfif IsDefined("r")><cfset logDump(label="doInsertResult", value=doInsertResult) ></cfif>
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
		<cfset logEntry(value="FUNCTION billingStudentNegativeAdjustment #Now()#") >
		<cfset logDump(label="arguments", value=arguments) >

		<cfquery name="billingStudents">
			select *
			from billingStudent
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfset logDump(label="QUERY billingStudents:", value=billingStudents) >
		<cfquery name="combined" dbtype="query">
			select CAST(contactId as INTEGER) contactId, CAST(districtId AS INTEGER) districtId, program
			from billingStudents
			union all
			select CAST(contactId as INTEGER) contactId, CAST(districtId AS INTEGER) districtId, program
			from contactData
		</cfquery>
		<cfset logDump(label="QUERY combined:", value=combined) >
		<cfquery name="missing" dbtype="query">
			select contactId
			from combined
			group by contactId, districtId, program
			having count(contactId) = 1
		</cfquery>
		<cfset logDump(label="QUERY missing:", value=missing) >
		<cfloop query="missing">
			<cfquery name="bs" dbtype="query">
				select *
				from billingStudents
				where contactId = <cfqueryparam value="#missing.contactId#">
			</cfquery>
			<cfset logDump(label="QUERY bs", value=bs) >
			<cfquery name="c" dbtype="query">
				select *
				from contactData
				where contactId = <cfqueryparam value="#missing.contactId#">
			</cfquery>
			<cfset logDump(label="QUERY c:", value=c) >
			<cftry>
				<!--- insert the adjustment reversal record --->
				<cfquery name="doInsertBillingStudent" result="resultBillingstudent" >
					insert into billingStudent(contactid, gnumber, pidm, districtid, term, program, enrolleddate, exitdate, billingdate, billingtype, billingstatus, includeflag, datecreated, datelastupdated, createdby, lastupdatedby)
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
					insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, typecode, includeflag, coursevalue, multiplier, billedamount, datecreated, datelastupdated, createdby, lastupdatedby)
					select #local.billingstudentid#, crn, crse, subj, Title, typecode, includeflag, coursevalue, multiplier, -1*billedamount, Now(), Now(), current_user(), current_user()
					from billingStudentItem
					where billingStudentId = <cfqueryparam value="#bs.billingStudentId#">
	       		</cfquery>
				<cfcatch type="any">
					<cfset logDump(label="resultBillingstudent", value=resultBillingstudent) >
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
		<cfargument name="termDropDate"type="date" required="true">
		<cfargument name="reconcilePreviousTerm" default="false">
		<!---<cfargument name="type" required="true">--->

		<!--- debug --->
		<cfset logEntry(value="FUNCTION setUpBilling #Now()#") >
		<cfset logDump(label="arguments", value=arguments) >

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

		<cfquery name="termExists">
			select min(billingStartDate) minBillingStartDate
			from billingStudent
			where term = <cfqueryparam value=arguments.term>
		</cfquery>

		<!--- did we set up this term already? then do monthly billing
		<cfif termExists.minBillingStartDate NEQ "" >
			<cfset doMonthlyBillingSetup()>
			<cfreturn 1>
		<cfif>--->

		<!--- first month of the term - carry on --->
		<cfloop array="#terms#" index="item">
			<cfset local.term = item[1]>
			<cfset local.termDropDate = item[2]>
			<cfset local.termBeginDate = item[3]>

			<!--- get all the students for this criteria--->
			<cfset var studentQry = getStudents(termdropdate=#local.termDropDate#, termBeginDate=#local.termBeginDate#) >

			<!--- DEBUG
			<cfset var studentQry = getStudents(termdropdate=#local.termDropDate#, termBeginDate=#local.termBeginDate#, bannerGNumber='G03779770') >
			--->

			<cfset logEntry(value = "getStudents return #studentQry.recordcount#") >
			<!------------------------------------------------>
			<!--- loop through each student                --->
			<!------------------------------------------------>
			<cfloop query = studentQry >
				<!--- debug code --->
				<cfset logDump(label="studentQryCurrentRow", value= #GetQueryRow(studentQry, CURRENTROW)#) >

				<!--- get the billing student record and the banner classes --->
				<cfset local.returnArray = getBillingStudent(contactrow=#GetQueryRow(studentQry, CURRENTROW)#, billingStartDate=#arguments.billingStartDate#, term=#local.term#) >
				<cfset local.billingStudentId = returnArray[1]>
				<cfset local.bannerClasses = returnArray[2]>

				<!--- debug code --->
				<cfset logEntry(value="bannerClasses record count: #local.bannerClasses.recordcount#") >
				<cfset logDump(label="bannerClasses:", value= #local.bannerClasses#) >

				<!--- if there are classes for this student, populate the billing student item table --->
				<cfif local.bannerClasses.recordcount GT 0>
					<cfset var result = populateClassEntries(billingstudentid=#local.billingStudentId#,
													GNumber=#studentQry.bannerGNumber#,
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

	<cffunction getMonthlyBilling>
		<!--- arguments --->
		<cfargument name="termBeginDate" type="date" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="termDropDate"type="date" required="true">

		<cfquery name="attendanceClasses">
			select distinct CRN
			from studentBillingItem
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfloop query="attendanceClasses">
			<cfquery name="bannerClassRoster" datasource="pcclinksbanner">
			select stu_id
			from swvlinks_courses
			where CRN = <cfqueryparam value="#attendanceClasses.CRN#">
				and term = <cfqueryparam vlaue="arguments.term">
			</cfquery>
			<!------------------------------------------------>
			<!--- loop through each student                --->
			<!------------------------------------------------>
			<cfloop query="bannerClassRoster">
				<cfset var studentQry = getStudents(termdropdate=#arguments.termDropDate#,
														termBeginDate=#arguments.termBeginDate#,
														bannerGNumber = #bannerClassRoster.stu_id#) >

				<!--- get the billing student record and the banner classes --->
				<cfset local.returnArray = getBillingStudent(contactrow=#GetQueryRow(studentQry, CURRENTROW)#, billingStartDate=#arguments.billingStartDate#, term=#local.term#) >
				<cfset local.billingStudentId = returnArray[1]>
				<cfset local.bannerClasses = returnArray[2]>

				<cfset var result = populateClassEntries(billingstudentid=#local.billingStudentId#,
													GNumber=#studentQry.bannerGNumber#,
													PIDM = #studentQry.PIDM#,
													billingStartDate=#arguments.billingStartDate#,
													bannerClasses=#local.bannerClasses#)>

				<cfset updateIncludeBasedOnPreviousClasses(billingstudentid=#local.billingStudentId#,
																		PIDM = #studentQry.PIDM#,
																		currentterm = #local.term#) >
			</cfloop> <!--- loop through each student --->
		</cfloop> <!--- loop through each class --->
	</cffunction>


	<cffunction name="getInsertCount" access="remote" returnFormat = "json">
		<cfargument name="term" required="true">
		<cfquery name="getCount">
			SELECT count(*) cnt FROM billingStudent WHERE Term = <cfqueryparam value="#arguments.term#">
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
			return rowData;
		}
	</cfscript>




	<!---<cffunction name="setUpBillingClassAttendanceForMonth1" access="remote" returnFormat="json" >
		<!--- arguments --->
		<cfargument name="term" required="true">
		<cfargument name="billingDate" type="date" required="true">
		<cfargument name="crn" required="true">

		<cfset logEntry(value="FUNCTION setUpBilling #Now()#") >
		<cfif debug><cfdump var="#arguments#"></cfif>

		<cfquery name="calendar">
			select *
			from bannerCalendar
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>

		<cfset term = arguments.term>
		<cfset termBeginDate = #calendar.termBeginDate#>
		<cfset termDropDate = #calendar.termDropDate#>

		<!--- get all the students for this criteria --->
		<cfset var studentQry = getStudents(termdropdate=#termDropDate#, termBeginDate=#termBeginDate#) >
		<!--- DEBUG
		<cfquery dbtype="query" name="studentQry">
			select *
			from studentQry1
			where contactid=21444
		</cfquery>--->
		<!------------------------------------------------>
		<!--- loop through each student                --->
		<!------------------------------------------------>
		<cfloop query = studentQry >
			<!--- debug code --->
			<cfif debug><cfdump var="#GetQueryRow(studentQry, CURRENTROW)#"></cfif>

			<!--- get the billing student record and the banner classes --->
			<cfset var returnArray = getBillingStudent(contactrow=#GetQueryRow(studentQry, CURRENTROW)#, billingdate=#arguments.billingDate#, term=#term#, crn=#arguments.crn#) >
			<cfset var billingStudentId = returnArray[1]>
			<cfset var bannerClasses = returnArray[2]>

			<!--- debug code --->
			<cfset logEntry(value="bannerClasses record count: #bannerClasses.recordcount#") >
			<cfif debug><br>bannerClasses: <cfdump var="#bannerClasses#"></cfif>

			<!--- if there are classes for this student, populate the billing student item table --->
			<cfif bannerClasses.recordcount GT 0>
				<cfset result = populateEntries(billingstudentid=#billingStudentId#,
												GNumber=#studentQry.bannerGNumber#,
												PIDM = #studentQry.PIDM#,
												billingDate=#arguments.billingDate#,
												bannerClasses=#bannerClasses#)>

				<!--- check if class already taken and exclude ?? for attendance??
				<cfset result = updateIncludeBasedOnPreviousClasses(billingstudentid=#billingStudentId#,
																	PIDM = #studentQry.PIDM#,
																	currentterm = #arguments.term#) >
				</cfif> <!--- end if of index=1, current term --->  --->

			</cfif> <!--- end populate billing entry --->

		</cfloop>
		<!--- end loop per student --->

		<!--- check if any adjustments needed ???
		<cfif arguments.reconcilePreviousTerm>
			<cfset billingStudentNegativeAdjustment(contactData = studentQry, term = term, billingDate = #arguments.termBeginDate#) >
		</cfif>--->
		<cfquery name="data">
			select c.firstName, c.lastName, c.bannerGNumber
				,crn, crse, subj, title
				,bsi.courseValue, bsi.billingStudentItemId
				,billingDate
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
	    		join contact c on bs.contactId = c.contactId
	    		join bannerCalendar cal1 on cal1.term = <cfqueryparam value="#arguments.term#">
	    		join bannerCalendar cal2 on bs.term = cal2.term and cal2.ProgramYear = cal1.ProgramYear
			where bsi.crn = <cfqueryparam value="#arguments.crn#">
		</cfquery>

		<cfreturn data>
	</cffunction>--->

	<cffunction name="logDump">
		<cfargument name="label" default="">
		<cfargument name="value" required=true>
		<cfargument name="level" default=0>
		<cfsavecontent variable="logtext">
			<cfdump var="#arguments.value#" format="text">
		</cfsavecontent>
		<cfset logEntry(label=arguments.label, value=logtext, level=arguments.level)>
	</cffunction>
	<cffunction name="logEntry">
		<cfargument name="label" default="">
		<cfargument name="value" required=true>
		<cfargument name="level" default=0>
		<cfset debuglevel = 0>
		<cfif debuglevel GTE arguments.level>
			<cfif len(label) GT 0>
				<cfset logtext= arguments.label & ":" & arguments.value>
			<cfelse>
				<cfset logtext = value>
			</cfif>
			<cflog file="#logFileName#" text="#logtext#">
		</cfif>
	</cffunction>

</cfcomponent>
