<!DOCTYPE html>
<cfdump var="#Session#">
<cfinvoke component="ProgramBilling" method="getCurrentTermSummary"  returnvariable="qryData">
</cfinvoke>
<cfset Session.Term = qryData.Term>
<cflock timeout=20 scope="Session" type="Exclusive">
	<cfset StructDelete(Session, "Program")>
	<cfset StructDelete(Session, "SchoolDistrict")>
</cflock>
<html>
	<head>
		<link rel="stylesheet" href="css/foundation.css">
		<script src="js/vendor/jquery.js"></script>
		<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
		<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.css"/>
	</head>
<body>
<nav class="top-bar" >
    <ul class="menu">
     	 <li><a href="Billing.cfm">Home</a></li>
     	 <li><a href="SetUpBilling.cfm">Generate</a></li>
     	 <li><a href="ProgramStudent.cfm">Submit Billing</a></li>
     	 <li><a href="Reconcile.cfm">Reconcile Previous Billing</a></li>
     	 <li><a href="BillingSummary.cfm">Reports</a></li>
	  </ul>
</nav>
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
</body>
<footer>
	<script type="text/javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
	<script type="text/javascript" src="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.js"></script>
	<script type="text/javascript" charset="utf8" src="js/jquery.blockUI.js"></script>

	<script>
	$(document).ready(function() {
		$('#dt_table').dataTable({
			paging:false,
			searching:false
		});
	});
	</script>
</footer>
</html>