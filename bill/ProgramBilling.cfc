<cfcomponent displayname="programbilling">

	<cfinclude template="/pcclinks/includes/logfunctions.cfm">

	<cffunction name="billingReport" returntype="query" access="remote">
		<!--- arguments --->
		<cfargument name="term" required="true">
		<cfargument name="program" default="">
		<cfargument name="schooldistrict" default="">

		<cfquery name="updateData">
			update billingStudent bs
			join (
				select billingStudentId,
					CASE WHEN creditYearTotal > 36 THEN creditYearTotal - 36 ELSE 0 END GeneratedOverageUnits,
					CASE WHEN creditYearTotal > 36
							THEN CASE WHEN (creditYearTotal - creditCurrentCycleTotal -36) < 0 THEN creditYearTotal - 36 ELSE 0 END
							ELSE creditCurrentCycleTotal
					END GeneratedBilledUnits
				from (select bsSub.billingStudentId, SUM(bsi.CourseValue) creditYearTotal, SUM(CASE term WHEN <cfqueryparam value=#arguments.term#> THEN bsi.CourseValue ELSE 0 END) creditCurrentCycleTotal
					  from billingStudent bsSub
						join billingStudentItem bsi on bsSub.BillingStudentID = bsi.BillingStudentID
						join keySchoolDistrict schooldistrict on bsSub.DistrictID = schooldistrict.keyschooldistrictid
						where bsi.includeFlag = 1
							and bsSub.Program = <cfqueryparam value=#arguments.program#>
							and schooldistrict.schooldistrict = <cfqueryparam value=#arguments.schooldistrict#>
							and term in (select term from bannerCalendar where programYear = (select programYear from bannerCalendar where term = <cfqueryparam value=#arguments.term#>))
						group by bsSub.billingStudentId) data
				)finalData
				on bs.billingStudentId = finalData.billingStudentId
		set bs.GeneratedOverageUnits = finalData.GeneratedOverageUnits,
			bs.GeneratedBilledUnits =  finalData.GeneratedBilledUnits,
			bs.GeneratedBilledAmount = ROUND(finalData.GeneratedBilledUnits /36*175,4),
			bs.GeneratedOverageAmount = ROUND(finalData.GeneratedOverageUnits /36*175,4)
		</cfquery>

		<cfquery name="data" >
			SELECT c.firstname, c.lastname, c.bannergnumber
				,Date_Format(bs.billingStartDate, '%m/%d/%Y') EnrolledDate
				,bs.Program
				,Date_Format(bs.ExitDate, '%m/%d/%Y') ExitDate
				,schooldistrict.schoolDistrict
				,Date_Format(bs.reportingStartDate, '%m/%d/%Y') reportingStartDate
				,Date_Format(bs.reportingEndDate, '%m/%d/%Y') reportingEndDate
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
				,SUM(bs.Credits+bs.CreditsOver) FYTotalNoOfCredits
				,SUM(bs.Credits) FYMaxTotalNoOfCredits
				,SUM(bs.Days+bs.DaysOver) FYTotalNoOfDays
				,SUM(bs.Days) FYMaxTotalNoOfDays
			FROM contact c
				join (SELECT contactId, Term,  billingStartDate, DistrictID, Program, ExitDate, reportingStartDate, reportingEndDate,
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
				,bs.ExitDate
				,schooldistrict.schoolDistrict
				,reportingStartDate
				,reportingEndDate
			HAVING sum(bs.Credits) <> 0
			ORDER BY c.lastname, c.firstname
		</cfquery>
		<cfreturn data>
	</cffunction>



	<!---<cffunction name="billingReport1" returntype="query" access="remote">
		<!--- arguments --->
	<cfargument name="program" default="">
	<cfargument name="schooldistrict" default="">
	<cfargument name="term" default="">
	<cfargument name="bannerGNumber" default="">
	<cfset debug="false">
	<!--- build array to be used to get one program year of datat --->
	<cfset quarters = ArrayNew(1)>
	<cfif right(arguments.term,2) GT 2>
		<cfset var year1 = left(arguments.term,4) >
		<cfset var year2 = year1+1>
	<cfelse>
		<cfset var year2 = left(arguments.term,4) >
		<cfset var year1 = year2-1>
	</cfif>
	<cfset quarters[1] = year1 & "03">
	<cfset quarters[2] = year1 & "04">
	<cfset quarters[3] = year2 & "01">
	<cfset quarters[4] = year2 & "02">
	<!--- main query --->
	<cfquery name="data" datasource="pcclinks" result="r">
			select c.firstname, c.lastname, c.bannergnumber
				,Date_Format(currentEnrolledStatus.StatusDate, '%m/%d/%Y') CurrentEnrolledDate
				,CASE WHEN currentEnrolledStatus.program = 'ytc' THEN keyStatus.statusText ELSE currentEnrolledStatus.program END CurrentProgram
				,Date_Format(currentExitStatus.StatusDate, '%m/%d/%Y') CurrentExitDate
				,keySchoolDistrict.schoolDistrict CurrentSchoolDistrict, bs.*, sd.schooldistrict billedschooldistrict,
				<cfif right(arguments.term,1) EQ 3>
					CAST(IFNULL(SummerNoOfClasses,0) as unsigned) FYTotalNoOfClasses,
					CAST(IFNULL(SummerNoOfClasses,0) as unsigned) CurrentTermNoOfClasses,
					CAST(IFNULL(SummerNoOfCredits,0) as unsigned) FYTotalNoOfCredits,
					CAST(IFNULL(SummerNoOfCredits,0) as unsigned) CurrentTermNoOfCredits,
					BSIDQ1 CurrentBillingStudentID
				</cfif>
				<cfif right(arguments.term,1) EQ 4>
					CAST((IFNULL(SummerNoOfClasses,0) + IFNULL(FallNoOfClasses,0)) as unsigned) FYTotalNoOfClasses,
					CAST(IFNULL(FallNoOfClasses,0) as unsigned) CurrentTermNoOfClasses,
					CAST((IFNULL(SummerNoOfCredits,0) + IFNULL(FallNoOfCredits,0)) as unsigned) FYTotalNoOfCredits,
					CAST(IFNULL(FallNoOfCredits,0) as unsigned) CurrentTermNoOfCredits,
					BSIDQ2 CurrentBillingStudentID
				</cfif>
				<cfif right(arguments.term,1) EQ 1>
					CAST((IFNULL(SummerNoOfClasses,0) + IFNULL(FallNoOfClasses,0) + IFNULL(WinterNoOfClasses,0)) as unsigned) FYTotalNoOfClasses,
					CAST(IFNULL(WinterNoOfClasses,0) as unsigned) CurrentTermNoOfClasses,
					CAST((IFNULL(SummerNoOfCredits,0) + IFNULL(FallNoOfCredits,0) + IFNULL(WinterNoOfCredits,0)) as unsigned) FYTotalNoOfCredits,
					CAST(IFNULL(WinterNoOfCredits,0) as unsigned) CurrentTermNoOfCredits,
					BSIDQ3 CurrentBillingStudentID
				</cfif>
				<cfif right(arguments.term,1) EQ 2>
					CAST((IFNULL(SummerNoOfClasses,0) + IFNULL(FallNoOfClasses,0) + IFNULL(WinterNoOfClasses,0) + IFNULL(SpringNoOfClasses,0)) as unsigned) FYTotalNoOfClasses,
					CAST(IFNULL(SpringNoOfClasses,0) as unsigned) CurrentTermNoOfClasses,
					CAST((IFNULL(SummerNoOfCredits,0) + IFNULL(FallNoOfCredits,0) + IFNULL(WinterNoOfCredits,0) + IFNULL(SpringNoOfClasses,0)) as unsigned) FYTotalNoOfCredits,
					CAST(IFNULL(SpringNoOfClasses,0) as unsigned) CurrentTermNoOfCredits,
					BSIDQ4 CurrentBillingStudentID
				</cfif>
			from contact c
			    join status currentEnrolledStatus on c.contactID = currentEnrolledStatus.contactID
					and currentEnrolledStatus.statusID = (select statusid from sidny.status where keyStatusID IN (2,13,14,15,16) and contactid = c.contactid and undoneStatusID is null order by statusdate desc limit 1)
				<cfif len(#arguments.bannerGNumber#) GT 0>
			    	and c.bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
			    </cfif>
			    join keyStatus keyStatus on currentEnrolledStatus.keyStatusID = keyStatus.keyStatusID
			    left outer join status currentExitStatus on c.contactID = currentExitStatus.contactID
					and currentExitStatus.statusID = (select statusid from sidny.status where keyStatusID = 3 and contactid = c.contactid and statusDate >= currentEnrolledStatus.statusDate and undoneStatusID is null order by statusdate desc limit 1)
			    join status currentSchoolStatus on c.contactid = currentSchoolStatus.contactID
					and currentSchoolStatus.statusID = (select statusID from sidny.status where keyStatusID = 7 and contactid = c.contactid and undoneStatusID is null order by statusdate desc limit 1)
				join statusSchoolDistrict statusSchoolDistrict on currentSchoolStatus.statusid = statusSchoolDistrict.statusID
			    join keySchoolDistrict keySchoolDistrict on statusSchoolDistrict.keySchoolDistrictID = keySchoolDistrict.keySchoolDistrictID
			    join (select contactid, districtid, program, enrolleddate, exitdate, MAX(BillingDate) BillingDate, MAX(BillingStatus) BillingStatus, MAX(BSIDQ1) BSIDQ1, MAX(BSIDQ2) BSIDQ2, MAX(BSIDQ3) BSIDQ3, MAX(BSIDQ4) BSIDQ4
			    		,sum(SummerNoOfClasses) SummerNoOfClasses
			    		,sum(SummerNoOfCredits) SummerNoOfCredits
			    		,sum(FallNoOfClasses) FallNoOfClasses
			    		,sum(FallNoOfCredits) FallNoOfCredits
			    		,sum(WinterNoOfClasses) WinterNoOfClasses
			    		,sum(WinterNoOfCredits) WinterNoOfCredits
			    		,sum(SpringNoOfClasses) SpringNoOfClasses
			    		,sum(SpringNoOfCredits) SpringNoOfCredits
					from(
					select bs.contactID, bs.Districtid, program, enrolleddate, exitdate
							,CASE bs.term WHEN #term# THEN bs.BillingDate ELSE NULL END BillingDate
							,CASE bs.term WHEN #term# THEN bs.BillingStatus ELSE NULL END BillingStatus
							,bs.BillingStudentID BSIDQ1, NULL BSIDQ2, NULL BSIDQ3, NULL BSIDQ4,  count(*) SummerNoOfClasses, sum(bsi.coursevalue) SummerNoOfCredits, Null FallNoOfClasses, Null FallNoOfCredits, NULL WinterNoOfClasses, NULL WinterNoOfCredits, NULL SpringNoOfClasses, NULL SpringNoOfCredits
					from billingStudent bs
						join billingStudentItem bsi on bs.BillingStudentid = bsi.billingstudentid
					where bs.includeflag = 1 and bsi.includeflag = 1 and bs.term = #quarters[1]#
					group by bs.contactid, bs.districtid, program, enrolleddate, exitdate
					union
					select bs.contactID, bs.Districtid, program, enrolleddate, exitdate
							,CASE bs.term WHEN #term# THEN bs.BillingDate ELSE NULL END BillingDate
							,CASE bs.term WHEN #term# THEN bs.BillingStatus ELSE NULL END BillingStatus
							,NULL BSIDQ1, bs.BillingStudentID BSIDQ2, NULL BSIDQ3, NULL BSIDQ4,  NULL SummerNoOfClasses, NULL SummerNoOfCredits, count(*) FallNoOfClasses, sum(bsi.coursevalue) FallNoOfCredits, NULL WinterNoOfClasses, NULL WinterNoOfCredits, NULL SpringNoOfClasses, NULL SpringNoOfCredits
					from billingStudent bs
						join billingStudentItem bsi on bs.BillingStudentid = bsi.billingstudentid
					where bs.includeflag = 1 and bsi.includeflag = 1 and bs.term = #quarters[2]#
					group by bs.contactid, bs.districtid, program, enrolleddate, exitdate
					union
					select bs.contactID, bs.Districtid, program, enrolleddate, exitdate
							,CASE bs.term WHEN #term# THEN bs.BillingDate ELSE NULL END BillingDate
							,CASE bs.term WHEN #term# THEN bs.BillingStatus ELSE NULL END BillingStatus
							,NULL BSIDQ1, NULL BSIDQ2, bs.BillingStudentID BSIDQ3, NULL BSIDQ4,  NULL SummerNoOfClasses, NULL SummerNoOfCredits, null FallNoOfClasses, null FallNoOfCredits, count(*) WinterNoOfClasses, sum(bsi.coursevalue) WinterNoOfCredits, NULL SpringNoOfClasses, NULL SpringNoOfCredits
					from billingStudent bs
						join billingStudentItem bsi on bs.BillingStudentid = bsi.billingstudentid
					where bs.includeflag = 1 and bsi.includeflag = 1 and bs.term = #quarters[3]#
					group by bs.contactid, bs.districtid, program, enrolleddate, exitdate
					union
					select bs.contactID, bs.Districtid, program, enrolleddate, exitdate
							,CASE bs.term WHEN #term# THEN bs.BillingDate ELSE NULL END BillingDate
							,CASE bs.term WHEN #term# THEN bs.BillingStatus ELSE NULL END BillingStatus
							,NULL BSIDQ1, NULL BSIDQ2, NULL BSIDQ3, bs.BillingStudentID BSIDQ4,  NULL SummerNoOfClasses, NULL SummerNoOfCredits, null FallNoOfClasses, null FallNoOfCredits, NULL WinterNoOfClasses, NULL WinterNoOfCredits, count(*) SpringNoOfClasses, sum(bsi.coursevalue) SpringNoOfCredits
					from billingStudent bs
						join billingStudentItem bsi on bs.BillingStudentid = bsi.billingstudentid
					where bs.includeflag = 1 and bsi.includeflag = 1 and bs.term = #quarters[4]#
					group by bs.contactid, bs.districtid, program, enrolleddate, exitdate
					) data
				group by contactid, districtid, program, enrolleddate, exitdate
				) bs
					on bs.contactid = c.contactid
			    join keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
			    where 1=1
			    	<cfif len(#arguments.bannerGNumber#) GT 0>
			    		and c.bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
			    	</cfif>
					<cfif len(#arguments.program#) GT 0>
			    		and bs.program = <cfqueryparam value="#arguments.program#">
			    	</cfif>
			    	<cfif len(#arguments.schooldistrict#) GT 0>
						and sd.schooldistrict = <cfqueryparam value="#arguments.schooldistrict#">
					</cfif>
			    order by lastname, firstname
		</cfquery>
	<cfreturn data>
	</cffunction>
--->

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
		<!--- arguments --->
		<cfargument name="term" default="">
		<cfargument name="program" default="">
		<cfargument name="bannerGNumber" default="">
		<cfif len(arguments.term) EQ 0>
			<cfinvoke component="LookUp" method="getMaxTerm" returnvariable="maxTerm">
			</cfinvoke>
		<cfelse>
			<cfset maxTerm = arguments.term>
		</cfif>
		<cfinvoke component="LookUp" method="getProgramYear" term="#maxTerm#" returnvariable="programYear">
		</cfinvoke>
		<!--- main query --->
		<cfquery name="data" >
			SELECT res.rsName coach
				,bs.BillingStudentId
				,bannerGNumber
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
    			,sum(bsi.CourseValue) FYTotalNoOfCredits
				,sum(case when bsYearly.term = bs.term then CourseValue else 0 end) CurrentTermNoOfCredits
			FROM contact c
				join billingStudent bsYearly on bsYearly.contactId = c.contactId
    			JOIN bannerCalendar on bsYearly.term = bannerCalendar.Term
					and bannerCalendar.ProgramYear = <cfqueryparam value="#programYear#">
				JOIN billingStudent bs on c.contactid = bs.contactID
					and bs.term = bannerCalendar.term
					<cfif len(arguments.term) GT 0>
					and bs.term = <cfqueryparam value="#arguments.term#">
					</cfif>
    			LEFT OUTER JOIN billingStudentItem bsi on bsYearly.BillingStudentID = bsi.BillingStudentID
				JOIN keySchoolDistrict sd on bsYearly.districtid = sd.keyschooldistrictid
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
			WHERE 1=1
			<cfif len(#arguments.program#) GT 0>
				<cfif #arguments.program# EQ 'Ytc'>
					and bs.program like 'YtC%'
			<cfelse>
					and bs.program = <cfqueryparam value="#arguments.program#">
				 </cfif>
		<cfelse>
				and c.bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
				<!---and bs.term = (select max(term) from billingStudent bs join contact c on bs.contactid = c.contactid where c.bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">)--->
			</cfif>
			GROUP BY res.rsName, bannerGNumber, lastname, schooldistrict, bs.enrolleddate, bs.exitdate, bs.program, bs.billingstatus, bs.includeFlag, bs.reviewWithCoachFlag, bs.billingNotes
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="getOtherBilling" returntype="query" access="remote">
		<cfargument name="contactid" required="true">
		<cfargument name="term" required="true">
		<cfquery name="data">
		SELECT bs.BillingStudentId, bs.PIDM, schooldistrict
				,Date_Format(bs.enrolledDate, '%m/%d/%Y') EnrolledDate
				,Date_Format(bs.exitDate, '%m/%d/%Y') ExitDate
				,bs.billingstatus, bs.Program, bs.billingStartDate, bs.ErrorMessage, bs.term
			FROM billingStudent bs
    			JOIN bannerCalendar on bs.term = bannerCalendar.Term
					and bannerCalendar.ProgramYear = (select ProgramYear from bannerCalendar where term = <cfqueryparam value="#arguments.term#">)
 				JOIN keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
		WHERE bs.contactid = <cfqueryparam value="#arguments.contactid#">
			and bs.term != <cfqueryparam value="#arguments.term#">
		ORDER BY bs.term desc
		</cfquery>
		<cfreturn data>
	</cffunction>


	<cffunction name="getProgramStudentList" returntype="query" returnformat="json" access="remote">
		<!--- arguments --->
		<cfargument name="program" type="string">
		<cfargument name="term">
		<cfset debug="false">
		<!--- get the yearly data for the parameters --->
		<cfset var yearlybilling = getProgramStudent(program=#arguments.program#, term = #arguments.term#) >
		<!--- query for the needed subset of columns --->
		<cfquery name="data" dbtype="query" result="r">
			select Coach, bannerGNumber, firstName, lastName, schoolDistrict
				,enrolledDate, exitDate, Program, Term, FYTotalNoOfCredits, CurrentTermNoOfCredits
				, billingStatus
			from yearlybilling
		</cfquery>
		<!--- debug code --->
		<cfif debug>
			<cfdump var="#r#" />
		</cfif>
		<cfif debug>
			<cfdump var="#data#" />
		</cfif>
		<!--- final return  --->
		<cfreturn data>
	</cffunction>


	<cffunction name="selectProgramStudentList2" returntype="query" returnformat="json" access="remote">
		<!--- arguments --->
		<cfargument name="program" type="string">
		<cfargument name="term">
		<cfargument name="schooldistrict" default="">
		<cfargument name="columns" type="array">
		<cfset debug="true">
		<!--- get the yearly data for the parameters --->
		<cfset var yearlybilling = yearlybilling(program=#arguments.program#, term=#arguments.term#, schooldistrict=#arguments.schooldistrict#) >
		<!------------------------------------------------------->
		<!--- build the subset of columns needed for the page --->
		<!------------------------------------------------------->
		<cfset var sql="">
		<cfloop array="#arguments.columns#" item="col">
			<cfset sql = #sql# & #col# & ","  >
		</cfloop>
		<cfset sql = RemoveChars(#sql#, len(#sql#), 1)>
		<cfif debug>
			<cfdump var="#sql#" />
		</cfif>
		<!--- query for the needed subset of columns --->
		<cfquery name="data" dbtype="query" result="r">
			select #sql#
			from yearlybilling
		</cfquery>
		<!--- debug code --->
		<cfif debug>
			<cfdump var="#r#" />
		</cfif>
		<cfif debug>
			<cfdump var="#data#" />
		</cfif>
		<!--- final return  --->
		<cfreturn data>
	</cffunction>


	<cffunction name="groupBySchoolDistrictAndProgram" returntype="query" access="remote">
		<cfargument name="term" required="yes">
		<cfargument name="billingType" required="yes">
		<cfquery name="data">
			select sd.schoolDistrict, bs.Program
				,sum(case when cal.ProgramQuarter = 1 then bsi.CourseValue else 0 END) SummerNoOfCredits
				,sum(case when cal.ProgramQuarter = 2 then bsi.CourseValue else 0 END) FallNoOfCredits
				,sum(case when cal.ProgramQuarter = 3 then bsi.CourseValue else 0 END) WinterNoOfCredits
				,sum(case when cal.ProgramQuarter = 4 then bsi.CourseValue else 0 END) SpringNoOfCredits
			from billingStudent bs
				join billingStudentItem bsi on  bs.BillingStudentID = bsi.BillingStudentID
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
		<cfargument name="gnumber" type="string" default="">
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
           	<cfif len(trim(arguments.gnumber)) >
				sub1_dataByMaxEnrolledDate.bannerGNumber = <cfqueryparam value="#arguments.gnumber#"> and
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
		<cfargument name="gnumber" type="string" default="">
		<cfset debug="false">
		<cfset termcode = #arguments.termyear#&"0"&#arguments.termnumber#>
		<cfquery name="banner" datasource="pcclinks">
			select gnumber, SFRSTCR_TERM_CODE from pcc_links.BannerCoursesReport where SFRSTCR_TERM_CODE = '#termcode#'
		</cfquery>
		<cfif debug>
			<cfdump var="#banner#" />
		</cfif>
		<cfset studentEnrollment=studentenrollment(program=#arguments.program#, gnumber=#arguments.gnumber#)>
		<!--- <cfdump var="#GetMetaData(studentEnrollment)#"> --->
		<cfquery name="studentsWithClassesInTerm" dbtype="query"  result="r">
			select distinct studentEnrollment.*, SFRSTCR_TERM_CODE
			from studentEnrollment, banner
			where studentEnrollment.bannerGNumber = banner.gnumber and
			<cfif len(trim(arguments.gnumber)) >
				bannerGNumber = <cfqueryparam value="#arguments.gnumber#">
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
				<cfoutput><a href="javascript:getStudent('programbillingstudent.cfm?cfdebug', {billingstudentid:'#studentsWithClassesInTerm.billingstudentid#',gNumber:'#studentsWithClassesInTerm.bannerGNumber#',program:'#studentsWithClassesInTerm.program#',enrolledDate:'#studentsWithClassesInTerm.enrolledDate#',exitDate:'#studentsWithClassesInTerm.exitDate#'});">Review</a></cfoutput>
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
		<cfargument name="billingstudentid" type="string" required="no" default="">
		<cfargument name="bannerGNumber" type="string" required="no" default="">
		<cfargument name="term" type="numeric" required="no" default="0">
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
			select *
			from billingStudentItem bsi
				join billingStudent bs on bsi.BillingStudentId=bs.BillingStudentId
				join contact c on bs.contactid = c.contactid
			where 1=1
				<cfif len(#arguments.billingstudentid#) GT 0 >
					and bs.billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
				</cfif>
				<cfif len(#arguments.bannerGNumber#) GT 0>
					and c.bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
						and bs.term = <cfqueryparam value="#arguments.term#">
				</cfif>
		</cfquery>
		<cfreturn data>
	</cffunction>

	<!---<cffunction name ="getBillingEntries" access="remote" returnType="struct">
		<!--- arguments --->
	<cfargument name="page" type="numeric" required="no" default="1">
	<cfargument name="pageSize" type="numeric" required="no" default="40">
	<cfargument name="gridsortcolumn" type="string" required="no">
	<cfargument name="gridsortdir" type="string" required="no">
	<cfargument name="billingstudentid" type="numeric" required="yes">
	<cfargument name="gNumber" type="string" required="yes">
	<cfargument name="program" type="string" required="yes">
	<cfargument name="termcode" type="string" required="yes">
	<!--- debug code --->
	<cfset debug="false">
	<cfif debug>
		<cfdump var="#arguments#" />
	</cfif>
	<!---<cfset billingdate = #arguments.termcode# & "01">--->
	<cfquery name="existingBilling" result="rexistingBilling">
			select distinct bsi.courseid
			from billingStudent bs
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			where
			<cfif len(trim(#arguments.billingstudentid#))>
				bs.billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
		<cfelse>
				gnumber = <cfqueryparam value="#arguments.gnumber#">
					and billingdate = <cfqueryparam value="#billingdate#">
			</cfif>
		</cfquery>
	<cfif debug>
		<cfoutput>
			existingBilling
		</cfoutput>
		<cfdump var="#rexistingBilling#" />
	</cfif>
	<cfquery name="bannerclasses" datasource="pcclinks" result="rbannerclasses">
			select *
			from pcc_links.BannerCoursesReport
			where gnumber = <cfqueryparam value="#arguments.gnumber#">
				and SFRSTCR_TERM_CODE = <cfqueryparam value="#arguments.termcode#">
		</cfquery>
	<cfif debug>
		<cfoutput>
			bannerclasses
		</cfoutput>
		<cfdump var="#rbannerclasses#" />
	</cfif>
	<cfquery name="unionRows" dbtype="query" result="runionRows">
			select SSBSECT_CRN
			from bannerclasses
			union all
			select courseid
			from existingBilling
		</cfquery>
	<cfif debug>
		<cfoutput>
			unionRows
		</cfoutput>
		<cfdump var="#runionRows#" />
	</cfif>
	<cfif arguments.billingstudentid eq 0>
		<cfset contactData = studentenrollment(gnumber = arguments.gNumber, program = arguments.program) >
	<cfelse>
		<cfset contactData = studentenrollment(billingstudentid = arguments.billingstudentid) >
	</cfif>
	<cfif debug>
		<cfoutput>
			contactData
		</cfoutput>
		<cfdump var="#contactData#" />
	</cfif>
	<cfquery name="insertRows" dbtype="query">
			select SSBSECT_CRN, contactData.bannerGNumber, contactData.keySchoolDistrictID, contactData.contactid
			from unionRows, contactData
			group by SSBSECT_CRN, contactData.bannerGNumber, contactData.keySchoolDistrictID, contactData.contactid
			having count(*) = 1
		</cfquery>
	<cfset parentid=0>
	<cfif debug>
		<cfdump var="#insertRows.recordcount#" />
	</cfif>
	<cfif insertRows.recordcount gt 0>
		<cfif arguments.billingstudentid eq 0>
			<cfquery name="doInsertParent" datasource="pcclinks" result="parent">
					insert into BillingStudent(contactid, gnumber, districtid, program, enrolleddate, exitdate, billingdate, billingtype, billingstatus)
					<cfoutput>
						values('#contactData.contactid#', '#contactData.bannerGNumber#', #contactData.keySchoolDistrictID#, '#contactData.program#', '#contactData.enrolleddate#', <cfqueryparam value="#contactdata.exitdate#" null="#not len(contactdata.exitdate)#">, '#billingdate#', 'CREDIT', 'IN PROGRESS')
					</cfoutput>
				</cfquery>
			<cfset parentid = #parent.GENERATEDKEY#>
		<cfelse>
			<cfset parentid = #arguments.billingstudentid#>
		</cfif>
		<cfquery name="doInsert" datasource="pcclinks">
				insert into BillingStudentItem(billingstudentid, courseid, typecode, includeflag, coursevalue, multiplier, billedamount)
				<cfoutput query="insertRows">
					select #parent.GENERATEDKEY#, #SSBSECT_CRN#, 'CREDIT', 1, 4, 4.8, 4*4.8
	        		<cfif currentrow LT insertRows.recordcount>UNION ALL</cfif>
				</cfoutput>
			</cfquery>
	<cfelse>
		<cfset parentid = #arguments.billingstudentid# >
	</cfif>
	<cfif debug>
		<cfdump var="#parentid#" />
	</cfif>
	<cfquery name="resultBilling" datasource="pcclinks">
			select *
			from pcc_links.BillingStudent bs
				join pcc_links.BillingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			where bs.billingstudentid = "#parentid#"
		</cfquery>
	<cfquery name="result" dbtype="query">
			select *
			from resultBilling, bannerclasses
			where resultBilling.courseid = bannerclasses.SSBSECT_CRN
		</cfquery>
	<cfreturn  QueryConvertForGrid(result,  ARGUMENTS.page, ARGUMENTS.pageSize)>
	</cffunction>
--->

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
			select TERM, CRN, SUBJ, CRSE, TITLE, coursevalue, bsi.IncludeFlag, BilledAmount, takenpreviousterm
			from billingStudentItem bsi
				join billingStudent bs on bsi.billingStudentID = bs.billingStudentId
			where bs.contactid = <cfqueryparam value="#arguments.contactid#">
		</cfquery>
		<cfquery dbtype="query" name="combined">
			select CAST(TERM as INTEGER) TERM, CAST(CRN as VARCHAR) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, TITLE, CAST(CREDITS as INTEGER) CREDITS, LEVL, GRADE, PASSED, -1 as IncludeFlag, 0 as BilledAmount, '' as TakenPreviousTerm
			from bannerclasses
			union
			select CAST(TERM as INTEGER) TERM, CAST(CRN as VARCHAR) CRN, CAST(CRSE AS varchar) CRSE, SUBJ, TITLE, CAST(CourseValue as INTEGER), '' as LVL, '' AS Grade, '' AS Passed, IncludeFlag, BilledAmount, CAST(takenpreviousterm as VARCHAR)
			from billedclasses
		</cfquery>
		<cfquery dbtype="query" name="final">
			select TERM, CRN, SUBJ, CRSE, TITLE, CREDITS
				, MAX(LEVL) LEVL, MAX(GRADE) Grade, MAX(PASSED) Passed, MAX(IncludeFlag) IncludeFlag, MAX(BilledAmount) BilledAmount, MAX(TakenPreviousTerm) TakenPreviousTerm
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


	<cffunction name="updatestudentbillingstatus" access="remote">
		<cfargument name="billingstudentid" required="yes">
		<cfargument name="billingReviewed" required="yes">
		<cfif arguments.billingReviewed EQ true>
			<cfset billingStatus = 'Completed'>
		<cfelse>
			<cfset billingStatus = 'In Progress'>
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


	<cffunction name="getNextGNumberInSession" access="remote" returntype="String" returnformat="json">
		<cfargument name="getNext" type="numeric" value="0">
		<cfargument name="getPrev" type="numeric" val="0">
		<cfargument name="bannerGNumber" required="true">
		<cfset debug="false">
		<cfif debug>
			<cfdump var="#Arguments#" />
		</cfif>
		<cfset gList = ListToArray(mid(Session.gList,1,len(Session.glist)-2))>
		<cfloop index="i" from="1" to="#arrayLen(gList)#">
			<cfset gList[i] = #replace(gList[i],"""","","all")#>
		</cfloop>
		<cfif debug>
			gList:
			<cfdump var="#gList#" />
			<br />
		</cfif>
		<!---<cfset gNumber = Session.bannerGNumber>--->
		<cfloop index="i" from="1" to="#arrayLen(gList)#">
			<cfset prev = gList[#i#]>
			<cfset next = gList[#i#]>
			<cfif debug>
				prev:
				<cfdump var="#prev#" />
				<br />
			</cfif>
			<cfif debug>
				next:
				<cfdump var="#next#" />
				<br />
			</cfif>
			<cfif gList[i] EQ bannerGNumber>
				<cfif debug>
					'gList[#i#] EQ #gNumber#'
					<br />
				</cfif>
				<cfif #i# GT 1>
					<cfif debug>
						'cfif #i# GT 1'
						<br />
					</cfif>
					<cfset prev = gList[#i# - 1]>
				</cfif>
				<cfif #i# LT #arrayLen(gList)#>
					<cfif debug>
						'#i# LT #arrayLen(gList)#'
						<br />
					</cfif>
					<cfset next = gList[#i# + 1]>
				</cfif>
				<cfif debug>
					<cfdump var="#i#" />
					:
					<cfdump var="#prev#" />
					,
					<cfdump var="#next#" />
					<br />
				</cfif>
				<cfbreak />
			</cfif>
		</cfloop>
		<cfif arguments.getNext EQ 1>
			<cfreturn next>
		<cfelse>
			<cfreturn prev>
		</cfif>
		<cfif debug>
			<cfdump var="#Session#" />
		</cfif>
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
				,SUM(CASE WHEN BillingStatus = 'BILLED' THEN CourseValue ELSE 0 END) Billed
				,SUM(CASE WHEN BillingStatus != 'BILLED' THEN CourseValue ELSE 0 END)  NotBilled
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
				,SUM(CASE WHEN bs.BillingStatus = 'COMPLETED' THEN 1 ELSE 0 END) StudentsReviewed
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
				join (select contactid, districtID, Program, bs.Term, BillingStatus, SUM(CourseValue) Amount
				 	  from billingStudent bs
						join billingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
				 	  where term = <cfqueryparam value="#arguments.term#">
						and BillingStatus != 'BILLED'
						and districtID = <cfqueryparam value="#arguments.districtID#">
			 	 	  group by contactid, districtID, Program, bs.Term, bs.BillingStatus
				 	  union
				 	  select bs.contactid, bs.districtID, bs.Program, bs.Term, bs.BillingStatus, SUM(CourseValue) Billed
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
			from (select c.contactid, c.Firstname, c.Lastname, c.bannerGNumber, schooldistrict, Program, bs.Term, SUM(CourseValue) Revised
					from billingStudent bs
						join billingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
						join keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
						join contact c on bs.contactid = c.contactid
						where term = <cfqueryparam value="#arguments.term#">
							and BillingStatus != 'BILLED'
						group by c.contactid, c.Firstname, c.Lastname, c.bannerGNumber, schooldistrict, program, term) nb
				left outer join
					(select contactid, schooldistrict, Program, Term, bs.billingstudentid
						,SUM(CourseValue) Billed
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


	<cffunction name="getLatestDateAttendanceMonth" access="remote" returntype="date">
		<cfquery name="data">
			select max(billingStartDate) lastAttendanceBillDate
			from billingStudent
			where program like '%attendance%'
		</cfquery>
		<cfreturn data.lastAttendanceBillDate>
	</cffunction>


	<cffunction name="getAttendanceClassesForMonth" access="remote" returntype="query">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfquery name="data">
			select distinct CRN, SUBJ, CRSE, Title
			from billingStudentItem bsi
				join billingStudent bs on bsi.billingStudentID = bs.billingStudentId
			where bs.billingStartDate = <cfqueryparam value="#arguments.billingStartDate#" >
				and bs.program like '%attendance%'
			order by CRN, SUBJ, CRSE, Title
		</cfquery>
		<cfreturn data>
	</cffunction>

	<!---

		<cffunction name="getClassAttendanceRows" access="remote">
		<cfargument name="crn" required="true">
		<cfargument name="term" required="true">
		<cfargument name="billingDate" required="true">
		<cfquery name="bannerdata" datasource="bannerpcclinks">
		select distinct pidm, stu_id GNumber, crn, crse, subj, title, <cfqueryparam value="#arguments.billingDate#"> billingDate, NULL CourseValue
		from swvlinks_course
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

		--->

	<cffunction name="getClassAttendanceGrid" access="remote">
		<cfargument name="crn" required="true">
		<cfargument name="billingStartDate" required="true">
		<cfquery name="data" >
			select PIDM, GNumber bannerGNumber, crn, crse, subj, title, billingStartDate, courseValue
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
		<cfset logDump(label="arguments", value=#arguments#)>
		<cfquery name="detailInsert" result="detailResult">
			DELETE
			FROM billingStudentItemDetail
			WHERe billingStudentItemId = <cfqueryparam value=#arguments.billingStudentItemId#>
		</cfquery>
		<cfset attendance = 0>
		<cfset numberOfDays = 0>
		<cfset dv = replace(arguments.detailValues,chr(9),"|^","ALL")>
		<cfset logDump(label="dv", value=#dv#)>
		<cfloop index="record" list="#dv#" delimiters="|^">
			<!---<cfset record = REPLACE(record,'\','\\')>--->
			<cfset logDump(label="record", value="#record#")>
			<cfquery name="detailInsert" result="detailResult">
				INSERT INTO billingStudentItemDetail(billingStudentItemID, billingStudentItemDetailValue)
				VALUES(#arguments.billingStudentItemId#, <cfqueryparam value="#replace(record,"^","")#">)
			</cfquery>
			<cfif UCASE(record) NEQ "N/A" and UCASE(record) NEQ "HOL">
				<cfset numberOfDays = numberOfDays + 1	>
				<cfif IsNumeric(record) and record GT 0>
					<cfset attendance = attendance + 1>
				</cfif>
			</cfif>
			<cfset logEntry(label="numberOfDays", value="#numberOfDays#")>
			<cfset logEntry(label="attendance", value="#attendance#")>
			<cfset logDump(label="detailResult", value=#detailResult#)>
		</cfloop>
		<cfquery name="updateItem">
			UPDATE billingStudentItem
			SET CourseValue = #attendance#
				, Amount2 = #numberOfDays#
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
		<cfargument name="courseValue" required="true">
		<cfargument name="amount2" required="true">
		<cfquery name="update">
			update billingStudentItem
			set courseValue = <cfqueryparam value="#arguments.courseValue#">
				,amount2 = <cfqueryparam value="#arguments.amount2#">
			where billingStudentItemId = <cfqueryparam value="#arguments.billingStudentItemId#">
		</cfquery>
	</cffunction>


	<cffunction name="getClassAttendanceForMonth" access="remote" returnFormat="json">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="crn" required="true">
		<cfquery name="data" result="dataResult">
			select c.firstName, c.lastName, c.bannerGNumber
				,crn, crse, subj, title
				,bsi.courseValue, bsi.billingStudentItemId
				,billingStartDate, bsi.amount2
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
	    		join contact c on bs.contactId = c.contactId
	    		join bannerCalendar cal1 on <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#"> between cal1.TermBeginDate and cal1.TermEndDate
	    		join bannerCalendar cal2 on bs.term = cal2.term and cal2.ProgramYear = cal1.ProgramYear
			where bsi.crn = <cfqueryparam value="#arguments.crn#">
			order by c.lastname, c.firstname
		</cfquery>
		<cfset logDump("dataResult",data) >
		<cfreturn data>
	</cffunction>


	<cffunction name="getAttendanceStudentsForTerm" access="remote" returnFormat="json">
		<cfargument name="term" required="true">
		<cfargument name="billingStartDate" type="date" required="true">
		<cfargument name="crn" required="true">
		<cfquery name="data" >
			select distinct c.firstname, c.lastname, c.bannerGNumber, bs.billingStudentId, ifnull(bsi.billingStudentItemId,0) billingStudentItemId, case when isnull(bsi.billingStudentItemID) or bsi.includeFlag = 0 then 0 else 1 end includeFlag
			from contact c
				join billingStudent bs on c.contactID = bs.contactID
				left outer join billingStudentItem bsi on bs.billingStudentId = bsi.billingStudentId
					and bsi.crn = <cfqueryparam value="#arguments.crn#">
			where term = <cfqueryparam value="#arguments.term#">
				and bs.billingStartDate = <cfqueryparam value="#DateFormat(arguments.billingStartDate,'yyyy-mm-dd')#">
				and bs.program like '%attendance%'
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getAttendanceCRNForTerm" access="remote" returnFormat="json">
		<cfargument name="term" required="true">
		<cfquery name="data" >
			select distinct CRN
			from billingStudent bs
				join billingStudentItem bsi on bs.billingStudentID = bsi.billingStudentId
			where term = <cfqueryparam value="#arguments.term#">
				and bs.program like '%attendance%'
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
				set billingScenarioId = <cfqueryparam value="#argments.billingScenarioId#">,
					crn = <cfqueryparam value="#arguments.crn#">,
					term = <cfqueryparam value="#arguments.term#">
				where billingScenarioByCourseId = <cfqueryparam value="#arguments.billingScenarioByCourseId#">
			</cfquery>
		</cfif>
	</cffunction>
	<cffunction name="insertClass" access="remote" returnformat="json" returntype="numeric">
		<cfargument name="billingStudentId" required="true">
		<cfargument name="crn" required="true">
		<cfargument name="subj" required="true">
		<cfargument name="crse" required="true">
		<cfargument name="title" required="true">
		<cfargument name="typecode" required="true">
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
				insert into billingStudentItem(billingstudentid, crn, crse, subj, Title, typecode, includeflag, coursevalue, multiplier, billedamount, datecreated, datelastupdated, createdby, lastupdatedby)
				values(<cfqueryparam value="#arguments.billingstudentid#">,
						<cfqueryparam value="#arguments.crn#">,
						<cfqueryparam value="#arguments.crse#">,
						<cfqueryparam value="#arguments.subj#">,
						<cfqueryparam value="#arguments.title#">,
						<cfqueryparam value="#arguments.typecode#">,
						1, 0, 0, 0, current_timestamp, current_timestamp,
						<cfqueryparam value="#Session.username#">,
						<cfqueryparam value="#Session.username#">)
			</cfquery>
			<cfreturn #resultBillingStudentItem.GENERATED_KEY#>
		</cfif>
	</cffunction>

	<cffunction name="removeItem" access="remote" >
		<cfargument name="billingStudentItemId" required="true">
		<cfquery name="deleteData" >
			update billingStudentItem
			set  includeFlag = 0
			where billingStudentItemId = <cfqueryparam value="#arguments.billingstudentitemid#">
		</cfquery>
	</cffunction>
	<cffunction name="attendanceReportDetail" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfquery name="data">
			select c.firstname, c.lastname, c.bannerGNumber, bs.billingStartDate
				,ROUND(bsi.CourseValue,2) Attendance, bsi.CRN, bsc.billingScenarioName, IndPercent, SmallPercent, InterPercent, LargePercent
				,ROUND(IFNULL(bsi.CourseValue,0)*IndPercent,2) as Ind
				,ROUND(IFNULL(bsi.CourseValue,0)*SmallPercent,2) as Small
				,ROUND(IFNULL(bsi.CourseValue,0)*InterPercent,2) as Inter
				,ROUND(IFNULL(bsi.CourseValue,0)*LargePercent,2) as Large
			from contact c
				join billingStudent bs on c.contactID = bs.contactID
				join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			    join billingScenarioByCourse bsbc  on bsi.CRN = bsbc.CRN
				join billingScenario bsc on bsbc.billingScenarioId = bsc.billingScenarioId
			    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bs.billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="attendanceReport" access="remote">
		<cfargument name="monthStartDate" type="date" required="true">
		<cfargument name="program" required="true">
		<cfargument name="schooldistrict" required="true">
		<cfquery name="updateReport">
			update billingStudent
				join
	            (
	            select billingStudentId,
					truncate(sum(ind) + sum(small)*0.333 + sum(inter)*0.222 + sum(large)*0.167 + sum(ind + small + inter + large)*0.0167, 2) Attendance
	            from (
	            select bs.billingStudentId
					,bsi.CourseValue Attendance
					,bsi.CourseValue*IFNULL(IndPercent,0) as Ind
					,bsi.CourseValue*IFNULL(SmallPercent,0) as Small
					,bsi.CourseValue*IFNULL(InterPercent,0) as Inter
					,bsi.CourseValue*IFNULL(LargePercent,0) as Large
				from billingStudent bs
					join billingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
				    join billingScenarioByCourse bsbc  on bsi.CRN = bsbc.CRN
					join billingScenario bsc on bsbc.billingScenarioId = bsc.billingScenarioId
				    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
				where bs.billingStartDate = <cfqueryparam value="#arguments.monthStartDate#">
					and bs.program = <cfqueryparam value="#arguments.program#">
					and sd.schoolDistrict = <cfqueryparam value="#arguments.schooldistrict#">) data
				group by billingStudentId) finalData
			on billingStudent.billingStudentId = finalData.billingStudentId
	        set GeneratedBilledAmount  = round(IFNULL(case when Attendance > 20 then 20 else Attendance end,0),2);
		</cfquery>
		<cfquery name="data">
			select billingStudentId, concat(lastname,', ',firstname) name, bannerGNumber, DATE_FORMAT(dob,'%m/%d/%Y') dob, DATE_FORMAT(exitdate,'%m/%d/%Y') exitDate,
				DATE_FORMAT(enrolledDate,'%m/%d/%Y') enrolledDate,
				DATE_FORMAT(reportingStartDate, '%m/%d/%Y') reportingStartDate, DATE_FORMAT(ReportingEndDate, '%m/%d/%Y') ReportingEndDate,
				ROUND(IFNULL(case when month(billingStartDate) = 6 then billedAmount end,0),1) Jun,
				ROUND(IFNULL(case when month(billingStartDate) = 7 then billedAmount end,0),1) Jul,
				ROUND(IFNULL(case when month(billingStartDate) = 8 then billedAmount end,0),1) Aug,
				ROUND(IFNULL(case when month(billingStartDate) = 9 then billedAmount end,0),1) Sept,
				ROUND(IFNULL(case when month(billingStartDate) = 10 then billedAmount end,0),1) Oct,
				ROUND(IFNULL(case when month(billingStartDate) = 11 then billedAmount end,0),1) Nov,
				ROUND(IFNULL(case when month(billingStartDate) = 12 then billedAmount end,0),1) `Dec`,
				ROUND(IFNULL(case when month(billingStartDate) = 1 then billedAmount end,0),1) Jan,
				ROUND(IFNULL(case when month(billingStartDate) = 2 then billedAmount end,0),1) Feb,
				ROUND(IFNULL(case when month(billingStartDate) = 3 then billedAmount end,0),1) Mar,
				ROUND(IFNULL(case when month(billingStartDate) = 4 then billedAmount end,0),1) Apr,
				ROUND(IFNULL(case when month(billingStartDate) = 5 then billedAmount end,0),1) May,
				20.0 Enrl
			from
            ( select c.firstname, c.lastname, c.bannerGNumber, c.dob
				,bs.billingStudentId, bs.billingStartDate, bs.exitdate, enrolled.enrolledDate
				,bs.reportingStartDate, bs.reportingEndDate
				,COALESCE(bs.FinalBilledAmount, bs.CorrectedBilledAmount, bs.GeneratedBilledAmount) BilledAmount
			from contact c
				join billingStudent bs on c.contactID = bs.contactID
			    join keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
                join (select contactId, min(billingStartDate) enrolledDate
                      from billingStudent
                      where billingStartDate >= '2017-07-03'
                      group by billingStudentId) enrolled
							on bs.contactId = enrolled.contactId
			where bs.billingStartDate = <cfqueryparam value="#arguments.monthStartDate#">
				and bs.program = <cfqueryparam value="#arguments.program#">
				and sd.schoolDistrict = <cfqueryparam value="#arguments.schooldistrict#">) data
			order by lastname, firstname
		</cfquery>
		<cfreturn data>
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
			) data
			order by crn
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getBillingStudentRecord" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfquery name="data">
			select *
			from billingStudent
			where billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="updatebillingStudentRecord" access="remote">
		<cfargument name="billingStudentId" required="true">
		<cfargument name="correctedBilledAmount" required="true">
		<cfargument name="correctedOverageAmount" required="true">
		<cfargument name="correctedBilledUnits" required="true">
		<cfargument name="correctedOverageUnits" required="true">

		<cfif arguments.correctedBilledAmount EQ "" && arguments.correctedBilledUnits NEQ "">
			<cfset arguments.correctedBilledAmount = arguments.correctedBilledUnits/36*175>
		</cfif>
		<cfif arguments.correctedOverageAmount EQ "" && arguments.correctedOverageUnits NEQ "">
			<cfset arguments.correctedOverageAmount = arguments.correctedOverageUnits/36*175>
		</cfif>
		<cfquery name="update">
			UPDATE billingStudent
				SET correctedBilledAmount = <cfif arguments.correctedBilledAmount EQ "">NULL<cfelse><cfqueryparam value="#arguments.correctedBilledAmount#"></cfif>,
				 correctedOverageAmount = <cfif arguments.correctedOverageAmount EQ "">NULL<cfelse><cfqueryparam value="#arguments.correctedOverageAmount#"></cfif>,
				 correctedBilledUnits = <cfif arguments.correctedBilledUnits EQ "">NULL<cfelse><cfqueryparam value="#arguments.correctedBilledUnits#"></cfif>
			WHERE billingStudentId = <cfqueryparam value="#arguments.billingStudentId#">
		</cfquery>
	</cffunction>
</cfcomponent>
