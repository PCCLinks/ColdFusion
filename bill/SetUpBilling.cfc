<cfcomponent displayname="SetUpBilling">
	<cfset globaldebug="false">

	<cffunction name="getStudents" dataSource="pcclinks" returntype="query" access="remote">
		<cfargument name="termDropDate">
		<cfargument name="termBeginDate">
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><br/>PROCEDURE getStudentsToBill</cfif>
		<cfstoredproc procedure="getStudentsToBill" datasource="pcclinks" >
			<cfprocparam value="#arguments.termBeginDate#" cfsqltype="CF_SQL_DATE">
			<cfprocparam value="#arguments.termDropDate#" cfsqltype="CF_SQL_DATE">
			<cfprocresult name="qry">
		</cfstoredproc>
		<cfreturn qry>
	</cffunction>

	<cffunction name="getBillingStudent" returntype="Array">
		<!--- parameters --->
		<cfargument name = "contactRow" >
		<cfargument name= "term" >
		<cfargument name = "billingDate" >
		<cfset var debug = "false" >

		<!--- debug code --->
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><br/>FUNCTION getBillingStudent</cfif>
		<cfif debug><cfdump var="#arguments#"></cfif>

		<!--- instantiate to accesss it as a struct --->
		<cfset var contactData = #arguments.contactRow#>

		<!--- get classes during the requested term --->
		<cfquery name="bannerClasses" datasource="bannerpcclinks">
			select *
			from swvlinks_course
			where STU_ID = <cfqueryparam value="#contactData.bannerGNumber#">
				and TERM = <cfqueryparam value="#arguments.term#">
		</cfquery>

		<!---------------------------------->
		<!--- get billing student record --->
		<!---------------------------------->
		<cfquery name="qry" datasource="pcclinks" >
			select * from billingStudent where GNumber = <cfqueryparam value="#contactData.bannerGNumber#"> and BillingDate = <cfqueryparam value="#DateFormat(arguments.billingDate,'yyyy-mm-dd')#">
		</cfquery>
		<!--- create a record if one does not exist --->
		<cfif qry.recordcount EQ 0 >
			<cfif debug><cfdump var="#qry#"></cfif>
			<cftry>
				<cfquery name="doInsertBillingStudent" result="resultBillingstudent" datasource="pcclinks" >
					insert into billingStudent(contactid, gnumber, districtid, term, program, enrolleddate, exitdate, billingdate, billingtype, billingstatus, includeflag, datecreated, datelastupdated, createdby, lastupdatedby)
					<cfoutput>
						values('#contactData.contactid#'
								,'#contactData.bannerGNumber#'
								,#contactData.keySchoolDistrictID#
								,#arguments.term#
								,'#contactData.program#'
								,'#contactData.enrolldate#'
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
			<cfquery name="updateError" datasource="pcclinks" >
				update billingStudent
				set ErrorMessage = 'Student is active but has no classes in Banner'
				where BillingStudentID = <cfqueryparam value="#billingstudentid#">
			</cfquery>
		</cfif>

		<!--- return the billing student record, and the collection of classese --->
		<cfreturn [billingstudentid, bannerClasses] >
	</cffunction>

	<cffunction name = "populateEntries" >
		<!--- arguments --->
		<cfargument name = "billingStudentId">
		<cfargument name = "GNumber">
		<cfargument name = "billingDate">
		<!--- passing in current classes in banner --->
		<cfargument name = "bannerClasses" type="query">

		<!--- debug code --->
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><br/>FUNCTION populateEntries</cfif>
		<cfif debug><cfdump var="#arguments#"></cfif>

		<!---------------------------------------------------------------->
		<!--- combine classes in billing table with classes in banner  --->
		<!--- in order to determine if any new classes need to be added --->
		<!---------------------------------------------------------------->

		<!--- get classes currently added to bill --->
		<cfquery name = "existingBilling" datasource="pcclinks">
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
			<cfquery name="doInsert" datasource="pcclinks" result="r">
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
					<cfset ytcProgram = 'YTC ELL Attendance'>
				<cfelse>
					<cfset ytcProgram = 'YTC ELL Credit'>
				</cfif>
				<cfquery name="updateBillingStudentToELL" >
					UPDATE billingStudent
					SET Program = '#ytcProgram#'
					WHERE billingStudentID = <cfqueryparam value="#arguments.billingStudentID#">
				</cfquery>
			</cfif> <!--- if ell query recordcount greater than 0 --->
		</cfif> <!--- end rows to insert --->

		<!--- debug code --->
		<cfif debug>
			<cfif IsDefined("r")><cfdump var="#r#" format="text"><cfelse>No rows to insert<br></cfif>
		</cfif>
	</cffunction>

	<cffunction name="checkIfClassPreviouslyTaken"  access="remote">
		<cfargument name = "GNumber">
		<cfargument name="currentterm">
		<cfargument name="CRSE" >
		<cfargument name="SUBJ">
		<cfquery name="previouscourses" datasource="bannerpcclinks">
			select Term
			from swvlinks_course
			where STU_ID = <cfqueryparam value="#arguments.GNumber#">
				and CRSE = <cfqueryparam value="#arguments.CRSE#">
				and SUBJ = <cfqueryparam value="#arguments.SUBJ#">
				AND TERM < <cfqueryparam value="#arguments.currentterm#">
		</cfquery>
		<cfreturn previouscourses>
	</cffunction>

	<cffunction name="updateIncludeBasedOnPreviousClasses">
		<cfargument name = "billingStudentId">
		<cfargument name = "GNumber">
		<cfargument name="currentterm">
		<cfquery name="currentcourses" datasource="pcclinks">
			select *
			from billingStudentItem
			where billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
		</cfquery>
		<cfloop query="currentcourses">
			<cfset qry=checkIfClassPreviouslyTaken(arguments.GNumber, arguments.currentterm, currentcourses.CRSE, currentcourses.SUBJ) >
			<cfif qry.recordcount GT 0>
				<cfquery name="updateitem" datasource="pcclinks">
					update billingStudentItem
					set includeflag = 0, takenpreviousterm = #qry.term#
					where billingstudentitemid = #billingstudentitemid#
				</cfquery>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="setUpBilling" access="remote" returnFormat="json">
		<!--- arguments --->
		<!---<cfargument name="program"> --->
		<cfargument name="termBeginDate" type="date">
		<cfargument name="term">
		<cfargument name="termDropDate"type="date">

		<!--- debug --->
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug>FUNCTION setUpBilling</cfif>
		<cfif debug><cfdump var="#arguments#"></cfif>

		<!--- used by UI --->
		<cfset Session.IsDone = 0>

		<!--- query for both the requested term and the prior term --->
		<cfloop from=1 to=2 index="i">
			<!--- first pass, requested term --->
			<cfif i EQ 1>
				<!---<cfset program = arguments.program> --->
				<cfset termDropDate = arguments.termDropDate>
				<cfset termBeginDate = arguments.termBeginDate>
				<cfset term = arguments.term>
			<cfelse>
				<!--- second pass, prior term --->
				<cfquery datasource="pcclinks" name="calendar">
					select *
					from bannerCalendar
					where term = (select max(term) from bannerCalendar where term < <cfqueryparam value="#arguments.term#">)
				</cfquery>
				<!--- <cfset program = arguments.program> --->
				<cfset termDropDate = calendar.termDropDate>
				<cfset termBeginDate = calendar.termBeginDate>
				<cfset term = calendar.term>
			</cfif>

			<!--- get all the students for this criteria --->
			<cfset var studentQry = getStudents(termdropdate=#termDropDate#, termBeginDate=#termBeginDate#) >

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
													billingDate=#termBeginDate#,
													bannerClasses=#bannerClasses#)>

					<!--- for current term only ---------------------->
					<!--- check if class already taken and exclude --->
					<cfif i EQ 1>
						<cfset result = updateIncludeBasedOnPreviousClasses(billingstudentid=#billingStudentId#,
																			GNumber=#studentQry.bannerGNumber#,
																			currentterm = #arguments.term#) >
					</cfif> <!--- end if of index=1, current term --->

				</cfif> <!--- end populate billing entry --->
			</cfloop>
			<!--- end loop per student --->

		</cfloop> <!--- end current and previous term --->
		<cfreturn 1> <!--- to indicate session is done --->
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
</cfcomponent>
