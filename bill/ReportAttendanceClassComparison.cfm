<cfinclude template="includes/header.cfm">


<cfinvoke component="LookUp" method="getFirstOpenAttendanceDate" returnvariable="selectedBillingDate"></cfinvoke>
<cfif IsDefined("form.billingStartDate")>
	<cfset selectedBillingDate = form.billingStartDate>
</cfif>
<cfif IsDefined("url.billingStartDate")>
	<cfset selectedBillingDate = url.billingStartDate>
</cfif>


<style>

	.dataTables_info{
		margin-right:10px !important;v
	}
	.dataTables_filter input{
		width:75%;
		display: inline-block;
	}
	.dataTables_length select {
		width:auto;
	}
	table.dataTable thead th.tooltipformat {
		color:gray;
		font-size:x-small;
		border-bottom-style:none;
		padding-bottom:0px;
	}
</style>

<div class="callout primary">Discrepancy Report between Current Billing and Current Banner Class Enrollment</div>
<div class="callout">
Compares billing entries with current banner class enrollment.  Indicates if a student added or dropped a class after
the billing entries were generated.
</div>
<table id="dt_table">
<thead>
<tr>
	<th>Type of Billing</th>
	<th>Banner G Number</th>
	<th>First Name</th>
	<th>Last Name</th>
	<th>Program</th>
	<th>CRN</th>
	<th>CRSE</th>
	<th>SUBJ</th>
	<th>Title</th>
	<th>Status</th>
</tr>
<tbody>
</table>
<cfsavecontent variable="pcc_scripts">
<script>
	var billingStartDate = '<cfoutput>#selectedBillingDate#</cfoutput>';
	$(document).ready(function() {
	    table = $('#dt_table').DataTable({
			ajax:{
				url: "report.cfc?method=CompareCurrentAttendance",
				data: {billingStartDate: billingStartDate},
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			paging:false,
			columnDefs:[
			{targets:9,
	    		render: function ( data, type, row ) {
	    			if(row[10]=='X')
    					return 'Dropped in Banner';
    				else
    					return 'Missing from Billing';
	    		  }
	    		}
	    	],
	    	order:[[0, 'asc']],
	    	rowGroup: {
    			dataSrc: 0
    		},
			language: {loadingRecords: 'Please wait...updating...will take a few minutes...'
						,emptyTable: 'No data for the selected month start date.'},
			buttons:[
					{extend: 'excel',
            			text: 'export',
            	  	}
            	  ],
           dom: '<"top"iBf>rt<"bottom"lp>',
	    });
	  });
</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">