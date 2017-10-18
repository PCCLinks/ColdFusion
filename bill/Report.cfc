<cfcomponent displayname="report">
	<cfinclude template="/pcclinks/includes/logfunctions.cfm">

	<cffunction name="generateBilling" access="remote">
		<cfargument name="billingType" require="true">
		<cfargument name="term" required ="true">
		<cfquery name="updateData">
			<cfif arguments.billingType EQ 'Term'>
				update billingStudent bs
				join (
					select billingStudentId,
						CASE WHEN creditYearTotal > 36 THEN creditYearTotal - 36 ELSE 0 END GeneratedOverageUnits,
						CASE WHEN creditYearTotal > 36
								THEN CASE WHEN (creditYearTotal - creditCurrentCycleTotal -36) < 0 THEN creditYearTotal - 36 ELSE 0 END
								ELSE creditCurrentCycleTotal
						END GeneratedBilledUnits
					from (select bsSub.billingStudentId, SUM(bsi.Credits) creditYearTotal, SUM(CASE term WHEN <cfqueryparam value=#arguments.term#> THEN bsi.Credits ELSE 0 END) creditCurrentCycleTotal
						  from billingStudent bsSub
							join billingStudentItem bsi on bsSub.BillingStudentID = bsi.BillingStudentID
							join keySchoolDistrict schooldistrict on bsSub.DistrictID = schooldistrict.keyschooldistrictid
							where bsi.includeFlag = 1
								and bsSub.Program not like '%attendance%'
								and bsSub.billingStatus = 'IN PROGRESS'
							group by bsSub.billingStudentId) data
					)finalData
					on bs.billingStudentId = finalData.billingStudentId
			set bs.GeneratedOverageUnits = finalData.GeneratedOverageUnits,
				bs.GeneratedBilledUnits =  finalData.GeneratedBilledUnits,
				bs.GeneratedBilledAmount = ROUND(finalData.GeneratedBilledUnits /36*175,4),
				bs.GeneratedOverageAmount = ROUND(finalData.GeneratedOverageUnits /36*175,4)
			<cfelse>
				update billingStudent
					join
		            (
		            select billingStudentId,
						truncate(sum(ind) + sum(small)*0.333 + sum(inter)*0.222 + sum(large)*0.167 + sum(ind + small + inter + large)*0.0167, 2) BilledAmount
		            from (
		            select bs.billingStudentId
						,bsi.Attendance
						,bsi.Attendance*IFNULL(IndPercent,0) as Ind
						,bsi.Attendance*IFNULL(SmallPercent,0) as Small
						,bsi.Attendance*IFNULL(InterPercent,0) as Inter
						,bsi.Attendance*IFNULL(LargePercent,0) as Large
					from billingStudent bs
						join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
					    join billingScenarioByCourse bsbc  on bsi.CRN = bsbc.CRN
						join billingScenario bsc on bsbc.billingScenarioId = bsc.billingScenarioId
					    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
					where bsi.includeFlag = 1
						and bs.Program like '%attendance%'
						and bs.billingStatus = 'IN PROGRESS') data
					group by billingStudentId) finalData
				on billingStudent.billingStudentId = finalData.billingStudentId
		        set GeneratedBilledAmount  = round(IFNULL(case when BilledAmount > 20 then 20 else BilledAmount end,0),2),
					GeneratedOverageAmount = round(IFNULL(case when BilledAmount > 20 then BilledAmount - 20 else 0 end,0),2)
			</cfif>
		</cfquery>
	</cffunction>

	<cffunction name="billingReport" returntype="query" access="remote">
		<!--- arguments --->
		<cfargument name="term" required="true">
		<cfargument name="program" default="">
		<cfargument name="schooldistrict" default="">
		<cfquery name="data" >
			SELECT c.firstname, c.lastname, c.bannergnumber
				,Date_Format(bs.billingStartDate, '%m/%d/%Y') EnrolledDate
				,bs.Program
				,schooldistrict.schoolDistrict
				,Date_Format(bs.reportingStartDate, '%m/%d/%Y') reportingStartDate
				,Date_Format(bs.reportingEndDate, '%m/%d/%Y') reportingEndDate
				,MAX(Date_Format(bs.ExitDate, '%m/%d/%Y')) ExitDate
				,SUM(case when cal.ProgramQuarter = 1 then bs.Credits else 0 end) SummerNoOfCredits
				,SUM(case when cal.ProgramQuarter = 1 then bs.Days else 0 end) SummerNoOfDays
				,MAX(case when cal.ProgramQuarter = 1 then bs.billingStudentId else 0 end) BillingStudentIdSummer
				,SUM(case when cal.ProgramQuarter = 2 then bs.Credits+bs.CreditsOver else 0 end) FallNoOfCredits
				,SUM(case when cal.ProgramQuarter = 2 then bs.CreditsOver else 0 end) FallNoOfCreditsOver
				,SUM(case when cal.ProgramQuarter = 2 then bs.Days+bs.DaysOver else 0 end) FallNoOfDays
				,SUM(case when cal.ProgramQuarter = 2 then bs.DaysOver else 0 end) FallNoOfDaysOver
				,MAX(case when cal.ProgramQuarter = 2 then bs.billingStudentId else 0 end) BillingStudentIdFall
				,SUM(case when cal.ProgramQuarter = 3 then bs.Credits+bs.CreditsOver else 0 end) WinterNoOfCredits
				,SUM(case when cal.ProgramQuarter = 3 then bs.CreditsOver else 0 end) WinterNoOfCreditsOver
				,SUM(case when cal.ProgramQuarter = 3 then bs.Days+bs.DaysOver else 0 end) WinterNoOfDays
				,SUM(case when cal.ProgramQuarter = 3 then bs.DaysOver else 0 end) WinterNoOfDaysOver
				,MAX(case when cal.ProgramQuarter = 3 then bs.billingStudentId else 0 end) BillingStudentIdWinter
				,SUM(case when cal.ProgramQuarter = 4 then bs.Credits+bs.CreditsOver else 0 end) SpringNoOfCredits
				,SUM(case when cal.ProgramQuarter = 4 then bs.CreditsOver else 0 end) SpringNoOfCreditsOver
				,SUM(case when cal.ProgramQuarter = 4 then bs.Days+bs.DaysOver else 0 end) SpringNoOfDays
				,SUM(case when cal.ProgramQuarter = 4 then bs.DaysOver else 0 end) SpringNoOfDaysOver
				,MAX(case when cal.ProgramQuarter = 4 then bs.billingStudentId else 0 end) BillingStudentIdSpring
				,SUM(bs.Credits+bs.CreditsOver) FYTotalNoOfCredits
				,SUM(bs.Credits) FYMaxTotalNoOfCredits
				,SUM(bs.Days+bs.DaysOver) FYTotalNoOfDays
				,SUM(bs.Days) FYMaxTotalNoOfDays
			FROM contact c
				join (SELECT contactId, billingStudentId, Term,  billingStartDate, DistrictID, Program, ExitDate, reportingStartDate, reportingEndDate,
						    COALESCE(FinalBilledUnits, CorrectedBilledUnits, GeneratedBilledUnits) Credits,
							COALESCE(FinalOverageUnits, CorrectedOverageUnits, GeneratedOverageUnits) CreditsOver,
							COALESCE(FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) Days,
							COALESCE(FinalOverageAmount, CorrectedOverageAmount, GeneratedOverageAmount) DaysOver
						FROM billingStudent
						join keySchoolDistrict schooldistrict on billingStudent.DistrictID = schooldistrict.keyschooldistrictid
						WHERE includeFlag = 1 and program = <cfqueryparam value=#arguments.program#>
								and schooldistrict.schooldistrict = <cfqueryparam value=#arguments.schooldistrict#>
								and term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value=#arguments.term#>))
					 ) bs
						on c.contactID = bs.contactId
				join bannerCalendar cal on bs.term = cal.Term
				join keySchoolDistrict schooldistrict on bs.DistrictID = schooldistrict.keyschooldistrictid
			GROUP BY c.firstname, c.lastname, c.bannergnumber
				,bs.billingStartDate
				,bs.Program
				,schooldistrict.schoolDistrict
				,reportingStartDate
				,reportingEndDate
			HAVING sum(bs.Credits) <> 0
			ORDER BY c.lastname, c.firstname
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="attendanceReport" access="remote">
		<cfargument name="monthStartDate" type="date" required="true">
		<cfargument name="term" required="true">
		<cfargument name="program" required="true">
		<cfargument name="schooldistrict" required="true">
		<cfquery name="data">
			select concat(lastname,', ',firstname) name, bannerGNumber, DATE_FORMAT(dob,'%m/%d/%Y') dob, MAX(DATE_FORMAT(exitdate,'%m/%d/%Y')) exitDate,
				MIN(DATE_FORMAT(billingStartDate,'%m/%d/%Y')) enrolledDate,
				MIN(DATE_FORMAT(reportingStartDate, '%m/%d/%Y')) reportingStartDate, MAX(DATE_FORMAT(ReportingEndDate, '%m/%d/%Y')) ReportingEndDate,
				20.0 Enrl,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 6 then billedAmount end,0),1)) Jun,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 7 then billedAmount end,0),1)) Jul,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 8 then billedAmount end,0),1)) Aug,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 9 then billedAmount end,0),1)) Sept,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 10 then billedAmount end,0),1)) Oct,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 11 then billedAmount end,0),1)) Nov,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 12 then billedAmount end,0),1)) `Dec`,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 1 then billedAmount end,0),1)) Jan,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 2 then billedAmount end,0),1)) Feb,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 3 then billedAmount end,0),1)) Mar,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 4 then billedAmount end,0),1)) Apr,
				SUM(ROUND(IFNULL(case when month(billingStartDate) = 5 then billedAmount end,0),1)) May,
				MAX(case when month(billingStartDate) = 6 then billingStudentId else 0 end) JunBillingStudentId,
				MAX(case when month(billingStartDate) = 7 then billingStudentId else 0 end) JulBillingStudentId,
				MAX(case when month(billingStartDate) = 8 then billingStudentId else 0 end) AugBillingStudentId,
				MAX(case when month(billingStartDate) = 9 then billingStudentId else 0 end) SeptBillingStudentId,
				MAX(case when month(billingStartDate) = 10 then billingStudentId else 0 end) OctBillingStudentId,
				MAX(case when month(billingStartDate) = 11 then billingStudentId else 0 end) NovBillingStudentId,
				MAX(case when month(billingStartDate) = 12 then billingStudentId else 0 end) DecBillingStudentId,
				MAX(case when month(billingStartDate) = 1 then billingStudentId else 0 end) JanBillingStudentId,
				MAX(case when month(billingStartDate) = 2 then billingStudentId else 0 end) FebBillingStudentId,
				MAX(case when month(billingStartDate) = 3 then billingStudentId else 0 end) MarBillingStudentId,
				MAX(case when month(billingStartDate) = 4 then billingStudentId else 0 end) AprBillingStudentId,
				MAX(case when month(billingStartDate) = 5 then billingStudentId else 0 end) MayBillingStudentId
			from
            ( select c.firstname, c.lastname, c.bannerGNumber, c.dob
				,bs.billingStudentId, bs.billingStartDate, bs.exitdate
				,bs.reportingStartDate, bs.reportingEndDate
				,COALESCE(bs.FinalBilledAmount, bs.CorrectedBilledAmount, bs.GeneratedBilledAmount) BilledAmount
			from contact c
				join billingStudent bs on c.contactID = bs.contactID
			    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bs.program = <cfqueryparam value="#arguments.program#">
				and sd.schoolDistrict = <cfqueryparam value="#arguments.schooldistrict#">
				and bs.term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value=#arguments.term#>))
			) data
			group by lastname, firstname, bannerGNumber, dob
			order by lastname, firstname
		</cfquery>
		<cfreturn data>
	</cffunction>

</cfcomponent>