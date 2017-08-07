<!--- header --->
<cfinclude template="includes/header.cfm" />

<cfif not StructKeyExists(Session, "pidm")>
	<cflocation url="caseload.cfm">
</cfif>
<cfif not StructKeyExists(Session, "maxterm")>
	<cflocation url="caseload.cfm">
</cfif>
<cfparam name="studentparam_pidm" default="#session.pidm#">
<cfparam name="studentparam_maxterm" default="#session.maxterm#">
<cfdump var="#session#">
<cfinvoke component="fc" method="getCaseload" pidm="#studentparam_pidm#" returnvariable="caseload_banner"></cfinvoke>
<cfdump var = "#caseload_banner#">
<cfparam name="studentparam_cohort" default="#caseload_banner.cohort#" >
<cfparam name="studentparam_bannerGNumber" default="#caseload_banner.bannerGNumber#">

<cfinvoke component="fc" method="getMaxRegistration" pidm ="#studentparam_pidm#" maxterm="#studentparam_maxterm#" returnvariable="maxRegistration"></cfinvoke>

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