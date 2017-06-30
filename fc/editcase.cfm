<!--- called by student.cfm
 pidm and cohort variable set by student.cfm
--->
<cfparam name="studentparam_pidm">
<cfparam name="studentparam_cohort">
<cflog file="pcclinks_fc" text="starting getFirstYearMetrics">
<cfinvoke component="fc" method="getFirstYearMetrics" pidm="#studentparam_pidm#" cohort="#studentparam_cohort#" returnvariable="firstYearMetrics"></cfinvoke>
<cflog file="pcclinks_fc" text="starting getCGPassed">
<cfinvoke component="fc" method="getCGPassed" pidm="#studentparam_pidm#" cohort="#studentparam_cohort#" returnvariable="cgPassed"></cfinvoke>
<cflog file="pcclinks_fc" text="finished getCGPassed">


<!---- Lookup Fields --->

<cfquery name="list_coach">
	SELECT distinct displayName as coachName
	FROM applicationUser
	WHERE position = 'coach'
	ORDER BY 1 ASC
</cfquery>

<!--- FORM ---->
<form action="javascript:saveContent();" method="post" id="editForm" name="editForm">
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

			<!-- Household Information checkboxes -->
			<div id="householdInfo">
			<!---<cfinvoke component="fc" method="getHouseholdWithAssignments" contactID=#caseload_banner.contactID#  returnVariable="mscb_data">--->
			<cfset mscb_description = 'Household Information'>
			<cfset mscb_fieldName = 'householdID'>
			<cfset mscb_componentname = "fc">
			<cfset mscb_methodName = "getHouseholdWithAssignments">
			<cfinclude template="#pcc_source#/includes/multiSelectCheckboxes.cfm">
			</div>

			<!-- Living Situation checkboxes -->
			<div id="livingsituation">
			<cfset mscb_description = 'Living Situation'>
			<cfset mscb_fieldName = 'livingSituationID'>
			<cfset mscb_componentname = "fc">
			<cfset mscb_methodName = "getLivingSituationWithAssignments">
			<cfinclude template="#pcc_source#/includes/multiSelectCheckboxes.cfm">
			</div>

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

					<option value = "none"
					<cfif "none" eq caseload_banner.weeklyWorkHours>
						selected
					</cfif>
					>none</option>

					<option value = "less than 20"
					<cfif "less than 20" eq caseload_banner.weeklyWorkHours>
						selected
					</cfif>
					>less than 20</option>

					<option value = "20 to 29"
					<cfif "20 to 29" eq caseload_banner.weeklyWorkHours>
						selected
					</cfif>
					>20 to 29</option> <option value = "30 to 39"
					<cfif "30 to 39" eq caseload_banner.weeklyWorkHours>
						selected
					</cfif>
					>30 to 39</option> <option value = "40 or more"
					<cfif "40 or more" eq caseload_banner.weeklyWorkHours>
						selected
					</cfif>
					>40 or more</option>
				</select>
			</label>
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
		</div>
		<!-- END COLUMN 1 -->

		<!-- COLUMN 2 -->
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
					<input type="text" name="P_DEGREE" readonly value="#caseload_banner.P_DEGREE#" />
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

			<!-- Exit Reason dropdown -->
			<label>
				Exit Reason

				<select name="exitReason">

					<option value="Academic frustration"
					<cfif "Academic frustration" eq caseload_banner.exitReason>
						selected
					</cfif>>Academic frustration
					</option>

					<option value="ASAP Issue"
					<cfif "ASAP Issue" eq caseload_banner.exitReason>
						selected
					</cfif>>ASAP Issue
					</option>


					<option value="Completed Certificate"
					<cfif "Completed Certificate" eq caseload_banner.exitReason>
						selected
					</cfif>>Completed Certificate
					</option>


					<option value="Completed Degree"
					<cfif "Completed Degree" eq caseload_banner.exitReason>
						selected
					</cfif>>Completed Degree
					</option>

					<option value="Completed Degree & Transfer"
					<cfif "Completed Degree & Transfer" eq caseload_banner.exitReason>
						selected
					</cfif>>Completed Degree & Transfer
					</option>

					<option value="Entered the Military"
					<cfif "Entered the Military" eq caseload_banner.exitReason>
						selected
					</cfif>>Entered the Military
					</option>

					<option value="Transferred"
					<cfif "Transferred" eq caseload_banner.exitReason>
						selected
					</cfif>>Transferred
					</option>



					<option value="Housing insecurity / homeless"
					<cfif "Housing insecurity / homeless" eq caseload_banner.exitReason>
						selected
					</cfif>>Housing insecurity / homeless
					</option>

					<option value="Incarcerated"
					<cfif "Incarcerated" eq caseload_banner.exitReason>
						selected
					</cfif>>Incarcerated
					</option>




					<option value="Leaving school to work"
					<cfif "Leaving school to work" eq caseload_banner.exitReason>
						selected
					</cfif>>Leaving school to work
					</option>


					<option value="Left without contact"
					<cfif "Left without contact" eq caseload_banner.exitReason>
						selected
					</cfif>>Left without contact
					</option>



					<option value="Mental health barriers"
					<cfif "Mental health barriers" eq caseload_banner.exitReason>
						selected
					</cfif>>Mental health barriers
					</option>

					<option value="Moving out of PCC district"
					<cfif "Moving out of PCC district" eq caseload_banner.exitReason>
						selected
					</cfif>>Moving out of PCC district
					</option>


					<option value="Parenting responsibilities"
					<cfif "Parenting responsibilities" eq caseload_banner.exitReason>
						selected
					</cfif>>Parenting responsibilities
					</option>

				</select>
			</label>
			<!-- End Exit Reason -->

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

			<!-- Enrichment Programs Checkboxes -->
			<div id="enrichmentprograms">
			<cfset mscb_description = 'Enrichment Programs'>
			<cfset mscb_fieldName = 'enrichmentProgramID'>
			<cfset mscb_componentname = "fc">
			<cfset mscb_methodName = "getEnrichmentProgramsWithAssignments">
			<cfinclude template="#pcc_source#/includes/multiSelectCheckboxes.cfm">
			</div>
			<!-- end enrichment programs -->

			<!-- Notes -->
			<div id="notes">
			<cfparam  name="tableName" default="futureConnect">
			<cfparam  name="contactID" default="#Form.contactid#">
			<cfinclude template="#pcc_source#/includes/notes.cfm" />
			</div>
			<!-- end div notes -->

			<label>
				Flag
				<cfoutput>
					<input type="checkbox" name="flag" value="#caseload_banner.flagged#"  <cfif caseload_banner.flagged EQ 1 >checked</cfif>/>
				</cfoutput>
			</label>

			<input name="submit" value="Save" class="success button" type="submit" />
			<div id="savemessage"></div>
		</div>
		<!---- END COLUMN 3 --->
	</div> 	<!--- end row class --->
</form>
<cfsavecontent variable="editcase_script">
<script>
   function saveContent(){
   		form = {};
   		flagCheckBoxFound = false;
   		flagFieldName = 'flagged';
   		$.each($('form').serializeArray(), function(index, field) {
   			if(field.name == flagFieldName){
   				flagCheckBoxFound = true;
   			}
      		form[field.name] = field.value;
      	});
      	//checkboxes only show up when checked
      	if(flagCheckBoxFound == false){
      		form[flagFieldName] = 0;
      	}
		$.blockUI({ message: 'Saving...' });
		 $.ajax({
            type: 'post',
            url: 'fc.cfc?method=updateCase',
            data: {data : JSON.stringify(form), isAjax:'yes'},
            datatype:'json',
            success: function (data, textStatus, jqXHR) {
            	updateContent();
            	var d = new Date();
				$('#savemessage').html('Last saved ' + addZero(d.getHours()) + ':' + addZero(d.getMinutes()) + ':' + addZero(d.getSeconds()));
		    },
            error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
			}
          });
		$.unblockUI();
	}
	function updateContent(){
		//notes
		url = "<cfoutput>#pcc_source#/includes/notes.cfm?contactid=#contactid#&tablename=#tablename#</cfoutput>";
		$('#notes').load(url);
		//household
		url = "<cfoutput>#pcc_source#/includes/multiselectcheckboxes.cfm?contactid=#contactid#&mscb_componentname=pcclinks.fc.fc&mscb_methodname=getHouseholdWithAssignments&mscb_fieldName=householdID&mscb_description=Household%20Information</cfoutput>";
		$('#householdInfo').load(url, function(){$(this).foundation();});
		//living
		url = "<cfoutput>#pcc_source#/includes/multiselectcheckboxes.cfm?contactid=#contactid#&mscb_componentname=pcclinks.fc.fc&mscb_methodname=getLivingSituationWithAssignments&mscb_fieldName=livingSituationID&mscb_description=Living%20Situation</cfoutput>";
		$('#livingsituation').load(url, function(){$(this).foundation();});
		//enrichment
		url = "<cfoutput>#pcc_source#/includes/multiselectcheckboxes.cfm?contactid=#contactid#&mscb_componentname=pcclinks.fc.fc&mscb_methodname=getEnrichmentProgramsWithAssignments&mscb_fieldName=enrichmentProgramId&mscb_description=Enrichment%20Program</cfoutput>";
		$('#enrichmentprograms').load(url, function(){$(this).foundation();});
	}
	function addZero($time) {
	  if ($time < 10) {
	    $time = "0" + $time;
	  }
	  return $time;
	}
</script>
</cfsavecontent>