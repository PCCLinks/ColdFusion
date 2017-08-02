
<cfcomponent displayname="SetUpBilling">
	<cfsetting requesttimeout="10000">
	<cfset globaldebug="false">

	<cffunction name="getStudents" returntype="query" access="remote">
		<cfargument name="termDropDate" required="true">
		<cfargument name="termBeginDate" required="true">
		<cfargument name="bannerGNumber">
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><cfoutput><br/>PROCEDURE getStudentsToBill #Now()#</cfoutput></cfif>
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
		<cfset inList =  ValueList(missingPIDM.bannerGNumber,",")>
		<cfif debug><cfdump var="#inList#"></cfif>
		<cfif debug><cfoutput><br/>PROCEDURE getStudentsToBill swvlinks_person #Now()#</cfoutput></cfif>
		<!---<cflog file="pcclinks_bill" text="PROCEDURE getStudentsToBill swvlinks_person #Now()#">--->
		<cfquery datasource="bannerpcclinks" name="pidm">
			SELECT distinct PIDM, STU_ID
			FROM swvlinks_person
			WHERE STU_ID IN (<cfqueryparam value="#inList#" list="yes" cfsqltype="String">)
		</cfquery>
		<cfif debug><cfoutput><br/>PROCEDURE getStudentsToBill combine query #Now()#</cfoutput></cfif>
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
		<cfif debug><cfoutput><br/>PROCEDURE getStudentsToBill return final #Now()#</cfoutput></cfif>
		<!---<cflog file="pcclinks_bill" text="PROCEDURE getStudentsToBill return final #Now()#">--->
		<cfreturn final>
	</cffunction>

	<cffunction name="getBillingStudent" returntype="Array">
		<!--- parameters --->
		<cfargument name = "contactRow" required="true">
		<cfargument name= "term" required="true">
		<cfargument name = "billingDate" required="true">
		<cfargument name="crn">
		<cfset var debug = "false">

		<!--- debug code --->
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><cfoutput><br/>FUNCTION getBillingStudent #Now()#</cfoutput></cfif>
		<!---<cflog file="pcclinks_bill" text="PROCEDURE getBillingStudent #Now()#">--->
		<cfif debug><cfdump var="#arguments#"></cfif>

		<!--- instantiate to accesss it as a struct --->
		<cfset var contactData = #arguments.contactRow#>

		<!--- get classes during the requested term --->
		<cfquery name="bannerClasses" datasource="bannerpcclinks" timeout="180">
			select distinct CRN, CRSE, SUBJ, Title, Credits
			from swvlinks_course2
			where PIDM = <cfqueryparam value="#contactData.pidm#">
				and TERM = <cfqueryparam value="#arguments.term#">
				<cfif len(arguments.crn) GT 0>
				and CRN = <cfqueryparam value="#arguments.crn#">
				</cfif>
		</cfquery>

		<!---------------------------------->
		<!--- get billing student record --->
		<!---------------------------------->
		<cfquery name="qry" >
			select *
			from billingStudent
			where GNumber = <cfqueryparam value="#contactData.bannerGNumber#">
				and Term = <cfqueryparam value="#arguments.term#">
				and billingDate = <cfqueryparam value="#arguments.billingDate#">
				and districtID = <cfqueryparam value="#contactData.districtID#">
				<!--- at this point, just going to compare ytc with gtc --->
				and LEFT(program,3) = LEFT(<cfqueryparam value="#contactData.program#">,3)
		</cfquery>
		<!--- create a record if one does not exist --->
		<cfif qry.recordcount EQ 0 >
			<cfif debug><cfdump var="#qry#"></cfif>
			<cftry>
				<cfquery name="doInsertBillingStudent" result="resultBillingstudent" >
					insert into billingStudent(contactid, gnumber, PIDM, districtid, term, program, enrolleddate, exitdate, billingdate, billingtype, billingstatus, includeflag, datecreated, datelastupdated, createdby, lastupdatedby)
					<cfoutput>
						values('#contactData.contactid#'
								,'#contactData.bannerGNumber#'
								,<cfqueryparam value="#contactData.PIDM#" null="#not len(contactdata.PIDM)#">
								,#contactData.districtID#
								,#arguments.term#
								,'#contactData.program#'
								,'#contactData.enrolleddate#'
								,<cfqueryparam value="#contactdata.exitdate#" null="#not len(contactdata.exitdate)#">
								,'#DateFormat(arguments.billingDate,'yyyy-mm-dd')#'
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
				<cfset var billingstudentid = #resultBillingstudent.GENERATED_KEY# >
				<cfcatch type="any">
					<cfdump var="#contactRow#">
					<cfdump var="#DateFormat(arguments.billingDate,'yyyy-mm-dd')#">
					<cfrethrow />
				</cfcatch>
			</cftry>
			<cfif debug>billingstudentid=<cfoutput>#billingstudentid#</cfoutput></cfif>
			<cfif debug><cfdump var="#resultBillingstudent#"></cfif>
		<!--- else grab the id of the current  record --->
		<cfelse>
			<cfset var billingstudentid = #qry.billingstudentid#>
		</cfif> <!--- end get billing  student record --->

		<!--- debug code --->
		<cfif debug>billingstudentid=<cfoutput>#billingstudentid#</cfoutput></cfif>
		<cfif debug><cfdump var="#bannerClasses#"></cfif>

		<!--- if no classes for this term - log an message - unusual --->
		<cfif bannerClasses.recordcount EQ 0>
			<cfif debug>in banner classes recordcount = 0</cfif>
			<cfquery name="updateError" >
				update billingStudent
				set ErrorMessage = 'Student is active but has no classes in Banner',
					BillingStatus = 'NO CLASSES'
				where BillingStudentID = <cfqueryparam value="#billingstudentid#">
			</cfquery>
		</cfif>

		<!--- return the billing student record, and the collection of classese --->
		<cfreturn [billingstudentid, bannerClasses] >
	</cffunction>

	<cffunction name = "populateEntries" >
		<!--- arguments --->
		<cfargument name = "billingStudentId" required="true">
		<cfargument name = "GNumber" required="true">
		<cfargument name = "PIDM" required="true">
		<cfargument name = "billingDate" required="true">
		<!--- passing in current classes in banner --->
		<cfargument name = "bannerClasses" type="query" required="true">

		<!--- debug code --->
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><cfoutput><br/>FUNCTION populateEntries #Now()#</cfoutput></cfif>
		<!---<cflog file="pcclinks_bill" text="PROCEDURE populateEntries #Now()#">--->
		<cfif debug><cfdump var="#arguments#"></cfif>

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
		<cfif debug>existing billing: <cfdump var="#existingBilling#"></cfif>

		<!--- union with banner data ---->
		<cfquery name="unionRows" dbtype="query">
			select CAST(CRN as INTEGER) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, Title, CAST(Credits as INTEGER) Credits, 1 addOrSubtract
			from bannerClasses
			union all
			select CAST(CRN as INTEGER) CRN, CAST(CRSE as varchar) CRSE, SUBJ, Title, CAST(CourseValue as INTEGER), -1 addOrSubtract
			from existingBilling
		</cfquery>

		<!--- debug code --->
		<cfif debug>UNION ROWS<br/>
			<cfif unionRows.recordcount GT 0><cfdump var="#unionRows#">
			<cfelse>No union rows
			</cfif>
		</cfif>

		<!--- get rows where there is a row to add or remove --->
		<cfquery name="rowsToInsert" dbtype="query">
			select CRN, CRSE, SUBJ, Title, Credits, SUM(addOrSubtract) addOrSubtract
			from unionRows
			group by CRN, CRSE, SUBJ, Title, Credits
			having SUM(addOrSubtract) <> 0
		</cfquery>
		<cfif debug><cfdump var="#rowsToInsert#"></cfif>

		<!--- if rows to insert --->
		<cfif rowstoInsert.recordcount GT 0>
			<cfquery name="doInsert" result="r">
				insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, typecode, includeflag, coursevalue, multiplier, billedamount, datecreated, datelastupdated, createdby, lastupdatedby)
				<cfoutput query="rowsToInsert">
				select #arguments.billingStudentId#, #crn#, '#crse#', '#subj#', '#Title#', 'CREDIT', 1, #Credits*AddOrSubtract#, 4.8, #Credits*AddOrSubtract#*4.8, Now(), Now(), current_user(), current_user()
	       			<cfif currentrow LT rowsToInsert.recordcount>UNION ALL</cfif>
				</cfoutput>
			</cfquery>

			<!--- label as YTC ELL Attendance or Credit if applicable --->
			<!--- going to do this here rather than as a separate query but not
			   sure how this works with re-runs and changes and protecting manual
			   entries --->
			<cfquery name="ellCount" dbtype="query">
				select Title
				from rowstoInsert
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
				<cfif ellAttendance GT ellCredit>
					<cfset ytcProgram = 'YtC ELL Attendance'>
				<cfelse>
					<cfset ytcProgram = 'YtC ELL Credit'>
				</cfif>
				<cfquery name="updateBillingStudentToELL" >
					UPDATE billingStudent
					SET Program = '#ytcProgram#'
					WHERE billingStudentID = <cfqueryparam value="#arguments.billingStudentID#">
				</cfquery>
			</cfif> <!--- if ell query recordcount  --->
		</cfif> <!--- end rows to insert --->

		<!--- debug code --->
		<cfif debug>
			<cfif IsDefined("r")><cfdump var="#r#" format="text"><cfelse>No rows to insert<br></cfif>
		</cfif>
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
		<cfquery name="currentcourses">
			select *
			from billingStudentItem
			where billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
		</cfquery>
		<cfloop query="currentcourses">
			<cfset qry=checkIfClassPreviouslyWithdrawn(arguments.PIDM, arguments.currentterm, currentcourses.CRSE, currentcourses.SUBJ) >
			<cfif qry.recordcount GT 0>
				<cfquery name="updateitem" >
					update billingStudentItem
					set includeflag = 0, takenpreviousterm = #qry.term#
					where billingstudentitemid = #billingstudentitemid#
				</cfquery>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="billingStudentNegativeAdjustment" access="remote" >
		<cfargument name="contactData" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingDate" required="true">

		<!--- debug --->
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><cfoutput><br>FUNCTION billingStudentNegativeAdjustment #Now()#</cfoutput></cfif>
		<!---<cflog file="pcclinks_bill" text="PROCEDURE billingStudentNegativeAdjustment #Now()#">--->
		<cfif debug><cfdump var="#arguments#"></cfif>

		<cfquery name="billingStudents">
			select *
			from billingStudent
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfif debug>QUERY billingStudents:<br><cfdump var="#billingStudents#"></cfif>
		<cfquery name="combined" dbtype="query">
			select CAST(contactId as INTEGER) contactId, CAST(districtId AS INTEGER) districtId, program
			from billingStudents
			union all
			select CAST(contactId as INTEGER) contactId, CAST(districtId AS INTEGER) districtId, program
			from contactData
		</cfquery>
		<cfif debug>QUERY combined:<br><cfdump var="#combined#"></cfif>
		<cfquery name="missing" dbtype="query">
			select contactId
			from combined
			group by contactId, districtId, program
			having count(contactId) = 1
		</cfquery>
		<cfif debug>QUERY missing:<br><cfdump var="#missing#"></cfif>
		<cfloop query="missing">
			<cfquery name="bs" dbtype="query">
				select *
				from billingStudents
				where contactId = <cfqueryparam value="#missing.contactId#">
			</cfquery>
			<cfif debug>QUERY bs:<br><cfdump var="#bs#"></cfif>
			<cfquery name="c" dbtype="query">
				select *
				from contactData
				where contactId = <cfqueryparam value="#missing.contactId#">
			</cfquery>
			<cfif debug>QUERY c:<br><cfdump var="#c#"></cfif>
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
				<cfset var billingstudentid = #resultBillingstudent.GENERATED_KEY# >
				<!--- insert the items from the old billing student to be shown up as adjustments --->
				<cfquery name="doInsertBillingStudentItem">
					insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, typecode, includeflag, coursevalue, multiplier, billedamount, datecreated, datelastupdated, createdby, lastupdatedby)
					select #billingstudentid#, crn, crse, subj, Title, typecode, includeflag, coursevalue, multiplier, -1*billedamount, Now(), Now(), current_user(), current_user()
					from billingStudentItem
					where billingStudentId = <cfqueryparam value="#bs.billingStudentId#">
	       		</cfquery>
				<cfcatch type="any">
					<cfdump var="#resultBillingstudent#">
					<cfrethrow />
				</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>

	<cffunction name="setUpBilling" access="remote" returnFormat="json" >
		<!--- arguments --->
		<cfargument name="termBeginDate" type="date" required="true">
		<cfargument name="term" required="true">
		<cfargument name="termDropDate"type="date" required="true">
		<cfargument name="reconcilePreviousTerm" default="false">

		<!--- debug --->
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug>FUNCTION setUpBilling #Now()#</cfif>
		<!---<cflog file="pcclinks_bill" text="PROCEDURE setUpBilling #Now()#">--->
		<cfif debug><cfdump var="#arguments#"></cfif>

		<!--- used by UI --->
		<cfset Session.IsDone = 0>

		<cfset terms = [[arguments.term, arguments.termDropDate, arguments.TermBeginDate]]>
		<cfif arguments.reconcilePreviousTerm>
			<cfquery name="calendar">
				select *
				from bannerCalendar
				where term = (select max(term) from bannerCalendar where term < <cfqueryparam value="#arguments.term#">)
			</cfquery>
			<cfset ArrayAppend(terms, [calendar.term, calendar.termDropDate, calendar.termBeginDate])>
		</cfif>

		<cfloop array="#terms#" index="item">
			<cfset term = item[1]>
			<cfset termDropDate = item[2]>
			<cfset termBeginDate = item[3]>

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
				<cfset var returnArray = getBillingStudent(contactrow=#GetQueryRow(studentQry, CURRENTROW)#, billingdate=#termBeginDate#, term=#term#) >
				<cfset var billingStudentId = returnArray[1]>
				<cfset var bannerClasses = returnArray[2]>

				<!--- debug code --->
				<cfif debug><br>bannerClasses record count: <cfdump var="#bannerClasses.recordcount#"></cfif>
				<cfif debug><br>bannerClasses: <cfdump var="#bannerClasses#"></cfif>

				<!--- if there are classes for this student, populate the billing student item table --->
				<cfif bannerClasses.recordcount GT 0>
					<cfset result = populateEntries(billingstudentid=#billingStudentId#,
													GNumber=#studentQry.bannerGNumber#,
													PIDM = #studentQry.PIDM#,
													billingDate=#termBeginDate#,
													bannerClasses=#bannerClasses#)>

					<!--- for current term only ---------------------->
					<!--- check if class already taken and exclude --->
					<cfif term EQ arguments.term>
						<cfset result = updateIncludeBasedOnPreviousClasses(billingstudentid=#billingStudentId#,
																			PIDM = #studentQry.PIDM#,
																			currentterm = #arguments.term#) >
					</cfif> <!--- end if of index=1, current term --->

				</cfif> <!--- end populate billing entry --->

			</cfloop>
			<!--- end loop per student --->

			<!--- check if any adjustments needed --->
			<cfif arguments.reconcilePreviousTerm>
				<cfset billingStudentNegativeAdjustment(contactData = studentQry, term = term, billingDate = #arguments.termBeginDate#) >
			</cfif>
		</cfloop> <!--- end current and previous term --->
		<cfreturn 1> <!--- to indicate session is done --->
	</cffunction>

	<cffunction name="getInsertCount" access="remote" returnFormat = "json">
		<cfargument name="term" required="true">
		<cfquery name="getCount">
			SELECT count(*) cnt FROM sidny.billingStudent WHERE Term = <cfqueryparam value="#arguments.term#">
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

	<cffunction name="getClassAttendanceRows" access="remote">
		<cfargument name="crn" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingDate" required="true">
		<cfquery name="bannerdata" datasource="bannerpcclinks">
			select distinct pidm, stu_id GNumber, crn, crse, subj, title, <cfqueryparam value="#arguments.billingDate#"> billingDate, NULL CourseValue
			from swvlinks_course2
			where crn = <cfqueryparam value="#arguments.crn#">
		</cfquery>
		<cfquery name="billingData">
			select NULL PIDM, GNumber, crn, crse, subj, title, billingDate, courseValue
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.BillingStudentId
			where term = <cfqueryparam value="#arguments.term#">
				and bsi.crn = <cfqueryparam value="#arguments.crn#">
				and bs.billingDate = <cfqueryparam value="#arguments.billingDate#">
		</cfquery>
		<cfquery name="dataUnion" dbtype="query">
			select PIDM, gNumber, crn, CAST(crse as VARCHAR) crse, subj, title, CAST(billingDate AS DATE) billingDate, CAST(courseValue AS DECIMAL) courseValue
			from bannerdata
			union
			select CAST(pidm as INTEGER), gNumber, crn, CAST(crse AS VARCHAR), subj, title, CAST(billingDate as DATE), courseValue
			from billingData
		</cfquery>
		<cfreturn dataUnion>
	</cffunction>

	<cffunction name="getClassAttendanceForEdit" access="remote">
		<cfargument name="crn" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingDate" required="true">
		<cfset dataUnion = getClassAttendanceRows(crn = "#Arguments.crn#", Term="#Arguments.term#",billingDate="#Arguments.billingDate#")>
		<cfreturn dataUnion>
	</cffunction>

	<cffunction name="getClassAttendanceGrid" access="remote">
		<cfargument name="crn" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingDate" required="true">
		<cfset dataUnion = getClassAttendanceRows(crn = "#Arguments.crn#", Term="#Arguments.term#",billingDate="#Arguments.billingDate#")>
		<cfset getBuckets = getMonthlyAttendanceBuckets(term = #arguments.term#)>
		<cfquery name="data" dbtype="query">
			select pidm, GNumber, crn, crse, subj, title, getBuckets.billingDate, max(courseValue) courseValue
			from dataUnion, getBuckets
			group by pidm, GNumber, crn, crse, subj, title, getBuckets.billingDate
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getMonthlyAttendanceBuckets" access="remote">
		<cfargument name="term" required="true">
		<cfquery name="data">
			SELECT CAST(concat(year(TermBeginDate),'-',months.MonthNum,'-01') as date) BillingDate
			FROM bannercalendar
			join (select 1 MonthNum union select 2 union select 3 union select 4 union select 5 union select 6
					union select 7 union select 8 union select 9 union select 10 union select 11 union select 12) months
			on months.MonthNum between MONTH(TermBeginDate) and MONTH(TermEndDate)
			where Term = <cfqueryparam value="#Arguments.Term#">
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="updateAttendance" access="remote">
		<cfargument name="billingStudentItemId" required="true">
		<cfargument name="courseValue" required="true">
		<cfquery name="update">
			update billingStudentItem
			set courseValue = <cfqueryparam value="#arguments.courseValue#">
			where billingStudentItemId = <cfqueryparam value="#arguments.billingStudentItemId#">
		</cfquery>
	</cffunction>


	<cffunction name="setUpBillingClassAttendanceForMonth" access="remote" returnFormat="json" >
		<!--- arguments --->
		<cfargument name="term" required="true">
		<cfargument name="billingDate" type="date" required="true">
		<cfargument name="crn" required="true">

		<!--- debug --->
		<cfset var debug = "true" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug>FUNCTION setUpBilling #Now()#</cfif>
		<!---<cflog file="pcclinks_bill" text="PROCEDURE setUpBilling #Now()#">--->
		<cfif debug><cfdump var="#arguments#"></cfif>

		<cfquery name="bannerdata" datasource="bannerpcclinks">
			select distinct stu_id
			from swvlinks_course2
			where crn = <cfqueryparam value="#arguments.crn#">
		</cfquery>
		<cfif debug><cfdump var="#bannerdata#"></cfif>

		<cfquery name="calendar">
			select *
			from bannerCalendar
			where term = <cfqueryparam value="#arguments.term#">
		</cfquery>

		<cfset term = arguments.term>
		<cfset termBeginDate = #calendar.termBeginDate#>
		<cfset termDropDate = #calendar.termDropDate#>

		<!------------------------------------------------>
		<!--- loop through each student                --->
		<!------------------------------------------------>
		<cfloop query = bannerdata >


			<!--- get all the students for this criteria --->
			<cfset var studentQry = getStudents(termdropdate=#termDropDate#, termBeginDate=#termBeginDate#, bannerGNumber=#bannerdata.stu_id#) >
			<!--- debug code --->
			<cfif debug><cfdump var="#GetQueryRow(studentQry, CURRENTROW)#"></cfif>

			<!--- get the billing student record and the banner classes --->
			<cfset var returnArray = getBillingStudent(contactrow=#GetQueryRow(studentQry, CURRENTROW)#, billingdate=#arguments.billingDate#, term=#term#, crn=#arguments.crn#) >
			<cfset var billingStudentId = returnArray[1]>
			<cfset var bannerClasses = returnArray[2]>

			<!--- debug code --->
			<cfif debug><br>bannerClasses record count: <cfdump var="#bannerClasses.recordcount#"></cfif>
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
	</cffunction>


	<cffunction name="setUpBillingClassAttendanceForMonth1" access="remote" returnFormat="json" >
		<!--- arguments --->
		<cfargument name="term" required="true">
		<cfargument name="billingDate" type="date" required="true">
		<cfargument name="crn" required="true">

		<!--- debug --->
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug>FUNCTION setUpBilling #Now()#</cfif>
		<!---<cflog file="pcclinks_bill" text="PROCEDURE setUpBilling #Now()#">--->
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
			<cfif debug><br>bannerClasses record count: <cfdump var="#bannerClasses.recordcount#"></cfif>
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
	</cffunction>

</cfcomponent>
