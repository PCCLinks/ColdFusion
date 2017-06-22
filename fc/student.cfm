<cfset debug=false>
<cfif structKeyExists(FORM, "bannerGNumber")>
	<cfset Session.bannerGNumber = FORM.bannerGNumber>
	<cfif debug><cfdump var="#FORM#"></cfif>
</cfif>
<cfif debug><cfdump var="#SESSION#"></cfif>
<cfparam name="studentvar_id" default="#Session.bannerGNumber#">
<cfif debug><cfdump var="#studentvar_id#"></cfif>


<cfinvoke component="fc" method="getCaseload" bannerGNumber="#studentvar_id#" returnvariable="caseload_banner"></cfinvoke>
<cfparam name="studentvar_cohort" default="#caseload_banner.cohort#" >
<cfinvoke component="fc" method="getMaxRegistration" bannerGNumber="#studentvar_id#" returnvariable="maxRegistration"></cfinvoke>


<!--- menu --->
<cfsavecontent variable="pcc_menu">
	<header>
	<div class="row">
        <div class="small-12 medium-4 large-3 columns">
            <span class="visually-hide">PCC Links Future Connect</span>
            <img src="/pcclinks/images/fclogo.png" onerror="this.src='images/logo.png'; this.onerror=null;" alt="PCC Links Future Connect" />
        </div>
        <div class="small-12 medium-8 large-9 columns">
			<br class="clear">
        	<ul class="menu">
		      	<li><a href="dashboard.cfm">Home</a></li>
		      	<li><a href="caseload.cfm">Caseload</a></li>
	 		</ul>
        </div>
   </div> <!-- end row -->
</header>
</cfsavecontent>

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
		<h3>GPA: #caseload_banner.O_GPA# <br>Credits Earned: #caseload_banner.O_EARNED#</h3>
		</div>

		<div class = "large-4 columns" style="text-align:left">
		<h3>Last Registered: #maxRegistration.maxRegistrationTerm# <br> with #maxRegistration.maxRegistrationCredits# credits</h3>
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


<cfinclude template="includes/footer.cfm" />