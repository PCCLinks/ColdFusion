<cfinvoke component="ProgramBilling" method="getReconcileSummary"  returnvariable="qryData">
</cfinvoke>
<cfinclude template="includes/header.cfm">

<!---- Main Body --->
<div class="row">
	<div class="callout primary">
		<cfoutput>Reconcile for Term: #qryData.Term#</cfoutput>
	</div>
</div>
<div class="row">
       <table id="dt_table" class="hover" cellspacing="0" width="100%">
           <thead>
               <tr>
				<th id="districtId"></th>
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
						<td>#qryData.districtID#</th>
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

<cfsavecontent variable="pcc_scripts">
	<script>
	$(document).ready(function() {
		$('#dt_table').dataTable({
			paging:false,
			searching:false,
			columnDefs:[
                {	targets: 4,
                	render: function ( data, type, row ) {
                  				return '<a href="javascript:goToReconcileStudent(\'' + row[0] + '\', \'' + row[2] + '\');" >' + row[4] + '</a>';
             					}
         					},
         				{targets: 0,
         				 visible:false
         					}
         				]
			});
	});
	function goToReconcileStudent(districtId, program){
		sessionStorage.setItem('districtId', districtId);
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
</cfsavecontent>

<cfinclude template="includes/footer.cfm">