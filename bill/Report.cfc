<cfcomponent displayname="report">
	<cfobject name="appObj" component="application">

	<cffunction name="calculateBilling" access="remote">
		<cfargument name="billingType" require="true">
		<cfargument name="term" >
		<cfargument name="billingStartDate">
		<cfargument name="maxCreditsPerYear" >
		<cfargument name="maxDaysPerYear">
		<cfargument name="maxDaysPerBillingPeriod" >
		<cfif arguments.billingType EQ 'Term'>
			<cfquery name="updateTermData">
				update billingStudent bsToUpdate
				join (
					select bs.billingStudentId,
						CASE WHEN creditYearTotal >= <cfqueryparam value="#arguments.maxCreditsPerYear#">
							THEN CASE WHEN Overage < 0 THEN 0 Else Overage END
							ELSE creditCurrentCycleTotal
							END GeneratedBilledUnits,
						creditCurrentCycleTotal -
							(CASE WHEN creditYearTotal >= <cfqueryparam value="#arguments.maxCreditsPerYear#">
								  THEN CASE WHEN Overage < 0 THEN 0 Else Overage END
								  ELSE creditCurrentCycleTotal END)
							GeneratedOverageUnits
					from (select max(bsSub.billingStudentId) billingStudentId
							,SUM(bsi.Credits) creditYearTotal
							,SUM(CASE term WHEN <cfqueryparam value=#arguments.term#> THEN bsi.Credits ELSE 0 END) creditCurrentCycleTotal
							,<cfqueryparam value="#arguments.maxCreditsPerYear#">-(SUM(bsi.Credits) - SUM(CASE term WHEN <cfqueryparam value="#arguments.term#"> THEN bsi.Credits ELSE 0 END)) Overage
						  from billingStudent bsSub
							join billingStudentItem bsi on bsSub.BillingStudentID = bsi.BillingStudentID
							join keySchoolDistrict schooldistrict on bsSub.DistrictID = schooldistrict.keyschooldistrictid
							where bsi.includeFlag = 1 and bsSub.includeFlag = 1
								and bsSub.Program not like '%attendance%'
								and bsSub.term in (select term from bannerCalendar
													where ProgramYear = (select ProgramYear from bannerCalendar where term = <cfqueryparam value="#arguments.term#">)
													)
							group by bsSub.contactId) data
						join billingStudent bs
							on data.billingStudentId = bs.billingStudentId
					where bs.term = <cfqueryparam value="#arguments.term#">
					)finalData
					on bsToUpdate.billingStudentId = finalData.billingStudentId
			set bsToUpdate.GeneratedOverageUnits = finalData.GeneratedOverageUnits,
				bsToUpdate.GeneratedBilledUnits =  finalData.GeneratedBilledUnits,
				bsToUpdate.GeneratedBilledAmount = ROUND(finalData.GeneratedBilledUnits /<cfqueryparam value="#arguments.maxCreditsPerYear#">* <cfqueryparam value="#arguments.maxDaysPerYear#">,4),
				bsToUpdate.GeneratedOverageAmount = ROUND(finalData.GeneratedOverageUnits /<cfqueryparam value="#arguments.maxCreditsPerYear#">* <cfqueryparam value="#arguments.maxDaysPerYear#">,4),
				bsToUpdate.maxCreditsPerTerm = <cfqueryparam value="#arguments.maxCreditsPerYear#">,
				bsToUpdate.maxDaysPerYear = <cfqueryparam value="#arguments.maxDaysPerYear#">
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
                ,bsOther.Days OtherDaysBilled
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
				,SUM(bs.Days+bs.DaysOver) + IFNULL(bsOther.Days,0) FYTotalNoOfDays
				,CASE WHEN (SUM(bs.Days) + IFNULL(bsOther.Days,0)) > 175 THEN 175 ELSE (SUM(bs.Days) + IFNULL(bsOther.Days,0)) END FYMaxTotalNoOfDays
			FROM (SELECT billingStudent.contactId, billingStudent.billingStudentId, firstname, lastname, billingStudent.bannerGNumber,
							Term, DistrictID, Program, ExitDate, billingStartDate, billingEndDate,
						    COALESCE(FinalBilledUnits, CorrectedBilledUnits, GeneratedBilledUnits) Credits,
							COALESCE(FinalOverageUnits, CorrectedOverageUnits, GeneratedOverageUnits) CreditsOver,
							COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) Days,
							COALESCE(PostBillCorrectedOverageAmount, FinalOverageAmount, CorrectedOverageAmount, GeneratedOverageAmount) DaysOver
						FROM billingStudent
							JOIN billingStudentProfile bsp on billingStudent.contactId = bsp.contactId
						join keySchoolDistrict schooldistrict on billingStudent.DistrictID = schooldistrict.keyschooldistrictid
						WHERE includeFlag = 1 and program = <cfqueryparam value=#arguments.program#>
								and schooldistrict.schooldistrict = <cfqueryparam value=#arguments.schooldistrict#>
								and term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value=#arguments.term#>))
								and COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) != 0
					 ) bs
				left outer join (SELECT billingStudent.contactId,
						sum(
							COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount)) Days
						FROM billingStudent
							JOIN billingStudentProfile bsp on billingStudent.contactId = bsp.contactId
						join keySchoolDistrict schooldistrict on billingStudent.DistrictID = schooldistrict.keyschooldistrictid
						WHERE includeFlag = 1 and program != <cfqueryparam value=#arguments.program#>
								and schooldistrict.schooldistrict = <cfqueryparam value=#arguments.schooldistrict#>
								and term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = 201802))
								and COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) != 0
						group by billingStudent.contactId
					 ) bsOther
					on bs.contactId = bsOther.contactId
				join bannerCalendar cal on bs.term = cal.Term
				join keySchoolDistrict schooldistrict on bs.DistrictID = schooldistrict.keyschooldistrictid
			GROUP BY bs.firstname, bs.lastname, bs.bannergnumber
				,bs.Program
				,schooldistrict.schoolDistrict
				,bsOther.Days
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
<!--- code 4/17/2018>
	<cffunction name="termReport" returntype="query" access="remote">
		<!--- arguments --->
		<cfargument name="term" required="true">
		<cfargument name="program" default="">
		<cfargument name="schooldistrict" default="">
		<cfquery name="data" >
			SELECT bs.firstname, bs.lastname, bs.bannergnumber
				,bs.Program
				,schooldistrict.schoolDistrict
				,Date_Format(bs.ExitDate, '%m/%d/%Y') ExitDate
				,Date_Format(MIN(bs.billingStartDate), '%m/%d/%Y') EntryDate
				,Date_Format(MAX(bs.billingStartDate), '%m/%d/%Y') billingStartDate
				,Date_Format(MAX(bs.billingEndDate), '%m/%d/%Y') billingEndDate
				,SUM(case when cal.ProgramQuarter = 1 then bs.Credits else 0 end) SummerNoOfCredits
				,SUM(case when cal.ProgramQuarter = 1 then bs.Days else 0 end) SummerNoOfDays
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
							Term, DistrictID, Program, bse.ExitDate, billingStartDate, billingEndDate,
						    COALESCE(FinalBilledUnits, CorrectedBilledUnits, GeneratedBilledUnits) Credits,
							COALESCE(FinalOverageUnits, CorrectedOverageUnits, GeneratedOverageUnits) CreditsOver,
							COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) Days,
							COALESCE(FinalOverageAmount, CorrectedOverageAmount, GeneratedOverageAmount) DaysOver
						FROM billingStudent
							JOIN billingStudentProfile bsp on billingStudent.contactId = bsp.contactId
							LEFT OUTER JOIN billingStudentExit bse on billingStudent.contactId = bse.contactId and bse.exitDate between billingStudent.billingStartDate and billingStudent.billingEndDate
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
				,schooldistrict.schoolDistrict, bs.exitDate
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
--->
	<cffunction name="attendanceReport" access="remote">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="term" required="true">
		<cfargument name="program" required="true">
		<cfargument name="schooldistrict" required="true">
		<cfquery name="data">
			select concat(lastname,', ',firstname) name, bannerGNumber, DATE_FORMAT(dob,'%m/%d/%Y') dob, DATE_FORMAT(exitdate,'%m/%d/%Y') exitDate,
				DATE_FORMAT(MIN(billingStartDate),'%m/%d/%Y') enrolledDate,
				DATE_FORMAT(MAX(billingStartDate), '%m/%d/%Y') ReportStartDate, DATE_FORMAT(MAX(billingEndDate), '%m/%d/%Y') ReportEndDate,
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
			    join (select bs.billingStudentId, max(coalesce(bs.exitDate, bsNext.exitDate)) exitDate
					  from billingStudent bs
						left outer join billingStudent bsNext on bs.contactID = bsNext.contactID
						and bs.enrolledDate = bsNext.enrolledDate
						and bsNext.program = <cfqueryparam value="#arguments.program#">
					  where bs.program = <cfqueryparam value="#arguments.program#">
					  group by bs.billingStudentId
					 ) bsCalcExitDate
					   	on bs.billingStudentId = bsCalcExitDate.billingStudentId
			where bs.program = <cfqueryparam value="#arguments.program#">
				and sd.schoolDistrict = <cfqueryparam value="#arguments.schooldistrict#">
				and includeFlag = 1
				and bs.term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value=#arguments.term#>))
				and bs.billingStartDate <= <cfqueryparam value="#arguments.billingStartDate#">
			) data,
 			(select min(termBeginDate) reportStartDate, max(termEndDate) reportEndDate
              from bannerCalendar
               where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value=#arguments.term#>)
  			  and term <= <cfqueryparam value=#arguments.term#>) bannerCal
			group by lastname, firstname, bannerGNumber, dob, schooldistrict, program, exitdate
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
		<cfargument name="postBillCorrectedBilledAmount" default="">
		<cfargument name="generatedBilledAmount">
		<cfargument name="billingStudentExitReasonCode" default="">
		<cfargument name="exitDate" default="">
		<cfargument name="program" default="">

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
				 exitDate = <cfif arguments.exitDate EQ "">NULL<cfelse><cfqueryparam value="#DateFormat(arguments.exitDate,'yyyy-mm-dd')#"></cfif>,
				 program = <cfif arguments.program EQ "">NULL<cfelse><cfqueryparam value="#arguments.program#"></cfif>
			WHERE billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
	</cffunction>
	<cffunction name="updatebillingStudentRecordExit" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfargument name="exitDate" required="true">
		<cfargument name="billingStudentExitReasonCode" required="true">
		<cfargument name="adjustedDaysPerMonth" required="true">

		<cfquery name="update">
			UPDATE billingStudent
				SET adjustedDaysPerMonth = <cfif arguments.adjustedDaysPerMonth EQ "">NULL<cfelse><cfqueryparam value="#arguments.adjustedDaysPerMonth#"></cfif>,
		 		 billingStudentExitReasonCode = <cfif arguments.billingStudentExitReasonCode EQ "">NULL<cfelse><cfqueryparam value="#arguments.billingStudentExitReasonCode#"></cfif>,
				 exitDate = <cfif arguments.exitDate EQ "">NULL<cfelse><cfqueryparam value="#DateFormat(arguments.exitDate,'yyyy-mm-dd')#"></cfif>
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
				DATE_FORMAT(max(bs.ExitDate), '%m/%d/%Y') ExitDate,
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
			group by LastName, FirstName, DOB, Grade, enrolledDate, schoolDistrict, program
		</cfquery>
		<cfset Session.exitStatusReport = data>
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
				,sum(Attendance) DaysPresent
				,sum(MaxPossibleAttendance)-sum(Attendance) DaysAbsent
				,Program, SchoolDistrict, beginDate, endDate
			from (
				select bs.contactId, bsNext.exitDate
					,bsp.FirstName, bsp.LastName, bs.Program, schooldistrict
					,beginDate, endDate
					,MIN(bs.billingStartDate) entryDate
					,MAX(bs.billingStartDate) maxBillingDate
					,MAX(bs.billingStudentId) maxbillingStudentId
					,MAX(CASE WHEN bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
							  THEN bs.AdjustedIndHours ELSE 0
						END) AdjustedIndHours
				from (select BillingStartDate beginDate, billingEndDate endDate from billingStudent where billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#"> limit 1) dates,
					billingStudent bs
					join billingStudentProfile bsp on bs.contactId = bsp.contactId
					join keySchoolDistrict sd on bs.districtId = sd.keySchoolDistrictId
					left outer join billingStudent bsNext on bs.contactId = bsNext.contactID
						and bs.program = bsNext.program
			            and bs.DistrictID = bsNext.DistrictID
						and bsNext.billingStartDate >= bs.billingStartDate
			            and bsNext.ExitDate is not null
				where bs.billingStartDate <= <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
					and bs.term in (select term from bannerCalendar where programYear = (select max(ProgramYear) from bannerCalendar where TermBeginDate <= <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#"> ))
					and bs.includeFlag = 1
					and bs.program like '%attendance%'
					<cfif structKeyExists(arguments, "program")>
					and bs.program = <cfqueryparam value="#arguments.program#">
					</cfif>
					<cfif structKeyExists(arguments, "districtid")>
					and bs.districtid = <cfqueryparam value="#arguments.districtid#">
					</cfif>
				group by bs.contactId, bsNext.exitDate, bs.program, schooldistrict, beginDate, endDate
			) bs
				left outer join billingStudentItem bsi on bs.maxBillingStudentId = bsi.billingStudentId
					and bsi.IncludeFlag = 1
					and bs.maxBillingDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			group by contactId, exitDate, FirstName, LastName, entryDate, maxBillingDate, maxBillingStudentId
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
	<cffunction name="overageReport1" access="remote">
		<cfargument name="gtcOrYes" required="true">
		<cfquery name="data">
			SELECT bsp.firstName, bsp.lastName, bs.bannerGNumber, substring_index(statusIDCoach,'|',-1) Coach,
				MAX(billingStudentId) billingStudentId,
				SUM(coalesce(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount,0)) Days,
    			SUM(coalesce(FinalBilledUnits, CorrectedBilledUnits, GeneratedBilledUnits,0)) Credits,
                MAX(bs.Term) MaxTerm
			FROM billingStudent bs
				join billingStudentProfile bsp on bs.contactId = bsp.contactId
				JOIN bannerCalendar bc on bs.term = bc.term
                LEFT OUTER JOIN (SELECT contactID, max(concat(status.statusDate,'|', res.rsName)) statusIDCoach
		   			  FROM status
						join statusResourceSpecialist sres on status.statusId = sres.statusID
						JOIN keyResourceSpecialist res
							ON sres.keyResourceSpecialistID = res.keyResourceSpecialistID
           			  WHERE keyStatusID = 6
						and undoneStatusID is null
          			  GROUP BY contactID) coach
					ON coach.contactID = bs.contactID
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
		<cfset bannerYear = LEFT(arguments.programyear,4)>

		<cfquery name="data">
			select bs.contactId,
				bs.Program,
				bsp.LastName,
				bsp.FirstName,
				fnGetGrade(dob, #bannerYear#) Grade,
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

	<cffunction name="attendanceEntry" returntype="query" returnformat="json"  access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfargument name="noHoursOnly" required="false" default="false">
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
				,SUM(CASE WHEN Attendance = 0 THEN 1 ELSE 0 END) NumStudentsNoHours
			from(
			select bs.billingStudentId, sum(IFNULL(Attendance,0)) Attendance
			from billingStudent bs
				left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
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
				left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
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
				left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
			group by bs.bannerGNumber, bsp.FirstName, bsp.LastName
			having sum(IFNULL(Attendance,0)) = 0
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
			where bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
			group by crn, subj, crse, Title
			having sum(IFNULL(Attendance,0)) = 0
			order by subj, crse
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="prevBillingPeriodComparison" returnformat="json" access="remote" >
		<cfargument name="billingStartDate" required="true">
		<cfquery name="prevPeriod">
			select contactId, max(billingStartDate) billingStartDate
			from billingStudent
			where billingStartDate < <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			group by contactId
		</cfquery>
		<cfquery name="data">
			select bsPrev.bannerGNumber, bsp.FirstName, bsp.LastName, bsPrev.program PreviousProgram, bsPrev.exitDate PreviousExitDate, IFNULL(bsCurrent.program, 'Missing!') CurrentProgram,  bsPrev.billingStudentId
            from billingStudent bsPrev
				join (select contactId, max(billingStartDate) billingStartDate
						from billingStudent
						where billingStartDate < <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
						group by contactId) prevPer on bsPrev.contactId = prevPer.contactId
							and prevPer.billingStartDate = bsPrev.billingStartDate
				join billingStudentProfile bsp on bsPrev.contactId = bsp.contactId
				left outer join billingStudent bsCurrent on bsPrev.ContactID = bsCurrent.contactID
					 and bsCurrent.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			where (bsCurrent.billingStudentId is null and bsPrev.exitDate is null)
					or (bsPrev.program != bsCurrent.program and (bsPrev.exitDate is null or bsPrev.exitDate >= <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">))
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
</cfcomponent>