<cfcomponent displayname="programbilling">

<cffunction name="yearlybilling" returntype="query" access="remote">
		<cfargument name="program" default="">
		<cfargument name="schooldistrict" default="">
		<cfargument name="term" default="">
		<cfargument name="bannerGNumber" default="">
		<cfset debug="false">
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
					BSIDQ1 CurrentStudentBillingID
				</cfif>
				<cfif right(arguments.term,1) EQ 4>
					CAST((IFNULL(SummerNoOfClasses,0) + IFNULL(FallNoOfClasses,0)) as unsigned) FYTotalNoOfClasses,
					CAST(IFNULL(FallNoOfClasses,0) as unsigned) CurrentTermNoOfClasses,
					CAST((IFNULL(SummerNoOfCredits,0) + IFNULL(FallNoOfCredits,0)) as unsigned) FYTotalNoOfCredits,
					CAST(IFNULL(FallNoOfCredits,0) as unsigned) CurrentTermNoOfCredits,
					BSIDQ2 CurrentStudentBillingID
				</cfif>
				<cfif right(arguments.term,1) EQ 1>
					CAST((IFNULL(SummerNoOfClasses,0) + IFNULL(FallNoOfClasses,0) + IFNULL(WinterNoOfClasses,0)) as unsigned) FYTotalNoOfClasses,
					CAST(IFNULL(WinterNoOfClasses,0) as unsigned) CurrentTermNoOfClasses,
					CAST((IFNULL(SummerNoOfCredits,0) + IFNULL(FallNoOfCredits,0) + IFNULL(WinterNoOfCredits,0)) as unsigned) FYTotalNoOfCredits,
					CAST(IFNULL(WinterNoOfCredits,0) as unsigned) CurrentTermNoOfCredits,
					BSIDQ3 CurrentStudentBillingID
				</cfif>
				<cfif right(arguments.term,1) EQ 2>
					CAST((IFNULL(SummerNoOfClasses,0) + IFNULL(FallNoOfClasses,0) + IFNULL(WinterNoOfClasses,0) + IFNULL(SpringNoOfClasses,0)) as unsigned) FYTotalNoOfClasses,
					CAST(IFNULL(SpringNoOfClasses,0) as unsigned) CurrentTermNoOfClasses,
					CAST((IFNULL(SummerNoOfCredits,0) + IFNULL(FallNoOfCredits,0) + IFNULL(WinterNoOfCredits,0) + IFNULL(SpringNoOfClasses,0)) as unsigned) FYTotalNoOfCredits,
					CAST(IFNULL(SpringNoOfClasses,0) as unsigned) CurrentTermNoOfCredits,
					BSIDQ4 CurrentStudentBillingID
				</cfif>
			from sidny.contact c
			    join sidny.status currentEnrolledStatus on c.contactID = currentEnrolledStatus.contactID
					and currentEnrolledStatus.statusID = (select statusid from sidny.status where keyStatusID IN (2,13,14,15,16) and contactid = c.contactid and undoneStatusID is null order by statusdate desc limit 1)
				<cfif len(#arguments.bannerGNumber#) GT 0>
			    	and c.bannerGNumber = <cfqueryparam value="#arguments.bannerGNumber#">
			    </cfif>
			    join sidny.keyStatus keyStatus on currentEnrolledStatus.keyStatusID = keyStatus.keyStatusID
			    left outer join sidny.status currentExitStatus on c.contactID = currentExitStatus.contactID
					and currentExitStatus.statusID = (select statusid from sidny.status where keyStatusID = 3 and contactid = c.contactid and statusDate >= currentEnrolledStatus.statusDate and undoneStatusID is null order by statusdate desc limit 1)
			    join sidny.status currentSchoolStatus on c.contactid = currentSchoolStatus.contactID
					and currentSchoolStatus.statusID = (select statusID from sidny.status where keyStatusID = 7 and contactid = c.contactid and undoneStatusID is null order by statusdate desc limit 1)
				join sidny.statusSchoolDistrict statusSchoolDistrict on currentSchoolStatus.statusid = statusSchoolDistrict.statusID
			    join sidny.keySchoolDistrict keySchoolDistrict on statusSchoolDistrict.keySchoolDistrictID = keySchoolDistrict.keySchoolDistrictID
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
					from pcc_links.BillingStudent bs
						join pcc_links.BillingStudentItem bsi on bs.BillingStudentid = bsi.billingstudentid
					where bs.includeflag = 1 and bsi.includeflag = 1 and bs.term = #quarters[1]#
					group by bs.contactid, bs.districtid, program, enrolleddate, exitdate
					union
					select bs.contactID, bs.Districtid, program, enrolleddate, exitdate
							,CASE bs.term WHEN #term# THEN bs.BillingDate ELSE NULL END BillingDate
							,CASE bs.term WHEN #term# THEN bs.BillingStatus ELSE NULL END BillingStatus
							,NULL BSIDQ1, bs.BillingStudentID BSIDQ2, NULL BSIDQ3, NULL BSIDQ4,  NULL SummerNoOfClasses, NULL SummerNoOfCredits, count(*) FallNoOfClasses, sum(bsi.coursevalue) FallNoOfCredits, NULL WinterNoOfClasses, NULL WinterNoOfCredits, NULL SpringNoOfClasses, NULL SpringNoOfCredits
					from pcc_links.BillingStudent bs
						join pcc_links.BillingStudentItem bsi on bs.BillingStudentid = bsi.billingstudentid
					where bs.includeflag = 1 and bsi.includeflag = 1 and bs.term = #quarters[2]#
					group by bs.contactid, bs.districtid, program, enrolleddate, exitdate
					union
					select bs.contactID, bs.Districtid, program, enrolleddate, exitdate
							,CASE bs.term WHEN #term# THEN bs.BillingDate ELSE NULL END BillingDate
							,CASE bs.term WHEN #term# THEN bs.BillingStatus ELSE NULL END BillingStatus
							,NULL BSIDQ1, NULL BSIDQ2, bs.BillingStudentID BSIDQ3, NULL BSIDQ4,  NULL SummerNoOfClasses, NULL SummerNoOfCredits, null FallNoOfClasses, null FallNoOfCredits, count(*) WinterNoOfClasses, sum(bsi.coursevalue) WinterNoOfCredits, NULL SpringNoOfClasses, NULL SpringNoOfCredits
					from pcc_links.BillingStudent bs
						join pcc_links.BillingStudentItem bsi on bs.BillingStudentid = bsi.billingstudentid
					where bs.includeflag = 1 and bsi.includeflag = 1 and bs.term = #quarters[3]#
					group by bs.contactid, bs.districtid, program, enrolleddate, exitdate
					union
					select bs.contactID, bs.Districtid, program, enrolleddate, exitdate
							,CASE bs.term WHEN #term# THEN bs.BillingDate ELSE NULL END BillingDate
							,CASE bs.term WHEN #term# THEN bs.BillingStatus ELSE NULL END BillingStatus
							,NULL BSIDQ1, NULL BSIDQ2, NULL BSIDQ3, bs.BillingStudentID BSIDQ4,  NULL SummerNoOfClasses, NULL SummerNoOfCredits, null FallNoOfClasses, null FallNoOfCredits, NULL WinterNoOfClasses, NULL WinterNoOfCredits, count(*) SpringNoOfClasses, sum(bsi.coursevalue) SpringNoOfCredits
					from pcc_links.BillingStudent bs
						join pcc_links.BillingStudentItem bsi on bs.BillingStudentid = bsi.billingstudentid
					where bs.includeflag = 1 and bsi.includeflag = 1 and bs.term = #quarters[4]#
					group by bs.contactid, bs.districtid, program, enrolleddate, exitdate
					) data
				group by contactid, districtid, program, enrolleddate, exitdate
				) bs
					on bs.contactid = c.contactid
			    join sidny.keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
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
	<cffunction name="select" returntype = "struct" access="remote">
		<cfargument name="page" type="numeric" required="no" default=1>
	    <cfargument name="pageSize" type="numeric" required="no" default=10>
	    <cfargument name="gridsortcolumn" type="string" required="no" default="">
	    <cfargument name="gridsortdir" type="string" required="no" default="">
		<cfargument name="program" default="YtC Credit">
		<cfargument name="schooldistrict" default="Tigard/Tualatin">
		<cfargument name="term" default="201701">
		<cfset var data = yearlybilling(program=#arguments.program#, term=#arguments.term#, schooldistrict=#arguments.schooldistrict#) >
		<cfreturn QueryConvertForGrid(data,  arguments.page, arguments.pageSize)>
	</cffunction>

	<cffunction name="selectprogramstudentlist" returntype = "query" returnformat="json" access="remote">
		<cfargument name="program" type="string">
		<cfargument name="term" >
		<cfargument name="schooldistrict" default="" >
		<cfargument name="columns" type="array">
		<cfset debug="true">
		<cfset var yearlybilling = yearlybilling(program=#arguments.program#, term=#arguments.term#, schooldistrict=#arguments.schooldistrict#) >
		<cfset var sql="">
		<cfloop array="#arguments.columns#" item="col">
			<cfset sql = #sql# & #col# & ","  >
		</cfloop>
		<cfset sql = RemoveChars(#sql#, len(#sql#), 1)>
		<cfif debug><cfdump var="#sql#"></cfif>
		<cfquery name="data" dbtype="query" result="r">
			select #sql#
			from yearlybilling
		</cfquery>
		<cfif debug><cfdump var="#r#"></cfif>
		<cfif debug><cfdump var="#data#"></cfif>
		<cfreturn data>
	</cffunction>
	<cffunction name="groupBySchoolDistrictAndProgram" returntype="query" access="remote">
		<cfargument name="term" required="yes">
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
		<cfquery name="data" datasource="pcclinks">
			select sd.schoolDistrict, bs.Program
				,sum(case when term = #quarters[1]# then bsi.CourseValue else 0 END) SummerNoOfCredits
				,sum(case when term = #quarters[2]# then bsi.CourseValue else 0 END) FallNoOfCredits
				,sum(case when term = #quarters[3]# then bsi.CourseValue else 0 END) WinterNoOfCredits
				,sum(case when term = #quarters[4]# then bsi.CourseValue else 0 END) SpringNoOfCredits
			from pcc_links.BillingStudent bs
				join  pcc_links.BillingStudentItem bsi on  bs.BillingStudentID = bsi.BillingStudentID
			    join sidny.keySchoolDistrict sd on  bs.DistrictID = sd.keySchoolDistrictID
			group by sd.schoolDistrict, bs.Program
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="selectStudentBilling" returntype = "query" returnFormat="json" access="remote">
		<cfargument name="program" type="string">
		<cfargument name="schooldistrict" type="string">
		<cfargument name="term" >
		<cfset debug="false">
		<cfif debug><cfdump var="#arguments#"></cfif>
		<cfset var data = yearlybilling(program=#arguments.program#, term=#arguments.term#, schooldistrict=#arguments.schooldistrict#) >
		<cfif debug><cfdump var="#data#"></cfif>
		<cfreturn data>
	</cffunction>

	<cffunction name="studentenrollment" returntype="Query">
		<cfargument name="program" type="string" default="">
		<cfargument name="gnumber" type="string" default="">
		<cfargument name="billingstudentid" type="numeric" default=0>
		<cfset debug="false">
		<cfif debug>
			<cfdump var="#arguments#">
		</cfif>
		<cfquery datasource="pcclinks" name="studentbillingData" result="r" >
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
			<cfdump var="#banner#">
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
			<cfdump var="#studentsWithClassesInTerm#">
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
			<cfoutput>selectstudent arguments:</cfoutput>
			<cfdump var="#arguments#">
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
		<cfif debug><cfdump var="#r#"></cfif>
		<cfreturn data >
	</cffunction>

	<cffunction name ="selectBillingEntries" access="remote" returnType="query">
		<cfargument name="billingstudentid" type="string" required="no" default="">
		<cfargument name="bannerGNumber" type="string" required="no" default="">
		<cfargument name="term" type="numeric" required="no" default="0">
		<cfset debug="false">
		<cfif debug>
			<cfoutput>selectstudent arguments:</cfoutput>
			<cfdump var="#arguments#">
		</cfif>
		<cfquery name="data" datasource="pcclinks">
			select *
			from pcc_links.BillingStudentItem bsi
				join pcc_links.BillingStudent bs on bsi.BillingStudentId  =bs.BillingStudentId
				join sidny.contact c on bs.contactid = c.contactid
				join pcc_links.BannerCourse bc on bsi.CRN = bc.CRN and bc.term = bs.term and bs.gnumber = bc.stu_id
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

	<cffunction name ="getBillingEntries" access="remote" returnType="struct">
		<cfargument name="page" type="numeric" required="no" default=1>
	    <cfargument name="pageSize" type="numeric" required="no" default=40>
	    <cfargument name="gridsortcolumn" type="string" required="no">
	    <cfargument name="gridsortdir" type="string" required="no">
	    <cfargument name="billingstudentid" type="numeric" required="yes">
		<cfargument name="gNumber" type="string" required="yes">
		<cfargument name="program" type="string" required="yes">
		<cfargument name="termcode" type="string" required="yes">
		<cfset debug="false">
		<cfif debug>
			<cfdump var="#arguments#">
		</cfif>
		<cfset billingdate = #arguments.termcode# & "01">
		<cfquery name="existingBilling" datasource="pcclinks" result="rexistingBilling">
			select distinct bsi.courseid
			from pcc_links.BillingStudent bs
				join pcc_links.BillingStudentItem bsi on bs.BillingStudentID = bsi.BillingStudentID
			where
			<cfif len(trim(#arguments.billingstudentid#))>
				bs.billingstudentid = <cfqueryparam value="#arguments.billingstudentid#">
			<cfelse>
				gnumber = <cfqueryparam value="#arguments.gnumber#">
					and billingdate = <cfqueryparam value="#billingdate#">
			</cfif>
		</cfquery>
		<cfif debug>
			<cfoutput>existingBilling</cfoutput>
			<cfdump var="#rexistingBilling#">
		</cfif>
		<cfquery name="bannerclasses" datasource="pcclinks" result="rbannerclasses">
			select *
			from pcc_links.BannerCoursesReport
			where gnumber = <cfqueryparam value="#arguments.gnumber#">
				and SFRSTCR_TERM_CODE = <cfqueryparam value="#arguments.termcode#">
		</cfquery>
		<cfif debug>
			<cfoutput>bannerclasses</cfoutput>
			<cfdump var="#rbannerclasses#">
		</cfif>
		<cfquery name="unionRows" dbtype="query" result="runionRows">
			select SSBSECT_CRN
			from bannerclasses
			union all
			select courseid
			from existingBilling
		</cfquery>

		<cfif debug>
			<cfoutput>unionRows</cfoutput>
			<cfdump var="#runionRows#">
		</cfif>
		<cfif arguments.billingstudentid eq 0>
			<cfset contactData = studentenrollment(gnumber = arguments.gNumber, program = arguments.program) >
		<cfelse>
			<cfset contactData = studentenrollment(billingstudentid = arguments.billingstudentid) >
		</cfif>
		<cfif debug>
			<cfoutput>contactData</cfoutput>
			<cfdump var="#contactData#">
		</cfif>
		<cfquery name="insertRows" dbtype="query">
			select SSBSECT_CRN, contactData.bannerGNumber, contactData.keySchoolDistrictID, contactData.contactid
			from unionRows, contactData
			group by SSBSECT_CRN, contactData.bannerGNumber, contactData.keySchoolDistrictID, contactData.contactid
			having count(*) = 1
		</cfquery>
		<cfset parentid=0>
		<cfif debug>
			<cfdump var="#insertRows.recordcount#">
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
			<cfdump var="#parentid#">
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

	<cffunction name ="selectBannerClasses" access="remote" returnType="query">
		<cfargument name="row" type="struct" required="yes">
		<cfset debug="false">
		<cfif debug><cfdump var="#arguments.row#"></cfif>
		<cfquery name="bannerclasses" datasource="pcclinks">
			select *
			from pcc_links.BannerCourse
			where stu_id = <cfqueryparam value="#arguments.row.gnumber#">
				and term < <cfqueryparam value="#arguments.row.term#">
				<cfif len(arguments.row.subj) GT 0>
				and subj = (SELECT SUBJ FROM pcc_links.BannerCourse WHERE CRN = <cfqueryparam value="#arguments.row.crn#">
				</cfif>
			order by TERM
		</cfquery>
		<cfif debug><cfdump var="#bannerclasses#"></cfif>
		<cfreturn  bannerclasses>
	</cffunction>

	<cffunction name ="getBannerClasses" access="remote" returnType="struct">
		<cfargument name="page" type="numeric" required="no" default=1>
	    <cfargument name="pageSize" type="numeric" required="no" default=40>
	    <cfargument name="gridsortcolumn" type="string" required="no">
	    <cfargument name="gridsortdir" type="string" required="no">
		<cfargument name="gNumber" type="string" required="yes">
	    <cfargument name="SSBSECT_SUBJ_CODE" type = "string" default = "">
		<cfargument name="termcode" type="string" required="yes">
		<cfquery name="bannerclasses" datasource="pcclinks">
			select *
			from pcc_links.BannerCoursesReport
			where gnumber = <cfqueryparam value="#arguments.gnumber#">
				and SSBSECT_SUBJ_CODE = <cfqueryparam value="#arguments.SSBSECT_SUBJ_CODE#">
				and SFRSTCR_TERM_CODE < <cfqueryparam value="#arguments.termcode#">
			order by SFRSTCR_TERM_CODE DESC
		</cfquery>
		<cfreturn  QueryConvertForGrid(bannerclasses,  ARGUMENTS.page, ARGUMENTS.pageSize)>
	</cffunction>

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
      	<cfargument name="row" type="struct" required="yes">
		<cfquery datasource="pcclinks">
		UPDATE BillingStudent
		SET IncludeFlag = '#ARGUMENTS.grid.includeflag#'
		WHERE billingstudentid = <cfqueryparam value="#ARGUMENTS.grid.billingstudentid#">
		</cfquery>
    </cffunction>

	<cffunction name="editstudentbillingiteminclude" access="remote">
      	<cfargument name="row" type="struct" required="yes">
		<cfquery datasource="pcclinks">
		UPDATE pcc_links.BillingStudentItem
		SET IncludeFlag = '#ARGUMENTS.row.includeflag#'
		WHERE billingstudentitemid = <cfqueryparam value="#ARGUMENTS.row.billingstudentitemid#">
		</cfquery>
    </cffunction>

	<cffunction name="storesessiondata" access="remote" output="false">
		    <cfset requestBody = toString( getHttpRequestData().content ) />

    <!--- Double-check to make sure it's a JSON value. --->
    <cfif isJSON( requestBody )>

        <!--- Echo back POST data. --->
        <cfdump
            var="#deserializeJSON( requestBody )#"
            label="HTTP Body"
        />
	<cfelse>
		<cfdump var="xxx">
    </cfif>
	</cffunction>
	<cffunction name="getGNumber" access="remote">
		<cfargument name="getNext" type="numeric" value=0>
		<cfargument name="getPrev" type="numeric" val=0>
		<cfset debug="true">
		<cfif debug><cfdump var="#Session#"></cfif>
		<cfset gList = ListToArray(Session.gList)>
		<cfset gNumber = Session.bannerGNumber>
		<cfloop index="i" from="1" to="#arrayLen(gList)#" >
			<cfset prev = gList[#i#]>
			<cfset next = gList[#i#]>
			<cfif debug><cfdump var="#i#">:<cfdump var="#prev#">,<cfdump var="#next#"><br/></cfif>
			<cfif gList[#i#] EQ #gNumber#>
				<cfif #i# GT 1>
					<cfset prev = gList[#i# - 1]>
				</cfif>
				<cfif #i# LT #arrayLen(gList)#>
					<cfset next = gList[#i# + 1]>
				</cfif>
				<cfif debug><cfdump var="#i#">:<cfdump var="#prev#">,<cfdump var="#next#"><br/></cfif>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfif arguments.getNext EQ 1>
			<cfset Session.bannerGNumber = next>
		<cfelse>
			<cfset Session.bannerGNumber = prev>
		</cfif>
		<cfif debug><cfdump var="#Session#"></cfif>
	</cffunction>
	<cffunction name="getReconcileSummary" access="remote" returntype="query">
		<cfquery datasource="pcclinks" name="prevTerm">
			SELECT MAX(Term) Term
			FROM pcc_links.BillingStudent
			WHERE Term < (SELECT MAX(Term)
						  FROM pcc_links.BillingStudent)
		</cfquery>
		<cfquery name="data" datasource="pcclinks">
			select schooldistrict, Program, Term
				,SUM(CASE WHEN BillingStatus = 'BILLED' THEN CourseValue ELSE 0 END) Billed
				,SUM(CASE WHEN BillingStatus != 'BILLED' THEN CourseValue ELSE 0 END)  NotBilled
				,SUM(CASE WHEN BillingStatus = 'BILLED' THEN BilledAmount ELSE 0 END) BilledDollars
				,SUM(CASE WHEN BillingStatus != 'BILLED' THEN BilledAmount ELSE 0 END) NotBilledDollars
			from pcc_links.BillingStudent bs
				join pcc_links.BillingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
			    join sidny.keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
			where term = <cfqueryparam value="#prevTerm.Term#">
			group by schooldistrict, program, term
		</cfquery>
		<cfreturn data>
	</cffunction>

	<cffunction name="getCurrentTermSummary" access="remote" returntype="query">
		<cfquery datasource="pcclinks" name="data">
			SELECT bs.Program, sd.schoolDistrict, bs.term
				,SUM(CASE WHEN bs.BillingStatus = 'IN PROGRESS' THEN 1 ELSE 0 END) StudentsStillBeingReviewed
				,SUM(CASE WHEN bs.BillingStatus = 'COMPLETED' THEN 1 ELSE 0 END) StudentsReviewed
			from pcc_links.BillingStudent bs
			    join sidny.keySchoolDistrict sd on bs.DistrictID = sd.keySchoolDistrictID
			where bs.term = (select max(term) from pcc_links.BillingStudent)
			group by bs.Program, sd.schoolDistrict, bs.term
		</cfquery>
		<cfreturn data>
	</cffunction>
	<cffunction name="getProgramDistrictReconcile" access="remote" returntype="query">
		<cfargument name="term" >
		<cfargument name="schooldistrict">
		<cfargument name="program">
		<cfquery name="data" datasource="pcclinks">
			select CONCAT(nb.Firstname, ' ', nb.Lastname, ' (', nb.bannerGNumber, ')') Name, nb.schooldistrict SchoolDistrict, nb.Program, nb.Revised, nb.Term
				,billed.SchoolDistrict PriorBilledSchoolDistrict, billed.Program PriorBilledProgram, billed.Billed
			from (select c.contactid, c.Firstname, c.Lastname, c.bannerGNumber, schooldistrict, Program, bs.Term, SUM(CourseValue) Revised
					from pcc_links.BillingStudent bs
						join pcc_links.BillingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
						join sidny.keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
						join sidny.contact c on bs.contactid = c.contactid
						where term = <cfqueryparam value="#arguments.term#">
							and BillingStatus != 'BILLED'
						group by c.contactid, c.Firstname, c.Lastname, c.bannerGNumber, schooldistrict, program, term) nb
				left outer join
					(select contactid, schooldistrict, Program, Term, bs.billingstudentid
						,SUM(CourseValue) Billed
					from pcc_links.BillingStudent bs
						join pcc_links.BillingStudentItem bsi on bs.billingstudentid = bsi.billingstudentid
						join sidny.keySchoolDistrict sd on bs.districtid = sd.keyschooldistrictid
					where term = <cfqueryparam value="#arguments.term#">  and BillingStatus = 'BILLED'
					group by contactid, schooldistrict, program
					) billed
				on billed.contactid = nb.contactid
				where (billed.program = <cfqueryparam value="#arguments.program#">  and billed.schooldistrict=<cfqueryparam value="#arguments.schooldistrict#">)
					or (nb.program = <cfqueryparam value="#arguments.program#"> and nb.schooldistrict = <cfqueryparam value="#arguments.schooldistrict#">)
		</cfquery>
		<cfreturn data>
	</cffunction>
</cfcomponent>