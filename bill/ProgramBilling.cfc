<cfcomponent displayname="programbilling">

	<cfobject name="appObj" component="application">
	<!---><cffunction name="select" returntype="struct" access="remote">
		<cfargument name="page" type="numeric" required="no" default="1">
		<cfargument name="pageSize" type="numeric" required="no" default="10">
		<cfargument name="gridsortcolumn" type="string" required="no" default="">
		<cfargument name="gridsortdir" type="string" required="no" default="">
		<cfargument name="program" default="YtC Credit">
		<cfargument name="schooldistrict" default="Tigard/Tualatin">
		<cfargument name="term" default="201701">
		<cfset var data = yearlybilling(program=#arguments.program#, term=#arguments.term#, schooldistrict=#arguments.schooldistrict#) >
		<cfreturn QueryConvertForGrid(data,  arguments.page, arguments.pageSize)>
	</cffunction>--->


	<cffunction name="getBillingStudentForYear" returntype="query" access="remote">
		<cfargument name="billingStudentId" required="true">

		<cfquery name="qryInfo">
			select contactId, term, billingStartDate
			from billingStudent
			where billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>

		<!--- make sure all is up to date --->
		<cfstoredproc procedure="spBillingUpdateAttendanceBilling">
			<cfprocparam value="#qryInfo.billingStartDate#" cfsqltype="CF_SQL_DATE">
			<cfprocparam value="#Session.username#" cfsqltype="CF_SQL_STRING">
			<cfprocresult name="qry">
		</cfstoredproc>

		<!--- main query --->
		<cfquery name="data" >
			SELECT res.rsName coach
				,bs.BillingStudentId
				,bs.bannerGNumber
				,bs.PIDM
				,schooldistrict
				,bs.contactId
				,Date_Format(bs.enrolledDate, '%m/%d/%Y') EnrolledDate
				,Date_Format(bs.exitDate, '%m/%d/%Y') ExitDate
				,fnGetBillingStatus(bs.billingStudentId) billingstatus
				,bs.Program
				,bsp.firstname
				,bsp.lastname
				,bs.billingStartDate
				,bs.term
				,bs.includeFlag
				,bs.reviewWithCoachFlag
				,bs.billingNotes
				,bs.reviewNotes
				,SIDNYExitDate.exitDate SIDNYExitDate
			FROM billingStudent bs
				JOIN billingStudentProfile bsp on bs.contactId = bsp.contactId
 				LEFT OUTER JOIN keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
				<!--- GET COACH --->
				LEFT OUTER JOIN (SELECT contactID, max(statusID) statusID
		   			  FROM status
		   			  <!--- coaches status --->
           			  WHERE keyStatusID = 6
						and undoneStatusID is null
          			  GROUP BY contactID) coachLastStatus
			    	ON coachLastStatus.contactID = bs.contactID
				LEFT OUTER JOIN (SELECT sres.statusID, res.rsName
		  			  FROM statusResourceSpecialist sres
						JOIN keyResourceSpecialist res
							ON sres.keyResourceSpecialistID = res.keyResourceSpecialistID) res
					ON coachLastStatus.statusID = res.statusID
				<!--- end get coach --->
				<!---  GET LATEST ENTRY AND EXIT DATES --->
				LEFT OUTER JOIN (SELECT enrolled.contactId, exitDate
					  FROM (select contactId, max(statusDate) enrolledDate
						from status s
						<!--- enrollment statuses --->
						where keyStatusID in (2,13,14,15,16)
							and undoneStatusID is null
						 and contactId = <cfqueryparam value="#qryInfo.contactId#">) enrolled
							left outer join (select contactId, max(statusDate) exitDate
											from status s
											<!--- exit statuses --->
											where keyStatusID in (3,12)
											 and undoneStatusID IS NULL
											 and contactId = <cfqueryparam value="#qryInfo.contactId#">) exited
						<!--- validate that exit date is after enrolled date --->
					  ON enrolledDate < exitDate ) SIDNYExitDate
				 ON SIDNYExitDate.contactId = bs.contactId
			WHERE bs.contactId = <cfqueryparam value="#qryInfo.contactId#">
				and bs.term in (select term from bannerCalendar
									where ProgramYear = (select ProgramYear
															from bannerCalendar
															where term = <cfqueryparam value="#qryInfo.term#">
															))
			ORDER BY BillingStartDate desc
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
				,fnGetBillingStatus(bs.billingStudentId) billingstatus, bs.Program, bs.billingStartDate, bs.term
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
		<cfargument name="program" type="string" default="">
		<cfargument name="programYear" type="string" required="true">
		<cfquery name="data" >
			SELECT res.rsName coach
				,bs.bannerGNumber
				,bsp.firstname
				,bsp.lastname
				,schooldistrict
				,bs.Program
				,Date_Format(bs.exitDate, '%m/%d/%Y') ExitDate
				,bs.term MaxTerm
				,IFNULL(bsi.credits, 0) CurrentTermNoOfCredits
   				,IFNULL(bsiPrev.credits,0) PrevTermNoOfCredits
				,fnGetBillingStatus(bs.billingStudentId) LatestStatus
				,bs.BillingStudentId
			FROM billingStudent bs
				left outer join (select billingStudentId, sum(Credits) credits
						from billingStudentItem
                        group by billingStudentId
					) bsi
					on bs.BillingStudentID = bsi.BillingStudentID
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				join bannerCalendar cal on bs.term = cal.Term
				<!--- DETERMINE PREVIOUS TERM --->
                left outer join bannerCalendar calPrevTerm on cal.ProgramYear = calPrevTerm.ProgramYear
					and calPrevTerm.ProgramQuarter = cal.ProgramQuarter - 1
                left outer join billingStudent bsPrevTerm on bsPrevTerm.contactId = bs.contactId
					and bsPrevTerm.billingStartDate = calPrevTerm.TermBeginDate
				left outer join (select billingStudentId, sum(Credits) credits
						from billingStudentItem
                        group by billingStudentId
					) bsiPrev
					on bsiPrev.BillingStudentID = bsPrevTerm.BillingStudentID
 				JOIN keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
				<!--- DETERMINE COACH --->
				JOIN (SELECT contactID, max(statusID) statusID
		   			  FROM status
           			  WHERE keyStatusID = 6
          			  GROUP BY contactID) coachLastStatus
			    	ON coachLastStatus.contactID = bs.contactID
				JOIN (SELECT sres.statusID, res.rsName
		  			  FROM statusResourceSpecialist sres
						JOIN keyResourceSpecialist res
							ON sres.keyResourceSpecialistID = res.keyResourceSpecialistID) res
					ON coachLastStatus.statusID = res.statusID
			WHERE bs.billingStudentId in (
				SELECT MAX(BillingStudentId) billingStudentId
				FROM billingStudent
				<cfif len(arguments.program) GT 0>
				WHERE
					<cfif arguments.program EQ 'YtC'>
						bs.program like 'YtC%'
					<cfelse>
						bs.program = <cfqueryparam value="#arguments.program#">
					 </cfif>
				</cfif>
				GROUP BY ContactId, Program
			)
		</cfquery>

		<cfreturn data>
	</cffunction>

	<cffunction name="getTranscriptStudentList" returntype="query" returnformat="json" access="remote">
		<cfargument name="term" required = "true">
		<cfquery name="data" >
			SELECT bsp.firstname
				,bsp.lastname
				,bs.bannerGNumber
				,schooldistrict
				,program
				,res.rsName coach
				,bs.billingStudentId
				,IFNULL(CreditsEntered,0) CreditsEntered
				,bs.pidm
			FROM billingStudent bs
				JOIN billingStudentProfile bsp on bs.contactId = bsp.contactId
				JOIN keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
				JOIN (SELECT contactID, max(statusID) statusID
		   			  FROM status
           			  WHERE keyStatusID = 6
          			  GROUP BY contactID) coachLastStatus
			    	ON coachLastStatus.contactID = bs.contactID
				JOIN (SELECT sres.statusID, res.rsName
		  			  FROM statusResourceSpecialist sres
						JOIN keyResourceSpecialist res
							ON sres.keyResourceSpecialistID = res.keyResourceSpecialistID) res
					ON coachLastStatus.statusID = res.statusID
			WHERE bs.term = <cfqueryparam value="#arguments.term#">
				and program not like '%attendance%'
				and COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) != 0
		</cfquery>
		<cfreturn data>
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
			select bs.billingStudentId, bs.pidm, bs.Program, bs.Term, fnGetBillingStatus(bs.billingStudentId) billingstatus
				,bsi.billingStudentItemId, bsi.TakenPreviousTerm, bsi.IncludeFlag, bsi.CRN, bsi.Subj, bsi.CRSE, bsi.Title, bsi.Credits
				,sum(bsiAttend.Attendance) AttendanceToDate, 1 inBilling, 0 inBanner
			from billingStudentItem bsi
				join billingStudent bs on bsi.BillingStudentId=bs.BillingStudentId
				join billingStudent bsAttend on bs.contactId = bsAttend.contactID
					and bs.billingStartDate <= bsAttend.billingStartDate
				join bannerCalendar cal on bs.term = cal.term
					and bsAttend.billingStartDate between cal.termbegindate and cal.termEndDate
				join billingStudentItem bsiAttend on bsAttend.billingStudentId = bsiAttend.billingStudentId
					and bsi.CRN = bsiAttend.CRN
			where bs.billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
            group by bs.billingStudentId, bs.pidm, bs.Program, bs.Term, fnGetBillingStatus(bs.billingStudentId),
				bsi.TakenPreviousTerm, bsi.IncludeFlag,
				bsi.CRN, bsi.Subj, bsi.Title, bsi.Credits
		</cfquery>

		<cfset local.inList =  ValueList(data.crn,",")>
		<cfquery name="banner" datasource="bannerpcclinks" >
			select distinct Term, CRN, Subj, CRSE, Title, Credits
			from swvlinks_course
			where pidm = <cfqueryparam value="#data.pidm#">
				and term = <cfqueryparam value="#data.term#">
		</cfquery>
		<cfquery name="notinbilling" dbtype="query">
			select *
			from banner
			where crn not in (<cfqueryparam value="#local.inList#" list="yes" cfsqltype="String">)
		</cfquery>
		<cfoutput query="notinbilling">
			<cfset QueryAddRow(data)>
			<cfset QuerySetCell(data, "billingStatus", "Missing from Billing System, recently added in Banner")>
			<cfset QuerySetCell(data, "Term", term)>
			<cfset QuerySetCell(data, "CRN", crn)>
			<cfset QuerySetCell(data, "Subj", subj)>
			<cfset QuerySetCell(data, "CRSE", crse)>
			<cfset QuerySetCell(data, "Title", title)>
			<cfset QuerySetCell(data, "Credits", credits)>
			<cfset QuerySetCell(data, "inBilling", 0)>
			<cfset QuerySetCell(data, "inBanner", 1)>
		</cfoutput>
		<cfset local.inList =  ValueList(banner.crn,",")>
		<cfset rownum = 1>
		<cfoutput query="data">
			<cfif ListContains(local.inList, crn)>
				<cfset QuerySetCell(data, "inBanner", 1, rownum)>
			</cfif>
			<cfset rownum = rownum+1>
		</cfoutput>
		<cfreturn data>
	</cffunction>

	<cffunction name="selectBannerClassesFromSession" access="remote" returnType="query" returnformat="JSON">
		<cfset dataSrc = selectBannerClasses(pidm: Session.qryStudent.pidm
							,maxterm:Session.qryStudent.Term
							,contactId: Session.qryStudent.contactId)>
		<cfquery name="data" dbtype="query">
			select ProgramYear, Term, CRSE, SUBJ, Title, Credits, Grade, TakenPreviousTerm, IncludeFlag, billingStudentItemId, IsTermBilling
			from dataSrc
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="selectBannerClasses" access="remote" returnType="query" >
		<cfargument name="pidm" required="yes">
		<cfargument name="contactId" required="yes">
		<cfquery name="bannerclasses" datasource="bannerpcclinks" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#" >
			select distinct PIDM, STU_ID, TERM, CRN, LEVL, SUBJ, CRSE, TITLE, CREDITS, GRADE, PASSED
			from swvlinks_course
			where pidm = <cfqueryparam value="#arguments.pidm#">
		</cfquery>
		<cfquery name="billedclasses" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#" >
			select TERM, CRN, SUBJ, CRSE, TITLE, CREDITS, bsi.IncludeFlag, takenpreviousterm, bsi.billingStudentItemId, CASE WHEN bs.Program like '%Attendance%' THEN 0 ELSE 1 END IsTermBilling
			from billingStudentItem bsi
				join billingStudent bs on bsi.billingStudentID = bs.billingStudentId
			where bs.contactid = <cfqueryparam value="#arguments.contactid#">
		</cfquery>
		<cfquery dbtype="query" name="combined" >
			select CAST(TERM as INTEGER) TERM, CAST(CRN as VARCHAR) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, TITLE, CAST(CREDITS as INTEGER) CREDITS, LEVL, GRADE, PASSED, -1 as IncludeFlag, '' as TakenPreviousTerm, 0 as billingStudentItemId, -1 as IsTermBilling
			from bannerclasses
			union
			select CAST(TERM as INTEGER) TERM, CAST(CRN as VARCHAR) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, TITLE, CAST(CREDITS as INTEGER), '' as LVL, '' AS Grade, '' AS Passed, IncludeFlag, CAST(takenpreviousterm as VARCHAR), billingStudentItemId, IsTermBilling
			from billedclasses
		</cfquery>
		<cfquery name="calendar" cachedWithin="#createTimeSpan( 0, 1, 0, 0 )#" >
			SELECT ProgramYear, term
				,CASE WHEN ProgramQuarter = 1 THEN 'Summer'
					WHEN ProgramQuarter = 2 THEN 'Fall'
					WHEN ProgramQuarter = 3 THEN 'Winter'
					WHEN ProgramQuarter = 4 THEN 'Spring'
				END TermDescription
			FROM sidny.bannerCalendar
		</cfquery>
		<cfquery dbtype="query" name="final"  >
			select calendar.ProgramYear, calendar.TermDescription, combined.TERM, CRN, SUBJ, CRSE, TITLE, CREDITS
				, MAX(LEVL) LEVL, MAX(GRADE) Grade, MAX(PASSED) Passed, MAX(IncludeFlag) IncludeFlag, MAX(TakenPreviousTerm) TakenPreviousTerm
				, MAX(billingStudentItemId) billingStudentItemId, MAX(IsTermBilling) IsTermBilling
			from combined, calendar
			where CAST(combined.Term AS VARCHAR) = CAST(calendar.Term AS VARCHAR)
			group by calendar.ProgramYear, calendar.TermDescription, combined.TERM, CRN, SUBJ, CRSE, TITLE, CREDITS
		</cfquery>
		<cfreturn final>
	</cffunction>

	<cffunction name="updateStudentBillingItemInclude" access="remote">
		<cfargument name="billingstudentitemid" required="yes">
		<cfargument name="includeflag" required="yes">
		<cfquery>
			UPDATE billingStudentItem
			SET IncludeFlag = '#ARGUMENTS.includeflag#',
				lastUpdatedBy=<cfqueryparam value=#Session.username#>,
				dateLastUpdated=current_timestamp
			WHERE billingstudentitemid = <cfqueryparam value="#ARGUMENTS.billingstudentitemid#">
		</cfquery>
	</cffunction>

	<cffunction name="updateStudentBillingProgram" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="program" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET Program = '#ARGUMENTS.program#',
				lastUpdatedBy=<cfqueryparam value=#Session.username#>,
				dateLastUpdated=current_timestamp
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>

	<cffunction name="updateStudentBillingExitDate" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="exitDate" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET exitDate = <cfif arguments.exitDate EQ "">NULL<cfelse><cfqueryparam value="#DateFormat(arguments.exitDate,'yyyy-mm-dd')#"></cfif>,
				lastUpdatedBy=<cfqueryparam value=#Session.username#>,
				dateLastUpdated=current_timestamp
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>


	<cffunction name="updateStudentBillingStatus" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="billingStatus" required="yes">

		<cfquery>
			UPDATE billingStudent
			SET billingStatus = <cfqueryparam value="#arguments.billingStatus#">,
				lastUpdatedBy=<cfqueryparam value=#Session.username#>,
				dateLastUpdated=current_timestamp
			WHERE billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
		</cfquery>
	</cffunction>

	<cffunction name="updateStudentReviewWithCoachFlag" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="reviewWithCoachFlag" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET reviewWithCoachFlag = '#arguments.reviewWithCoachFlag#',
				lastUpdatedBy=<cfqueryparam value=#Session.username#>,
				dateLastUpdated=current_timestamp
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>

	<cffunction name="updateStudentIncludeFlag" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="includeFlag" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET includeFlag = '#arguments.includeFlag#',
				lastUpdatedBy=<cfqueryparam value=#Session.username#>,
				dateLastUpdated=current_timestamp
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>
	<cffunction name="updateStudentReviewNotes" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="reviewNotes" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET reviewNotes = '#arguments.reviewNotes#',
				lastUpdatedBy=<cfqueryparam value=#Session.username#>,
				dateLastUpdated=current_timestamp
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>


	<cffunction name="getCurrentTermSummary" access="remote" returntype="query">
		<cfquery name="data">
			SELECT bs.Program, sd.schoolDistrict, bs.term
				,SUM(CASE WHEN bs.BillingStatus = 'IN PROGRESS' THEN 1 ELSE 0 END) StudentsStillBeingReviewed
				,SUM(CASE WHEN bs.BillingStatus = 'REVIEWED' THEN 1 ELSE 0 END) StudentsReviewed
			from billingStudent bs
			    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bs.term = (select max(term) from billingStudent)
			group by bs.Program, sd.schoolDistrict, bs.term
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getAttendanceClassesForMonth" access="remote" returntype="query" >
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
				,maxPossibleAttendance = #numberOfDays#
				,lastUpdatedBy=<cfqueryparam value=#Session.username#>
				,dateLastUpdated=current_timestamp
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
		<cfargument name="notes" required="true">
		<cfquery name="update">
			update billingStudentItem
			set attendance = <cfif arguments.attendance EQ "">NULL<cfelse><cfqueryparam value="#arguments.attendance#"></cfif>
				,maxPossibleAttendance = <cfif arguments.maxPossibleAttendance EQ "">NULL<cfelse><cfqueryparam value="#arguments.maxPossibleAttendance#"></cfif>
				,billingStudentItemNotes = <cfqueryparam value="#arguments.notes#">
				,lastUpdatedBy=<cfqueryparam value=#Session.username#>
				,dateLastUpdated=current_timestamp
			where billingStudentItemId = <cfqueryparam value="#arguments.billingStudentItemId#">
		</cfquery>
	</cffunction>


	<cffunction name="getClassAttendanceForMonth" access="remote" returnFormat="JSON"  >
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="crn" required="true">
		<cfquery name="classAttendanceForMonth">
			select bsp.firstName, bsp.lastName, bs.bannerGNumber, bs.exitDate
				,crn, crse, subj, title
				,bsi.attendance, bsi.billingStudentItemId, bs.billingStudentId
				,billingStartDate, bsi.MaxPossibleAttendance, bsi.billingStudentItemNotes
			from billingStudent bs
				JOIN billingStudentProfile bsp on bs.contactId = bsp.contactId
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			where bsi.crn = <cfqueryparam value="#arguments.crn#">
				and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bsi.includeFlag = 1
			order by bsp.lastname, bsp.firstname
		</cfquery>
		<cfreturn classAttendanceForMonth>
	</cffunction>

	<cffunction name="getBannerClassForTerm" access="remote" returnFormat="json">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="crn" required="true">
		<cfif IsNumeric(arguments.crn)>
			<cfquery name="term">
				select min(term) Term
				from bannerCalendar
				where <cfqueryparam value="#DateFormat(arguments.billingStartDate, 'yyyy-mm-dd')#"> between termBeginDate and termEndDate
			</cfquery>
			<cfquery name="data" datasource="bannerpcclinks" cachedWithin="#createTimeSpan(0,1,0,0)#">
				select distinct crn, stu_id
				from swvlinks_course
				where crn = <cfqueryparam value="#arguments.crn#">
					and term = <cfqueryparam value="#term.Term#">
			</cfquery>
			<cfreturn data>
		<cfelse>
			<cfreturn QueryNew("crn, stu_id")>
		</cfif>
	</cffunction>

	<cffunction name="getAttendanceStudentsForCRN" access="remote" returnFormat="json">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="crn" required="true">
		<cfquery name="data" >
			select distinct bsp.firstname, bsp.lastname, bs.bannerGNumber, bs.billingStudentId, ifnull(bsi.billingStudentItemId,0) billingStudentItemId, case when isnull(bsi.billingStudentItemID) or bsi.includeFlag = 0 then 0 else 1 end includeFlag
			from billingStudent bs
				JOIN billingStudentProfile bsp on bs.contactId = bsp.contactId
				left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
					and bsi.crn = <cfqueryparam value="#arguments.crn#">
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
			order by case when isnull(bsi.billingStudentItemID) or bsi.includeFlag = 0 then 0 else 1 end desc
				, lastname, firstname
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getStudentsForBillingStartDate" access="remote" returnFormat="json">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfquery name="data" >
			select distinct bsp.firstname, bsp.lastname, bs.bannerGNumber, bs.billingStudentId, 0 billingStudentItemId, 0 includeFlag
			from billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
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
			set indPercent = <cfif len(arguments.indPercent) EQ 0>0<cfelse><cfqueryparam value="#arguments.indPercent#"></cfif>,
				smallPercent = <cfif len(arguments.smallPercent) EQ 0>0<cfelse><cfqueryparam value="#arguments.smallPercent#"></cfif>,
				interPercent = <cfif len(arguments.interPercent) EQ 0>0<cfelse><cfqueryparam value="#arguments.interPercent#"></cfif>,
				largePercent = <cfif len(arguments.largePercent) EQ 0>0<cfelse><cfqueryparam value="#arguments.largePercent#"></cfif>
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
		<cfif checkIfExists.cnt EQ 0 AND arguments.billingScenarioId NEQ "">
			<cfquery name="doInsert" result="insertedItem">
				insert into billingScenarioByCourse(billingScenarioId, crn, term)
				values(<cfqueryparam value="#arguments.billingScenarioId#">, <cfqueryparam value="#arguments.crn#">, <cfqueryparam value="#arguments.term#">)
			</cfquery>
		<cfelse>
			<cfif arguments.billingScenarioId EQ "">
				<cfquery name="doDelete">
					delete from billingScenarioByCourse
					where crn = <cfqueryparam value="#arguments.crn#">
						and term = <cfqueryparam value="#arguments.term#">
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
				,lastUpdatedBy=<cfqueryparam value=#Session.username#>
				,dateLastUpdated=current_timestamp
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
				,lastUpdatedBy=<cfqueryparam value=#Session.username#>
				,dateLastUpdated=current_timestamp
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

	<cffunction name="setBillingStudentItemInactive" access="remote" >
		<cfargument name="billingStudentItemId" required="true">
		<cfquery name="deleteData" >
			update billingStudentItem
			set  includeFlag = 0
				,lastUpdatedBy=<cfqueryparam value=#Session.username#>
				,dateLastUpdated=current_timestamp
			where billingStudentItemId = <cfqueryparam value="#arguments.billingstudentitemid#">
		</cfquery>
	</cffunction>

	<cffunction name="getScenarioCourses" access="remote">
		<cfargument name="term" required="true">
		<cfquery name="data">
			select *
			from (select bsbc1.billingScenarioByCourseId, bsbc1.billingScenarioId, bsbc1.Term, bsbc1.CRN, bsData.CRSE, bsData.SUBJ, bsData.Title
			from billingScenarioByCourse bsbc1
				join (select distinct crn, CRSE, SUBJ, Title
					  from billingStudentItem bsi
						join billingStudent bs on bsi.billingStudentId = bs.BillingStudentID
						where bs.term = <cfqueryparam value="#arguments.term#">
					) bsData on bsbc1.crn = bsData.crn
			where bsbc1.term = <cfqueryparam value="#arguments.term#">
			union
			select null, null, bs.term, bsi.crn, bsi.CRSE, bsi.SUBJ, bsi.Title
			from billingStudentItem bsi
				join billingStudent bs on bsi.billingStudentId = bs.BillingStudentID
				left outer join billingScenarioByCourse bsbc on bsi.crn = bsbc.crn and bs.term = bsbc.term
			where bs.term = <cfqueryparam value="#arguments.term#">
				and bsbc.crn is null
				and bs.program like '%attendance%'
			) data
			order by SUBJ, CRSE
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getBillingStudentByBillingStartDate" returnformat="json" access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
			select bsp.firstName, bsp.lastName, bs.bannerGNumber, bs.Program, Date_Format(bs.exitDate,'%m/%d/%Y') exitdate
				,er.billingStudentExitReasonDescription, bs.billingStudentId
			from billingStudent bs
				JOIN billingStudentProfile bsp on bs.contactId = bsp.contactId
				left join billingStudentExitReason er on bs.billingStudentExitReasonCode = er.billingStudentExitReasonCode
			where billingStartDate =  <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getExitDateList" returnformat="json" access="remote">
		<cfstoredproc procedure="spUpdateBillingStudentExitData" >
			<cfprocparam value="0" cfsqltype="CF_SQL_STRING">
			<cfprocresult name="data">
		</cfstoredproc>

		<cfreturn data>
	</cffunction>


	<cffunction name="getTranscriptTerms" access="remote" >
		<cfargument name="bannerGNumber" required="true">
		<cfquery name="data">
			select distinct term, pidm, contactId
			from billingStudent
			where bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
			order by term desc
		</cfquery>
		<!---><cfquery name="bannerclasses" datasource="bannerpcclinks">
			select distinct <cfqueryparam value="#bs.contactId#"> contactId, pidm, term
			from swvlinks_course
			where pidm = <cfqueryparam value="#bs.pidm#">
		</cfquery>
		<cfquery name="data1" dbtype="query">
			select CAST(contactId as INTEGER) contactId, CAST(pidm AS INTEGER) pidm, CAST(term as INTEGER) term
			from bs
			union
			select CAST(contactId as INTEGER) contactId, CAST(pidm AS INTEGER) pidm, CAST(term as INTEGER) term
			from bannerclasses
		</cfquery>
		<cfquery name="data" dbtype="query">
			select distinct contactId, pidm, term
			from data1
			order by term desc
		</cfquery>--->
		<cfreturn data>
	</cffunction>

	<cffunction name="getBannerClassesForStudent" access="remote" returnType="query">
		<cfargument name="pidm" required="yes">
		<cfquery name="banner" datasource="bannerpcclinks">
			select TERM, CRN, SUBJ, CRSE, TITLE, CREDITS, GRADE, PASSED, '' takenPreviousTerm
			from swvlinks_course
			where pidm = <cfqueryparam value="#arguments.pidm#">
		</cfquery>
		<cfquery name="bs" >
			select TERM, CRN, SUBJ, CRSE, TITLE, CREDITS, '' GRADE, '' PASSED, takenPreviousTerm
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			where pidm = <cfqueryparam value="#arguments.pidm#">
		</cfquery>
		<cfquery name="data1" dbtype="query">
			select CAST(TERM AS INTEGER) TERM, CRN, SUBJ, CRSE, TITLE, CREDITS, GRADE, PASSED, CAST(takenPreviousTerm AS VARCHAR) takenPreviousTerm
			from banner
			union select CAST(TERM AS INTEGER), CRN, SUBJ, CRSE, TITLE, CREDITS, GRADE, PASSED, CAST(takenPreviousTerm AS VARCHAR) takenPreviousTerm
			from bs
		</cfquery>
		<cfquery name="calendar">
			SELECT ProgramYear, term
				,CASE WHEN ProgramQuarter = 1 THEN 'Summer'
					WHEN ProgramQuarter = 2 THEN 'Fall'
					WHEN ProgramQuarter = 3 THEN 'Winter'
					WHEN ProgramQuarter = 4 THEN 'Spring'
				END TermDescription
			FROM sidny.bannerCalendar
		</cfquery>
		<cfquery name="data" dbtype="query">
			select data1.TERM, CRN, SUBJ, CRSE, TITLE, CREDITS, ProgramYear, TermDescription, MAX(GRADE) Grade, MAX(PASSED) Passed, MAX(takenPreviousTerm) TakenPreviousTerm
			from data1, calendar
			where CAST(data1.Term AS VARCHAR) = CAST(calendar.Term AS VARCHAR)
			group by data1.TERM, CRN, SUBJ, CRSE, TITLE, CREDITS, ProgramYear, TermDescription
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getbillingStudentProfile"  returntype="query" access="remote">
		<cfargument name="contactId" required="true">
		<cfquery name ="data">
			select *
			from billingStudentProfile
			where contactid = <cfqueryparam value="#arguments.contactId#">
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="updateBillingStudentProfile" access="remote">
		<cfargument name="contactId" required="true">
		<cfargument name="firstName" required="true">
		<cfargument name="lastName" required="true">
		<cfargument name="dob" required="true">
		<cfargument name="gender" required="true">
		<cfargument name="ethnicity" required="true">
		<cfargument name="address" required="true">
		<cfargument name="city" required="true">
		<cfargument name="state" required="true">
		<cfargument name="zip" required="true">

		<cfquery name="update">
			update billingStudentProfile
			set firstname = <cfqueryparam value="#arguments.firstname#">,
				lastName = <cfqueryparam value="#arguments.lastName#">,
				dob = <cfqueryparam value="#DateFormat(arguments.dob,'yyyy-mm-dd')#">,
				gender = <cfqueryparam value="#arguments.gender#">,
				ethnicity = <cfqueryparam value="#arguments.ethnicity#">,
				address = <cfqueryparam value="#arguments.address#">,
				city = <cfqueryparam value="#arguments.city#">,
				state = <cfqueryparam value="#arguments.state#">,
				zip = <cfqueryparam value="#arguments.zip#">
			where contactId = <cfqueryparam value="#arguments.contactid#">
		</cfquery>
	</cffunction>

	<cffunction name="getStudentForCRNAndTerm" returntype="query" access="remote">
		<cfargument name="crn" required="true">
		<cfargument name="term" required="true">
		<cfquery name="data">
			select distinct firstname, lastname
			from billingStudentProfile bp
				join billingStudent bs on bp.contactid = bs.contactid
			    join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			where bs.term = <cfqueryparam value="#arguments.term#">
			and bsi.crn = <cfqueryparam value="#arguments.crn#">
			order by firstname, lastname
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="updateStudentBillingCreditEntered" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="value" required="yes">
		<cfquery>
			UPDATE billingStudent
			SET CreditsEntered = '#ARGUMENTS.value#',
				lastUpdatedBy=<cfqueryparam value=#Session.username#>,
				dateLastUpdated=current_timestamp
			WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.billingstudentid#">
		</cfquery>
	</cffunction>
	<cffunction name="getStudentsMissingFromCRN" access="remote" returntype="String" returnformat="plain">
		<cfargument name="crn" required="true">
		<cfargument name="billingStartDate" required="true">

		<cfset classdata = getClassAttendanceForMonth(arguments.billingStartDate, arguments.crn)>
		<cfset bannerdata = getBannerClassForTerm(arguments.billingStartDate, arguments.crn)>

		<cfset html = "">
		<cfset finalHtml = "">
		<!--- Generate a list of students that are registered in Banner but not in the biling system --->
		<cfset inList =  valueList(classdata.bannerGNumber,",")>
		<cfquery name="bannermissing" dbtype="query">
			select *
			from bannerdata
			where stu_id NOT IN (<cfqueryparam value="#inList#" list="yes" cfsqltype="String">)
		</cfquery>
		<cfif bannermissing.recordcount GT 0>
			<cfoutput query="bannermissing" >
				<cfstoredproc procedure="spGetCurrentExitDate" >
					<cfprocparam cfsqltype="CF_SQL_INTEGER" value="0">
					<cfprocparam cfsqltype="cf_SQL_VARCHAR" value="#stu_id#">
					<cfprocresult name="student">
				</cfstoredproc>
				<cfif student.exitDate EQ '' OR DateDiff('d', student.exitDate, Now()) LT 45>
					<cfsavecontent variable="missingHtml">
						<li>Student #student.firstname# #student.lastname# (#student.bannerGNumber#) <cfif student.exitdate NEQ ''>Exit Date: #DateFormat(student.exitDate,'m/d/yyyy')# </cfif>missing from class.  <a href="javascript:addMissingBannerStudent('#stu_id#');">Add Student</a></li>
					</cfsavecontent>
					<cfset html = html & missingHtml>
				</cfif>
			</cfoutput>
			<cfif html NEQ ''>
			<cfsavecontent variable="finalHtml">
				<b><span style="color:red">Students Missing from Billing</span></b>
				<ul>
					<cfoutput>#html#</cfoutput>
				</ul>
			</cfsavecontent>
			</cfif>
		</cfif>
		<cfreturn finalHtml>
	</cffunction>

	<cffunction name="getBillingStudentByContactId" access="remote" returnformat="JSON">
		<cfargument name="contactId" required=true>
		<cfargument name="programYear" required=true>
		<cfquery name="data">
			select contactId
				,billingStudentId
				,date_format(billingStartDate,'%Y-%m-%d') billingStartDate
				,date_format(exitDate,'%Y-%m-%d') exitDate
				,BillingStudentExitReasonCode
				,adjustedDaysPerMonth
				,date_format(billingEndDate,'%Y-%m-%d') billingEndDate
				,includeFlag
				,program
			from billingStudent
			where contactId = <cfqueryparam value="#arguments.contactId#">
				and term in (select term from bannerCalendar where ProgramYear = <cfqueryparam value="#arguments.programYear#">)
			order by billingStartDate desc
		</cfquery>
		<cfreturn data>
	</cffunction>

</cfcomponent>
