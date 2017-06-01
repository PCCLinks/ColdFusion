<!--- called by student.cfm
 cohort varialbe set by student.cfm
--->

<cfinvoke component="fc" method="getFirstYearMetrics" id="#studentvar_id#" cohort="#studentvar_cohort#" returnvariable="firstYearMetrics">
</cfinvoke>
<cfinvoke component="fc" method="getCGPassed" id="#studentvar_id#" cohort="#studentvar_cohort#" returnvariable="cgPassed">
</cfinvoke>
<cfinvoke component="fc" method="getASAP_Degree" id="#studentvar_id#" returnvariable="ASAP_Degree">
</cfinvoke>
<cfquery datasource="pcclinks" name="list_status">
	SELECT distinct statusabcx
	FROM pcc_links.fc
	where statusabcx is not null
	ORDER BY 1 ASC
</cfquery>
<cfquery datasource="pcclinks" name="list_cohort">
	SELECT distinct cohort
	FROM pcc_links.fc
	where cohort is not null
	ORDER BY 1 ASC
</cfquery>
<cfquery datasource="pcclinks" name="list_coach">
	SELECT distinct CoachName
	FROM pcc_links.coach
	ORDER BY 1 ASC
</cfquery>
<cfquery datasource="pcclinks" name="list_gender">
	SELECT distinct GenderName
	FROM pcc_links.gender
	ORDER BY 1 ASC
</cfquery>
<cfquery datasource="pcclinks" name="list_campus">
	SELECT distinct CampusName
	FROM pcc_links.campus
	ORDER BY 1 ASC
</cfquery>

<form action="saveCase.cfm" method="post" id="editForm" name="editForm">
	<input name="method" type="hidden" value="update" />
	<cfoutput>
		<input name="G" type="hidden" value="#caseload_banner.G#" />
	</cfoutput>
	<div class="row">
		<div class="large-4 columns">
			<label>
				First Name*
				<cfoutput>
					<input type="text" name="first_name" readonly value="#caseload_banner.first_name#" />
				</cfoutput>
			</label>
			<label>
				Last Name*
				<cfoutput>
					<input type="text" name="last_name" readonly value="#caseload_banner.last_name#" />
				</cfoutput>
			</label>
			<label>
				Cohort
				<select name="cohort">
					<cfoutput query="list_cohort">
						<option value="#cohort#"
						<cfif cohort eq caseload_banner.cohort>
							selected
						</cfif>
						> #cohort#</option>
					</cfoutput>
				</select>
			</label>
			<label>
				Gender*
				<select name="gender">
					<cfoutput query="list_gender">
						<option value="#GenderName#"
						<cfif GenderName eq caseload_banner.gender >
							selected
						</cfif>
						> #GenderName# </option>
					</cfoutput>
				</select>
			</label>
			<label>
				Race*
				<cfoutput>
					<input type="text" name="race" readonly value="#caseload_banner.BI_REP_RACE#" />
				</cfoutput>
			</label>
			<label>
				High School
				<cfoutput>
					<input type="text" name="hs" readonly value="#caseload_banner.hs#" />
				</cfoutput>
			</label>
			<label>
				Campus*
				<select name="campus">
					<cfoutput query="list_campus">
						<option value="#CampusName#"
						<cfif CampusName eq caseload_banner.campus>
							selected
						</cfif>
						> #CampusName# </option>
					</cfoutput>
				</select>
			</label>
			<label>
				Parental status
				<select name="parental_status">
					<option value="Unknown"
					<cfif "Unknown" eq caseload_banner.parental_status>
						selected
					</cfif>
					>Unknown</option> <option value="Yes"
					<cfif "Yes" eq caseload_banner.parental_status>
						selected
					</cfif>
					>Yes >Yes</option> <option value="No"
					<cfif "No" eq caseload_banner.parental_status>
						selected
					</cfif>
					>No >No</option>
				</select>
			</label>
			<label>
				Household Information
				<select name="household_information">
					<option value="None of the above"
					<cfif "None of the above" eq caseload_banner.household_information>
						selected
					</cfif>
					>None of the above</option> <option value="Housing assistance from Home Forward"
					<cfif "Housing assistance from Home Forward" eq caseload_banner.household_information>
						selected
					</cfif>
					>Housing assistance from Home Forward </option> <option value="Special Supplemental Nutrition Program for Woman, Infants & Children (WIC)"
					<cfif "Special Supplemental Nutrition Program for Woman, Infants & Children (WIC)" eq caseload_banner.household_information>
						selected
					</cfif>
					>Special Supplemental Nutrition Program for Woman, Infants & Children (WIC)</option> <option value="Free or Reduced Price School Lunch"
					<cfif "Free or Reduced Price School Lunch" eq caseload_banner.household_information>
						selected
					</cfif>
					>Free or Reduced Price School Lunch</option> <option value="Food Stamps"
					<cfif "Food Stamps" eq caseload_banner.household_information>
						selected
					</cfif>
					>Food Stamps</option> <option value="Temporary Assistance for Needy Families (TANF)"
					<cfif "Temporary Assistance for Needy Families (TANF)" eq caseload_banner.household_information>
						selected
					</cfif>
					>Temporary Assistance for Needy Families (TANF)</option> <option value="Supplemental Security Income"
					<cfif "Supplemental Security Income" eq caseload_banner.household_information>
						selected
					</cfif>
					>Supplemental Security Income</option>
				</select>
			</label>
			<label>
				Living Situation
				<select name="living_situation">
					<option value="None of the above"
					<cfif "None of the above" eq caseload_banner.living_situation>
						selected
					</cfif>
					>None of the above</option> <option value="Is/was in foster care"
					<cfif "Is/was in foster care" eq caseload_banner.living_situation>
						selected
					</cfif>
					>Is/was in foster care</option> <option value="Is/was homeless"
					<cfif "Is/was homeless" eq caseload_banner.living_situation>
						selected
					</cfif>
					>Is/was homeless</option> <option value="Emancipated minor"
					<cfif "Emancipated minor" eq caseload_banner.living_situation>
						selected
					</cfif>
					>Emancipated minor</option>
				</select>
			</label>
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
					<input type="text" name="professional_goal" value="#caseload_banner.professional_goal#" />
				</cfoutput>
			</label>
			<label>
				Weekly Work Hours
				<select name="work_hours_weekly">
					<option value = "less than 20"
					<cfif "less than 20" eq caseload_banner.work_hours_weekly>
						selected
					</cfif>
					>less than 20</option> <option value = "20to29"
					<cfif "20to29" eq caseload_banner.work_hours_weekly>
						selected
					</cfif>
					>20to29</option> <option value = "30to39"
					<cfif "30to39" eq caseload_banner.work_hours_weekly>
						selected
					</cfif>
					>30to39</option> <option value = "40 or more"
					<cfif "40 or more" eq caseload_banner.work_hours_weekly>
						selected
					</cfif>
					>40 or more</option>
				</select>
			</label>
			<label>
				EFC
				<cfoutput>
					<input type="text" name="efc" readonly />
				</cfoutput>
			</label>
			<label>
				Academic Hold
				<cfoutput>
					<input type="text" name="hold" readonly value="#caseload_banner.RE_HOLD#" />
				</cfoutput>
			</label>
		</div>
		<div class="large-4 columns">
			<label>
				StatusABCX
				<select name="statusabcx">
					<cfoutput query="list_status">
						<option value="#statusabcx#"
						<cfif statusabcx eq caseload_banner.statusabcx >
							selected
						</cfif>
						>#statusabcx#</OPTION>
					</cfoutput>
				</select>
			</label>
			<label>
				ASAP
				<cfoutput>
					<input type="text" name="asap_status" readonly value="#ASAP_Degree.INCOMING_SAP#" />
				</cfoutput>
			</label>
			<label>
				Credits Earned
				<cfoutput>
					<input type="text" name="credits_earned" readonly value="#caseload_banner.O_EARNED#" />
				</cfoutput>
			</label>
			<label>
				GPA
				<cfoutput>
					<input type="text" name="gpa_cumulative" readonly value="#caseload_banner.O_GPA#" />
				</cfoutput>
			</label>
			<label>
				Registered Next Term
				<cfoutput>
					<input type="text" name="registered_next_term" readonly value="#caseload_banner.registered_next_term#" />
				</cfoutput>
			</label>
			<label>
				Degree Declared
				<cfoutput>
					<input type="text" name="degree_declared" readonly value="#ASAP_Degree.P_DEGR#" />
				</cfoutput>
			</label>
			<label>
				Reading Placement
				<cfoutput>
					<input type="text" name="rd_test" readonly value="#caseload_banner.te_read#" />
				</cfoutput>
			</label>
			<label>
				Writing Placement
				<cfoutput>
					<input type="text" name="wr_test" readonly value="#caseload_banner.te_write#" />
				</cfoutput>
			</label>
			<label>
				Math Placement
				<cfoutput>
					<input type="text" name="ma_test" readonly value="#caseload_banner.te_math#" />
				</cfoutput>
			</label>
			<label>
				CG100
				<cfoutput>
					<input type="text" name="cg100" readonly value=
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
					<input type="text" name="cg130" readonly value=
					<cfif "#cgPassed.cg130Passed#" eq 1>
						Yes
					<cfelse>
						No
					</cfif>
					>
				</cfoutput>
			</label>
			<label>
				FirstYearCredits*
				<cfoutput>
					<input type="text" name="firstYearCredits" readonly value="#firstYearMetrics.firstYearCredits#" />
				</cfoutput>
			</label>
			<label>
				FirstYearGPA*
				<cfoutput>
					<input type="text" name="firstYearGPA" readonly value="#DecimalFormat(firstYearMetrics.firstYearGPA)#" />
				</cfoutput>
			</label>
			<label>
				Exit Reason
				<select name="outcome_exit_reason">
					<option value="Housing insecurity / homeless"
					<cfif "Housing insecurity / homeless" eq caseload_banner.outcome_exit_reason>
						selected
					</cfif>
					> Housing insecurity / homeless</option> <option value="Mental health barriers"
					<cfif "Mental health barriers" eq caseload_banner.outcome_exit_reason>
						selected
					</cfif>
					> Mental health barriers</option> <option value="Leaving school to work"
					<cfif "Leaving school to work" eq caseload_banner.outcome_exit_reason>
						selected
					</cfif>
					> Leaving school to work</option> <option value="Parenting responsibilities"
					<cfif "Parenting responsibilities" eq caseload_banner.outcome_exit_reason>
						selected
					</cfif>
					> Parenting responsibilities</option> <option value="Left without contact"
					<cfif "Left without contact" eq caseload_banner.outcome_exit_reason>
						selected
					</cfif>
					> Left without contact</option>
				</select>
			</label>
		</div>
		<div class="large-4 columns">
			<label>
				Coach
				<a href="http://localhost:8500/pcclinks/Lookup.cfm?LookUpType=Coach" style="font-size: 0.75em;">
					edit coach list
				</a>
				<select name="Coach">
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
					<input type="text" name="phone1" value="#caseload_banner.phone1#" />
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
					<input type="text" name="email_pcc" readonly value="#caseload_banner.email_pcc#" />
				</cfoutput>
			</label>
			<label>
				Email Personal
				<cfoutput>
					<input type="text" name="email_personal" value="#caseload_banner.email_personal#" />
				</cfoutput>
			</label>
			<label>
				Enrichment Programs
				<select multiple name="enrichment">
					<option value="CG 190 Leadership"
					<cfif "CG 190 Leadership" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>CG 190 Leadership</option> <option value="WSI - Summer Works Internship"
					<cfif "WSI - Summer Works Internship" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>WSI - Summer Works Internship</option> <option value="Portland Bureau Internship"
					<cfif "Portland Bureau Internship" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>Portland Bureau Internship</option> <option value="Providence Health related Internship"
					<cfif "Providence Health related Internship" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>Providence Health related Internship</option> <option value="City of Hillsboro Internship"
					<cfif "City of Hillsboro Internship" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>City of Hillsboro Internship</option> <option value="City of Beaverton Internship"
					<cfif "City of Beaverton Internship" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>City of Beaverton Internship</option> <option value="BEC Internship"
					<cfif "BEC Internship" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>BEC Internship</option> <option value="AVID Tutor"
					<cfif "AVID Tutor" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>AVID Tutor</option> <option value="GearUp CAM Mentor"
					<cfif "GearUp CAM Mentor" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>GearUp CAM Mentor</option> <option value="Volunteer work in community"
					<cfif "Volunteer work in community" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>Volunteer work in community</option> <option value="Volunteer work in community from CG 190 Leadership"
					<cfif "Volunteer work in community from CG 190 Leadership" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>Volunteer work in community from CG 190 Leadership</option> <option value="Work Study"
					<cfif "Work Study" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>Work Study</option> <option value="ASPCC"
					<cfif "ASPCC" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>ASPCC</option> <option value="FC Outreach with Coordinator"
					<cfif "FC Outreach with Coordinator" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>FC Outreach with Coordinator</option> <option value="FC Ambassador @ Orientation"
					<cfif "FC Ambassador @ Orientation" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>FC Ambassador @ Orientation</option> <option value="Field trips to other Universities or Colleges"
					<cfif "Field trips to other Universities or Colleges" eq caseload_banner.enrichment_programs>
						selected
					</cfif>
					>Field trips to other Universities or Colleges</option>
				</select>
			</label>
			<label>
				Notes
				<textarea name="notes" rows="10">
				</textarea>
				<cfinclude template="#pcc_source#/includes/notes.cfm" />
			</label>
			<input name="submit" value="Save" class="success button" type="submit" />
		</div>
	</div>
	<!--- end row class --->
</form>