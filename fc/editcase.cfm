<!--- called by student.cfm as a cfinclude
 pidm and cohort variable set by student.cfm
--->

<cfparam name="studentparam_pidm" default="#FORM.pidm#">
<cfparam name="studentparam_cohort" default="#FORM.cohort#">
<cfinvoke component="fc" method="getEditCase" pidm="#studentparam_pidm#" returnvariable="caseload_banner"></cfinvoke>
<cfinvoke component="fc" method="getFirstYearMetrics" pidm="#studentparam_pidm#" cohort="#studentparam_cohort#" returnvariable="firstYearMetrics"></cfinvoke>
<cfinvoke component="fc" method="getCGPassed" pidm="#studentparam_pidm#" cohort="#studentparam_cohort#" returnvariable="cgPassed"></cfinvoke>


<!---- Lookup Fields --->

<cfquery name="list_coach">
	SELECT distinct displayName as coach
	FROM applicationUser
	WHERE position = 'coach'
	ORDER BY 1 ASC
</cfquery>

<!--- FORM ---->
<form id="editForm" name="editForm" action="javascript:saveStudentContent();">
	<input name="method" type="hidden" value="update" />
	<cfoutput>
		<input name="contactID" type="hidden" value="#caseload_banner.contactID#" />
		<input name="pidm" type="hidden" value="#caseload_banner.pidm#" />
	</cfoutput>
	<!--- MAIN ROW ---->
	<div class="row">
		<!--- COLUMN 1 --->
		<div class="large-4 columns">
			<label>
				Preferred Name
				<cfoutput>
					<input type="text" name="preferredName" value="#caseload_banner.preferredName#" />
				</cfoutput>
			</label>

			<label> Cohort
			<cfoutput>
				<input type="text" name="cohort" readonly value="#caseload_banner.cohort#" />
			</cfoutput>
			</label>

			<label> Funding Source
			<cfoutput>
				<input type="text" name="fundedby" readonly value="#caseload_banner.fundedby#" />
			</cfoutput>
			</label>

			<!-- Gender Select -->
			<cfset values=["Female", "Male", "Non-binary", "Choose not to say"]>
			<cfmodule template="includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.gender#"
				so_label = "Gender"
				so_selectname="gender"
			>
			<!-- end gender select -->

			<label>
				Race
				<cfoutput>
					<input type="text" name="REP_RACE" readonly value="#caseload_banner.REP_RACE#" />
				</cfoutput>
			</label>
			<label>
				High School
				<cfoutput>
					<input type="text" name="HighSchool" readonly value="#caseload_banner.HighSchool#" />
				</cfoutput>
			</label>

			<!--- Campus Select
			<cfset values=["Cascade", "Southeast", "Sylvania", "Rock Creek"]>
			<cfmodule template="#pcc_source#/includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.campus#"
				so_label = "Campus"
				so_selectname="campus"

	 end campus select --->


			<!-- Parental status Select -->
			<cfset values=["Yes", "No"]>
			<cfmodule template="includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.parentalStatus#"
				so_label = "Parental status"
				so_selectname="parentalStatus"
			>
			<!-- end Parental status select -->

			<!---  REMOVED FOR NOW
			<!-- Household Information checkboxes -->
			<!-- ajax jquery refreshed -->
			<div id="householdInfo">
			<cfmodule template="#pcc_source#/includes/multiSelectCheckboxes.cfm"
				mscb_description = 'Household Information'
				mscb_fieldName = 'householdID'
				mscb_componentname = "fc"
				mscb_methodName = "getHouseholdWithAssignments"
				contactid = "#caseload_banner.contactID#"
			>
			</div>
			--->

			<!--- <label>Citizen Status -- REMOVE fix so it updates with selection
				<select name='citizen_status' selected=#caseload_banner.citizen_status#>
				<option value="Unknown">Unknown</option>
				<option value="Resident">Resident</option>
				<option value="DACA">DACA</option>
				<option value="Undocumented">Undocumented</option>
				</select>
				</label> --->

			<label>
				Career Plan
				<cfoutput>
					<input type="text" name="careerPlan" value="#caseload_banner.careerPlan#" />
				</cfoutput>
			</label>

			<!-- Weekly Work Hours Select -->
			<cfset values=["none", "less than 20", "20 to 29","30 to 39","40 or more"]>
			<cfmodule template="includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.weeklyWorkHours#"
				so_label = "Weekly Work Hours"
				so_selectname="weeklyWorkHours"
			>
			<!-- end Weekly Work Hours select -->


			<label>
				EFC
				<cfoutput>
					<input type="text" name="EFC" readonly value="#caseload_banner.EFC#" />
				</cfoutput>

			</label>
			<label>
				Academic Hold
				<cfoutput>
					<input type="text" name="RE_HOLD" readonly value="#caseload_banner.RE_HOLD#" />
				</cfoutput>
			</label>


		<!-- Living Situation checkboxes -->
		<!-- ajax jquery refreshes div -->
		<div id="livingsituation">
		<cfmodule template="includes/multiSelectCheckboxes.cfm"
			mscb_description = 'Living Situation'
			mscb_fieldName = 'livingSituationID'
			mscb_componentname = "fc"
			mscb_methodName = "getLivingSituationWithAssignments"
			contactid = "#caseload_banner.contactID#"
		>
		</div>

		<!-- Enrichment Programs Checkboxes -->
		<!-- refreshed by jquery -->
		<div id="enrichmentprograms">
		<cfmodule template="includes/multiSelectCheckboxes.cfm"
			mscb_description = 'Enrichment Programs'
			mscb_fieldName = 'enrichmentProgramID'
			mscb_componentname = "fc"
			mscb_methodName = "getEnrichmentProgramsWithAssignments"
			contactid = "#caseload_banner.contactID#"
		>
		</div>
		<!-- end enrichment programs -->


		</div>
		<!-- END COLUMN 1 -->

		<!-- COLUMN 2 -->
		<div class="large-4 columns">

			<!-- Status Internal Select -->
			<cfset values=["A", "B", "C", "X"]>
			<cfmodule template="includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.statusInternal#"
				so_label = "Status Internal"
				so_selectname="statusInternal"
			>
			<!-- end Status Internal select -->


			<!-- Exit Reason Select -->
			<cfset values=["Academic frustration", "ASAP Issue", "Completed Certificate","Completed Degree"
							,"Completed Degree & Transfer","Entered the Military","Transferred"
							,"Housing insecurity / homeless","Incarcerated","Leaving school to work"
							,"Left without contact","Mental health barriers","Moving out of PCC district"
							,"Non-Clearinghouse Transfer or Completion", "Parenting responsibilities"]>
			<cfmodule template="includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.exitReason#"
				so_label = "Exit Reason"
				so_selectname="exitReason"
			>
			<!-- end Exit Reason select -->


			<label>
				ASAP
				<cfoutput>
					<input type="text" name="ASAP_STATUS" readonly value="#caseload_banner.ASAP_STATUS#" />
				</cfoutput>
			</label>
			<label>
				Credits Earned
				<cfoutput>
					<input type="text" name="O_EARNED" readonly value="#caseload_banner.O_EARNED#" />
				</cfoutput>
			</label>
			<label>
				GPA
				<cfoutput>
					<input type="text" name="O_GPA" readonly value="#caseload_banner.O_GPA#" />
				</cfoutput>
			</label>

			<!--->
			<label>
				Registered For:
				<cfoutput>
					<input type="text" name="registered_next_term" readonly value="#caseload_banner.registered_next_term#" />
				</cfoutput>
			</label>
			--->
			<label>
				Degree Declared
				<cfoutput>
					<cfset Variables.p_degree = #caseload_banner.P_DEGREE# >
					<cfif #caseload_banner.P_DEGREE# EQ "000000" >
						<cfset Variables.p_degree = "Undeclared">
					</cfif>
					<input type="text" name="P_DEGREE" readonly value="#Variables.p_degree#" />
				</cfoutput>
			</label>
			<label>
				Reading Placement
				<cfoutput>
					<input type="text" name="te_read" readonly value="#caseload_banner.te_read#" />
				</cfoutput>
			</label>
			<label>
				Writing Placement
				<cfoutput>
					<input type="text" name="te_write" readonly value="#caseload_banner.te_write#" />
				</cfoutput>
			</label>
			<label>
				Math Placement
				<cfoutput>
					<input type="text" name="te_math" readonly value="#caseload_banner.te_math#" />
				</cfoutput>
			</label>
			<label>
				CG100
				<cfoutput>
					<input type="text" name="cg100Passed" readonly value=
					<cfif "#cgPassed.cg100Passed#" eq 1>
						Yes
					<cfelse>
						No
					</cfif>
					>
				</cfoutput>
			</label>
			<label>
				CG130
				<cfoutput>
					<input type="text" name="cg130Passed" readonly value=
					<cfif "#cgPassed.cg130Passed#" eq 1>
						Yes
					<cfelse>
						No
					</cfif>
					>
				</cfoutput>
			</label>

			<label>
				CG190
				<cfoutput>
					<input type="text" name="cg190Passed" readonly value=
					<cfif "#cgPassed.cg190Passed#" eq 1>
						Yes
					<cfelse>
						No
					</cfif>
					>
				</cfoutput>
			</label>

			<label>
				FirstYearCredits
				<cfoutput>
					<input type="text" name="firstYearCredits" readonly value="#firstYearMetrics.firstYearCredits#" />
				</cfoutput>
			</label>
			<label>
				FirstYearGPA
				<cfoutput>
					<cfset Variables.firstYearGPA = #firstYearMetrics.firstYearGPA#>
					<!--- set to rounded, if there is a value --->
					<cfif LEN(Variables.firstYearGPA)>
						<cfset Variables.firstYearGPA = #DecimalFormat(firstYearMetrics.firstYearGPA)#>
					</cfif>
					<input type="text" name="firstYearGPA" readonly value="#Variables.firstYearGPA#" />
				</cfoutput>
			</label>

		</div>
		<!--- END COLUMN 2 --->

		<!--- COLUMN 3 --->
		<div class="large-4 columns">
			<!-- Coach Select -->
			<cfset values= ListToArray(ValueList(list_coach.coach))>
			<cfmodule template="includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.coach#"
				so_label = "Coach"
				so_selectname="coach"
			>
			<!-- end Coach select -->

			<label>
				Cell Phone
				<cfoutput>
					<input type="text" name="cellPhone" value="#caseload_banner.cellPhone#" />
				</cfoutput>
			</label>
			<label>
				Phone2
				<cfoutput>
					<input type="text" name="phone2" value="#caseload_banner.phone2#" />
				</cfoutput>
			</label>
			<label>
				Email PCC
				<cfoutput>
					<input type="text" name="PCC_EMAIL" readonly value="#caseload_banner.PCC_EMAIL#" />
				</cfoutput>
			</label>
			<label>
				Email Personal
				<cfoutput>
					<input type="text" name="emailPersonal" value="#caseload_banner.emailPersonal#" />
				</cfoutput>
			</label>

			<!-- Notes -->
			<div id="notes">
			<cfparam  name="tableName" default="futureConnect">
			<cfparam  name="contactID" default="#caseload_banner.contactID#">
			<cfinclude template="includes/notes.cfm" />
			</div>
			<!-- end div notes -->

			<label>
				Flag
				<cfoutput>
					<input type="checkbox" name="flagged" value="#caseload_banner.flagged#"  <cfif caseload_banner.flagged EQ 1 >checked</cfif>/>
				</cfoutput>
			</label>

			<input name="submit" value="Save" class="success button" type="submit" />
			<cfif Session.userRole EQ "admin">
			<br><input name="deleteStudentInput" value="Delete" class="button alert" onClick="javascript:deleteStudent('<cfoutput>#caseload_banner.contactID#</cfoutput>');" style="width:75px"/>
			</cfif>
			<div id="savemessage"></div>
		</div>
		<!---- END COLUMN 3 --->
	</div> 	<!--- end row class --->
</form>


