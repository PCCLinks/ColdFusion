<cfsavecontent variable="pcc_menu">
	<nav class="top-bar" >
    <ul class="menu">
	  <li><img src="/PCCLinks/images/fclogo.png"/></li>
      <li><a href="dashboard.cfm">Home</a></li>
      <li><a href="caseload.cfm">Caseload</a></li>
	  </ul>
	</nav>
</cfsavecontent>
<cfinclude template="includes/header.cfm" />

<!--- main content --->
<ul class="tabs" data-tabs id="student-tabs">
  <li class="tabs-title is-active"><a href="#panel1" aria-selected="true">Edit</a></li>
  <li class="tabs-title"><a href="#panel2">Student Dashboard</a></li>
</ul>

<div class="tabs-content" data-tabs-content="student-tabs">
  <div class="tabs-panel is-active" id="panel1">
    <cfinclude template="editcase.cfm">
  </div>
  <div class="tabs-panel" id="panel2">
    <cfinclude template="studentdashboard.cfm">
  </div>
</div>


<cfinclude template="includes/footer.cfm" />