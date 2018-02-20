<cfcomponent displayname="report">
	<cfobject name="appObj" component="application">

	<cffunction name="calculateBilling" access="remote">
		<cfargument name="billingType" require="true">
		<cfargument name="term" >
		<cfargument name="billingStartDate">
		<cfargument name="maxCreditsPerTerm" >
		<cfargument name="maxDaysPerYear">
		<cfargument name="maxDaysPerBillingPeriod" >
		<cfif arguments.billingType EQ 'Term'>
			<cfquery name="updateTermData">
				update billingStudent bs
				join (
					select billingStudentId,
						CASE WHEN creditYearTotal > <cfqueryparam value="#arguments.maxCreditsPerTerm#"> THEN creditYearTotal - <cfqueryparam value="#arguments.maxCreditsPerTerm#"> ELSE 0 END GeneratedOverageUnits,
						CASE WHEN creditYearTotal > <cfqueryparam value="#arguments.maxCreditsPerTerm#">
								THEN CASE WHEN (creditYearTotal - creditCurrentCycleTotal -<cfqueryparam value="#arguments.maxCreditsPerTerm#">) < 0
											THEN creditYearTotal - <cfqueryparam value="#arguments.maxCreditsPerTerm#"> ELSE 0 END
								ELSE creditCurrentCycleTotal
						END GeneratedBilledUnits
					from (select bsSub.billingStudentId, SUM(bsi.Credits) creditYearTotal, SUM(CASE term WHEN <cfqueryparam value=#arguments.term#> THEN bsi.Credits ELSE 0 END) creditCurrentCycleTotal
						  from billingStudent bsSub
							join billingStudentItem bsi on bsSub.BillingStudentID = bsi.BillingStudentID
							join keySchoolDistrict schooldistrict on bsSub.DistrictID = schooldistrict.keyschooldistrictid
							where bsi.includeFlag = 1
								and bsSub.Program not like '%attendance%'
								and bsSub.billingStatus IN ('IN PROGRESS','REVIEWED')
								and bsSub.term = <cfqueryparam value="#arguments.term#">
							group by bsSub.billingStudentId) data
					)finalData
					on bs.billingStudentId = finalData.billingStudentId
			set bs.GeneratedOverageUnits = finalData.GeneratedOverageUnits,
				bs.GeneratedBilledUnits =  finalData.GeneratedBilledUnits,
				bs.GeneratedBilledAmount = ROUND(finalData.GeneratedBilledUnits /<cfqueryparam value="#arguments.maxCreditsPerTerm#">* <cfqueryparam value="#arguments.maxDaysPerYear#">,4),
				bs.GeneratedOverageAmount = ROUND(finalData.GeneratedOverageUnits /<cfqueryparam value="#arguments.maxCreditsPerTerm#">* <cfqueryparam value="#arguments.maxDaysPerYear#">,4),
				bs.maxCreditsPerTerm = <cfqueryparam value="#arguments.maxCreditsPerTerm#">,
				bs.maxDaysPerYear = <cfqueryparam value="#arguments.maxDaysPerYear#">
			</cfquery>
		<cfelse>
			<cfquery name="updateBillingStudentItem">
				update billingStudentItem bsi
					join billingStudent bs on bs.BillingStudentID = bsi.BillingStudentID
				    join billingScenarioByCourse bsbc  on bsi.CRN = bsbc.CRN
					join billingScenario bsc on bsbc.billingScenarioId = bsc.billingScenarioId
				    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
				set bsi.Scenario = bsc.billingScenarioName,
					bsi.IndPercent = bsc.IndPercent,
					bsi.SmallPercent = bsc.SmallPercent,
					bsi.InterPercent = bsc.InterPercent,
					bsi.LargePercent = bsc.LargePercent
				where bsi.includeFlag = 1
					and bs.Program like '%attendance%'
					and bs.billingStatus IN ('IN PROGRESS','REVIEWED')
					and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			</cfquery>
			<!--- going to do some stepped updates to help with calculations of max days per month
			   where a month is split between two terms.  In that instance, the later billing start date
			   for the month will have the aggregated number of days between the two terms, and contain
			   the amount billed for the month --->
			 <!--- TODO - repeating where clause -- need better solution --->
			<cfquery name="updateWithParamMaxDaysPerBillingPeriod">
				update billingStudent
				set maxDaysPerBillingPeriod = <cfqueryparam value="#arguments.maxDaysPerBillingPeriod#">
				where Program like '%attendance%'
					and billingStatus IN ('IN PROGRESS','REVIEWED')
					and billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			</cfquery>
			<cfquery name="updateMaxDaysPerMonth" result="x">
				update billingStudent
					join (select contactId, max(billingStartDate) billingStartDate, sum(maxDaysPerBillingPeriod) maxDaysPerMonth
					      from billingStudent bsSub
						  where bsSub.Program like '%attendance%'
								and bsSub.billingStatus IN ('IN PROGRESS','REVIEWED')
								and MONTH(bsSub.billingStartDate) = MONTH(<cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">)
								and YEAR(bsSub.billingStartDate) = YEAR(<cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">)
						  group by contactId
						) bsMonth on billingStudent.contactId = bsMonth.contactId
							and billingStudent.billingStartDate = bsMonth.billingStartDate
				set billingStudent.maxDaysPerMonth = bsMonth.maxDaysPerMonth
			</cfquery>
			<cfset appObj.logDump(label="updateWithMonthMaxDaysPerMonth", value="#x#", level=3)>
			<cfquery name="updateAttendance2">
				update billingStudent
					join
		            (
		            select billingStudentId
						,truncate(sum(ind) + sum(small)*0.333 + sum(inter)*0.222 + sum(large)*0.167 + sum(ind + small + inter + large)*0.0167, 2) BilledAmount
						,sum(small) Small, sum(inter) Inter, sum(Large) Large
		            from (
		            select bs.billingStudentId
						,bsi.Attendance
						,bsi.Attendance*IFNULL(IndPercent,0) as Ind
						,bsi.Attendance*IFNULL(SmallPercent,0) as Small
						,bsi.Attendance*IFNULL(InterPercent,0) as Inter
						,bsi.Attendance*IFNULL(LargePercent,0) as Large
					from billingStudent bs
						join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
					    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
					where bsi.includeFlag = 1
						and bs.Program like '%attendance%'
						and bs.billingStatus IN ('IN PROGRESS','REVIEWED')
						and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
						) data
					group by billingStudentId) finalData
				on billingStudent.billingStudentId = finalData.billingStudentId
		        set GeneratedBilledAmount  = round(IFNULL(case when BilledAmount > billingStudent.maxDaysPerMonth
		        												then billingStudent.maxDaysPerMonth
		        												else BilledAmount end,0),2),
					GeneratedOverageAmount = round(IFNULL(case when BilledAmount > billingStudent.maxDaysPerMonth
																 then BilledAmount - billingStudent.maxDaysPerMonth
																 else 0 end,0),2),
					SmGroupPercent = 0.333,
					InterGroupPercent = 0.222,
					LargeGroupPercent = 0.167,
					CMPercent = 0.0167,
					AdjustedIndHours = case when BilledAmount > billingStudent.maxDaysPerMonth
											then (billingStudent.maxDaysPerMonth -  (0.3497 * Small) - (0.2387 * Inter) - (0.1837 * Large)) / 1.0167
											else NULL
										end
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="reCalculateBilling" access="remote">
		<cfargument name="billingType" require="true">
		<cfargument name="program" required="true">
		<cfargument name="schooldistrict" required="true">
		<cfargument name="term" >
		<cfargument name="billingStartDate">

		<cfif billingType EQ 'Term'>
			<cfquery name="data">
				select maxCreditsPerTerm, maxDaysPerYear
				from billingStudent
				where term = <cfqueryparam value="#arguments.term#">
					and program not like '%attendance%'
					and maxCreditsPerTerm is not null
	                and maxDaysPerYear is not null
				order by DateLastUpdated desc
				limit 1
			</cfquery>
			<cfset calculateBilling(billingType = arguments.billingType, term = arguments.term,
					maxCreditsPerTerm = data.maxCreditsPerTerm,
					maxDaysPerYear = data.maxDaysPerYear)>
			<cfset termReport(term = arguments.term, program = arguments.program,
				schooldistrict = arguments.schooldistrict)>
		<cfelse>
			<cfquery name="data">
				select maxDaysPerBillingPeriod
				from billingStudent
				where billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
					and program like '%attendance%'
					and maxDaysPerBillingPeriod is not null
				order by DateLastUpdated desc
				limit 1
			</cfquery>
			<cfset calculateBilling(billingType = arguments.billingType, billingStartDate = arguments.billingStartDate,
					maxDaysPerBillingPeriod = data.maxDaysPerBillingPeriod)>
			<cfset attendanceReport(monthStartDate = arguments.billingStartDate, term = arguments.term,
						program=arguments.program, schooldistrict=arguments.schooldistrict)>
		</cfif>
	</cffunction>

	<cffunction name="termReport" returntype="query" access="remote">
		<!--- arguments --->
		<cfargument name="term" required="true">
		<cfargument name="program" default="">
		<cfargument name="schooldistrict" default="">
		<cfquery name="data" >
			SELECT bs.firstname, bs.lastname, bs.bannergnumber
				,bs.Program
				,schooldistrict.schoolDistrict
				,MIN(Date_Format(bs.billingStartDate, '%m/%d/%Y')) EntryDate
				,MAX(Date_Format(bs.billingStartDate, '%m/%d/%Y')) billingStartDate
				,MAX(Date_Format(bs.billingEndDate, '%m/%d/%Y')) billingEndDate
				,MAX(Date_Format(bs.ExitDate, '%m/%d/%Y')) ExitDate
				,SUM(case when cal.ProgramQuarter = 1 then bs.Credits else 0 end) SummerNoOfCredits
				,SUM(case when cal.ProgramQuarter = 1 then bs.Days else 0 end) SummerNoOfDays
				,MAX(case when cal.ProgramQuarter = 1 then bs.billingStudentId else 0 end) BillingStudentIdSummer
				,SUM(case when cal.ProgramQuarter = 2 then bs.Credits+bs.CreditsOver else 0 end) FallNoOfCredits
				,SUM(case when cal.ProgramQuarter = 2 then bs.CreditsOver else 0 end) FallNoOfCreditsOver
				,SUM(case when cal.ProgramQuarter = 2 then bs.Days+bs.DaysOver else 0 end) FallNoOfDays
				,SUM(case when cal.ProgramQuarter = 2 then bs.DaysOver else 0 end) FallNoOfDaysOver
				,SUM(case when cal.ProgramQuarter = 3 then bs.Credits+bs.CreditsOver else 0 end) WinterNoOfCredits
				,SUM(case when cal.ProgramQuarter = 3 then bs.CreditsOver else 0 end) WinterNoOfCreditsOver
				,SUM(case when cal.ProgramQuarter = 3 then bs.Days+bs.DaysOver else 0 end) WinterNoOfDays
				,SUM(case when cal.ProgramQuarter = 3 then bs.DaysOver else 0 end) WinterNoOfDaysOver
				,SUM(case when cal.ProgramQuarter = 4 then bs.Credits+bs.CreditsOver else 0 end) SpringNoOfCredits
				,SUM(case when cal.ProgramQuarter = 4 then bs.CreditsOver else 0 end) SpringNoOfCreditsOver
				,SUM(case when cal.ProgramQuarter = 4 then bs.Days+bs.DaysOver else 0 end) SpringNoOfDays
				,SUM(case when cal.ProgramQuarter = 4 then bs.DaysOver else 0 end) SpringNoOfDaysOver
				,MAX(bs.billingStudentId) BillingStudentIdMostCurrent
				,SUM(bs.Credits+bs.CreditsOver) FYTotalNoOfCredits
				,SUM(bs.Credits) FYMaxTotalNoOfCredits
				,SUM(bs.Days+bs.DaysOver) FYTotalNoOfDays
				,SUM(bs.Days) FYMaxTotalNoOfDays
			FROM (SELECT billingStudent.contactId, billingStudent.billingStudentId, firstname, lastname, billingStudent.bannerGNumber,
							Term, DistrictID, Program, ExitDate, billingStartDate, billingEndDate,
						    COALESCE(FinalBilledUnits, CorrectedBilledUnits, GeneratedBilledUnits) Credits,
							COALESCE(FinalOverageUnits, CorrectedOverageUnits, GeneratedOverageUnits) CreditsOver,
							COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) Days,
							COALESCE(FinalOverageAmount, CorrectedOverageAmount, GeneratedOverageAmount) DaysOver
						FROM billingStudent
							JOIN billingStudentProfile bsp on billingStudent.contactId = bsp.contactId
						join keySchoolDistrict schooldistrict on billingStudent.DistrictID = schooldistrict.keyschooldistrictid
						WHERE includeFlag = 1 and program = <cfqueryparam value=#arguments.program#>
								and schooldistrict.schooldistrict = <cfqueryparam value=#arguments.schooldistrict#>
								and term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value=#arguments.term#>))
								and COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) != 0
					 ) bs
				join bannerCalendar cal on bs.term = cal.Term
				join keySchoolDistrict schooldistrict on bs.DistrictID = schooldistrict.keyschooldistrictid
			GROUP BY bs.firstname, bs.lastname, bs.bannergnumber
				,bs.Program
				,schooldistrict.schoolDistrict
			HAVING sum(bs.Credits) <> 0
			ORDER BY bs.lastname, bs.firstname, bs.billingStartDate
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

	<cffunction name="attendanceReport" access="remote">
		<cfargument name="monthStartDate" type="date" required="true">
		<cfargument name="term" required="true">
		<cfargument name="program" required="true">
		<cfargument name="schooldistrict" required="true">
		<cfquery name="data">
			select concat(lastname,', ',firstname) name, bannerGNumber, DATE_FORMAT(dob,'%m/%d/%Y') dob, DATE_FORMAT(exitdate,'%m/%d/%Y') exitDate,
				MIN(DATE_FORMAT(billingStartDate,'%m/%d/%Y')) enrolledDate,
				DATE_FORMAT(bannerCal.reportStartDate, '%m/%d/%Y') ReportStartDate, DATE_FORMAT(bannerCal.reportEndDate, '%m/%d/%Y') ReportEndDate,
				SUM(IFNULL(Enrollment,0)) Enrl, schooldistrict, program,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 6 then billedAmount end,0),1)) Jun,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 7 then billedAmount end,0),1)) Jul,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 8 then billedAmount end,0),1)) Aug,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 9 then billedAmount end,0),1)) Sept,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 10 then billedAmount end,0),1)) Oct,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 11 then billedAmount end,0),1)) Nov,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 12 then billedAmount end,0),1)) Dcm,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 1 then billedAmount end,0),1)) Jan,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 2 then billedAmount end,0),1)) Feb,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 3 then billedAmount end,0),1)) Mar,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 4 then billedAmount end,0),1)) Apr,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 5 then billedAmount end,0),1)) May,
				SUM(ROUND(IFNULL(billedAmount,0),1)) Attnd,
				MAX(billingStudentId) billingStudentIdMostCurrent
			from
            ( select bsp.firstname, bsp.lastname, bs.bannerGNumber, bsp.dob
				,bs.billingStudentId, bs.billingStartDate, bsCalcExitDate.exitdate
				,bs.billingEndDate
				,COALESCE(bs.adjustedDaysPerMonth,bs.maxDaysPerMonth) Enrollment, sd.schooldistrict, program
				,COALESCE(bs.PostBillCorrectedBilledAmount, bs.FinalBilledAmount, bs.CorrectedBilledAmount, bs.GeneratedBilledAmount) BilledAmount
			from billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
			    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			    join (select bs.billingStudentId, coalesce(max(bs.exitDate), max(bsNext.exitDate)) exitDate
					  from billingStudent bs
						left outer join billingStudent bsNext on bs.contactID = bsNext.contactID
						and bs.billingStartDate < bsNext.billingStartDate
						and bsNext.program = <cfqueryparam value="#arguments.program#">
					  where bs.program = <cfqueryparam value="#arguments.program#">
					  group by bs.billingStudentId
					 ) bsCalcExitDate
					   	on bs.billingStudentId = bsCalcExitDate.billingStudentId
			where bs.program = <cfqueryparam value="#arguments.program#">
				and sd.schoolDistrict = <cfqueryparam value="#arguments.schooldistrict#">
				and includeFlag = 1
				and bs.term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value=#arguments.term#>))
			) data,
 			(select min(termBeginDate) reportStartDate, max(termEndDate) reportEndDate
              from bannerCalendar
               where programYear = (select programYear from bannerCalendar where term = 201704)
  			  and term <= 201704) bannerCal
			group by lastname, firstname, bannerGNumber, dob, schooldistrict, program, exitdate, bannerCal.reportStartDate, bannerCal.reportEndDate
			order by lastname, firstname, exitdate
		</cfquery>
		<cfset list = "">
		<cfloop query="data">
			 <cfset list = listAppend(list, billingStudentIdMostCurrent,",")>
		</cfloop>
		<cfset Session.billingstudentlist = list>
		<cfset Session.reportAttendanceData = data>
		<cfreturn data>
	</cffunction>

	<cffunction name="attendanceReportDetail" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfquery name="data">
			select bsp.firstname, bsp.lastname, bs.bannerGNumber, bs.billingStartDate
				,ROUND(IFNULL(bsi.Attendance,0),2) Attendance, bsi.CRN
                ,IFNULL(bsi.Scenario,'Unassigned') Scenario, IFNULL(IndPercent,0) IndPercent
                ,IFNULL(SmallPercent,0) SmallPercent, IFNULL(InterPercent,0) InterPercent
                ,IFNULL(LargePercent,0) LargePercent
				,ROUND(IFNULL(bsi.Attendance,0)*IFNULL(IndPercent,0),2) as Ind
				,ROUND(IFNULL(bsi.Attendance,0)*IFNULL(SmallPercent,0),2) as Small
				,ROUND(IFNULL(bsi.Attendance,0)*IFNULL(InterPercent,0),2) as Inter
				,ROUND(IFNULL(bsi.Attendance,0)*IFNULL(LargePercent,0),2) as Large
				,ROUND(IFNULL(bsi.Attendance,0)*(IFNULL(LargePercent,0)+IFNULL(IndPercent,0)+IFNULL(SmallPercent,0)+IFNULL(InterPercent,0))/10,2) as CM
				,ROUND(IFNULL(bs.SmGroupPercent,0),2) SmGroupPercent
				,ROUND(IFNULL(bs.InterGroupPercent,0),2) InterGroupPercent
				,ROUND(IFNULL(bs.LargeGroupPercent,0),2) LargeGroupPercent
				,IFNULL(bs.CMPercent,0) CMPercent
				,ROUND(IFNULL(bs.GeneratedBilledAmount,0),2) GeneratedBilledAmount
				,ROUND(IFNULL(bs.GeneratedOverageAmount,0),2) GeneratedOverageAmount
			from billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bs.billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="closeBillingCycle" access="remote">
		<cfargument name="term" >
		<cfargument name="billingStartDate" >
		<cfargument name="billingType" required="true">
		<cfquery name="update">
			update billingStudent
			set billingStatus = 'BILLED',
				FinalBilledUnits = COALESCE(CorrectedBilledUnits, GeneratedBilledUnits),
				FinalOverageUnits = COALESCE(CorrectedOverageUnits, GeneratedOverageUnits),
				FinalBilledAmount = COALESCE(CorrectedBilledAmount, GeneratedBilledAmount),
				FinalOverageAmount = COALESCE(CorrectedOverageAmount, GeneratedOverageAmount)
			where
				<cfif arguments.billingType EQ 'attendance'>
					billingStartDate =<cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
					and program like '%attendance%'
				<cfelse>
					term = <cfqueryparam value="#arguments.term#">
					and program not like '%attendance%'
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
		<cfargument name="correctedBilledAmount" required="true">
		<cfargument name="correctedOverageAmount" required="true">
		<cfargument name="correctedBilledUnits" default="">
		<cfargument name="correctedOverageUnits" default="">
		<cfargument name="billingNotes" required="true">
		<cfargument name="includeFlag" default="0">
		<cfargument name="adjustedDaysPerMonth" default="">
		<cfargument name="billingRecordExitReasonCode" default="">
		<cfargument name="postBillCorrectedBilledAmount" default="">
		<cfargument name="generatedBilledAmount">
		<cfargument name="billingStudentExitReasonCode" default="">
		<cfargument name="exitDate" default="">

		<cfif arguments.includeFlag EQ "on">
			<cfset arguments.includeFlag = 1>
		</cfif>

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
				 exitDate = <cfif arguments.exitDate EQ "">NULL<cfelse><cfqueryparam value="#DateFormat(arguments.exitDate,'yyyy-mm-dd')#"></cfif>
			WHERE billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
	</cffunction>
	<cffunction name="exitStatusReport"  returntype="query" returnformat="json"  access="remote">
		<cfargument name="programyear" required="true">
		<cfargument name="program">
		<cfargument name="districtid">
		<cfquery name="data">
			select bsp.LastName,
				bsp.FirstName,
				DATE_FORMAT(bsp.DOB, '%m/%d/%Y') DOB,
				case
					when dob < date(concat(banneryear-21,'-09-01')) then 'Over'
					when dob < date(concat(banneryear-20,'-09-01')) then 15
					when dob < date(concat(banneryear-19,'-09-01')) then 14
					when dob < date(concat(banneryear-18,'-09-01')) then 13
					when dob < date(concat(banneryear-17,'-09-01')) then 12
					when dob < date(concat(banneryear-16,'-09-01')) then 11
					when dob < date(concat(banneryear-15,'-09-01')) then 10
					when dob < date(concat(banneryear-14,'-09-01')) then 9
				end Grade,
				DATE_FORMAT(min(bs.billingStartDate), '%m/%d/%Y') EntryDate,
				DATE_FORMAT(bsCalcExitDate.ExitDate, '%m/%d/%Y') ExitDate,
				MAX(bs.billingStudentExitReasonCode) 'ExitReason'
			from (
				select left(programyear,4) banneryear
				from bannerCalendar
				where term = 201801
				) calendardata,
				 billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
				join (select bs.billingStudentId, coalesce(max(bs.exitDate), max(bsNext.exitDate)) exitDate
					  from billingStudent bs
						left outer join billingStudent bsNext on bs.contactID = bsNext.contactID
							and bs.billingStartDate < bsNext.billingStartDate
						group by bs.billingStudentId
						 ) bsCalcExitDate
					   		on bs.billingStudentId = bsCalcExitDate.billingStudentId
			where bs.term in (select term from bannerCalendar where programYear = <cfqueryparam value="#arguments.programyear#">)
				and includeFlag = 1
				<cfif structKeyExists(arguments, "program")>
				and bs.program = <cfqueryparam value="#arguments.program#">
				</cfif>
				<cfif structKeyExists(arguments, "districtid")>
				and bs.districtid = <cfqueryparam value="#arguments.districtid#">
				</cfif>
			group by LastName, FirstName, DOB, 'Grade', bsCalcExitDate.ExitDate, schoolDistrict, program
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="admReport" returntyp="query" returnformat="json" access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfargument name="program">
		<cfargument name="districtid">
		<cfquery name="data">
			select LastName, FirstName
				,Date_Format(EntryDate,'%m/%d/%Y') EntryDate
				,Date_Format(ExitDate,'%m/%d/%Y') ExitDate
				,FORMAT(sum(bsi.Attendance*IFNULL(LargePercent,0)),1) as LargeGrp
				,FORMAT(sum(bsi.Attendance*IFNULL(InterPercent,0)),1) as InterGrp
				,FORMAT(sum(bsi.Attendance*IFNULL(SmallPercent,0)),1) as SmallGrp
				,FORMAT(CASE WHEN AdjustedIndHours = 0 THEN sum(bsi.Attendance*IFNULL(IndPercent,0)) ELSE AdjustedIndHours END,1) as Tutorial
			from (
				select bs.contactId, bsNext.exitDate
					,bsp.FirstName, bsp.LastName
					,MIN(bs.billingStartDate) entryDate
					,MAX(bs.billingStartDate) maxBillingDate
					,MAX(bs.billingStudentId) maxbillingStudentId
					,MAX(CASE WHEN bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
							  THEN bs.AdjustedIndHours ELSE 0
						END) AdjustedIndHours
				from billingStudent bs
					join billingStudentProfile bsp on bs.contactId = bsp.contactId
					left outer join billingStudent bsNext on bs.contactId = bsNext.contactID
						and bs.program = bsNext.program
			            and bs.DistrictID = bsNext.DistrictID
						and bsNext.billingStartDate >= bs.billingStartDate
			            and bsNext.ExitDate is not null
				where bs.billingStartDate <= <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
					and bs.term in (select term from bannerCalendar where programYear = (select max(ProgramYear) from bannerCalendar where TermBeginDate <= <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#"> ))
					and bs.includeFlag = 1
					<cfif structKeyExists(arguments, "program")>
					and bs.program = <cfqueryparam value="#arguments.program#">
					</cfif>
					<cfif structKeyExists(arguments, "districtid")>
					and bs.districtid = <cfqueryparam value="#arguments.districtid#">
					</cfif>
				group by bs.contactId, bsNext.exitDate
			) bs
				left outer join billingStudentItem bsi on bs.maxBillingStudentId = bsi.billingStudentId
					and bsi.IncludeFlag = 1
					and bs.maxBillingDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			group by contactId, exitDate, FirstName, LastName, entryDate, maxBillingDate, maxBillingStudentId
		</cfquery>
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
			SELECT bsp.firstName, bsp.lastName, bs.bannerGNumber,
				MAX(billingStudentId) billingStudentId,
				SUM(coalesce(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount,0)) Days,
    			SUM(coalesce(FinalBilledUnits, CorrectedBilledUnits, GeneratedBilledUnits,0)) Credits
			FROM billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				JOIN bannerCalendar bc on bs.term = bc.term
			WHERE <cfif arguments.gtcOrYes EQ 'gtc'>
				Program = 'GtC'
				<cfelse>
				Program like 'YtC%'
				</cfif>
				and ProgramYear = (SELECT MAX(ProgramYear) from bannerCalendar where termBeginDate < now())
			GROUP BY bsp.firstname, bsp.lastname, bs.bannerGNumber
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
			    ,Date_Format(BillingStartDate, '%m/%d/%Y') BillingStartDate
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
			    ,bs2.EntryDate
			    ,bs.BillingStartDate
				,IFNULL(bsCalcExitDate.ExitDate,bs.BillingEndDate) EndDate
				,bsi.Attendance
				,bsi.Credits
				,IFNULL(bsi.Attendance,0)*(IFNULL(LargePercent,0)+IFNULL(IndPercent,0)+IFNULL(SmallPercent,0)+IFNULL(InterPercent,0))/10 as CM
				,bsi.Attendance*IFNULL(IndPercent,0) Ind
				,bsi.Attendance*IFNULL(SmallPercent,0) Small
				,bsi.Attendance*IFNULL(InterPercent,0) Inter
				,bsi.Attendance*IFNULL(LargePercent,0) Large
			from billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				join (select bs.billingStudentId, coalesce(max(bs.exitDate), max(bsNext.exitDate)) exitDate
						from billingStudent bs
							left outer join billingStudent bsNext on bs.contactID = bsNext.contactID
								and bs.billingStartDate < bsNext.billingStartDate
						group by bs.billingStudentId
						) bsCalcExitDate
					on bs.billingStudentId = bsCalcExitDate.billingStudentId
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
				join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
				join (select contactId
						,min(billingStartDate) EntryDate
					  from billingStudent
					  where includeFlag = 1
							and term in (select term from bannerCalendar where programYear = (select max(ProgramYear) from bannerCalendar where TermBeginDate <=  <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">))
					 group by contactId) bs2 on bs.contactid = bs2.contactId
			where bsi.includeFlag = 1
				and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				<cfif structKeyExists(arguments, "program")>
					and bs.program = <cfqueryparam value="#arguments.program#">
				</cfif>
				<cfif structKeyExists(arguments, "districtid")>
					and bs.districtid = <cfqueryparam value="#arguments.districtid#">
				</cfif>
			) data
			group by lastname, firstname, EntryDate, BillingStartDate, EndDate
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="enrollmentReport"  returntype="query" returnformat="json"  access="remote">
		<cfargument name="programyear" required="true">
		<cfargument name="program">
		<cfargument name="districtid">
		<cfset bannerYear = left(arguments.programyear,4)>
		<cfquery name="data">
			select bs.contactId,
				bs.Program,
				bsp.LastName,
				bsp.FirstName,
				fnGetGrade(dob, 2017) Grade,
				DATE_FORMAT(bs.EntryDate, '%m/%d/%Y'),
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
				bsp.bannerGNumber
 			from vBillingStudentEnrollExit bs
				join (select distinct contactId
						from billingStudent bs1
							join billingStudentItem bsi1
								on bs1.billingStudentId = bsi1.billingStudentId and bsi1.IncludeFlag = 1
							join bannerCalendar bc on bs1.term = bc.term and bc.ProgramYear = <cfqueryparam value="#arguments.programyear#">
					) classes
						on bs.contactId = classes.contactid
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
				join (select bs.contactID, coalesce(max(bs.exitDate), max(bsNext.exitDate)) exitDate
					  from billingStudent bs
						left outer join billingStudent bsNext on bs.contactID = bsNext.contactID
							and bs.billingStartDate < bsNext.billingStartDate
						group by bs.contactID
						 ) bsCalcExitDate
					   		on bs.contactID = bsCalcExitDate.contactID
				join (SELECT contactID, max(concat(status.statusDate,'|', res.rsName)) statusIDCoach
		   			  FROM status
						join statusResourceSpecialist sres on status.statusId = sres.statusID
						JOIN keyResourceSpecialist res
							ON sres.keyResourceSpecialistID = res.keyResourceSpecialistID
           			  WHERE keyStatusID = 6
						and undoneStatusID is null
          			  GROUP BY contactID) coach
			    	ON coach.contactID = bs.contactID
			where bs.programYear = <cfqueryparam value="#arguments.programyear#">
				<cfif structKeyExists(arguments, "program")>
				and bs.program = <cfqueryparam value="#arguments.program#">
				</cfif>
				<cfif structKeyExists(arguments, "districtid")>
				and bs.districtid = <cfqueryparam value="#arguments.districtid#">
				</cfif>
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="attendanceentry" returntype="query" returnformat="json"  access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data">
			select CRN, CRSE, SUBJ, Title, CASE WHEN bs.IncludeFlag=0 OR bs.IncludeFlag IS NULL THEN 'Student NOT Billed' ELSE NULL END IncludeStudent
				,bsp.bannerGNumber, bsp.firstName, bsp.lastName, bs.billingStudentId, Attendance, MaxPossibleAttendance
			    ,CASE WHEN bsi.IncludeFlag=0 OR bsi.IncludeFlag IS NULL THEN 'Class NOT Billed' ELSE NULL END IncludeClass
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			    left outer join billingStudentProfile bsp on bs.contactid = bsp.contactId
			where bs.billingStartDate = <cfqueryparam value="#arguments.billingStartDate#">
			and bs.program like '%attendance%'
			order by CRN, lastname
		</cfquery>
		<cfreturn data>
	</cffunction>

</cfcomponent>