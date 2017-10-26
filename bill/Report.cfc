<cfcomponent displayname="report">
	<cfinclude template="/pcclinks/includes/logfunctions.cfm">

	<cffunction name="calculateBilling" access="remote">
		<cfargument name="billingType" require="true">
		<cfargument name="term" required ="true">
		<cfargument name="billingStartDate">
		<cfargument name="maxCreditsPerTerm" >
		<cfargument name="maxDaysPerYear">
		<cfargument name="maxDaysPerMonth" >
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
								and bsSub.billingStatus = 'IN PROGRESS'
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
			<cfquery name="updateAttendance1">
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
					and bs.billingStatus = 'IN PROGRESS'
					and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
			</cfquery>
			<cfquery name="updateAttendance2">
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
					    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
					where bsi.includeFlag = 1
						and bs.Program like '%attendance%'
						and bs.billingStatus = 'IN PROGRESS'
						and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">) data
					group by billingStudentId) finalData
				on billingStudent.billingStudentId = finalData.billingStudentId
		        set GeneratedBilledAmount  = round(IFNULL(case when BilledAmount > <cfqueryparam value="#arguments.maxDaysPerMonth#"> then <cfqueryparam value="#arguments.maxDaysPerMonth#"> else BilledAmount end,0),2),
					GeneratedOverageAmount = round(IFNULL(case when BilledAmount > <cfqueryparam value="#arguments.maxDaysPerMonth#"> then BilledAmount - <cfqueryparam value="#arguments.maxDaysPerMonth#"> else 0 end,0),2),
					SmGroupPercent = 0.333,
					InterGroupPercent = 0.222,
					LargeGroupPercent = 0.167,
					CMPercent = 0.0167,
					MaxDaysPerMonth = <cfqueryparam value="#arguments.maxDaysPerMonth#">
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="billingReport" returntype="query" access="remote">
		<!--- arguments --->
		<cfargument name="term" required="true">
		<cfargument name="program" default="">
		<cfargument name="schooldistrict" default="">
		<cfquery name="data" >
			SELECT c.firstname, c.lastname, c.bannergnumber
				,bs.Program
				,schooldistrict.schoolDistrict
				,MIN(Date_Format(bs.billingStartDate, '%m/%d/%Y')) EnrolledDate
				,MAX(Date_Format(bs.reportingStartDate, '%m/%d/%Y')) reportingStartDate
				,MAX(Date_Format(bs.reportingEndDate, '%m/%d/%Y')) reportingEndDate
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
							COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) Days,
							COALESCE(FinalOverageAmount, CorrectedOverageAmount, GeneratedOverageAmount) DaysOver
						FROM billingStudent
						join keySchoolDistrict schooldistrict on billingStudent.DistrictID = schooldistrict.keyschooldistrictid
						WHERE includeFlag = 1 and program = <cfqueryparam value=#arguments.program#>
								and schooldistrict.schooldistrict = <cfqueryparam value=#arguments.schooldistrict#>
								and term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value=#arguments.term#>))
								and COALESCE(PostBillCorrectedBilledAmount, FinalBilledAmount, CorrectedBilledAmount, GeneratedBilledAmount) != 0
					 ) bs
						on c.contactID = bs.contactId
				join bannerCalendar cal on bs.term = cal.Term
				join keySchoolDistrict schooldistrict on bs.DistrictID = schooldistrict.keyschooldistrictid
			GROUP BY c.firstname, c.lastname, c.bannergnumber
				,bs.Program
				,schooldistrict.schoolDistrict
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
				,COALESCE(bs.PostBillCorrectedBilledAmount, bs.FinalBilledAmount, bs.CorrectedBilledAmount, bs.GeneratedBilledAmount) BilledAmount
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

	<cffunction name="attendanceReportDetail" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfquery name="data">
			select c.firstname, c.lastname, c.bannerGNumber, bs.billingStartDate
				,ROUND(bsi.Attendance,2) Attendance, bsi.CRN, bsi.Scenario, IndPercent, SmallPercent, InterPercent, LargePercent
				,ROUND(IFNULL(bsi.Attendance,0)*IndPercent,2) as Ind
				,ROUND(IFNULL(bsi.Attendance,0)*SmallPercent,2) as Small
				,ROUND(IFNULL(bsi.Attendance,0)*InterPercent,2) as Inter
				,ROUND(IFNULL(bsi.Attendance,0)*LargePercent,2) as Large
			from contact c
				join billingStudent bs on c.contactID = bs.contactID
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bs.billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="closeBillingCycle" access="remote">
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" >
		<cfargument name="billingType" required="true">
		<cfquery name="update">
			update billingStudent
			set billingStatus = 'COMPLETE',
				FinalBilledUnits = COALESCE(CorrectedBilledUnits, GeneratedBilledUnits),
				FinalOverageUnits = COALESCE(CorrectedOverageUnits, GeneratedOverageUnits),
				FinalBilledAmount = COALESCE(CorrectedBilledAmount, GeneratedBilledAmount),
				FinalOverageAmount = COALESCE(CorrectedOverageAmount, GeneratedOverageAmount)
			where term = <cfqueryparam value="#arguments.term#">
				<cfif arguments.billingType EQ 'attendance'>
					and billingStartDate =<cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
					and program like '%attendance%'
				<cfelse>
					and program not like '%attendance%'
				</cfif>
		</cfquery>
	</cffunction>

	<cffunction name="getBillingStudentRecord" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfquery name="data">
			select bs.*, c.firstname, c.lastname, sd.schooldistrict
			from billingStudent bs
				join contact c on bs.contactid = c.contactid
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
		<cfargument name="program" required="true">
		<cfargument name="billingNotes" required="true">
		<cfargument name="includeFlag" default="0">
		<cfargument name="exitDate" required="true">
		<cfargument name="adjustedDaysPerMonth" default="">
		<cfargument name="billingRecordExitReasonCode" default="">
		<cfargument name="postBillCorrectedBilledAmount" default="">
		<cfargument name="generatedBilledAmount">
		<cfargument name="billingStudentExitReasonCode" default="">

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
				 program = <cfqueryparam value="#arguments.program#">,
				 billingNotes = <cfqueryparam value="#arguments.billingNotes#">,
				 includeFlag = <cfqueryparam value="#arguments.includeFlag#">,
				 exitDate = <cfif arguments.exitDate EQ "">NULL<cfelse><cfqueryparam value="#DateFormat(arguments.exitDate,'yyyy-mm-dd')#"></cfif>
			WHERE billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
	</cffunction>
	<cffunction name="exitStatusReport"  returntype="query" returnformat="json"  access="remote">
		<cfargument name="term" required="true">
		<cfargument name="program">
		<cfargument name="districtid">
		<cfquery name="data">
			select LastName,
				FirstName,
				DATE_FORMAT(DOB, '%m/%d/%Y') DOB,
				'Grade',
				min(DATE_FORMAT(billingStartDate, '%m/%d/%Y')) EntryDate,
				DATE_FORMAT(ExitDate, '%m/%d/%Y') ExitDate,
				billingStudentExitReasonCode 'ExitReason',
				program,
				schoolDistrict
			from (select c.firstname, c.lastname, c.bannerGNumber, c.dob
							,bs.billingStudentId, bs.billingStartDate, bs.exitdate
			                ,bs.billingStudentExitReasonCode, schoolDistrict, program
						from contact c
							join billingStudent bs on c.contactID = bs.contactID
						    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
						where bs.term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value="#arguments.term#">))
							<cfif structKeyExists(arguments, "program")>
								and bs.program = <cfqueryparam value="#arguments.program#">
							</cfif>
							<cfif structKeyExists(arguments, "districtid")>
								and bs.districtid = <cfqueryparam value="#arguments.districtid#">
							</cfif>
				) data
			group by LastName, FirstName, DOB, 'Grade', ExitDate, BillingStudentExitReasonCode, schoolDistrict, program
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="admReport"  returntype="query" returnformat="json"  access="remote">
		<cfargument name="billingStartDate" required="true">
		<cfargument name="program">
		<cfargument name="districtid">
		<cfquery name="data">
			select LastName, FirstName,
				Date_Format(EntryDate,'%m/%d/%Y') EntryDate,
				Date_Format(ExitDate,'%m/%d/%Y') ExitDate,
				sum(large) LargeGrp,
				sum(inter) InterGrp,
				sum(small) SmallGrp,
				sum(ind) Tutorial
			from (
			select bs.billingStudentId, bs.contactId
				,bsi.Attendance
				,bsi.Attendance*IFNULL(IndPercent,0) as Ind
				,bsi.Attendance*IFNULL(SmallPercent,0) as Small
				,bsi.Attendance*IFNULL(InterPercent,0) as Inter
				,bsi.Attendance*IFNULL(LargePercent,0) as Large
			from billingStudent bs
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
			join contact on data.contactId = contact.contactId
		    join (select contactId, max(exitDate) ExitDate, min(billingStartDate) EntryDate
				  from billingStudent
		          group by contactId) bs2 on contact.contactid = bs2.contactId
			group by lastname, firstname, entrydate, exitdate
		</cfquery>
		<cfreturn data>
	</cffunction>
</cfcomponent>