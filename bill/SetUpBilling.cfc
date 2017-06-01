<cfcomponent displayname="SetUpBilling">
	<cfset globaldebug="false">

	<cffunction name="getStudents" returntype="query" access="remote">
		<cfargument name="program"/>
		<cfargument name="termDropDate">
		<cfargument name="termBeginDate">
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><br/>FUNCTION getStudents</cfif>
		<cfquery name="qry" datasource="fc" result="r">
			select sub1_dataByMaxEnrolledDate.contactid
				, sub1_dataByMaxEnrolledDate.bannerGNumber
				, sub1_dataByMaxEnrolledDate.lastName
				, sub1_dataByMaxEnrolledDate.firstName
			    , sub1_dataByMaxEnrolledDate.program
			    , sub1_dataByMaxEnrolledDate.enrolleddate
			    , sub1_dataByMaxEnrolledDate.exitdate
			    , bs.billingdate
			    , bs.billingstatus
			    , bs.notes
			    , IFNULL(bs.billingstudentid,0) billingstudentid
                , keySchoolDistrict.keySchoolDistrictID
                , keySchoolDistrict.schoolDistrict
			 from
			 	( select contact.contactID
				 		, contact.bannerGNumber
						, contact.lastName
						, contact.firstName
					    , sub2_dataByEnrolledAndExited.program
					    , MAX(sub2_dataByEnrolledAndExited.enrolleddate) EnrolledDate
					    , MAX(sub2_dataByEnrolledAndExited.exitdate) ExitDate
					from sidny.contact
					inner join
						( select enrolled.contactid
							,CASE WHEN enrolled.program = 'ytc' THEN keyStatus.statusText ELSE enrolled.program END program
							,enrolled.statusdate enrolleddate, max(exited.statusdate) exitdate
		                  from sidny.status enrolled
		                  	join sidny.keyStatus keyStatus on enrolled.keyStatusID = keyStatus.keyStatusID
							left outer join sidny.status exited
								on enrolled.contactid = exited.contactid
									and enrolled.program = exited.program
									and exited.statusdate >= enrolled.statusdate
									and exited.keyStatusID = 3
									and exited.undoneStatusID is null
						  where enrolled.keyStatusID IN (2,13,14,15,16)
							and enrolled.undoneStatusID is null
						  group by enrolled.contactid, enrolled.program, enrolled.statusdate
						) sub2_dataByEnrolledAndExited
		              on contact.contactID = sub2_dataByEnrolledAndExited.contactID
		              where length(contact.bannerGNumber) > 0
		              group by contact.contactID
			            , contact.bannerGNumber
						, contact.lastName
						, contact.firstName
					    , sub2_dataByEnrolledAndExited.program
		         ) sub1_dataByMaxEnrolledDate
						left outer join sidny.status statusSD on sub1_dataByMaxEnrolledDate.contactid = statusSD.contactid
							and statusSD.statusid = (select statusid from sidny.status where keyStatusID=7 and contactid = sub1_dataByMaxEnrolledDate.contactid and undoneStatusID is null order by statusdate desc limit 1)
                        left outer join sidny.statusSchoolDistrict statusSchoolDistrict on statusSD.statusid = statusSchoolDistrict.statusID
                        left outer join sidny.keySchoolDistrict keySchoolDistrict on statusSchoolDistrict.keySchoolDistrictID = keySchoolDistrict.keySchoolDistrictID
						left outer join pcc_links.BillingStudent bs on sub1_dataByMaxEnrolledDate.contactid = bs.contactid
			where sub1_dataByMaxEnrolledDate.program = <cfqueryparam value="#arguments.program#">
				and sub1_dataByMaxEnrolledDate.EnrolledDate <= <cfqueryparam value="#DATEFORMAT(arguments.termBeginDate,'yy-mm-dd')#">
				and (sub1_dataByMaxEnrolledDate.ExitDate >= <cfqueryparam value="#DATEFORMAT(arguments.termDropDate,'yy-mm-dd')#"> or sub1_dataByMaxEnrolledDate.ExitDate IS NULL)
		</cfquery>
		<cfif debug>
			<cfdump var="#r#" format="text">
		</cfif>
		<cfreturn qry>
	</cffunction>

	<cffunction name="getBillingStudent" returntype="Array">
		<cfargument name = "contactRow" >
		<cfargument name= "term" >
		<cfargument name = "billingDate" >
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><br/>FUNCTION getBillingStudent</cfif>
		<cfif debug><cfdump var="#arguments#"></cfif>
		<cfset var contactData = #arguments.contactRow#>
		<cfquery name="qry" datasource="fc">
			select * from pcc_links.BillingStudent where GNumber = <cfqueryparam value="#contactData.bannerGNumber#"> and BillingDate = <cfqueryparam value="#DateFormat(arguments.billingDate,'yyyy-mm-dd')#">
		</cfquery>
		<cfquery name="bannerClasses" datasource="fc">
			select *
			from pcc_links.BannerCourse
			where STU_ID = <cfqueryparam value="#contactData.bannerGNumber#">
				and TERM = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfif qry.recordcount EQ 0 >
			<cfif debug><cfdump var="#qry#"></cfif>
			<cftry>
				<cfquery name="doInsertBillingStudent" datasource="fc" result="resultBillingstudent">
					insert into pcc_links.BillingStudent(contactid, gnumber, districtid, term, program, enrolleddate, exitdate, billingdate, billingtype, billingstatus, includeflag, datecreated, datelastupdated, createdby, lastupdatedby)
					<cfoutput>
						values('#contactData.contactid#'
								,'#contactData.bannerGNumber#'
								,#contactData.keySchoolDistrictID#
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
					<cfrethrow />
				</cfcatch>
			</cftry>
			<cfif debug>billingstudentid=<cfoutput>#billingstudentid#</cfoutput></cfif>
			<cfif debug><cfdump var="#resultBillingstudent#"></cfif>
		<cfelse>
			<cfset var billingstudentid = #qry.billingstudentid#>
		</cfif>
		<cfif debug>billingstudentid=<cfoutput>#billingstudentid#</cfoutput></cfif>
		<cfif debug><cfdump var="#bannerClasses#"></cfif>
		<cfif bannerClasses.recordcount EQ 0>
			<cfif debug>in banner classes recordcount = 0</cfif>
			<cfquery name="updateError" datasource="fc" >
				update pcc_links.BillingStudent
				set ErrorMessage = 'Student is active but has no classes in Banner'
				where BillingStudentID = <cfqueryparam value="#billingstudentid#">
			</cfquery>
		</cfif>
		<cfreturn [billingstudentid, bannerClasses] >
	</cffunction>

	<cffunction name = "populateEntries" >
		<cfargument name = "billingStudentId">
		<cfargument name = "GNumber">
		<cfargument name = "billingDate">
		<cfargument name = "bannerClasses" type="query">
		<cfset var debug = "false" >
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug><br/>FUNCTION populateEntries</cfif>
		<cfif debug><cfdump var="#arguments#"></cfif>
		<cfquery name = "existingBilling" datasource="fc">
			select *
			from pcc_links.BillingStudent bs
				join pcc_links.BillingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			where bs.billingstudentid = <cfqueryparam value="#arguments.billingStudentID#">
		</cfquery>
		<cfif debug><cfdump var="#existingBilling#"></cfif>
		<cfquery name="unionRows" dbtype="query">
			select CRN, CRSE, SUBJ, Credits, 1 addOrSubtract
			from bannerClasses
			union all
			select CRN, CRSE, SUBJ, CAST(CourseValue as INTEGER), -1
			from existingBilling
		</cfquery>
		<cfif debug>UNION ROWS<br/>
			<cfif unionRows.recordcount GT 0><cfdump var="#unionRows#">
			<cfelse>No union rows
			</cfif>
		</cfif>
		<cfquery name="rowsToInsert" dbtype="query">
			select CRN, CRSE, SUBJ, Credits, addOrSubtract from unionRows group by CRN, CRSE, SUBJ, Credits having count(*) = 1
		</cfquery>
		<cfif debug><cfdump var="#rowsToInsert#"></cfif>
		<cfif rowstoInsert.recordcount GT 0>
			<cfquery name="doInsert" datasource="fc" result="r">
				insert into pcc_links.BillingStudentItem(billingstudentid, crn, crse, subj, typecode, includeflag, coursevalue, multiplier, billedamount, datecreated, datelastupdated, createdby, lastupdatedby)
				<cfoutput query="rowsToInsert">
				select #arguments.billingStudentId#, #crn#, #crse#, '#subj#', 'CREDIT', 1, #Credits*AddOrSubtract#, 4.8, #Credits*AddOrSubtract#*4.8, Now(), Now(), current_user(), current_user()
	       			<cfif currentrow LT rowsToInsert.recordcount>UNION ALL</cfif>
				</cfoutput>
			</cfquery>
		</cfif>
		<cfif debug><cfdump var="#r#" format="text"></cfif>
		<cfreturn "done">
	</cffunction>

	<cffunction name="getPreviousCourses" access="remote">
		<cfargument name = "GNumber">
		<cfargument name="currentterm">
		<cfargument name="CRSE" >
		<cfargument name="SUBJ">
		<cfquery name="previouscourses" datasource="fc">
			select *
			from pcc_links.BannerCourse
			where STU_ID = <cfqueryparam value="#arguments.GNumber#">
				and CRSE = <cfqueryparam value="#arguments.CRSE#">
				and SUBJ = <cfqueryparam value="#arguments.SUBJ#">
				AND TERM < <cfqueryparam value="#arguments.currentterm#">
		</cfquery>
		<cfreturn previouscourses>
	</cffunction>

	<cffunction name="updatePreviousClasses">
		<cfargument name = "billingStudentId">
		<cfargument name = "GNumber">
		<cfargument name="currentterm">
		<cfquery name="previouscourses" datasource="fc">
			select *
			from pcc_links.BannerCourse
			where STU_ID = <cfqueryparam value="#arguments.GNumber#">
		</cfquery>
		<cfquery name="currentcourses" datasource="fc">
			select *
			from pcc_links.BillingStudentItem
			where billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
		</cfquery>
		<cfloop query="currentcourses">
			<cfset qry=getPreviousCourses(GNumber, CRSE, SUBJ) >
			<cfif qry.count GT 0>
				<cfquery name="updateitem" datasource="fc">
					update pcc_links.BillingStudentItem
					set includeflag = 0, takenpreviousterm = #qry.term#
					where billingstudentitem = #billingstudentitemid#
				</cfquery>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="setUpBilling" access="remote" returnFormat="json">
		<cfargument name="program">
		<cfargument name="termBeginDate" type="date">
		<cfargument name="term">
		<cfargument name="termDropDate"type="date">
		<cfset var debug = "false" >
		<cfset Session.IsDone = 0>
		<cfif globaldebug><cfset debug = "true"></cfif>
		<cfif debug>FUNCTION setUpBilling</cfif>
		<cfif debug><cfdump var="#arguments#"></cfif>
		<cfloop from=1 to=2 index="i">
			<cfif i EQ 1>
				<cfset program = arguments.program>
				<cfset termDropDate = arguments.termDropDate>
				<cfset termBeginDate = arguments.termBeginDate>
				<cfset term = arguments.term>
			<cfelse>
				<cfquery datasource="fc" name="calendar">
					select *
					from pcc_links.BannerCalendar
					where term = (select max(term) from pcc_links.BannerCalendar where term < <cfqueryparam value="#arguments.term#">)
				</cfquery>
				<cfset program = arguments.program>
				<cfset termDropDate = calendar.termDropDate>
				<cfset termBeginDate = calendar.termBeginDate>
				<cfset term = calendar.term>
			</cfif>
			<cfset var studentQry = getStudents(program=#program#, termdropdate=#termDropDate#, termBeginDate=#termBeginDate#) >
			<cfloop query = studentQry >
				<cfif debug><cfdump var="#GetQueryRow(studentQry, CURRENTROW)#"></cfif>
				<cfset var returnArray = getBillingStudent(contactrow=#GetQueryRow(studentQry, CURRENTROW)#, billingdate=#termBeginDate#, term=#term#) >
				<cfif debug>bannerClasses record count: <cfdump var="#returnArray[2].recordcount#"></cfif>
				<cfif returnArray[2].recordcount GT 0>
					<cfset result = populateEntries(billingstudentid=#returnArray[1]#,
													GNumber=#studentQry.bannerGNumber#,
													billingDate=#termBeginDate#,
													bannerClasses=#returnArray[2]#)>
				</cfif>
			</cfloop>
		</cfloop>
		<cfreturn 1>
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
