<cfcomponent displayname="report">
	<cfobject name="appObj" component="application">

	<cffunction name="calculateBilling" access="remote">
		<cfargument name="billingType" required= true>
		<cfargument name = "term">
		<cfargument name = "billingStartDate">

		<cfif arguments.billingType EQ 'Term'>
			<cfset generateTermBilling(arguments.Term)>
		<cfelse>
			<cfset generateAttendanceBilling(arguments.billingStartDate)>
		</cfif>
	</cffunction>
	<cffunction name="generateTermBilling">
		<cfargument name="term">

		<cfstoredproc procedure="spBillingGenerateTermBilling">
			<cfprocparam value="#arguments.term#" cfsqltype="CF_SQL_INTEGER">
			<cfprocparam value="#Session.username#" cfsqltype="CF_SQL_STRING">
			<cfprocresult name="qry">
		</cfstoredproc>
	</cffunction>
	<cffunction name="termReport" returntype="query" access="remote">
		<!--- arguments --->
		<cfargument name="programYear" required = "true">
		<cfargument name="program" default="">
		<cfargument name="schooldistrict" default="">

		<cfquery name="data" >
			SELECT firstname, lastname, bannergnumber
				,Program
				,schoolDistrict
                ,OtherDaysBilled
				,Date_Format(EntryDate, '%m/%d/%Y') EntryDate
				,Date_Format(billingStartDate, '%m/%d/%Y') billingStartDate
				,Date_Format(billingEndDate, '%m/%d/%Y') billingEndDate
				,Date_Format(ExitDate, '%m/%d/%Y') ExitDate
				,SummerCredits SummerNoOfCredits
				,SummerDays SummerNoOfDays
				,FallCredits FallNoOfCredits
				,FallCreditsOverage FallNoOfCreditsOver
				,FallDays FallNoOfDays
				,FallDaysOverage FallNoOfDaysOver
				,WinterCredits WinterNoOfCredits
				,WinterCreditsOverage WinterNoOfCreditsOver
				,WinterDays WinterNoOfDays
				,WinterDaysOverage WinterNoOfDaysOver
				,SpringCredits SpringNoOfCredits
				,SpringCreditsOverage SpringNoOfCreditsOver
				,SpringDays SpringNoOfDays
				,SpringDaysOverage SpringNoOfDaysOver
				,bs.billingStudentId BillingStudentIdMostCurrent
				,FYTotalNoOfCredits
				,FYMaxTotalNoOfCredits
				,FYTotalNoOfDays
				,FYMaxTotalNoOfDays
			FROM billingCycle bc
				join billingReport br on bc.LatestBillingReportID = br.billingReportId
				join billingReportTerm brt
					on br.billingReportId = brt.billingReportId
				join (select contactID, max(billingStudentId) billingStudentID from billingStudent group by contactID) bs
					on brt.contactID = bs.contactID
			WHERE FYTotalNoOfCredits <> 0
                and program = <cfqueryparam value="#arguments.program#">
                and schoolDistrict = <cfqueryparam value="#arguments.schooldistrict#">
				and bc.programYear = <cfqueryparam value="#programYear#">
			ORDER BY lastname, firstname, billingStartDate
		</cfquery>
		<cfset list = "">
		<cfloop query="data">
			 <cfset list = listAppend(list, billingStudentIdMostCurrent,",")>
		</cfloop>
		<cfset Session.billingstudentlist = list>
		<cfset Session.reportTermData = data>
		<cfset appObj.logDump(label="billingstudentlist", value="#list#", level=3)>
		<cfset appObj.logDump(label="Session.billingstudentlist", value="#Session.billingstudentlist#", level=3)>
		<cfreturn data>
	</cffunction>

	<cffunction name="generateAttendanceBilling">
		<cfargument name="billingStartDate">

		<cfstoredproc procedure="spBillingGenerateAttendanceBilling">
			<cfprocparam value="#arguments.billingStartDate#" cfsqltype="CF_SQL_DATE">
			<cfprocparam value="#Session.username#" cfsqltype="CF_SQL_STRING">
			<cfprocresult name="qry">
		</cfstoredproc>
	</cffunction>

	<cffunction name="attendanceReport" access="remote">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="programYear" required="true">
		<cfargument name="program" required="true">
		<cfargument name="schooldistrict" required="true">

		<cfquery name="data">
			select concat(bsp.lastname,', ',bsp.firstname) name
				,bsp.bannerGNumber
				,DATE_FORMAT(dob,'%m/%d/%Y') dob
				,DATE_FORMAT(exitdate,'%m/%d/%Y') exitDate
				,DATE_FORMAT(entryDate,'%m/%d/%Y') enrolledDate
				,DATE_FORMAT(billingStartDate, '%m/%d/%Y') ReportStartDate
				,DATE_FORMAT(LAST_DAY(billingEndDate), '%m/%d/%Y') ReportEndDate
				,ROUND(TotalEnrollment,1)  Enrl
				,schooldistrict
				,program
				,ROUND(June,1) Jun
				,ROUND(July,1) Jul
				,ROUND(August,1) Aug
				,ROUND(September,1) Sept
				,ROUND(October,1) Oct
				,ROUND(November,1) Nov
				,ROUND(December,1) Dcm
				,ROUND(January,1) Jan
				,ROUND(February,1) Feb
				,ROUND(March,1) Mar
				,ROUND(April,1) Apr
				,ROUND(May,1) May
				,ROUND(TotalAttendance,1) Attnd,
				bs.billingStudentId billingStudentIdMostCurrent
			FROM billingCycle bc
				join billingReport br on bc.LatestBillingReportID = br.billingReportId
				join billingReportAttendance bra
					on br.billingReportId = bra.billingReportId
				join billingStudentProfile bsp on bra.contactId = bsp.contactID
				join (select contactID, max(billingStudentId) billingStudentID from billingStudent group by contactID) bs
					on bra.contactID = bs.contactID
			WHERE program = <cfqueryparam value="#arguments.program#">
                and schoolDistrict = <cfqueryparam value="#arguments.schooldistrict#">
				and bc.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			ORDER BY bsp.lastname, bsp.firstname, bc.billingStartDate
		</cfquery>

		<cfset Session.reportAttendanceData = data>
		<cfreturn data>
	</cffunction>



	<cffunction name="closeBillingCycle" access="remote">
		<cfargument name="term" >
		<cfargument name="billingStartDate" >
		<cfargument name="billingType" required="true">
		<cfquery name="update">
			UPDATE billingCycle
			SET BillingCloseDate = now(), dateLastUpdated = now(), lastUpdatedBy = '#Session.username#', ClosingBillingReportID = LatestBillingReportID
			WHERE billingType = <cfqueryparam value="#arguments.billingType#">
				<cfif arguments.billingType EQ 'Term'>
				AND Term = <cfqueryparam value="#arguments.term#">
				<cfelse>
				AND billingStartDate = <cfqueryparam value="#arguments.billingStartDate#">
				</cfif>
		</cfquery>
	</cffunction>

	<cffunction name="openBillingCycle" access="remote">
		<cfargument name="term" >
		<cfargument name="billingStartDate" >
		<cfargument name="billingType" required="true">
		<cfquery name="update">
			UPDATE billingCycle
			SET BillingCloseDate = NULL, ClosingBillingReportID=NULL, dateLastUpdated = now(), lastUpdatedBy = '#Session.username#'
			WHERE billingType = <cfqueryparam value="#arguments.billingType#">
				<cfif arguments.billingType EQ 'Term'>
				AND Term = <cfqueryparam value="#arguments.term#">
				<cfelse>
				AND billingStartDate = <cfqueryparam value="#arguments.billingStartDate#">
				</cfif>
		</cfquery>
	</cffunction>

	<cffunction name="getBillingStudentRecord" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfquery name="data">
			select bs.*, bsp.firstname, bsp.lastname, sd.schooldistrict
			from billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				join keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
			where billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="updatebillingStudentRecord" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfargument name="billingStudentExitReasonCode" default="">
		<cfargument name="exitDate" default="">
		<cfargument name="program" default="">
		<cfargument name="billingNotes" required="true">
		<cfargument name="includeFlag" default="0">
		<cfargument name="adjustedDaysPerMonth" default="">
		<!---><cfargument name="correctedBilledAmount" default="">
		<cfargument name="correctedOverageAmount" default="">
		<cfargument name="correctedBilledUnits" default="">
		<cfargument name="correctedOverageUnits" default="">
		<cfargument name="postBillCorrectedBilledAmount" default="">
		<cfargument name="generatedBilledAmount" >--->

		<cfif arguments.includeFlag EQ "on">
			<cfset arguments.includeFlag = 1>
		</cfif>

		<cfquery name="update">
			UPDATE billingStudent
				SET adjustedDaysPerMonth = <cfif arguments.adjustedDaysPerMonth EQ "">NULL<cfelse><cfqueryparam value="#arguments.adjustedDaysPerMonth#"></cfif>,
		 		 billingStudentExitReasonCode = <cfif arguments.billingStudentExitReasonCode EQ "">NULL<cfelse><cfqueryparam value="#arguments.billingStudentExitReasonCode#"></cfif>,
				 billingNotes = <cfqueryparam value="#arguments.billingNotes#">,
				 includeFlag = <cfqueryparam value="#arguments.includeFlag#">,
				 exitDate = <cfif arguments.exitDate EQ "">NULL<cfelse><cfqueryparam value="#DateFormat(arguments.exitDate,'yyyy-mm-dd')#"></cfif>,
				 program = <cfif arguments.program EQ "">NULL<cfelse><cfqueryparam value="#arguments.program#"></cfif>
			WHERE billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>

	<!--->
		<cfquery name="update">
			UPDATE billingStudent
				SET correctedBilledAmount = <cfif arguments.correctedBilledAmount EQ "">NULL<cfelse><cfqueryparam value="#arguments.correctedBilledAmount#"></cfif>,
				 correctedOverageAmount = <cfif arguments.correctedOverageAmount EQ "">NULL<cfelse><cfqueryparam value="#arguments.correctedOverageAmount#"></cfif>,
				 correctedBilledUnits = <cfif arguments.correctedBilledUnits EQ "">NULL<cfelse><cfqueryparam value="#arguments.correctedBilledUnits#"></cfif>,
				 correctedOverageUnits = <cfif arguments.correctedOverageUnits EQ "">NULL<cfelse><cfqueryparam value="#arguments.correctedOverageUnits#"></cfif>,
		 		 adjustedDaysPerMonth = <cfif arguments.adjustedDaysPerMonth EQ "">NULL<cfelse><cfqueryparam value="#arguments.adjustedDaysPerMonth#"></cfif>,
		 		 billingStudentExitReasonCode = <cfif arguments.billingStudentExitReasonCode EQ "">NULL<cfelse><cfqueryparam value="#arguments.billingStudentExitReasonCode#"></cfif>,
		 		 postBillCorrectedBilledAmount = <cfif arguments.postBillCorrectedBilledAmount EQ "">NULL<cfelse><cfqueryparam value="#arguments.postBillCorrectedBilledAmount#"></cfif>,
		 		 generatedBilledAmount = <cfqueryparam value="#arguments.generatedBilledAmount#">,
				 billingNotes = <cfqueryparam value="#arguments.billingNotes#">,
				 includeFlag = <cfqueryparam value="#arguments.includeFlag#">,
				 exitDate = <cfif arguments.exitDate EQ "">NULL<cfelse><cfqueryparam value="#DateFormat(arguments.exitDate,'yyyy-mm-dd')#"></cfif>,
				 program = <cfif arguments.program EQ "">NULL<cfelse><cfqueryparam value="#arguments.program#"></cfif>
			WHERE billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
		--->
	</cffunction>
	<cffunction name="updatebillingStudentRecordExit" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfargument name="exitDate" required="true">
		<cfargument name="billingStudentExitReasonCode" required="true">
		<cfargument name="adjustedDaysPerMonth" >
		<cfargument name="includeFlag" required="true">

		<cfquery name="update">
			UPDATE billingStudent
				SET adjustedDaysPerMonth = <cfif arguments.adjustedDaysPerMonth EQ "">NULL<cfelse><cfqueryparam value="#arguments.adjustedDaysPerMonth#"></cfif>,
		 		 billingStudentExitReasonCode = <cfif arguments.billingStudentExitReasonCode EQ "">NULL<cfelse><cfqueryparam value="#arguments.billingStudentExitReasonCode#"></cfif>,
				 exitDate = <cfif arguments.exitDate EQ "">NULL<cfelse><cfqueryparam value="#DateFormat(arguments.exitDate,'yyyy-mm-dd')#"></cfif>,
				 includeFlag = <cfqueryparam value="#arguments.includeFlag#">
			WHERE billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
	</cffunction>
	<cffunction name="exitStatusReport"  returntype="query" returnformat="json"  access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfargument name="program">
		<cfargument name="districtid">

		<cfquery name="cal">
			select left(MAX(programyear),4) bannerYear, max(programYear) programYear
			from bannerCalendar
			where termBeginDate <= <cfqueryparam value="#arguments.billingStartDate#">
		</cfquery>

		<cfquery name="data">
			select bsp.LastName,
				bsp.FirstName,
				gender,
				ethnicity,
				DATE_FORMAT(bsp.DOB, '%m/%d/%Y') DOB,
				fnGetGrade(dob, #cal.bannerYear#) Grade,
				DATE_FORMAT(min(bs.billingStartDate), '%m/%d/%Y') EntryDate,
				DATE_FORMAT(bs.ExitDate, '%m/%d/%Y') ExitDate,
				MAX(bs.billingStudentExitReasonCode) 'ExitReason',
				bs.Program,
				SchoolDistrict,
				Date('#DateFormat(arguments.billingStartDate,"yyyy-mm-dd")#') billingStartDate
			from billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bs.term in (select term from bannerCalendar where programYear = <cfqueryparam value="#cal.programyear#">)
				and includeFlag = 1
				<cfif structKeyExists(arguments, "program")>
				and bs.program = <cfqueryparam value="#arguments.program#">
				</cfif>
				<cfif structKeyExists(arguments, "districtid")>
				and bs.districtid = <cfqueryparam value="#arguments.districtid#">
				</cfif>
			group by LastName, FirstName, DOB, Grade, exitDate, schoolDistrict, program
		</cfquery>
		<cfset Session.exitStatusReport = data>
		<cfreturn data>
	</cffunction>
	<cffunction name="admReport" returntyp="query" returnformat="json" access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfargument name="program">
		<cfargument name="districtid">
		<cfquery name="data">
			select bsYear.LastName, bsYear.FirstName
				,Date_Format(bsYear.EntryDate,'%m/%d/%Y') EntryDate
				,Date_Format(bsYear.ExitDate,'%m/%d/%Y') ExitDate
				,FORMAT(sum(bsi.Attendance*IFNULL(LargePercent,0)),1) as LargeGrp
				,FORMAT(sum(bsi.Attendance*IFNULL(InterPercent,0)),1) as InterGrp
				,FORMAT(sum(bsi.Attendance*IFNULL(SmallPercent,0)),1) as SmallGrp
				,FORMAT(CASE WHEN IFNULL(bs.AdjustedIndHours,0) = 0 THEN sum(bsi.Attendance*IFNULL(IndPercent,0)) ELSE bs.AdjustedIndHours END,1) as Tutorial
				,sum(bsi.Attendance) DaysPresent
				,sum(bsi.MaxPossibleAttendance)-sum(bsi.Attendance) DaysAbsent
				,bsYear.Program, bsYear.SchoolDistrict, bc.billingStartDate BeginDate, bc.BillingEndDate EndDate
			from (
				select bs.contactId, bs.exitDateGroupBy exitDate
					,bsp.FirstName, bsp.LastName, bs.Program, schooldistrict
					,MIN(bs.billingStartDate) entryDate
					,MAX(bs.billingStudentId) lastbillingStudentId
				from (select contactId
						,(select min(exitDate) from billingStudent where billingStartDate >= bsSub.billingStartDate and bannerGNumber = bsSub.bannerGNumber) exitDateGroupBy
						, billingStartDate
						, billingStudentId
						, Program
						, districtId
					  from billingStudent bsSub
					  where billingStartDate <= <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
						and term in (select term from bannerCalendar where programYear = (select max(ProgramYear) from bannerCalendar where TermBeginDate <= <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#"> ))
						and includeFlag = 1
						and program like '%attendance%'
						<cfif structKeyExists(arguments, "program")>
						and program = <cfqueryparam value="#arguments.program#">
						</cfif>
						<cfif structKeyExists(arguments, "districtid")>
						and districtid = <cfqueryparam value="#arguments.districtid#">
						</cfif>) bs
					join billingStudentProfile bsp on bs.contactId = bsp.contactId
					join keySchoolDistrict sd on bs.districtId = sd.keySchoolDistrictId
					join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
				group by bs.contactId, bs.exitDateGroupBy, bs.program, schooldistrict
			) bsYear
				join billingCycle bc on bc.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
						and bc.billingType = 'attendance'
				left outer join billingStudent bs on bsYear.lastBillingStudentId = bs.billingStudentId
					and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
					and bsi.IncludeFlag = 1
			group by bsYear.LastName, bsYear.FirstName, bsYear.EntryDate, bsYear.ExitDate
				,bs.AdjustedIndHours, bsYear.Program, bsYear.SchoolDistrict, bc.billingStartDate, bc.BillingEndDate
		</cfquery>
		<cfset Session.admReport = data>
		<cfreturn data>
	</cffunction>

	<cffunction name="gtcOverageReport" access="remote">
		<cfreturn overageReport(gtcOrYes="GtC")>
	</cffunction>
	<cffunction name="YtCOverageReport" access="remote">
		<cfreturn overageReport(gtcOrYes="YtC")>
	</cffunction>
	<cffunction name="overageReport" access="remote">
		<cfargument name="gtcOrYes" required="true">
		<cfquery name="data">
			SELECT bsp.firstName, bsp.lastName, bs.bannerGNumber, substring_index(statusIDCoach,'|',-1) Coach,
				bs.billingStudentId,
				ROUND(bs.Credits,2) Credits,
                bs.MaxTerm
			FROM  (select bs.contactId, bs.bannerGNumber,
						MAX(bs.billingStudentId) billingStudentId,
						MAX(bs.Term) MaxTerm,
						SUM(CASE WHEN Program like '%Attendance%' THEN IFNULL(Attendance,0)/4.86
									ELSE IFNULL(Credits,0) END) Credits
					  from billingStudent bs
					  	join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
					  where bs.includeFlag = 1 and bsi.includeFlag = 1
					  	 and <cfif arguments.gtcOrYes EQ 'gtc'>
							Program = 'GtC'
							<cfelse>
							Program like 'YtC%'
							</cfif>
							and Term IN (SELECT Term from bannerCalendar where ProgramYear = (SELECT MAX(ProgramYear) from bannerCalendar where termBeginDate < now()))
					  group by bs.contactId, bs.bannerGNumber) bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
                LEFT OUTER JOIN (SELECT contactID, max(concat(status.statusDate,'|', res.rsName)) statusIDCoach
		   			  FROM status
						join statusResourceSpecialist sres on status.statusId = sres.statusID
						JOIN keyResourceSpecialist res
							ON sres.keyResourceSpecialistID = res.keyResourceSpecialistID
           			  WHERE keyStatusID = 6
						and undoneStatusID is null
          			  GROUP BY contactID) coach
					ON coach.contactID = bs.contactID
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="ppsReport"  returntype="query" returnformat="json"  access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfargument name="program">
		<cfargument name="districtid">
		<cfquery name="data">
			select lastname
				,firstname
			    ,Date_Format(BillingStartDate, '%m/%d/%Y') BeginDate
			    ,Date_Format(EndDate, '%m/%d/%Y') EndDate
			    ,sum(Credits) Credits
			    ,round(sum(CM),1) CM
			    ,round(sum(Inter),1) Inter
			    ,round(sum(Large),1) Large
			    ,round(sum(Small),1) Small
			    ,round(sum(Ind),1) Ind
			from
			(select bsp.lastname
				,bsp.firstname
			    ,bs.BillingStartDate
				,IFNULL(bs.ExitDate,bs.BillingEndDate) EndDate
				,bsi.Attendance
				,bsi.Credits
				,IFNULL(bsi.Attendance,0)*(IFNULL(LargePercent,0)+IFNULL(IndPercent,0)+IFNULL(SmallPercent,0)+IFNULL(InterPercent,0))/10 as CM
				,bsi.Attendance*IFNULL(IndPercent,0) Ind
				,bsi.Attendance*IFNULL(SmallPercent,0) Small
				,bsi.Attendance*IFNULL(InterPercent,0) Inter
				,bsi.Attendance*IFNULL(LargePercent,0) Large
			from billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
				join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bsi.includeFlag = 1
				and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				<cfif structKeyExists(arguments, "program")>
					and bs.program = <cfqueryparam value="#arguments.program#">
				</cfif>
				<cfif structKeyExists(arguments, "districtid")>
					and bs.districtid = <cfqueryparam value="#arguments.districtid#">
				</cfif>
			) data
			group by lastname, firstname, billingStartDate, EndDate
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="enrollmentReport"  returntype="query" returnformat="json"  access="remote">
		<cfargument name="programyear" required="true">
		<cfargument name="program" default="">
		<cfargument name="districtid" default="-1">

		<cfquery name="data">
		   select bs.contactId,
				sd.SchoolDistrict,
				bs.Program,
				bsp.LastName,
				bsp.FirstName,
				fnGetGrade(dob, LEFT(<cfqueryparam value="#arguments.programyear#">,4)) Grade,
				DATE_FORMAT(min(bs.BillingStartDate), '%m/%d/%Y'),
				DATE_FORMAT(bs.ExitDate, '%m/%d/%Y') ExitDate,
				IFNULL(bs.billingStudentExitReasonCode,0) 'ExitReason',
				substring_index(statusIDCoach,'|',-1) Coach,
				CASE WHEN bs.Program LIKE '%ELL%' THEN 'TRUE' ELSE 'FALSE' END ELL,
				Gender,
				DATE_FORMAT(bsp.DOB, '%m/%d/%Y') DOB,
				Address,
				City,
				State,
				Zip,
				bsp.bannerGNumber,
                bs.DistrictID
		    from billingStudent bs
		        join billingStudentProfile bsp on bsp.contactID = bs.contactID
		        JOIN bannerCalendar bc on bs.term = bc.term
				LEFT OUTER JOIN (SELECT contactID, max(concat(status.statusDate,'|', res.rsName)) statusIDCoach
								  FROM status
									join statusResourceSpecialist sres on status.statusId = sres.statusID
									JOIN keyResourceSpecialist res
										ON sres.keyResourceSpecialistID = res.keyResourceSpecialistID
								  WHERE keyStatusID = 6
									and undoneStatusID is null
								  GROUP BY contactID
					) coach
						on bs.ContactID = coach.contactID
				 JOIN keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bc.ProgramYear = <cfqueryparam value="#arguments.programyear#">
				and (bs.Program = <cfqueryparam value="#arguments.program#"> or <cfqueryparam value="#arguments.program#"> = '')
		        and (bs.DistrictID = <cfqueryparam value="#arguments.districtid#"> or <cfqueryparam value="#arguments.districtid#"> = -1)
			group by bs.contactId,
						bs.Program,
						bsp.LastName,
						bsp.FirstName,
						bs.ExitDate,
						bs.billingStudentExitReasonCode,
						substring_index(statusIDCoach,'|',-1),
						Gender,
						bsp.DOB,
						Address,
						City,
						State,
						Zip,
						bsp.bannerGNumber
		</cfquery>

		<cfreturn data>
	</cffunction>

	<cffunction name="attendanceEntry" returntype="query" returnformat="json"  access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfargument name="noHoursOnly" required="false" default="false">
		<cfargument name="noClassesOnly" required="false" default="false">
		<cfquery name="data">
			select CRN, CRSE, SUBJ, Title, CASE WHEN bs.IncludeFlag=0 OR bs.IncludeFlag IS NULL THEN 'Student NOT Billed' ELSE NULL END IncludeStudent
				,bsp.bannerGNumber, bsp.firstName, bsp.lastName, bs.billingStudentId, Attendance, MaxPossibleAttendance
				,schoolDistrict, bs.Program
			    ,CASE WHEN bsi.IncludeFlag=0 OR bsi.IncludeFlag IS NULL THEN 'Class NOT Billed' ELSE NULL END IncludeClass
			    ,bs.exitDate
			    ,bsi.billingStudentItemNotes Notes
			    ,sidnyExitDate.exitDate sidnyExitDate
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			    left outer join billingStudentProfile bsp on bs.contactid = bsp.contactId
			    left outer join keySchoolDistrict sd on bs.districtId = sd.keySchoolDistrictId
			    join (select enrolled.contactId, exitDate
					  from (select contactId, max(statusDate) enrolledDate
							from status s
							where keyStatusID in (2,13,14,15,16)
								and undoneStatusID is null
							group by contactId) enrolled
						 left outer join (select contactId, max(statusDate) exitDate
										  from status s
										  where keyStatusID in (3,12)
											 and undoneStatusID IS NULL
										  group by contactId) exited
								on enrolled.contactId = exited.contactId
									and enrolledDate < exitDate) sidnyExitDate
					on bs.contactId = sidnyExitDate.contactId
			where bs.billingStartDate = <cfqueryparam value="#arguments.billingStartDate#">
				and bs.program like '%attendance%'
				<cfif arguments.noHoursOnly>
				and bs.billingStudentId IN (select bs.billingStudentId
				                            from billingStudent bs
				                              left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
				                            where bs.billingStartDate = <cfqueryparam value="#arguments.billingStartDate#">
												and bs.program like '%attendance%'
				                            group by bs.billingStudentId
				                            having sum(IFNULL(attendance,0)) = 0)
				</cfif>
				<cfif arguments.noClassesOnly>
				and bs.billingStudentId not IN (select distinct bs.billingStudentId
				                            from billingStudent bs
				                              join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
				                            where bs.billingStartDate = <cfqueryparam value="#arguments.billingStartDate#">
												and bs.program like '%attendance%')
				</cfif>
			order by CRN, lastname
		</cfquery>
		<cfset Session.attendanceEntryPrint = data>
		<cfif arguments.noHoursOnly>
			<cfset Session.attendanceEntryTitle = "Classes and Students with Zero Attendance Hours for " & DateFormat(arguments.billingStartDate,'mm-dd-yy')>
		</cfif>
		<cfreturn data>
	</cffunction>

	<cffunction name="updateOverrideTotal" access="remote">
		<cfargument name="program" required="true">
		<cfargument name="schooldistrict" required="true">
		<cfargument name="month" required="true">
		<cfargument name="value" required="true">
		<cfset appObj.logDump(label="arguments", value="#arguments#", level=5) >
		<cfquery name="update" result="r">
			update billingStudentTotalOverride
			set `#month#` =  <cfif len(arguments.value) EQ 0>NULL<cfelse><cfqueryparam value="#arguments.value#"></cfif>
			where program = <cfqueryparam value="#arguments.program#">
				and schooldistrict = <cfqueryparam value="#arguments.schooldistrict#">
		</cfquery>
		<cfset appObj.logDump(label="r", value="#r#", level=5) >
	</cffunction>

	<cffunction name="sidnyBillingComparison" returnformat="json" access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfstoredproc procedure="spPopulateTmpEnrollExit">
			<cfprocparam value="0" cfsqltype="CF_SQL_STRING">
			<cfprocresult name="qry">
		</cfstoredproc>
		<cfquery name="data1">
			select bs.bannerGNumber, bsp.firstName, bsp.lastName, ee.programDetail SIDNYProgram, bs.program, bs.billingStudentId
			from billingStudent bs
				join billingStudentProfile bsp on bsp.contactId = bs.contactId
				left outer join sptmp_CurrentEnrollExit ee on bs.contactId = ee.contactId
			where bs.BillingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			and bs.program != ee.programDetail
		</cfquery>
		<cfquery name="data2">
			select c.bannerGNumber, c.firstName, c.lastName, ee.programDetail SIDNYProgram, CAST('Missing!' as CHAR) Program, CAST(NULL as SIGNED) billingStudentId
			from sptmp_CurrentEnrollExit ee
				join contact c on ee.contactId = c.contactId
				left outer join billingStudent bs on bs.contactId = ee.contactId
				<!--- adding 15 days to start date as buffer for late enrollments --->
			where ee.exitDate is null and ee.enrolledDate < <cfqueryparam value="#DateFormat(DateAdd('d', 15, arguments.billingStartDate),'yyyy-mm-dd')#">
			and bs.billingStudentId is null
		</cfquery>
		<cfquery name="data" dbtype="query">
			select *
			from data1
			union
			select *
			from data2
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getAttendanceEnteredByStudent" access="remote" >
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
			select SUM(CASE WHEN Attendance > 0 THEN 1 ELSE 0 END) NumStudentsEntered
				,SUM(CASE WHEN Attendance = 0 and NumOfClasses > 0 THEN 1 ELSE 0 END) NumStudentsNoHours
				,SUM(CASE WHEN NumOfClasses = 0 THEN 1 ELSE 0 END) NumStudentsNoClasses
			from(
			select bs.billingStudentId, sum(IFNULL(Attendance,0)) Attendance, count(billingStudentItemId) NumOfClasses
			from billingStudent bs
				left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
					and bsi.includeFlag = 1
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
				and bs.includeFlag = 1
			group by bs.billingStudentId) data
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getAttendanceEnteredByClass" access="remote" >
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
			select SUM(CASE WHEN Attendance > 0 THEN 1 ELSE 0 END) NumClassesEntered
				,SUM(CASE WHEN Attendance = 0 THEN 1 ELSE 0 END) NumClassesNoHours
			from(
			select bsi.crn, sum(IFNULL(Attendance,0)) Attendance
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
					and bsi.includeFlag = 1
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
				and bs.includeFlag = 1
			group by bsi.crn) data
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getStudentsNoHours" access="remote" >
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
			select bs.bannerGNumber, bsp.FirstName, bsp.LastName
			from billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
					and bsi.includeFlag = 1
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
				and bs.includeFlag = 1
			group by bs.bannerGNumber, bsp.FirstName, bsp.LastName
			having sum(IFNULL(Attendance,0)) = 0
			order by bsp.LastName, bsp.FirstName
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getStudentsNoClasses" access="remote" >
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
			select bs.bannerGNumber, bsp.FirstName, bsp.LastName
			from billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
				and bs.includeFlag = 1
				and bsi.billingStudentItemId is null
			group by bs.bannerGNumber, bsp.FirstName, bsp.LastName
			order by bsp.LastName, bsp.FirstName
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getClassesNoHours" access="remote" >
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
			select crn, subj, crse, Title, count(*) NumOfStudents
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
					and bsi.includeFlag = 1
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
				and bs.includeFlag = 1
			group by crn, subj, crse, Title
			having sum(IFNULL(Attendance,0)) = 0
			order by subj, crse
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="prevBillingPeriodComparison" returnformat="json" access="remote" >
		<cfargument name="billingStartDate" required="true">
		<cfargument name="billingType" required="true">
		<cfquery name="prevPeriod">
			select max(billingStartDate) billingStartDate
			from billingCycle
			where billingStartDate < <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and billingType = <cfqueryparam value="#arguments.billingType#">
		</cfquery>
		<cfquery name="data">
			select bsPrev.bannerGNumber, bsp.FirstName, bsp.LastName, bsPrev.program PreviousProgram, bsPrev.exitDate PreviousExitDate, IFNULL(bsCurrent.program, 'Missing!') CurrentProgram,  bsPrev.billingStudentId
            from billingStudent bsPrev
				join billingStudentProfile bsp on bsPrev.contactId = bsp.contactId
				left outer join billingStudent bsCurrent on bsPrev.ContactID = bsCurrent.contactID
					 and bsCurrent.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			where bsPrev.includeFlag = 1
				and bsPrev.billingStartDate = '#DateFormat(prevPeriod.billingStartDate, "yyyy-mm-dd")#'
			 	and bsPrev.program <cfif arguments.billingType EQ 'Term'>not</cfif> like '%attendance%'
			 	and (
			 		(bsCurrent.billingStudentId is null and bsPrev.exitDate is null)
						or (bsPrev.program != bsCurrent.program and bsPrev.exitDate is null )
					)
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getAttendanceBilledInfo" access="remote" >
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
	        select sum(coalesce(CorrectedBilledAmount, GeneratedBilledAmount)) BilledAmount, max(MaxDaysPerMonth) MaxDaysPerMonth
            from billingStudent
            where billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and program like '%attendance%'
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="compareCurrentAttendance" access="remote" returnformat="json" >
		<cfargument name="billingStartDate" required="true">
		<cfquery name="billing">
			select CRN, bs.bannerGNumber, pidm, CRSE, SUBJ, Title, firstname, lastname, bs.Program,  CASE WHEN bs.Program LIKE '%Attendance%' THEN 'Attendance' ELSE 'Term' END BillingType
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
			where billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and CRN REGEXP '^[0-9]+$'
		</cfquery>
		<cfquery name="students" dbtype="query">
			select bannerGNumber, firstname, lastname, program, billingType
			from billing
			group by bannerGNumber, firstname, lastname, program, billingType
		</cfquery>
		<cfquery name="billingStudent" dbtype="query">
			select pidm
			from billing
			group by pidm
		</cfquery>
		<cfset local.inList =  ValueList(billingStudent.pidm,",")>
		<cfquery name="calendar">
			select Term, termEndDate
			from bannerCalendar
			where <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#"> between termBeginDate and termEndDate
		</cfquery>
		<cfquery name="bannerClasses" datasource="bannerpcclinks" >
			select distinct CRN, STU_ID, CRSE, SUBJ, Title
			from swvlinks_course
			where term = <cfqueryparam value ="#calendar.term#">
				and pidm IN  (<cfqueryparam value="#local.inList#" list="yes" cfsqltype="String">)
		</cfquery>
		<cfquery name="combined" dbtype="query">
			select CRN, CRSE, SUBJ, Title, bannerGNumber, 'Billing' billingSource, 'X' bannerSource
			from billing
			union all
			select CRN, CRSE, SUBJ, Title, STU_ID, 'X' billingSource, 'Banner' bannerSource
			from bannerClasses
		</cfquery>
		<cfquery name="data1" dbtype="query" >
			select CRN, bannerGNumber, CRSE, SUBJ, Title, CAST(MIN(billingSource) AS varchar) billingSource, CAST(MIN(bannerSource) as varchar) bannerSource
			from combined
			group by CRN, CRSE, SUBJ, Title, bannerGNumber
		</cfquery>
		<cfquery name="data" dbtype="query">
			select students.billingType, students.bannerGNumber, students.firstname, students.lastname,Program, CRN, CRSE, SUBJ, Title
				,billingSource, bannerSource
			from data1, students
			where data1.bannerGNumber = students.bannerGNumber
				and (billingSource = 'X' or bannerSource = 'X')
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getLastBillingGeneratedMessage" access="remote" returnformat="plain" returntype="String">
		<cfargument name="billingType" required="true">
		<cfargument name="programYear" required="true">
		<cfargument name="includeTitle" default=true>

		<cfif arguments.billingType EQ 'Term'>
			<cfset isTerm = true>
		<cfelse>
			<cfset isTerm = false>
		</cfif>

		<cfset reportTable = 'billingReportTerm'>
		<cfinvoke component="LookUp" method="getNextTermToBill" returnvariable="nextTerm"></cfinvoke>
		<cfif isTerm>
			<cfinvoke component="LookUp" method="getNextTermToBill" returnvariable="nextTerm"></cfinvoke>
			<cfset nextBillingStartDate = ''>
		<cfelse>
			<cfinvoke component="LookUp" method="getOpenAttendanceDates" returnvariable="attendanceData"></cfinvoke>
			<cfset nextTerm = attendanceData.Term>
			<cfset nextBillingStartDate = attendanceData.billingStartDate>
		</cfif>
		<cfquery name="maxDates">
			SELECT IFNULL(MAX(r.dateCreated),'1900-01-01') maxGeneratedDate, MAX(Term) maxTerm, max(BillingStartDate) maxBillingStartDate
			FROM billingCycle bc
				join billingReport r on bc.billingCycleId = r.billingCycleId
			where programYear = <cfqueryparam value="#arguments.programYear#">
				and billingType = <cfqueryparam value="#arguments.billingType#">
				<!---><cfif isTerm>
				and term = #nextTerm#
				<cfelse>
				and billingStartDate = '#DateFormat(nextBillingStartDate, "yyyy-mm-dd")#'
				</cfif>--->
		</cfquery>
		<cfquery name="lastChange"  >
			SELECT GREATEST(max(bs.dateLastUpdated), max(bsi.dateLastUpdated)) lastUpdated
			FROM billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			WHERE program <cfif isTerm>not</cfif> like '%attendance%'
		</cfquery>
		<cfquery name="billingCycle">
			SELECT Term BillingTerm, BillingStartDate
			FROM billingCycle
			WHERE billingCloseDate IS NULL
				AND billingType = <cfqueryparam value="#arguments.billingType#">
				AnD ProgramYear = <cfqueryparam value="#arguments.programYear#">
			ORDER BY billingStartDate
		</cfquery>
		<cfsavecontent variable="msg">
			<cfoutput>
			<cfif includeTitle><h4><cfif isTerm>Term<cfelse>Attendance</cfif> Billing for Year #arguments.ProgramYear#</h4></cfif>
			<div class="callout primary">
				<cfif billingCycle.recordCount EQ 1>
					<b>Open Billing Period:</b>
						<cfif isTerm> #convertTerm(billingCycle.billingTerm)#
						<cfelse>#dFmt(billingCycle.BillingStartDate)#</cfif>
					<br>
				</cfif>
				<cfif billingCycle.recordCount GT 1>
					<b>Open Billing Periods:</b>
					<cfloop query="billingCycle">
						<cfif isTerm>#convertTerm(billingCycle.billingTerm)#,
						<cfelse>#dFmt(billingCycle.BillingStartDate)#</cfif>
					</cfloop><br>
				</cfif>
				<cfif billingCycle.recordCount EQ 0>
					No Open Billing Periods<br>
				</cfif>
				<cfif maxDates.maxTerm EQ ''>
				<b>No reports yet generated</b>
				<cfelse>
				<b>Report last generated for:</b>
					<cfif isTerm>Term #convertTerm(maxDates.maxTerm)#
					<cfelse>#dFmt(maxDates.maxBillingStartDate)#</cfif>
					on <span style="color:blue">#dtFmt(maxDates.maxGeneratedDate)#</span>
				</cfif>
			</div>
			<div class="callout primary">
				<div class="row">
					<div class="small-21 medium-12 columns">
						<b>Last date changed:</b> <span <cfif DateDiff("n", maxDates.maxGeneratedDate, lastChange.lastUpdated) GT 1>style="color:red"</cfif>>
						#dtFmt(lastChange.lastUpdated)#
						</span>
					</div>
				</div>
			</div>
			</cfoutput>
		</cfsavecontent>
		<cfreturn msg>
	</cffunction>

	<cffunction name="getReportList" returntype="query" access="remote" returnformat="JSON">
		<cfargument name="programYear" required="yes">
		<cfargument name="billingType" required="yes">
		<cfquery name="data">
			select schoolDistrict, Program
			from billingCycle bc
				join billingReport br on bc.LatestBillingReportID = br.billingReportId
			<cfif arguments.billingType EQ 'term'>
				join billingReportTerm r
			<cfelse>
				join billingReportAttendance r
			</cfif>
					on br.billingReportId = r.billingReportId
			where programYear = <cfqueryparam value="#arguments.programYear#">
			group by schoolDistrict, Program
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getBillingCycle" access="remote">
		<cfargument name="billingStartDate" required=true>
		<cfargument name="billingType" required=true>
		<cfquery name="data">
			select *
			from billingCycle
			where billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and billingType = <cfqueryparam value="#arguments.billingType#">
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getMissingScenarioCount" access="remote">
		<cfargument name="billingStartDate">

		<cfquery name="data">
			select distinct bsi.CRN
			from billingStudentItem bsi
				join billingStudent bs on bsi.billingStudentId = bs.BillingStudentID
				left outer join billingScenarioByCourse bsbc on bsi.crn = bsbc.crn and bs.term = bsbc.term
			where bs.term = (select max(term) from bannerCalendar where termBeginDate <= '2018-07-02')
				and bsbc.crn is null
				and bs.program like '%attendance%'
			order by bsi.CRN
		</cfquery>
	</cffunction>

	<cffunction name="getBillingDiffMaxMonth">
		<cfquery name="maxMonth">
			select max(month(billingStartDate)) month
			from billingCycle
			where ProgramYear = (select max(ProgramYear) from billingCycle)
			and billingCloseDate is not null
		</cfquery>
		<cfset maxMonth = maxMonth.month>
		<!--- need January to be greater than June - December for the flow of the program year --->
		<cfif maxMonth LT 6>
			<cfset maxMonth = maxMonth + 20>
		</cfif>
		<cfreturn maxMonth>
	</cffunction>
	<cffunction name="getBillingDifferencesAttendance">
		<cfset maxMonth = getBillingDiffMaxMonth()>
		<!--- need January to be greater than June - December for the flow of the program year --->
		<cfif maxMonth LT 6>
			<cfset maxMonth = maxMonth + 20>
		</cfif>
		<cfquery name="data">
			select *
			from(

			select repB.SchoolDistrict, repB.Program
				,repB.contactID, repB.bannerGNumber, repB.FirstName, repB.LastName
				,round(repB.June - ifnull(repA.June,0),1) June
			    ,round(repB.July - ifnull(repA.July,0),1) July
			    ,round(repB.August - ifnull(repA.August,0),1) August
			    ,round(repB.September - ifnull(repA.September,0),1) September
			    ,round(repB.October - ifnull(repA.October,0),1) October
			    ,round(repB.November - ifnull(repA.November,0),1) November
			    ,round(repB.December - ifnull(repA.December,0),1) December
			    ,round(repB.January - ifnull(repA.January,0),1) January
			    ,round(repB.February - ifnull(repA.February,0),1) February
			    ,round(repB.March - ifnull(repA.March,0),1) March
			    ,round(repB.April - ifnull(repA.April,0),1) April
			    ,round(repB.May - ifnull(repA.May,0),1) May
			    ,round(repB.TotalAttendance - ifnull(repA.TotalAttendance,0),1) Attendance
			from
			(select contactID, bannerGNumber, FirstName, LastName, Program, SchoolDistrict
				,June, July, August, September, October, November, December, January, February
			    ,March, April, May, TotalAttendance
			from billingCycle bc
				join billingReport br on bc.LatestBillingReportID = br.BillingReportId
			    join billingReportAttendance bra on br.BillingReportId = bra.BillingReportId
			where bc.billingCycleId = (select max(billingCycleId) from billingCycle where billingType = 'attendance')
				) repB
			left outer join (select contactID, bannerGNumber, FirstName, LastName, Program, SchoolDistrict
				,June, July, August, September, October, November, December, January, February
			    ,March, April, May, TotalAttendance
			from billingCycle bc
				join billingReport br on bc.LatestBillingReportID = br.BillingReportId
			    join billingReportAttendance bra on br.BillingReportId = bra.BillingReportId
			where bc.billingCycleId = (select max(billingCycleId) from billingCycle where billingType = 'attendance' and billingCycleId < (select max(billingCycleId) from billingCycle where billingType = 'attendance'))
			  ) repA
				on repA.contactID = repB.contactID
					and repA.Program = repB.Program
			        and repA.SchoolDistrict = repB.SchoolDistrict
			where repB.June != IFNULL(repA.June,0)
				<cfif maxMonth GT 6>
					or repB.July != IFNULL(repA.July,0)
				</cfif>
				<cfif maxMonth GT 7>
					or repB.August != IFNULL(repA.August,0)
				</cfif>
				<cfif maxMonth GT 8>
					or repB.September != IFNULL(repA.September,0)
				</cfif>
				<cfif maxMonth GT 9>
					or repB.October != IFNULL(repA.October,0)
				</cfif>
				<cfif maxMonth GT 10>
					or repB.November != IFNULL(repA.November,0)
				</cfif>
				<cfif maxMonth GT 11>
					or repB.December != IFNULL(repA.December,0)
				</cfif>
				<cfif maxMonth GT 21>
					or repB.January != IFNULL(repA.January,0)
				</cfif>
				<cfif maxMonth GT 22>
					or repB.February != IFNULL(repA.February,0)
				</cfif>
				<cfif maxMonth GT 23>
					or repB.March != IFNULL(repA.March,0)
				</cfif>
				<cfif maxMonth GT 24>
					or repB.April != IFNULL(repA.April,0)
				</cfif>
				<cfif maxMonth GT 25>
					or repB.May != IFNULL(repA.May,0)
				</cfif>
			union
			select repA.SchoolDistrict, repA.Program
				,repA.contactID, repA.bannerGNumber, repA.FirstName, repA.LastName
				,round(ifnull(repB.June,0) - repA.June,1) June
			    ,round(ifnull(repB.July,0)- repA.July,1) July
			    ,round(ifnull(repB.August,0) - repA.August,1) August
			    ,round(ifnull(repB.September,0) - repA.September,1) September
			    ,round(ifnull(repB.October,0) - repA.October,1) October
			    ,round(ifnull(repB.November,0) - repA.November,1) November
			    ,round(ifnull(repB.December,0) - repA.December,1) December
			    ,round(ifnull(repB.January,0) - repA.January,1) January
			    ,round(ifnull(repB.February,0) - repA.February,1) February
			    ,round(ifnull(repB.March,0) - repA.March,1) March
			    ,round(ifnull(repB.April,0) - repA.April,1) April
			    ,round(ifnull(repB.May,0) - repA.May,1) May
			    ,round(ifnull(repB.TotalAttendance,0) - repA.TotalAttendance,1) TotalAttendance
			from
			(select contactID, bannerGNumber, FirstName, LastName, Program, SchoolDistrict
				,June, July, August, September, October, November, December, January, February
			    ,March, April, May, TotalAttendance
			from billingCycle bc
				join billingReport br on bc.LatestBillingReportID = br.BillingReportId
			    join billingReportAttendance bra on br.BillingReportId = bra.BillingReportId
			where bc.billingCycleId = (select max(billingCycleId) from billingCycle where billingType = 'attendance' and billingCycleId < (select max(billingCycleId) from billingCycle where billingType = 'attendance'))
			  ) repA
			left outer join (select contactID, bannerGNumber, FirstName, LastName, Program, SchoolDistrict
				,June, July, August, September, October, November, December, January, February
			    ,March, April, May, TotalAttendance
			from billingCycle bc
				join billingReport br on bc.LatestBillingReportID = br.BillingReportId
			    join billingReportAttendance bra on br.BillingReportId = bra.BillingReportId
			where bc.billingCycleId = (select max(billingCycleId) from billingCycle where billingType = 'attendance')
				) repB
				on repA.contactID = repB.contactID
					and repA.Program = repB.Program
			        and repA.SchoolDistrict = repB.SchoolDistrict
			where repB.contactID is null
				or repA.June != IFNULL(repB.June,0)
				<cfif maxMonth GT 6>
					or repA.July != IFNULL(repB.July,0)
				</cfif>
				<cfif maxMonth GT 7>
					or repA.August != IFNULL(repB.August,0)
				</cfif>
				<cfif maxMonth GT 8>
					or repA.September != IFNULL(repB.September,0)
				</cfif>
				<cfif maxMonth GT 9>
					or repA.October != IFNULL(repB.October,0)
				</cfif>
				<cfif maxMonth GT 10>
					or repA.November != IFNULL(repB.November,0)
				</cfif>
				<cfif maxMonth GT 11>
					or repA.December != IFNULL(repB.December,0)
				</cfif>
				<cfif maxMonth GT 21>
					or repA.January != IFNULL(repB.January,0)
				</cfif>
				<cfif maxMonth GT 22>
					or repA.February != IFNULL(repB.February,0)
				</cfif>
				<cfif maxMonth GT 23>
					or repA.March != IFNULL(repB.March,0)
				</cfif>
				<cfif maxMonth GT 24>
					or repA.April != IFNULL(repB.April,0)
				</cfif>
				<cfif maxMonth GT 25>
					or repA.May != IFNULL(repB.May,0)
				</cfif>

				) data
				order by SchoolDistrict, Program, Lastname, Firstname
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getStudentDiffCountAttendance">
		<cfset data = getBillingDifferencesAttendance()>
		<cfreturn data.recordCount>
	</cffunction>

	<cffunction name="getBillingStudentAudit" access="remote" returnformat="JSON">
		<cfargument name="bannerGNumber">
		<cfargument name="monthNumber">

		<cfquery name="getStartingDate">
			select max(billingStartDate) billingStartDate
			from billingCycle
			where billingType = 'attendance'
			  and billingCycleId <= (select max(billingCycleId) from billingCycle where billingType = 'attendance')
			  and month(billingStartDate) = <cfqueryparam value="#arguments.monthNumber#">
		</cfquery>

		<cfquery name="getAuditLogDate">
			select max(billingCloseDate) closeDate
			from billingCycle
			where billingType = 'attendance'
			  and billingCycleId < (select max(billingCycleId) from billingCycle where billingType = 'attendance')
		</cfquery>

		<cfquery name="data">
			select bs.bannerGNumber, al.columnName
				, al.oldValue, al.newValue, ifnull(al.action, 'inserted') action
				, Date_Format(ifnull(al.changedDate, bs.dateLastUpdated),'%m/%d/%y') changedDate
				, ifnull(al.changedBy, bs.lastUpdatedBy) changedBy
			from billingStudent bs
				left outer join auditLog al on bs.BillingStudentID = al.idValue
				    and al.tableName = 'BillingStudent'
					and al.columnName in ('Program', 'DistrictID', 'IncludeFlag')
			where ifnull(al.changedDate, bs.dateLastUpdated) >= <cfqueryparam value="#DateFormat(getAuditLogDate.closeDate,'yyyy-mm-dd')#">
				and bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
				and BillingStartDate = <cfqueryparam value="#DateFormat(getStartingDate.billingStartDate,'yyyy-mm-dd')#">
			order by al.columnName, al.changedDate;
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getBillingStudentItemAudit" access="remote" returnformat="JSON">
		<cfargument name="bannerGNumber">
		<cfargument name="monthNumber">

		<cfquery name="getStartingDate">
			select max(billingStartDate) billingStartDate
			from billingCycle
			where billingType = 'attendance'
			  and billingCycleId < (select max(billingCycleId) from billingCycle where billingType = 'attendance')
			  and month(billingStartDate) = <cfqueryparam value="#arguments.monthNumber#">
		</cfquery>

		<cfquery name="getAuditLogDate">
			select max(billingCloseDate) closeDate
			from billingCycle
			where billingType = 'attendance'
			  and billingCycleId < (select max(billingCycleId) from billingCycle where billingType = 'attendance')
		</cfquery>

		<cfquery name="data">
			select bs.bannerGNumber, bsi.Subj, bsi.Crse, bsi.CRN, bsi.Attendance
				,ifnull(al.columnName,'Attendance') columnName
				,al.oldValue
				,ifnull(al.newValue, Attendance) newValue
				,ifnull(al.action, 'inserted') action
				,Date_Format(ifnull(al.changedDate, bsi.dateLastUpdated),'%m/%d/%y') changedDate
				,Ifnull(al.changedBy, bsi.lastUpdatedBy) changedBy
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
				left outer join auditLog al on bsi.BillingStudentItemID = al.idValue
				    and al.tableName = 'BillingStudentItem'
					and al.columnName in ('Attendance', 'Scenario', 'IncludeFlag')
			where ifnull(al.changedDate, bsi.dateLastUpdated) >= <cfqueryparam value="#DateFormat(getAuditLogDate.closeDate,'yyyy-mm-dd')#">
				and bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
				and BillingStartDate = <cfqueryparam value="#DateFormat(getStartingDate.billingStartDate,'yyyy-mm-dd')#">
			order by bsi.subj, bsi.crse, bsi.crn, al.columnName, al.changedDate
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="convertTerm">
		<cfargument name="term" required="true">

		<cfinvoke component = "LookUp" method="convertTerm" returnvariable="data">
			<cfinvokeargument name="term" value="#arguments.term#">
		</cfinvoke>
		<cfreturn data>
	</cffunction>

	<cffunction name="dFmt">
		<cfargument name="dateValue">
		<cfreturn DateFormat(arguments.dateValue, "mm/dd/yyyy")>
	</cffunction>
	<cffunction name="dtFmt">
		<cfargument name="dateValue">
		<cfreturn DateTimeFormat(arguments.dateValue, "MM/dd/yyyy 'at' hh:nn")>
	</cffunction>
</cfcomponent>