<!---<cfdump var="#Session#">--->
<cfset programValue="" >
<cfif isDefined("Session.Program") >
	<cfset programValue="#Session.Program#" >
</cfif>
<cfset schooldistrictValue="" >
<cfif isDefined("Session.schooldistrict") >
	<cfset schooldistrictValue="#Session.schooldistrict#" >
</cfif>
<cfset termValue="" >
<cfif isDefined("Session.term") >
	<cfset termValue="#Session.term#" >
</cfif>
<cfinvoke component="LookUp" method = "getProgramYearTerms" term="#termValue#" returnvariable="terms"></cfinvoke>
<cfinvoke component="ProgramBilling" method="yearlybilling" returnvariable="qryData">
	<cfinvokeargument name="program" value="#programValue#">
	<cfinvokeargument name="schooldistrict" value="#schooldistrictvalue#">
	<cfinvokeargument name="term" value="#termValue#">
</cfinvoke>
<html>
<head>
 <link rel="stylesheet" href="css/foundation.css">
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.15/css/dataTables.foundation.min.css">
  <script src="js/vendor/modernizr.js"></script>
  <script src="js/vendor/jquery.js"></script>
<script src="https://code.jquery.com/jquery-1.12.4.js"></script>

</head>
<body>
<nav class="top-bar" >
    <ul class="menu">
     	 <li><a href="SetUpBilling.cfm">Generate</a></li>
     	 <li><a href="ProgramStudent.cfm">Submit Billing</a></li>
     	 <li><a href="Reconcile.cfm">Reconcile Previous Billing</a></li>
     	 <li><a href="BillingSummary.cfm">Reports</a></li>
	  </ul>
</nav>
<cfoutput>
<div class="row">
	<div class="callout">
		<h3>College Quarterly Credit - Equivalent Instructional Days</h3>
		<b>All Students at  #qryData.Program# for #terms.term1# and #terms.currentterm#</b>
	</div>
</div>
	<div class="row">
        <table id="dt_table" class="hover" cellspacing="0" width="100%">
            <thead>
                <tr id="headerRow">
                    <th id="FIRSTNAME">Student</th>
                    <th id="LASTNAME"></th>
                    <th id="CurrentEnrolledDate">Entry Date</th>
					<th id="CurrentExitDate">Exit Date</th>
					<th id="SummerNoOfCredits">Summer</th>
					<cfif #termValue# GTE #terms.term2#><th id="FallNoOfCredits">Fall</th></cfif>
					<cfif #termValue# GTE #terms.term3#><th id="WinterNoOfCredits">Winter</th></cfif>
					<cfif #termValue# GTE #terms.term4#><th id="SpringNoOfCredits">Spring</th></cfif>
                </tr>
            </thead>
            <tbody>
				<cfif not isNull(qryData)>
                	<cfloop query="qryData">
                    <tr>
                        <td>#qryData.FIRSTNAME#</td>
                        <td>#qryData.LASTNAME#</td>
                        <td>#qryData.CurrentEnrolledDate#</td>
						<td>#qryData.CurrentExitDate#</td>
						<td>
							<cfif LEN(qryData.SummerNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(qryData.SummerNoOfCredits,'_')#
							</cfif>
						</td>
						<cfif #termValue# GTE #terms.term2#>
						<td>
							<cfif LEN(qryData.FallNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(qryData.FallNoOfCredits,'_')#</cfif>
						</td>
						</cfif>
						<cfif #termValue# GTE #terms.term3#>
						<td>
							<cfif LEN(qryData.WinterNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(qryData.WinterNoOfCredits,'_')#</cfif>
						</td>
						</cfif>
						<cfif #termValue# GTE #terms.term4#>
						<td>
							<cfif LEN(qryData.SpringNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(qryData.SpringNoOfCredits,'_')#</cfif>
						</td>
						</cfif>
                    </tr>
                	</cfloop>
				</cfif>
            </tbody>
        </table>
    </div>
</cfoutput>
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