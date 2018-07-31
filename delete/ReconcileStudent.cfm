<!DOCTYPE html>
<!---<cfdump var="#Session#">--->
<cfinvoke component="ProgramBilling" method="getProgramDistrictReconcile"  returnvariable="qryData">
	<cfinvokeargument name="term" value="#Session.term#">
	<cfinvokeargument name="program" value="#Session.program#">
	<cfinvokeargument name="districtId" value="#Session.districtId#">
</cfinvoke>
<!---<cfdump var="#qryData#">--->
<cfinclude template="includes/header.cfm">

<div class="row">
	<div class="callout primary">
		<cfoutput>Reconcile for Term: #qryData.Term#</cfoutput>
	</div>
</div>
<div class="row">
       <table id="dt_table" class="hover" cellspacing="0" width="100%">
           <thead>
               <tr>
				<th id="Name">Name</th>
                <th id="SchoolDistrict">School District</th>
				<th id="Program">Program</th>
				<th id="Term">Term</th>
				<th id="Status">Billing Status</th>
				<th id="Amount">Billed</th>
               </tr>
           </thead>
           <tbody>
			<cfif not isNull(qryData)>
               <cfoutput query="qryData">
                   <tr>
						<td>#qryData.name#</td>
                       	<td>#qryData.schoolDistrict#</td>
						<td>#qryData.program#</td>
						<td>#qryData.term#</td>
						<td>#qryData.BillingStatus#</td>
						<td>#NumberFormat(qryData.Amount,'_')#</td>
                   </tr>
               </cfoutput>
			</cfif>
           </tbody>
       </table>
   </div>

<cfsavecontent  variable ="pcc_scripts">
	<script>
	$(document).ready(function() {
		$('#dt_table').dataTable({
			paging:false,
			searching:false,
			info: false,
			columnDefs: [
            { "visible": false, "targets": 0 }
        	],
			columns:[{data:'name'},{data:'schooldistrict'},{data:'program'}
						,{data: 'term'},{data:'billingStatus'},{data:'Amount'}
					],
	    	rowGroup: {
	    		dataSrc: 'name'
	    	}
 		});
	});

	</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">