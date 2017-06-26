<!--- called by student.cfm
 cohort varialbe set by student.cfm
--->

<cfinvoke component="fc" method="getFirstYearMetrics" id="#studentvar_id#" cohort="#studentvar_cohort#" returnvariable="firstYearMetrics"></cfinvoke>
<cfinvoke component="fc" method="getCGPassed" id="#studentvar_id#" cohort="#studentvar_cohort#" returnvariable="cgPassed"></cfinvoke>
<cfinvoke component="fc" method="getMaxTermData" id="#studentvar_id#" returnvariable="maxTermData"></cfinvoke>



<!---- Lookup Fields --->

<cfquery name="list_coach">
	SELECT distinct displayName as coachName
	FROM applicationUser
	WHERE position = 'coach'
	ORDER BY 1 ASC
</cfquery>

<cfquery name="list_gender">
	SELECT distinct GenderName
	FROM pcc_links.gender
	ORDER BY 1 ASC
</cfquery>

<cfquery name="list_campus">
	SELECT distinct CampusName
	FROM pcc_links.campus
	ORDER BY 1 ASC
</cfquery>


<!--- FORM ---->
<form action="saveCase.cfm" method="post" id="editForm" name="editForm">
	<cfoutput>
		<input name="contactID" type="hidden" value="#caseload_banner.contactID#" />
		<input name="bannerGNumber" type="hidden" value="#caseload_banner.bannerGNumber#" />
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



			<label>
				Gender
				<select name="gender">
					<option value="Female"
						<cfif "Female" eq caseload_banner.gender >
							selected
						</cfif>> Female
					</option>

					<option value="Male"
						<cfif "Male" eq caseload_banner.gender >
							selected
						</cfif>> Male
					</option>

					<option value="Non-binary"
						<cfif "Non-binary" eq caseload_banner.gender >
							selected
						</cfif>> Non-binary
					</option>
				</select>
			</label>


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
			<label>
				Campus
				<select name="campus">
					<option value="Cascade"
						<cfif "Cascade" eq caseload_banner.campus>
							selected
						</cfif>> Cascade
					</option>

					<option value="Southest"
						<cfif "Southest" eq caseload_banner.campus>
							selected
						</cfif>> Southest
					</option>

					<option value="Sylvania"
						<cfif "Sylvania" eq caseload_banner.campus>
							selected
						</cfif>> Sylvania
					</option>

					<option value="Rock Creek"
						<cfif "Rock Creek" eq caseload_banner.campus>
							selected
						</cfif>> Rock Creek
					</option>

				</select>
			</label>




			<label>
				Parental status
				<select name="parentalStatus">
					<option value="Unknown"
					<cfif "Unknown" eq caseload_banner.parentalStatus>
						selected
					</cfif>>Unknown
					</option> <option value="Yes"
					<cfif "Yes" eq caseload_banner.parentalStatus>
						selected
					</cfif>
					>Yes </option> <option value="No"
					<cfif "No" eq caseload_banner.parentalStatus>
						selected
					</cfif>
					>No </option>
				</select>
			</label>

			<!--- Household Information --->
			<cfinvoke component="fc" method="getHouseholdWithAssignments" contactID=#caseload_banner.contactID#  returnVariable="mscb_data">
			<cfset mscb_fieldNameDescription = 'Household Information'>
			<cfset mscb_fieldName = 'householdID'>
			<cfinclude template="#pcc_source#/includes/multiSelectCheckboxes.cfm">

			<!--- Living Situation --->
			<cfinvoke component="fc" method="getLivingSituationWithAssignments" contactID=#caseload_banner.contactID#  returnVariable="mscb_data">
			<cfset mscb_fieldNameDescription = 'Living Situation'>
			<cfset mscb_fieldName = 'livingSituationID'>
			<cfinclude template="#pcc_source#/includes/multiSelectCheckboxes.cfm">




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
			<label>
				Weekly Work Hours
				<select name="weeklyWorkHours">
					<option value = "less than 20"
					<cfif "less than 20" eq caseload_banner.weeklyWorkHours>
						selected
					</cfif>
					>less than 20</option> <option value = "20to29"
					<cfif "20to29" eq caseload_banner.weeklyWorkHours>
						selected
					</cfif>
					>20to29</option> <option value = "30to39"
					<cfif "30to39" eq caseload_banner.weeklyWorkHours>
						selected
					</cfif>
					>30to39</option> <option value = "40 or more"
					<cfif "40 or more" eq caseload_banner.weeklyWorkHours>
						selected
					</cfif>
					>40 or more</option>
				</select>
			</label>
			<label>
				EFC
				<cfoutput>
					<input type="text" name="EFC" readonly value="#maxTermData.EFC#" />
				</cfoutput>

			</label>
			<label>
				Academic Hold
				<cfoutput>
					<input type="text" name="RE_HOLD" readonly value="#caseload_banner.RE_HOLD#" />
				</cfoutput>
			</label>
		</div>
		<!--- END COLUMN 1 --->

		<!--- COLUMN 2 --->
		<div class="large-4 columns">

					<label>
				Status Internal
				<select name="statusInternal">
					<option value="A"
					<cfif "A" eq caseload_banner.statusInternal>
						selected
					</cfif>>A
					</option>

					<option value="B"
					<cfif "B" eq caseload_banner.statusInternal>
						selected
					</cfif>
					>B </option>

					<option value="C"
					<cfif "C" eq caseload_banner.statusInternal>
						selected
					</cfif>
					>C </option>

					<option value="X"
					<cfif "X" eq caseload_banner.statusInternal>
						selected
					</cfif>
					>X </option>

				</select>
			</label>




			<label>
				ASAP
				<cfoutput>
					<input type="text" name="ASAP_STATUS" readonly value="#maxTermData.ASAP_STATUS#" />
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
					<input type="text" name="P_DEGREE" readonly value="#maxTermData.P_DEGREE#" />
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
					<input type="text" name="firstYearGPA" readonly value="#DecimalFormat(firstYearMetrics.firstYearGPA)#" />
				</cfoutput>
			</label>

			<!--- Exit Reason --->
			<label>
				Exit Reason
				<select name="exitReason">
					<option value="Housing insecurity / homeless"
					<cfif "Housing insecurity / homeless" eq caseload_banner.exitReason>
						selected
					</cfif>
					> Housing insecurity / homeless</option>

					<option value="Mental health barriers"
					<cfif "Mental health barriers" eq caseload_banner.exitReason>
						selected
					</cfif>> Mental health barriers
					</option>

					<option value="Academic frustration"
					<cfif "Academic frustration" eq caseload_banner.exitReason>
						selected
					</cfif>> Academic frustration
					</option>

					<option value="Moving out of PCC district"
					<cfif "Moving out of PCC district" eq caseload_banner.exitReason>
						selected
					</cfif>> Moving out of PCC district
					</option>

					<option value="ASAP Issue"
					<cfif "ASAP Issue" eq caseload_banner.exitReason>
						selected
					</cfif>> ASAP Issue
					</option>

					<option value="Leaving school to work"
					<cfif "Leaving school to work" eq caseload_banner.exitReason>
						selected
					</cfif>
					> Leaving school to work</option> <option value="Parenting responsibilities"
					<cfif "Parenting responsibilities" eq caseload_banner.exitReason>
						selected
					</cfif>
					> Parenting responsibilities</option> <option value="Left without contact"
					<cfif "Left without contact" eq caseload_banner.exitReason>
						selected
					</cfif>
					> Left without contact</option>
				</select>
			</label>
			<!--- End Exit Reason --->
		</div>
		<!--- END COLUMN 2 --->

		<!--- COLUMN 3 --->
		<div class="large-4 columns">
			<label>
				Coach
				<select name="coach">
					<cfoutput query="list_coach">
						<option value="#CoachName#"
						<cfif CoachName eq caseload_banner.coach>
							selected
						</cfif>
						>#CoachName#</option>
					</cfoutput>
				</select>
			</label>
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

			<cfinvoke component="fc" method="getEnrichmentProgramsWithAssignments" contactID=#caseload_banner.contactID#  returnVariable="mscb_data">
			<cfset mscb_fieldNameDescription = 'Enrichment Programs'>
			<cfset mscb_fieldName = 'enrichmentProgramID'>
			<cfinclude template="#pcc_source#/includes/multiSelectCheckboxes.cfm">

			<cfinvoke component="fc" method="getNotes"  contactID = #caseload_banner.contactID# returnvariable="notesvar_data"></cfinvoke>
			<label>Notes
				<textarea name="notes" rows="10"></textarea>
				<cfinclude template="#pcc_source#/includes/notes.cfm" />
			</label>
			<input name="submit" value="Save" class="success button" type="submit" />
		</div>
		<!---- END COLUMN 3 --->
	</div> 	<!--- end row class --->
</form>
