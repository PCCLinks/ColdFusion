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
	SELECT distinct displayName as coach
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


			<!-- Gender Select -->
			<cfset values=["Female", "Male", "Non-binary"]>
			<cfmodule template="#pcc_source#/includes/selectOption.cfm"
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

			<!-- Campus Select -->
			<cfset values=["Cascade", "Southeast", "Sylvania", "Rock Creek"]>
			<cfmodule template="#pcc_source#/includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.campus#"
				so_label = "Campus"
				so_selectname="campus"
			>
			<!-- end campus select -->

			<!-- Parental status Select -->
			<cfset values=["Unknown", "Yes", "No"]>
			<cfmodule template="#pcc_source#/includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.parentalStatus#"
				so_label = "Parental status"
				so_selectname="parentalStatus"
			>
			<!-- end Parental status select -->

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

			<!-- Living Situation checkboxes -->
			<!-- ajax jquery refreshes div -->
			<div id="livingsituation">
			<cfmodule template="#pcc_source#/includes/multiSelectCheckboxes.cfm"
				mscb_description = 'Living Situation'
				mscb_fieldName = 'livingSituationID'
				mscb_componentname = "fc"
				mscb_methodName = "getLivingSituationWithAssignments"
				contactid = "#caseload_banner.contactID#"
			>
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

			<!-- Weekly Work Hours Select -->
			<cfset values=["none", "less than 20", "20 to 29","30 to 39","40 or more"]>
			<cfmodule template="#pcc_source#/includes/selectOption.cfm"
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
		</div>
		<!-- END COLUMN 1 -->

		<!-- COLUMN 2 -->
		<div class="large-4 columns">

			<!-- Status Internal Select -->
			<cfset values=["A", "B", "C", "X"]>
			<cfmodule template="#pcc_source#/includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.statusInternal#"
				so_label = "Status Internal"
				so_selectname="statusInternal"
			>
			<!-- end Status Internal select -->

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


			<!-- Exit Reason Select -->
			<cfset values=["Academic frustration", "ASAP Issue", "Completed Certificate","Completed Degree"
							,"Completed Degree & Transfer","Entered the Military","Transferred"
							,"Housing insecurity / homeless","Incarcerated","Leaving school to work"
							,"Left without contact","Mental health barriers","Moving out of PCC district"
							,"Parenting responsibilities"]>
			<cfmodule template="#pcc_source#/includes/selectOption.cfm"
				so_values="#values#"
				so_selectedvalue="#caseload_banner.exitReason#"
				so_label = "Exit Reason"
				so_selectname="exitReason"
			>
			<!-- end Exit Reason select -->

		</div>
		<!--- END COLUMN 2 --->

		<!--- COLUMN 3 --->
		<div class="large-4 columns">
			<!-- Coach Select -->
			<cfset values= ListToArray(ValueList(list_coach.coach))>
			<cfmodule template="#pcc_source#/includes/selectOption.cfm"
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

			<!-- Enrichment Programs Checkboxes -->
			<!-- refreshed by jquery -->
			<div id="enrichmentprograms">
			<cfmodule template="#pcc_source#/includes/multiSelectCheckboxes.cfm"
				mscb_description = 'Enrichment Programs'
				mscb_fieldName = 'enrichmentProgramID'
				mscb_componentname = "fc"
				mscb_methodName = "getEnrichmentProgramsWithAssignments"
				contactid = "#caseload_banner.contactID#"
			>
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
      	//checkboxes only show up as posted values when checked
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