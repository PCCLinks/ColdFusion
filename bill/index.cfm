<!--- header template --->
<cfinclude template="includes/header.cfm" />

<cfinvoke component="ProgramBilling" method="getCurrentTermSummary"  returnvariable="qryData">
</cfinvoke>
<cfset Session.Term = qryData.Term>
<cflock timeout=20 scope="Session" type="Exclusive">
	<cfset StructDelete(Session, "Program")>
	<cfset StructDelete(Session, "SchoolDistrict")>
</cflock>

<!-- Tabs -->
<ul class="tabs" data-tabs id="index-tabs">
	<li class="tabs-title is-active"><a href="#attendanceTab" aria-selected="true">Attendance Steps</a></li>
	<li class="tabs-title"><a href="#termTab">Term</a></li>
</ul>

<!-- billing tab content -->
<div class="tabs-content" data-tabs-content="index-tabs">
	<!-- attendance content -->
  	<div class = "tabs-panel is-active" id="attendanceTab">
    	<cfmodule template="includes/indexAttendanceInclude.cfm" >
  	</div>
	<!-- term content -->
	<div class = "tabs-panel" id="termTab">
		<!--- main content --->
		<div class="row">
			<div class="callout primary">
				<cfoutput>Billing for Term: #qryData.Term#</cfoutput>
			</div>
		</div>
		<div class="row">
			<table id="dt_table" class="stripe compact" cellspacing="0" width="100%">
				<thead>
		        	<tr>
		            	<th id="SchoolDistrict">School District</th>
						<th id="Program">Program</th>
						<th id="StudentsStillBeingReviewed">Review in Progress</th>
						<th id="StudentsReviewed">Reviewed</th>
		           </tr>
		        </thead>
		        <tbody>
				<cfif not isNull(qryData)>
		        	<cfoutput query="qryData">
		            <tr>
		            	<td>#qryData.schoolDistrict#</td>
						<td>#qryData.program#</td>
						<td>#qryData.StudentsStillBeingReviewed#</td>
						<td>#qryData.StudentsReviewed#</td>
		            </tr>
		            </cfoutput>
				</cfif>
		        </tbody>
			</table>
		</div>
	</div>
</div>

<!--- scripts referenced in footer --->
<cfsavecontent variable="pcc_scripts">
<script>
	$(document).ready(function() {
		$('#dt_table').dataTable({
			paging:false,
			searching:false
		});
	});
</script>
</cfsavecontent>

<!--- footer template --->
<cfinclude template="includes/footer.cfm">