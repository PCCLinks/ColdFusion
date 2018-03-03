<!---<cfdump var=#Session#>--->

<!doctype html>
<html class="no-js" lang="en">

<!--- CF Parameters --->
<cfparam name="pcc_source" default='/pcclinks' />
<cfparam name="pcc_title" default="PCC Links">
<cfparam name="pcc_styles" default='' />
<cfparam name="pcc_scripts" default='' />
<cfparam name="pcc_logo" default='' />
<cfparam name="pcc_menu" default='' />
<!--- end CF Parameters --->

<cfset pcc_title = 'PCC Links' /> 	<!--- Page title & h3 --->
<cfsavecontent variable="pcc_menu">	 <!--- List items for menu --->
	<ul class="dropdown menu" data-dropdown-menu>
		 <li><a href="index.cfm">Home</a></li>
		 <li><a>Term Billing</a>
			<ul class="menu">
				<li><a href="SetUpBilling.cfm?type=Term">Set Up Billing</a></li>
		 		<li><a href="AddStudent.cfm">Add Student</a></li>
				<li><a href="ReportSummary.cfm?type=Term">Reporting</a></li>
			</ul>
		</li>
		 <li><a>Attendance Billing</a>
			<ul class="menu">
				<li><a href="SetUpBilling.cfm?type=Attendance">Set Up Billing</a></li>
		 		<li><a href="AttendanceEntry.cfm">Enter Attendance</a></li>
		 		<li><a href="AddStudent.cfm">Add Student</a></li>
		 		<li><a href="AddScenario.cfm">Scenarios</a></li>
				<li><a href="ReportSummary.cfm?type=Attendance">Reporting</a></li>
				<li><a href="ReportAttendanceEntry.cfm">Attendance Summary</a></li>
				<li><a href="AttendanceBillingTotalOverride.cfm">Totals Override</a></li>
			</ul>
		</li>
		<li><a href="ProgramStudent.cfm">Review Billing</a>
			<ul class="menu">
				<li><a href="ProgramStudent.cfm">Review Billing</a></li>
		 		<li><a href="ProgramReview.cfm">Coach Review</a></li>
		 		<li><a href="Transcript.cfm">Transcript</a></li>
			</ul>
		</li>
		<li><a>Additional Reports</a>
			<ul class="menu">
				<li><a href="ReportExitStatus.cfm">Exit Status Report</a></li>
				<li><a href="ReportADM.cfm">ADM Report</a></li>
				<li><a href="ReportPPS.cfm">PPS Report</a></li>
				<li><a href="ReportEnrollment.cfm">Enrollment Report</a></li>
				<li><a href="ReportOverage.cfm?program=GtC">GtC Overage Report</a></li>
				<li><a href="ReportOverage.cfm?program=YtC">YtC Overage Report</a></li>
			</ul>
		</li>
		<li><a>Set Exits</a>
			<ul class="menu">
				<li><a href="ExitDate.cfm">Set Exit Reason</a></li>
				<li><a href="UpdateExitDates.cfm">Update Exit Dates</a></li>
			</ul>
		</li>
		 <!---<li><a href="Reconcile.cfm">Reconcile Previous Billing</a></li>--->
	</ul>
</cfsavecontent>

<!-- HEAD -->
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><cfoutput>#pcc_title#</cfoutput> | PCC</title>

    <!-- styles -->
	<link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>/css/foundation-datepicker.css" />
    <link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>/css/foundation.min.css" />
    <link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>/css/app.css" />
    <link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>/css/vendor/datatables.min.css" />
	<!--<link rel="stylesheet" href="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.css"/>
	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-colvis-1.3.1/b-html5-1.3.1/b-print-1.3.1/cr-1.3.3/fc-3.2.2/fh-3.1.2/kt-2.2.1/r-2.1.1/rg-1.0.0/sc-1.4.2/se-1.2.2/datatables.min.css"/>-->
	<cfoutput>#pcc_styles#</cfoutput>

	<!-- jquery -->
	<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery.js"></script>
	<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/Chart.bundle.min.js"></script>
 </head>
<!-- End HEAD -->

<!-- BODY -->
 <body>

    <!-- header -->
    <header id="header" aria-label="Main header" role="banner">
      <div class="row">
        <div class="small-12 medium-4 large-3 columns">
          <h1>
            <span class="visually-hide">Portland Community College</span>
              <a href="https://www.pcc.edu/">
                <img src="<cfoutput>#pcc_source#</cfoutput>/images/logo.svg" onerror="this.src='images/logo.png'; this.onerror=null;" alt="Portland Community College | Portland, Oregon" />
              </a>
          </h1>
        </div>
        <div class="small-10 medium-7 large-8 columns">
          <h2><cfoutput>#pcc_title#</cfoutput></h2>
        </div>
		<div class="small-2 medium-1 large-1 columns">
			<br class="clear"><a href="?action=logout" >Logout</a>
		</div>
      </div> <!-- end row -->
    </header> <!-- end header -->

    <nav id="nav" aria-label="Main navigation">
      <div class="row">
        <div class="small-12 columns">
          <cfoutput>#pcc_logo#</cfoutput>
          <ul class="menu">
            <cfoutput>#pcc_menu#</cfoutput>
          </ul>
        </div> <!-- end small-12 -->
      </div> <!-- end row -->
    </nav> <!-- end navigation -->

    <!-- content area -->
    <div id="content" class="row" aria-label="Page content">
    <div class="small-12 columns">


<!-- end header template -->

<!-- start editable content area -->