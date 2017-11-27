<cfcomponent displayname="programbilling">

	<cfobject name="appObj" component="application">

	<cffunction name="select" returntype="struct" access="remote">
		<cfargument name="page" type="numeric" required="no" default="1">
		<cfargument name="pageSize" type="numeric" required="no" default="10">
		<cfargument name="gridsortcolumn" type="string" required="no" default="">
		<cfargument name="gridsortdir" type="string" required="no" default="">
		<cfargument name="program" default="YtC Credit">
		<cfargument name="schooldistrict" default="Tigard/Tualatin">
		<cfargument name="term" default="201701">
		<cfset var data = yearlybilling(program=#arguments.program#, term=#arguments.term#, schooldistrict=#arguments.schooldistrict#) >
		<cfreturn QueryConvertForGrid(data,  arguments.page, arguments.pageSize)>
	</cffunction>


	<cffunction name="getProgramStudent" returntype="query" access="remote">
		<cfargument name="billingStudentId" required="true">
		<!--- main query --->
		<cfquery name="data" >
			SELECT res.rsName coach
				,bs.BillingStudentId
				,c.bannerGNumber
				,bs.PIDM
				,lastname
				,schooldistrict
				,c.contactId
				,Date_Format(bs.enrolledDate, '%m/%d/%Y') EnrolledDate
				,Date_Format(bs.exitDate, '%m/%d/%Y') ExitDate
				,bs.billingstatus
				,bs.Program
				,c.firstname
				,c.lastname
				,bs.billingStartDate
				,bs.ErrorMessage
				,bs.term
				,bs.includeFlag
				,bs.reviewWithCoachFlag
				,bs.billingNotes
			FROM contact c
				JOIN billingStudent bs on c.contactid = bs.contactID
 				JOIN keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
				JOIN (SELECT contactID, max(statusID) statusID
		   			  FROM status
           			  WHERE keyStatusID = 6
          			  GROUP BY contactID) coachLastStatus
			    	ON coachLastStatus.contactID = c.contactID
				JOIN (SELECT sres.statusID, res.rsName
		  			  FROM statusResourceSpecialist sres
						JOIN keyResourceSpecialist res
							ON sres.keyResourceSpecialistID = res.keyResourceSpecialistID) res
					ON coachLastStatus.statusID = res.statusID
			WHERE bs.billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="getOtherBilling" returntype="query" access="remote">
		<cfargument name="contactId" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
			SELECT bs.BillingStudentId, bs.PIDM, schooldistrict
				,Date_Format(bs.enrolledDate, '%m/%d/%Y') EnrolledDate
				,Date_Format(bs.exitDate, '%m/%d/%Y') ExitDate
				,bs.billingstatus, bs.Program, bs.billingStartDate, bs.ErrorMessage, bs.term
			FROM billingStudent bs
	    		JOIN bannerCalendar on bs.term = bannerCalendar.Term
					and bannerCalendar.ProgramYear = (select ProgramYear from bannerCalendar where term = <cfqueryparam value="#arguments.term#">)
	 			JOIN keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
			WHERE bs.contactId = <cfqueryparam value="#arguments.contactId#">
				and bs.billingStartDate != <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			ORDER BY bs.term desc
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="getProgramStudentList" returntype="query" returnformat="json" access="remote">
		<!--- arguments --->
		<cfargument name="program" type="string" required="true">
		<cfargument name="term" required="true">
		<cfquery name="data" >
			SELECT res.rsName coach
				,c.bannerGNumber
				,c.firstname
				,c.lastname
				,schooldistrict
				,Date_Format(bs.enrolledDate, '%m/%d/%Y') EnrolledDate
				,Date_Format(bs.exitDate, '%m/%d/%Y') ExitDate
				,bs.Program
				,bs.term
    			,sum(COALESCE(bsYearly.FinalBilledUnits, bsYearly.CorrectedBilledUnits, bsYearly.GeneratedBilledUnits,0)) FYTotalNoOfCredits
				,COALESCE(bs.FinalBilledUnits, bs.CorrectedBilledUnits, bs.GeneratedBilledUnits,0) CurrentTermNoOfCredits
				,bs.billingstatus
				,bs.BillingStudentId
			FROM contact c
				JOIN billingStudent bs on c.contactid = bs.contactID
					and bs.term = <cfqueryparam value="#arguments.term#">
				join billingStudent bsYearly on bsYearly.contactId = c.contactId
    			JOIN bannerCalendar on bsYearly.term = bannerCalendar.Term
					and bannerCalendar.ProgramYear = (select ProgramYear from bannerCalendar where term = <cfqueryparam value="#arguments.term#">)
				JOIN keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
				JOIN (SELECT contactID, max(statusID) statusID
		   			  FROM status
           			  WHERE keyStatusID = 6
          			  GROUP BY contactID) coachLastStatus
			    	ON coachLastStatus.contactID = c.contactID
				JOIN (SELECT sres.statusID, res.rsName
		  			  FROM statusResourceSpecialist sres
						JOIN keyResourceSpecialist res
							ON sres.keyResourceSpecialistID = res.keyResourceSpecialistID) res
					ON coachLastStatus.statusID = res.statusID
		<cfif len(arguments.program) GT 0>
			WHERE
			<cfif arguments.program EQ 'Ytc'>
				bs.program like 'YtC%'
			<cfelse>
				bs.program = <cfqueryparam value="#arguments.program#">
			 </cfif>
		</cfif>
			GROUP BY res.rsName, c.bannerGNumber, schooldistrict, bs.enrolleddate, bs.exitdate, bs.program, bs.billingstatus, bs.billingStudentId
					,COALESCE(bs.FinalBilledUnits, bs.CorrectedBilledUnits, bs.GeneratedBilledUnits,0)
		</cfquery>

		<cfreturn data>
	</cffunction>


	<cffunction name="groupBySchoolDistrictAndProgram" returntype="query" access="remote">
		<cfargument name="term" required="yes">
		<cfargument name="billingType" required="yes">
		<cfquery name="data">
			select sd.schoolDistrict, bs.Program
				,sum(case when cal.ProgramQuarter = 1 then bsi.Amount else 0 END) SummerAmount
				,sum(case when cal.ProgramQuarter = 2 then bsi.Amount else 0 END) FallAmount
				,sum(case when cal.ProgramQuarter = 3 then bsi.Amount else 0 END) WinterAmount
				,sum(case when cal.ProgramQuarter = 4 then bsi.Amount else 0 END) SpringAmount
			from billingStudent bs
				join (select billingStudentId,
						<cfif arguments.billingType EQ "term">Credits<cfelse>Attendance</cfif> Amount
					  from billingStudentItem) bsi on  bs.BillingStudentID = bsi.BillingStudentID
			    join keySchoolDistrict sd on  bs.DistrictID = sd.keySchoolDistrictID
			    join bannerCalendar cal on bs.term = cal.term
			    	and cal.ProgramYear = (select ProgramYear from bannerCalendar where term = <cfqueryparam value="#arguments.term#">)
			<cfif arguments.billingType EQ "term">
				where bs.program not like '%attendance%'
			<cfelse>
				where bs.program like '%attendance%'
			</cfif>
			group by sd.schoolDistrict, bs.Program
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="selectStudentBilling" returntype="query" returnFormat="json" access="remote">
		<cfargument name="program" type="string">
		<cfargument name="schooldistrict" type="string">
		<cfargument name="term">
		<cfset debug="false">
		<cfif debug>
			<cfdump var="#arguments#" />
		</cfif>
		<cfset var data = yearlybilling(program=#arguments.program#, term=#arguments.term#, schooldistrict=#arguments.schooldistrict#) >
		<cfif debug>
			<cfdump var="#data#" />
		</cfif>
		<cfreturn data>
	</cffunction>


	<cffunction name="studentenrollment" returntype="Query">
		<cfargument name="program" type="string" default="">
		<cfargument name="bannerGNumber" type="string" default="">
		<cfargument name="billingstudentid" type="numeric" default="0">
		<cfset debug="false">
		<cfif debug>
			<cfdump var="#arguments#" />
		</cfif>
		<cfquery datasource="pcclinks" name="studentbillingData" result="r" >
			select sub1_dataByMaxEnrolledDate.contactid
				, sub1_dataByMaxEnrolledDate.bannerGNumber
				, sub1_dataByMaxEnrolledDate.lastName
				, sub1_dataByMaxEnrolledDate.firstName
			    , sub1_dataByMaxEnrolledDate.program
			    , sub1_dataByMaxEnrolledDate.enrolleddate
			    , sub1_dataByMaxEnrolledDate.exitdate
			    , bs.billingStartDate
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
						( select enrolled.contactid, enrolled.program, enrolled.statusdate enrolleddate, max(exited.statusdate) exitdate
		                  from sidny.status enrolled
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
		              group by contact.contactID
			            , contact.bannerGNumber
						, contact.lastName
						, contact.firstName
					    , sub2_dataByEnrolledAndExited.program
		         ) sub1_dataByMaxEnrolledDate
						left outer join sidny.status statusSD on sub1_dataByMaxEnrolledDate.contactid = statusSD.contactid
							and statusSD.statusid = (select statusid from sidny.status where keyStatusID=7 and contactid = sub1_dataByMaxEnrolledDate.contactid order by statusdate asc limit 1)
                        left outer join sidny.statusSchoolDistrict statusSchoolDistrict on statusSD.statusid = statusSchoolDistrict.statusID
                        left outer join sidny.keySchoolDistrict keySchoolDistrict on statusSchoolDistrict.keySchoolDistrictID = keySchoolDistrict.keySchoolDistrictID
						left outer join pcc_links.BillingStudent bs on sub1_dataByMaxEnrolledDate.contactid = bs.contactid
			where
           	<cfif len(trim(arguments.bannerGNumber)) >
				sub1_dataByMaxEnrolledDate.bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#"> and
		<cfelseif NOT arguments.billingstudentid EQ 0>
				bs.BillingStudentID = <cfqueryparam value="#arguments.billingstudentid#"> and
			</cfif>
				sub1_dataByMaxEnrolledDate.program = <cfqueryparam value="#arguments.program#">
		</cfquery>
		<!--- <cfdump var="#r#" format="text"> --->
		<cfreturn studentbillingData>
	</cffunction>


	<cffunction name="selectstudents" access="remote" returntype="struct">
		<cfargument name="page" type="numeric" required="yes">
		<cfargument name="pageSize" type="numeric" required="yes">
		<cfargument name="gridsortcolumn" type="string" required="no">
		<cfargument name="gridsortdir" type="string" required="no">
		<cfargument name="termdropdate" type="date" required="yes">
		<cfargument name="termyear" type="numeric" required="yes">
		<cfargument name="termnumber" type="numeric" required="yes">
		<cfargument name="program" type="string" default="">
		<cfargument name="bannerGNumber" type="string" default="">
		<cfset debug="false">
		<cfset termcode = #arguments.termyear#&"0"&#arguments.termnumber#>
		<cfquery name="banner" datasource="pcclinks">
			select bannerGNumber, SFRSTCR_TERM_CODE from pcc_links.BannerCoursesReport where SFRSTCR_TERM_CODE = '#termcode#'
		</cfquery>
		<cfif debug>
			<cfdump var="#banner#" />
		</cfif>
		<cfset studentEnrollment=studentenrollment(program=#arguments.program#, bannerGNumber=#arguments.bannerGNumber#)>
		<!--- <cfdump var="#GetMetaData(studentEnrollment)#"> --->
		<cfquery name="studentsWithClassesInTerm" dbtype="query"  result="r">
			select distinct studentEnrollment.*, SFRSTCR_TERM_CODE
			from studentEnrollment, banner
			where studentEnrollment.bannerGNumber = banner.bannerGNumber and
			<cfif len(trim(arguments.bannerGNumber)) >
				bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
		<cfelse>
				program = <cfqueryparam value="#arguments.program#">
					and (exitdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.termdropdate#"> or exitdate is null)
			</cfif>
		</cfquery>
		<cfif debug>
			<cfdump var="#studentsWithClassesInTerm#" />
		</cfif>
		<!--- <cfdump var="#r#" format="text"> --->
		<cfset queryAddColumn(studentsWithClassesInTerm,"editlink","varchar",arrayNew(1))>
		<cfloop query="studentsWithClassesInTerm">
			<cfsavecontent variable="edittext">
				<cfoutput><a href="javascript:getStudent('programbillingstudent.cfm?cfdebug', {billingstudentid:'#studentsWithClassesInTerm.billingstudentid#',bannerGNumber:'#studentsWithClassesInTerm.bannerGNumber#',program:'#studentsWithClassesInTerm.program#',enrolledDate:'#studentsWithClassesInTerm.enrolledDate#',exitDate:'#studentsWithClassesInTerm.exitDate#'});">Review</a></cfoutput>
			</cfsavecontent>
			<cfset querySetCell(studentsWithClassesInTerm, "editlink", edittext, currentRow)>
		</cfloop>
		<cfreturn QueryConvertForGrid(studentsWithClassesInTerm,  ARGUMENTS.page, ARGUMENTS.pageSize)>
	</cffunction>


	<cffunction name="selectstudent" access="remote" returntype="query">
		<cfargument name="billingstudentid" type="string" required="no" default="">
		<cfargument name="bannerGNumber" type="string" required="no" default="">
		<cfargument name="term" type="numeric" required="no" default="0">
		<cfset debug="false">
		<cfif debug>
			<cfoutput>
				selectstudent arguments:
			</cfoutput>
			<cfdump var="#arguments#" />
		</cfif>
		<cfquery name="data" datasource="pcclinks" result="r">
			select *
			from sidny.contact c
				join pcc_links.BillingStudent bs on c.contactid = bs.contactid
			where 1=1
				<cfif len(#arguments.billingstudentid#) GT 0 >
					and bs.billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
				</cfif>
				<cfif len(#arguments.bannerGNumber#) GT 0>
					and c.bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
						and bs.term = <cfqueryparam value="#arguments.term#">
				</cfif>
		</cfquery>
		<cfif debug>
			<cfdump var="#r#" />
		</cfif>
		<cfreturn data >
	</cffunction>


	<cffunction name="selectBillingEntries" access="remote" returnType="query">
		<!--- arguments --->
		<cfargument name="billingstudentid" type="string" required="yes">
		<!--- debug code --->
		<cfset debug="false">
		<cfif debug>
			<cfoutput>
				selectstudent arguments:
			</cfoutput>
			<cfdump var="#arguments#" />
		</cfif>
		<!--- main query --->
		<cfquery name="data">
			select bs.billingStudentId, bs.Program, bs.Term, bs.billingStatus
				,bsi.billingStudentItemId, bsi.TakenPreviousTerm, bsi.IncludeFlag, bsi.CRN, bsi.Subj, bsi.Title, bsi.Credits
				,sum(bsiAttend.Attendance) AttendanceToDate
			from billingStudentItem bsi
				join billingStudent bs on bsi.BillingStudentId=bs.BillingStudentId
				join billingStudent bsAttend on bs.contactId = bsAttend.contactID
					and bs.billingStartDate <= bsAttend.billingStartDate
				join bannerCalendar cal on bs.term = cal.term
					and bsAttend.billingStartDate between cal.termbegindate and cal.termEndDate
				join billingStudentItem bsiAttend on bsAttend.billingStudentId = bsiAttend.billingStudentId
					and bsi.CRN = bsiAttend.CRN
			where bs.billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
            group by bs.billingStudentId, bs.Program, bs.Term, bs.billingStatus,
				bsi.TakenPreviousTerm, bsi.IncludeFlag,
				bsi.CRN, bsi.Subj, bsi.Title, bsi.Credits
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="selectBannerClasses" access="remote" returnType="query">
		<cfargument name="pidm" required="yes">
		<cfargument name="term" required="yes">
		<cfargument name="contactId" required="yes">
		<cfset debug="false">
		<cfif debug>
			<cfdump var="#arguments.row#" />
		</cfif>
		<cfquery name="bannerclasses" datasource="bannerpcclinks">
			select distinct PIDM, STU_ID, TERM, CRN, LEVL, SUBJ, CRSE, TITLE, CREDITS, GRADE, PASSED
			from swvlinks_course
			where pidm = <cfqueryparam value="#arguments.pidm#">
				and term <= <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfquery name="billedclasses">
			select TERM, CRN, SUBJ, CRSE, TITLE, CREDITS, bsi.IncludeFlag, takenpreviousterm
			from billingStudentItem bsi
				join billingStudent bs on bsi.billingStudentID = bs.billingStudentId
			where bs.contactid = <cfqueryparam value="#arguments.contactid#">
		</cfquery>
		<cfquery dbtype="query" name="combined">
			select CAST(TERM as INTEGER) TERM, CAST(CRN as VARCHAR) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, TITLE, CAST(CREDITS as INTEGER) CREDITS, LEVL, GRADE, PASSED, -1 as IncludeFlag, '' as TakenPreviousTerm
			from bannerclasses
			union
			select CAST(TERM as INTEGER) TERM, CAST(CRN as VARCHAR) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, TITLE, CAST(CREDITS as INTEGER), '' as LVL, '' AS Grade, '' AS Passed, IncludeFlag, CAST(takenpreviousterm as VARCHAR)
			from billedclasses
		</cfquery>
		<cfquery dbtype="query" name="final">
			select TERM, CRN, SUBJ, CRSE, TITLE, CREDITS
				, MAX(LEVL) LEVL, MAX(GRADE) Grade, MAX(PASSED) Passed, MAX(IncludeFlag) IncludeFlag, MAX(TakenPreviousTerm) TakenPreviousTerm
			from combined
			group by TERM, CRN, SUBJ, CRSE, TITLE, CREDITS
		</cfquery>
		<cfif debug>
			<cfdump var="#bannerclasses#" />
		</cfif>
		<cfreturn final>
	</cffunction>

	<!---<cffunction name ="getBannerClasses" access="remote" returnType="struct">
		<cfargument name="page" type="numeric" required="no" default=1>
		<cfargument name="pageSize" type="numeric" required="no" default=40>
		<cfargument name="gridsortcolumn" type="string" required="no">
		<cfargument name="gridsortdir" type="string" required="no">
		<cfargument name="pidm" type="string" required="yes">
		<cfargument name="SSBSECT_SUBJ_CODE" type = "string" default = "">
		<cfargument name="termcode" type="string" required="yes">
		<cfquery name="bannerclasses" datasource="pcclinks">
		select *
		from pcc_links.BannerCoursesReport
		where pidm = <cfqueryparam value="#arguments.pidm#">
		and SSBSECT_SUBJ_CODE = <cfqueryparam value="#arguments.SSBSECT_SUBJ_CODE#">
		and SFRSTCR_TERM_CODE < <cfqueryparam value="#arguments.termcode#">
		order by SFRSTCR_TERM_CODE DESC
		</cfquery>
		<cfreturn  QueryConvertForGrid(bannerclasses,  ARGUMENTS.page, ARGUMENTS.pageSize)>
		</cffunction>
--->

	<cffunction name="editnotes" access="remote">
		<cfargument name="gridaction" type="string" required="yes">
		<cfargument name="gridrow" type="struct" required="yes">
		<cfargument name="gridchanged" type="struct" required="yes">
		<cfquery datasource="pcclinks">
		UPDATE billingstudent
		SET notes = '#ARGUMENTS.gridchanged["notes"]#'
		WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.gridrow.billingstudentid#">
		</cfquery>
	</cffunction>


	<cffunction name="updatestudentbillinginclude" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="includeflag" required="yes">
		<cfquery datasource="pcclinks">
			UPDATE billingStudent
			SET IncludeFlag = '#ARGUMENTS.includeflag#'
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>


	<cffunction name="updatestudentbillingiteminclude" access="remote">
		<cfargument name="billingstudentitemid" required="yes">
		<cfargument name="includeflag" required="yes">
		<cfquery>
			UPDATE billingStudentItem
			SET IncludeFlag = '#ARGUMENTS.includeflag#'
			WHERE billingstudentitemid = <cfqueryparam value="#ARGUMENTS.billingstudentitemid#">
		</cfquery>
	</cffunction>


	<cffunction name="updatestudentbillingprogram" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="program" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET Program = '#ARGUMENTS.program#'
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>

	<cffunction name="updatestudentbillingexitDate" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="exitDate" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET exitDate = <cfif arguments.exitDate EQ "">NULL<cfelse><cfqueryparam value="#DateFormat(arguments.exitDate,'yyyy-mm-dd')#"></cfif>
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>


	<cffunction name="updatestudentbillingstatus" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="billingReviewed" required="yes">
		<cfif arguments.billingReviewed EQ true>
			<cfset billingStatus = 'COMPLETE'>
		<cfelse>
			<cfset billingStatus = 'IN PROGRESS'>
		</cfif>
		<cfquery>
			UPDATE billingStudent
			SET billingStatus = '#billingStatus#'
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>

	<cffunction name="updateStudentBillingNotes" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="billingNotes" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET billingNotes = '#arguments.billingNotes#'
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>

	<cffunction name="updateStudentReviewWithCoachFlag" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="reviewWithCoachFlag" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET reviewWithCoachFlag = '#arguments.reviewWithCoachFlag#'
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>

	<cffunction name="updateStudentIncludeFlag" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="includeFlag" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET includeFlag = '#arguments.includeFlag#'
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>


	<cffunction name="storesessiondata" access="remote" output="false">
		<cfset requestBody = toString( getHttpRequestData().content ) />
		<!--- Double-check to make sure it's a JSON value. --->
		<cfif isJSON( requestBody )>
			<!--- Echo back POST data. --->
			<cfdump var="#deserializeJSON( requestBody )#" label="HTTP Body" />
		<cfelse>
			<cfdump var="xxx" />
		</cfif>
	</cffunction>


	<cffunction name="getNextbillingStudentIdInSession" access="remote" returntype="String" returnformat="json">
		<cfargument name="getNext" type="numeric" value="0">
		<cfargument name="getPrev" type="numeric" val="0">
		<cfargument name="billingStudentId" required="true">
		<cfset debug="false">
		<cfset appObj.logDump(label="arguments", value="#Arguments#", level=3) />
		<cfset appObj.logDump(label="Session.billingStudentList", value="#Session.billingStudentList#", level=3) />
		<cfset list = ListToArray(mid(Session.billingStudentList,1,len(Session.billingStudentList)))>
		<cfset appObj.logDump(label="list", value="#list#", level=3) />
		<cfloop index="i" from="1" to="#arrayLen(list)#">
			<cfset list[i] = #replace(list[i],"""","","all")#>
		</cfloop>
		<cfset appObj.logDump(label="list", value="#list#", level=3) />
		<!---<cfset billingStudentIdList = Session.billingStudentIdList>--->
		<cfloop index="i" from="1" to="#arrayLen(list)#">
			<cfset prev = list[#i#]>
			<cfset next = list[#i#]>
			<cfset appObj.logDump(label="prev", value="#prev#", level=3) />
			<cfset appObj.logDump(label="next", value="#next#", level=3) />
			<cfif list[i] EQ billingStudentId>
				<cfset appObj.logEntry(value="list[#i#] EQ #billingStudentId#", level=3) />
				<cfif #i# GT 1>
					<cfset appObj.logEntry(value="cfif #i# GT 1", level=3) />
					<cfset prev = list[#i# - 1]>
				</cfif>
				<cfif #i# LT #arrayLen(list)#>
					<cfset appObj.logEntry(value="#i# LT #arrayLen(list)#", level=3) />
					<cfset next = list[#i# + 1]>
				</cfif>
				<cfset appObj.logDump(label="i", value="#i#", level=3) />
				<cfset appObj.logDump(label="prev", value="#prev#", level=3) />
				<cfset appObj.logDump(label="next", value="#next#", level=3) />
				<cfbreak />
			</cfif>
		</cfloop>
		<cfif arguments.getNext EQ 1>
			<cfreturn next>
		<cfelse>
			<cfreturn prev>
		</cfif>
		<cfset appObj.logDump(label="Session", value="#Session#", level=3) />
	</cffunction>


	<cffunction name="getReconcileSummary" access="remote" returntype="query">
		<cfquery name="prevTerm">
			SELECT MAX(Term) Term
			FROM billingStudent
			WHERE Term < (SELECT MAX(Term)
						  FROM billingStudent)
		</cfquery>
		<cfquery name="data">
			select keyschooldistrictid districtID, schooldistrict, Program, Term
				,SUM(CASE WHEN BillingStatus = 'BILLED' THEN CREDITS ELSE 0 END) Billed
				,SUM(CASE WHEN BillingStatus != 'BILLED' THEN CREDITS ELSE 0 END)  NotBilled
				,SUM(CASE WHEN BillingStatus = 'BILLED' THEN BilledAmount ELSE 0 END) BilledDollars
				,SUM(CASE WHEN BillingStatus != 'BILLED' THEN BilledAmount ELSE 0 END) NotBilledDollars
			from billingStudent bs
				join billingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
			    join keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
			where term = <cfqueryparam value="#prevTerm.Term#">
			group by schooldistrict, program, term
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="getCurrentTermSummary" access="remote" returntype="query">
		<cfquery name="data">
			SELECT bs.Program, sd.schoolDistrict, bs.term
				,SUM(CASE WHEN bs.BillingStatus = 'IN PROGRESS' THEN 1 ELSE 0 END) StudentsStillBeingReviewed
				,SUM(CASE WHEN bs.BillingStatus != 'COMPLETED' THEN 1 ELSE 0 END) StudentsReviewed
			from billingStudent bs
			    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bs.term = (select max(term) from billingStudent)
			group by bs.Program, sd.schoolDistrict, bs.term
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="getProgramDistrictReconcile" access="remote" returntype="query">
		<cfargument name="term">
		<cfargument name="districtID">
		<cfargument name="program">
		<cfquery name="data" >
			select CONCAT(c.Firstname, ' ', c.Lastname, ' (', c.bannerGNumber, ')') Name
				,sd.schooldistrict SchoolDistrict, transactions.Program
				,transactions.Term, transactions.BillingStatus, transactions.Amount
			from contact c
				join (select contactid, districtID, Program, bs.Term, BillingStatus, SUM(CREDITS) Amount
				 	  from billingStudent bs
						join billingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
				 	  where term = <cfqueryparam value="#arguments.term#">
						and BillingStatus != 'BILLED'
						and districtID = <cfqueryparam value="#arguments.districtID#">
			 	 	  group by contactid, districtID, Program, bs.Term, bs.BillingStatus
				 	  union
				 	  select bs.contactid, bs.districtID, bs.Program, bs.Term, bs.BillingStatus, SUM(CREDITS) Billed
				 	  from billingStudent notBilled
				 	  	join billingStudent bs
				 	  		on notBilled.districtID = <cfqueryparam value="#arguments.districtID#">
				 	  			and notBilled.BillingStatus != 'BILLED'
				 	  			and notBilled.term = <cfqueryparam value="#arguments.term#">
				 	  			and bs.term = <cfqueryparam value="#arguments.term#">
				 	  			and notBilled.contactID = bs.contactID
						join billingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
					  group by contactid, districtID, Program, bs.Term, bs.BillingStatus
				) transactions
					on transactions.contactid = c.contactid
				join keySchoolDistrict sd on transactions.districtid = sd.keyschooldistrictid
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="getProgramDistrictReconcileBackup" access="remote" returntype="query">
		<cfargument name="term">
		<cfargument name="schooldistrict">
		<cfargument name="program">
		<cfquery name="data" datasource="pcclinks">
			select CONCAT(nb.Firstname, ' ', nb.Lastname, ' (', nb.bannerGNumber, ')') Name, nb.schooldistrict SchoolDistrict, nb.Program, nb.Revised, nb.Term
				,billed.SchoolDistrict PriorBilledSchoolDistrict, billed.Program PriorBilledProgram, billed.Billed
			from (select c.contactid, c.Firstname, c.Lastname, c.bannerGNumber, schooldistrict, Program, bs.Term, SUM(CREDITS) Revised
					from billingStudent bs
						join billingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
						join keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
						join contact c on bs.contactid = c.contactid
						where term = <cfqueryparam value="#arguments.term#">
							and BillingStatus != 'BILLED'
						group by c.contactid, c.Firstname, c.Lastname, c.bannerGNumber, schooldistrict, program, term) nb
				left outer join
					(select contactid, schooldistrict, Program, Term, bs.billingstudentid
						,SUM(CREDITS) Billed
					from billingStudent bs
						join billingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
						join keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
					where term = <cfqueryparam value="#arguments.term#">  and BillingStatus = 'BILLED'
					group by contactid, schooldistrict, program
					) billed
				on billed.contactid = nb.contactid
				where (billed.program = <cfqueryparam value="#arguments.program#">  and billed.schooldistrict=<cfqueryparam value="#arguments.schooldistrict#">)
					or (nb.program = <cfqueryparam value="#arguments.program#"> and nb.schooldistrict = <cfqueryparam value="#arguments.schooldistrict#">)
		</cfquery>
		<cfreturn data>
	</cffunction>




	<cffunction name="getAttendanceClassesForMonth" access="remote" returntype="query">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfquery name="data">
			select distinct CRN, SUBJ, CRSE, Title
			from billingStudentItem bsi
				join billingStudent bs on bsi.billingStudentID = bs.billingStudentId
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
			order by CRN, SUBJ, CRSE, Title
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="getClassAttendanceGrid" access="remote">
		<cfargument name="crn" required="true">
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data" >
			select PIDM, bannerGNumber bannerGNumber, crn, crse, subj, title, billingStartDate, attendance
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.BillingStudentId
			where billingStartDate = <cfqueryparam value="#arguments.billingStartDate#">
				and bsi.crn = <cfqueryparam value="#arguments.crn#">
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


	<cffunction name="updateAttendanceDetail" access="remote" returnformat="json">
		<cfargument name="billingStudentItemId" required="true">
		<cfargument name="detailValues" required="true">
		<cfset appObj.logDump(label="arguments", value=#arguments#, level=3)>
		<cfquery name="detailInsert" result="detailResult">
			DELETE
			FROM billingStudentItemDetail
			WHERe billingStudentItemId = <cfqueryparam value=#arguments.billingStudentItemId#>
		</cfquery>
		<cfset attendance = 0>
		<cfset numberOfDays = 0>
		<cfset dv = replace(arguments.detailValues,chr(9)," |^","ALL")>
		<cfset appObj.logDump(label="dv", value=#dv#, level=3)>
		<cfloop index="record" list="#dv#" delimiters="|^">
			<!---<cfset record = REPLACE(record,'\','\\')>--->
			<cfset appObj.logDump(label="record", value="#record#", level=3)>
			<cfquery name="detailInsert" result="detailResult">
				INSERT INTO billingStudentItemDetail(billingStudentItemID, billingStudentItemDetailValue)
				VALUES(#arguments.billingStudentItemId#, <cfqueryparam value="#replace(record,"^","")#">)
			</cfquery>
			<cfif UCASE(record) NEQ "N/A" and UCASE(record) NEQ "HOL">
				<cfset numberOfDays = numberOfDays + 1	>
				<cfif (IsNumeric(record) and record GT 0)
					OR UCase(record) CONTAINS 'X'>
					<cfset attendance = attendance + 1>
				</cfif>
			</cfif>
			<cfset appObj.logEntry(label="numberOfDays", value="#numberOfDays#", level=3)>
			<cfset appObj.logEntry(label="attendance", value="#attendance#", level=3)>
			<cfset appObj.logDump(label="detailResult", value="#detailResult#", level=3)>
		</cfloop>
		<cfquery name="updateItem">
			UPDATE billingStudentItem
			SET attendance = #attendance#
				, maxPossibleAttendance = #numberOfDays#
			WHERE billingStudentItemId = <cfqueryparam value="#arguments.billingStudentItemId#">
		</cfquery>
		<cfset dataset = {"attendance":#attendance#, "numberOfDays":#numberOfDays#}>
		<cfreturn #SerializeJSON(dataset)#>
	</cffunction>


	<cffunction name="getBillingStudentItemDetail" access="remote">
		<cfargument name="billingStudentItemId" required="true">
		<cfquery name="data">
			select *
			from billingStudentItemDetail
			where billingStudentItemID = <cfqueryparam value="#arguments.billingStudentItemId#">
			order by billingStudentItemDetailId
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="updateAttendance" access="remote">
		<cfargument name="billingStudentItemId" required="true">
		<cfargument name="attendance" required="true">
		<cfargument name="maxPossibleAttendance" required="true">
		<cfquery name="update">
			update billingStudentItem
			set attendance = <cfif arguments.attendance EQ "">NULL<cfelse><cfqueryparam value="#arguments.attendance#"></cfif>
				,maxPossibleAttendance = <cfif arguments.maxPossibleAttendance EQ "">NULL<cfelse><cfqueryparam value="#arguments.maxPossibleAttendance#"></cfif>
			where billingStudentItemId = <cfqueryparam value="#arguments.billingStudentItemId#">
		</cfquery>
	</cffunction>


	<cffunction name="getClassAttendanceForMonth" access="remote" returnFormat="json">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="crn" required="true">
		<cfquery name="data" >
			select c.firstName, c.lastName, c.bannerGNumber
				,crn, crse, subj, title
				,bsi.attendance, bsi.billingStudentItemId
				,billingStartDate, bsi.MaxPossibleAttendance
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
	    		join contact c on bs.contactId = c.contactId
	    		join bannerCalendar cal1 on <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#"> between cal1.TermBeginDate and cal1.TermEndDate
	    		join bannerCalendar cal2 on bs.term = cal2.term and cal2.ProgramYear = cal1.ProgramYear
			where bsi.includeFlag = 1
				and bsi.crn = <cfqueryparam value="#arguments.crn#">
				and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			order by c.lastname, c.firstname
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="getAttendanceStudentsForCRN" access="remote" returnFormat="json">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="crn" required="true">
		<cfquery name="data" >
			select distinct c.firstname, c.lastname, c.bannerGNumber, bs.billingStudentId, ifnull(bsi.billingStudentItemId,0) billingStudentItemId, case when isnull(bsi.billingStudentItemID) or bsi.includeFlag = 0 then 0 else 1 end includeFlag
			from contact c
				join billingStudent bs on c.contactID = bs.contactID
				left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
					and bsi.crn = <cfqueryparam value="#arguments.crn#">
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
			order by case when isnull(bsi.billingStudentItemID) or bsi.includeFlag = 0 then 0 else 1 end desc
				, lastname, firstname
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getAttendanceStudentsForBillingStartDate" access="remote" returnFormat="json">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfquery name="data" >
			select distinct c.firstname, c.lastname, c.bannerGNumber, bs.billingStudentId, 0 billingStudentItemId, 0 includeFlag
			from contact c
				join billingStudent bs on c.contactID = bs.contactID
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
			order by lastname, firstname
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="insertScenario" access="remote">
		<cfargument name="billingScenarioName" required="true">
		<cfargument name="indPercent" required="true">
		<cfargument name="smallPercent" required="true">
		<cfargument name="interPercent" required="true">
		<cfargument name="largePercent" required="true">
		<cfquery name="doInsert" >
			insert into billingScenario(billingScenarioName, indPercent, smallPercent, interPercent, largePercent)
			values(<cfqueryparam value="#arguments.billingScenarioName#">,
					<cfqueryparam value="#arguments.indPercent#">,
					<cfqueryparam value="#arguments.smallPercent#">,
					<cfqueryparam value="#arguments.interPercent#">,
					<cfqueryparam value="#arguments.largePercent#">)
		</cfquery>
	</cffunction>
		<cffunction name="saveScenario" access="remote">
		<cfargument name="billingScenarioName" required="true">
		<cfargument name="indPercent" required="true">
		<cfargument name="smallPercent" required="true">
		<cfargument name="interPercent" required="true">
		<cfargument name="largePercent" required="true">
		<cfquery name="save">
			update billingScenario
			set indPercent = <cfqueryparam value="#arguments.indPercent#">,
				smallPercent = <cfqueryparam value="#arguments.smallPercent#">,
				interPercent = <cfqueryparam value="#arguments.interPercent#">,
				largePercent = <cfqueryparam value="#arguments.largePercent#">
			where billingScenarioName = <cfqueryparam value="#arguments.billingScenarioName#">
		</cfquery>
	</cffunction>
	<cffunction name="saveClassScenario" access="remote" >
		<cfargument name="billingScenarioId" required="true">
		<cfargument name="crn" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingScenarioByCourseId">
		<cfquery name="checkIfExists">
			select count(*) cnt
			from billingScenarioByCourse
			where crn = <cfqueryparam value="#arguments.crn#"> and term = <cfqueryparam value="#arguments.term#">
		</cfquery>
		<cfif #checkIfExists.cnt# EQ 0>
			<cfquery name="doInsert" result="insertedItem">
				insert into billingScenarioByCourse(billingScenarioId, crn, term)
				values(<cfqueryparam value="#arguments.billingScenarioId#">, <cfqueryparam value="#arguments.crn#">, <cfqueryparam value="#arguments.term#">)
			</cfquery>
		<cfelse>
			<cfquery name="doUpdate">
				update billingScenarioByCourse
				set billingScenarioId = <cfqueryparam value="#arguments.billingScenarioId#">,
					crn = <cfqueryparam value="#arguments.crn#">,
					term = <cfqueryparam value="#arguments.term#">
				where billingScenarioByCourseId = <cfqueryparam value="#arguments.billingScenarioByCourseId#">
			</cfquery>
		</cfif>
	</cffunction>
	<cffunction name="addStudentToClass" access="remote" returnformat="json" returntype="numeric">
		<cfargument name="billingStudentId" required="true">
		<cfargument name="crn" required="true">
		<cfargument name="billingStudentItemId" default="0">
		<cfif arguments.billingStudentItemId GT 0>
			<cfquery name="updateData" >
				update billingStudentItem
				set  includeFlag = 1
				where billingStudentItemId = <cfqueryparam value="#arguments.billingstudentitemid#">
			</cfquery>
			<cfreturn #arguments.billingstudentitemid#>
		<cfelse>
			<cfquery name="termInfo">
				select term
				from billingStudent
				where billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
			</cfquery>
			<cfquery name="classInfo" datasource="bannerpcclinks">
				select crn, crse, subj, title
				from swvlinks_course
				where crn = <cfqueryparam value="#arguments.crn#">
					and term = <cfqueryparam value="#termInfo.term#">
			</cfquery>
			<cfquery name="insertdata" result="resultBillingStudentItem">
				insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, includeflag, credits, datecreated, datelastupdated, createdby, lastupdatedby)
				values(<cfqueryparam value="#arguments.billingstudentid#">,
						<cfqueryparam value="#arguments.crn#">,
						<cfqueryparam value="#classInfo.crse#">,
						<cfqueryparam value="#classInfo.subj#">,
						<cfqueryparam value="#classInfo.title#">,
						1, 0, current_timestamp, current_timestamp,
						<cfqueryparam value="#Session.username#">,
						<cfqueryparam value="#Session.username#">)
			</cfquery>
			<cfreturn #resultBillingStudentItem.GENERATED_KEY#>
		</cfif>
	</cffunction>
	<cffunction name="insertClass" access="remote" returnformat="json" returntype="numeric">
		<cfargument name="billingStudentId" required="true">
		<cfargument name="crn" required="true">
		<cfargument name="subj" required="true">
		<cfargument name="crse" required="true">
		<cfargument name="title" required="true">
		<cfargument name="billingStudentItemId" default="0">
		<cfif arguments.billingStudentItemId GT 0>
			<cfquery name="updateData" >
				update billingStudentItem
				set  includeFlag = 1
				where billingStudentItemId = <cfqueryparam value="#arguments.billingstudentitemid#">
			</cfquery>
			<cfreturn #arguments.billingstudentitemid#>
		<cfelse>
			<cfquery name="insertdata" result="resultBillingStudentItem">
				insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, includeflag, credits, datecreated, datelastupdated, createdby, lastupdatedby)
				values(<cfqueryparam value="#arguments.billingstudentid#">,
						<cfqueryparam value="#arguments.crn#">,
						<cfqueryparam value="#arguments.crse#">,
						<cfqueryparam value="#arguments.subj#">,
						<cfqueryparam value="#arguments.title#">,
						1, 0, current_timestamp, current_timestamp,
						<cfqueryparam value="#Session.username#">,
						<cfqueryparam value="#Session.username#">)
			</cfquery>
			<cfreturn #resultBillingStudentItem.GENERATED_KEY#>
		</cfif>
	</cffunction>
	<cffunction name="addLab" access="remote" returnformat="plain" returntype="string">
		<cfargument name="crn" required="true">
		<cfargument name="billingStartDate" required="true">
		<cfquery name="termInfo">
			select distinct term
			from billingStudent
			where billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
		</cfquery>
		<cfquery name="classInfo" datasource="bannerpcclinks">
			select crn, crse, subj, title
			from swvlinks_course
			where crn = <cfqueryparam value="#arguments.crn#">
				and term = <cfqueryparam value="#termInfo.term#">
		</cfquery>
		<cfset newCRN = classInfo.crn & '-LAB'>
		<cfquery name="insertdata" result="resultBillingStudentItem">
			insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, includeflag, credits, datecreated, datelastupdated, createdby, lastupdatedby)
			select bs.billingStudentId, <cfqueryparam value="#newCRN#">,
						<cfqueryparam value="#classInfo.crse#">,
						<cfqueryparam value="#classInfo.subj#">,
						<cfqueryparam value="#classInfo.title#">,
						1, 0, current_timestamp, current_timestamp,
						<cfqueryparam value="#Session.username#">,
						<cfqueryparam value="#Session.username#">
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bsi.crn = <cfqueryparam value="#arguments.crn#">
				and bsi.includeFlag = 1
		</cfquery>
		<cfreturn #newCRN#>
	</cffunction>

	<cffunction name="removeItem" access="remote" >
		<cfargument name="billingStudentItemId" required="true">
		<cfquery name="deleteData" >
			update billingStudentItem
			set  includeFlag = 0
			where billingStudentItemId = <cfqueryparam value="#arguments.billingstudentitemid#">
		</cfquery>
	</cffunction>


	<cffunction name="getScenarioCourses" access="remote">
		<cfargument name="term" required="true">
		<cfquery name="data">
			select *
			from (select *
			from billingScenarioByCourse
			where term = <cfqueryparam value="#arguments.term#">
			union
			select null, null, bs.term, bsi.crn
			from billingStudentItem bsi
				join billingStudent bs on bsi.billingStudentId = bs.BillingStudentID
				left outer join billingScenarioByCourse bsbc on bsi.crn = bsbc.crn and bs.term = bsbc.term
			where bs.term = <cfqueryparam value="#arguments.term#">
				and bsbc.crn is null
				and bs.program like '%attendance%'
			) data
			order by crn
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getBillingStudentForYear" access="remote" >
		<cfargument name="contactid" required="true">
		<cfargument name="term" required="true">
		<cfquery name="data">
			select billingStudentId, Term, billingStartDate, program
			from billingStudent
			where term in (select term from bannerCalendar where programyear = (select distinct programYear from bannerCalendar where term = <cfqueryparam value="#arguments.term#">))
				and contactId = <cfqueryparam value="#arguments.contactid#">
			order by term
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getBillingStudentByBillingStartDate" returnformat="json" access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
			select c.firstName, c.lastName, c.bannerGNumber, bs.Program, Date_Format(bs.exitDate,'%m/%d/%y') exitdate
				,er.billingStudentExitReasonDescription, bs.billingStudentId
			from billingStudent bs
				join contact c on bs.contactId = c.contactId
				left join billingStudentExitReason er on bs.billingStudentExitReasonCode = er.billingStudentExitReasonCode
			where billingStartDate =  <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
		</cfquery>
		<cfreturn data>
	</cffunction>


</cfcomponent>
