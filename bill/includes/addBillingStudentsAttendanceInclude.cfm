<cfparam name="billingStartDate" default="">
<cfif isDefined("attributes.billingStartDate")>
	<cfset billingStartDate = "#attributes.billingStartDate#">
<cfelse>
	<cfset billingStartDate = "#url.billingStartDate#">
</cfif>

<cfparam name="dataType" default="">
<cfif isDefined("attributes.dataType")>
	<cfset dataType = "#attributes.dataType#">
<cfelse>
	<cfset dataType = "#url.dataType#">
</cfif>



<style>

	.dataTables_info{
		margin-right:10px !important;
	}
	.dataTables_filter input{
		width:75%;
		display: inline-block;
	}
	.dataTables_length select {
		width:auto;
	}
</style>
	<h4>Students Listed for Billing Period: <cfoutput>#DateFormat(url.billingStartDate,'mm-dd-yy')#</cfoutput></h4>
	<table id="dt_table_<cfoutput>#dataType#</cfoutput>">
		<thead>
			<th>First Name</th>
			<th>Last Name</th>
			<th>Banner G Number</th>
			<th>Add</th>
			<th></th>
			<th></th>
		</thead>
		<tbody>
		</tbody>
	</table>


	<script>

	var dt;
	$(document).ready(function() {
		//intialize table
		$.fn.dataTable.ext.errMode = 'throw';

		<cfoutput>
		<cfif dataType EQ 'allStudentsForBillingStartDate'>
			var url = "programBilling.cfc?method=getStudentsForBillingStartDate&billingStartDate=#billingStartDate#";
		<cfelse>
			var url = "programBilling.cfc?method=getAttendanceStudentsForCRN&billingStartDate=#billingStartDate#&crn=#url.crn#";
		</cfif>
		</cfoutput>

		var idxFirstName = 0;
		var idxLastName = 1;
		var idxBannerGNumber = 2;
		var idxBillingStudentID = 3;
		var idxBillingStudentItemID = 4;
		var idxIncludeFlag = 5;
		dt = $('#dt_table_<cfoutput>#dataType#</cfoutput>').DataTable( {
			destroy:true,
			processing:true,
			ajax:{
				url:url,
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			columnDefs: [
				 {targets:idxBillingStudentID,
				 	sortable:false,
				 	render: function ( data, type, row ) {
				 		<cfoutput>
				 		if(row[idxIncludeFlag] == 1){
				 			return '<a href="javascript:removeItem(' + row[idxBillingStudentItemID] + ', ' + row[idxBillingStudentID] + ');" id=' + row[idxBillingStudentID] + '>Remove Entry</a>';
				 		}else{
				 			return '<input type="checkbox" id=' + row[idxBillingStudentID] + ' onclick="javascript:insertItem(' + row[idxBillingStudentID] + ', ' + row[idxBillingStudentItemID] + ');">';
				 		}
				 		</cfoutput>
				 	}
				 },
				 {targets:[idxBillingStudentItemID, idxIncludeFlag],
				 	visible:false}
				],
			order: [[idxIncludeFlag, 'desc'],[idxLastName, 'asc']]
			});
	});
	function refresh(){
		dt.ajax.reload();
	}

	</script>