<!doctype html>
<html class="no-js" lang="en">

<!--- CF Parameters --->
<cfparam name="pcc_title" default="PCC Links">
<cfparam name="pcc_styles" default='' />
<cfparam name="pcc_scripts" default='' />
<cfparam name="pcc_logo" default='' />
<cfparam name="pcc_menu" default='' />
<cfparam name="pcc_source" default='/pcclinks' />
<!--- end CF Parameters --->

<cfset pcc_title = 'PCC Links' /> 	<!--- Page title & h3 --->


<!-- HEAD -->
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><cfoutput>#pcc_title#</cfoutput> | PCC</title>

    <!-- styles -->
    <link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>/css/foundation.min.css" />
    <link rel="stylesheet" href="<cfoutput>#pcc_source#</cfoutput>/css/app.css" />
	<cfoutput>#pcc_styles#</cfoutput>

	<!-- jquery -->
	<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery.js"></script>

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
        </div> <!-- end small-12 -->
      </div> <!-- end row -->
    </nav> <!-- end navigation -->

    <!-- content area -->
    <div id="content" class="row" aria-label="Page content">
    <div class="small-12 columns">


<!-- end header template -->

<!-- start editable content area -->
<div class="callout">
	There has been an authorization error accessing the PCC Links application.  Please contact PCC Links.
	<cfif StructKeyExists(session, "error") && len(trim(session.error))>
		<br><br>
		<cfoutput>#session.error#</cfoutput>
	<cfelse>
	</cfif>
</div>
<!-- end editable content area -->

<!-- start template footer -->
</div> <!-- end small-12 -->
 </div><!-- end content -->

<!-- scripts -->
<!---<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/jquery.js"></script>--->
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/what-input.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/vendor/foundation.min.js"></script>
<script src="<cfoutput>#pcc_source#</cfoutput>/js/pcc.js"></script>




<!-- end template footer -->

<!-- end body and html tags -->
</body>
</html>

