<!DOCTYPE html>
<!---<cfdump var="#Session#">--->
<cfinvoke component="ProgramBilling" method="getReconcileSummary"  returnvariable="qryData">
</cfinvoke>
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
		<cfoutput>Reconcile for Term: #qryData.Term#</cfoutput>
	</div>
</div>
<div class="row">
       <table id="dt_table" class="hover" cellspacing="0" width="100%">
           <thead>
               <tr>
                <th id="SchoolDistrict">School District</th>
				<th id="Program">Program</th>
				<th id="Billed">Billed</th>
				<th id="NotBilled">Revised</th>
               </tr>
           </thead>
           <tbody>
			<cfif not isNull(qryData)>
               <cfoutput query="qryData">
                   <tr>
                       	<td>#qryData.schoolDistrict#</td>
						<td>#qryData.program#</td>
						<td>#NumberFormat(qryData.Billed,'_')#</td>
						<td>#NumberFormat(qryData.NotBilled,'_')#</td>
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
			searching:false,
			columnDefs:[
                {	targets: 3,
                	render: function ( data, type, row ) {
                  				return '<a href="javascript:goToReconcileStudent(\'' + row[0] + '\', \'' + row[1] + '\');" >' + row[3] + '</a>';
             					}
         					}
         				]
			});
	});
	function goToReconcileStudent(schooldistrict, program){
		sessionStorage.setItem('schooldistrict', schooldistrict);
		sessionStorage.setItem('program', program);
		sessionStorage.setItem('term', <cfoutput>#qryData.Term#</cfoutput>);
		saveSessionToServer();
		setTimeout(goToReconcileStudentPage,100);
	}
	function goToReconcileStudentPage(){
		window.location = "ReconcileStudent.cfm";
	}
	function saveSessionToServer(){
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  		$.post("SaveSession.cfm", data);
	}
	</script>
</footer>
</html>