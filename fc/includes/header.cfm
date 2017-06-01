<!doctype html>
<html class="no-js" lang="en">
<!--- CF Parameters --->
<cfparam name="pcc_source" default='/PCCLinks/' />
<cfparam name="pcc_title" default="PCC Links">
<cfparam name="pcc_styles" default='' />
<cfparam name="pcc_scripts" default='' />
<cfparam name="pcc_logo" default='' />
<cfparam name="pcc_menu" default='' />
<!--- end CF Parameters --->
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><cfoutput>#pcc_title#</cfoutput> | PCC</title>

    <!-- styles -->
    <link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>css/foundation.min.css" />
    <link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>css/app.css" />
    <!--<link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>css/pcc.css" /> -->
	<link rel="stylesheet" href="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.css"/>
	<cfoutput>#pcc_styles#</cfoutput>

	<!-- jquery -->
	<script src="<cfoutput>#pcc_source#</cfoutput>js/vendor/jquery.js"></script>
	<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.5.0/Chart.bundle.js"></script>

  </head>
  <body>


    <!-- header -->
    <nav class="top-bar" >
	   <div class="row expanded columns">
        <div class="small-1 columns">
          <h1>
            <span class="visually-hide">Portland Community College</span>
              <a href="https://www.pcc.edu/">
                <img src="<cfoutput>#pcc_source#</cfoutput>images/logo.svg" onerror="this.src='images/logo.png'; this.onerror=null;" alt="Portland Community College | Portland, Oregon" />
              </a>
          </h1>
        </div>
        <div class="small-2 columns" id="header">
          <h2><cfoutput>#pcc_title#</cfoutput></h2>
        </div>

        <div class="small-9 columns">
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
