<cfif not StructKeyExists(FORM, "pidm")>
	<cfthrow message = "Student.cfm expecting PIDM in Form posting">
</cfif>
<cfif not StructKeyExists(FORM, "maxterm")>
	<cfthrow message = "Student.cfm expecting MaxTerm in Form posting">
</cfif>

<cfparam name="studentparam_pidm" default="#form.pidm#">
<cflog file="pcclinks_fc" text="starting getCaseload">
<cfinvoke component="fc" method="getCaseload" pidm="#studentparam_pidm#" returnvariable="caseload_banner"></cfinvoke>
<cflog file="pcclinks_fc" text="starting getMaxReg">
<cfparam name="studentparam_cohort" default="#caseload_banner.cohort#" >
<cfparam name="studentparam_maxterm" default="#form.maxterm#">
<cfinvoke component="fc" method="getMaxRegistration" pidm ="#studentparam_pidm#" maxterm="#studentparam_maxterm#" returnvariable="maxRegistration"></cfinvoke>
<cflog file="pcclinks_fc" text="finished getMaxRegistration">
<!--- header --->
<cfinclude template="includes/header.cfm" />

<!--- main content --->
<ul class="tabs" data-tabs id="student-tabs">
  <li class="tabs-title is-active"><a href="#panel1" aria-selected="true">Edit</a></li>
  <li class="tabs-title"><a href="#panel2">Student Dashboard</a></li>
</ul>

<div class="callout primary">
<cfoutput>
	<div class = "row">
		<div class = "large-4 columns">
			<h3>#caseload_banner.STU_NAME# <br> #caseload_banner.STU_ID#</h3>
		</div>
		<div class = "large-4 columns" style="text-align:left">
			<h3>Overall GPA: #caseload_banner.O_GPA# <br>Total Credits Earned: #caseload_banner.O_EARNED#</h3>
		</div>
		<div class = "large-4 columns" style="text-align:left">
			<h3>Last Registration: <br> #maxRegistration.maxRegistrationTerm# for #maxRegistration.maxRegistrationCredits# credits</h3>
		</div>
	</div>
	</cfoutput>
</div>

<div class="tabs-content" data-tabs-content="student-tabs">
  <div class="tabs-panel is-active" id="panel1">
	<cfinclude template="editcase.cfm">
  </div>
  <div class="tabs-panel" id="panel2">
    <cfinclude template="studentdashboard.cfm">
  </div>
</div>
<cfsavecontent variable="pcc_scripts">
<cfoutput>
#editcase_script#
#studentdashboard_script#
</cfoutput>
</cfsavecontent>

<cfinclude template="includes/footer.cfm" />