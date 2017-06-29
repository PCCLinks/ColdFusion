<!---  <cfdump var=#Session#> --->

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

<cfset pcc_title 	= 'PCC Links' /> 	<!--- Page title & h3 --->
<cfset pcc_logo	  = '<img src="/pcclinks/images/future-connect.png" alt="Future Connect logo">' />	<!--- Include app logo image--->
<cfsavecontent variable="pcc_menu">	 <!--- List items for menu --->
	<li><a href="dashboard.cfm">Home</a></li>
	<li><a href="caseload.cfm">Caseload</a></li>
</cfsavecontent>

<!-- HEAD -->
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><cfoutput>#pcc_title#</cfoutput> | PCC</title>

    <!-- styles -->
    <link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>/css/foundation.min.css" />
    <link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>/css/app.css" />
	<link rel="stylesheet" href="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.css"/>
	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-colvis-1.3.1/b-html5-1.3.1/b-print-1.3.1/cr-1.3.3/fc-3.2.2/fh-3.1.2/kt-2.2.1/r-2.1.1/rg-1.0.0/sc-1.4.2/se-1.2.2/datatables.min.css"/>
	<cfoutput>#pcc_styles#</cfoutput>

	<!-- jquery -->
	<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery.js"></script>
	<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/Chart.bundle.min.js"></script>
 </head>
<!-- End HEAD -->

<!-- BODY -->
 <body>

	<!--- Authentication Template --->
	<cfinclude template="#pcc_source#/includes/auth.cfm">

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