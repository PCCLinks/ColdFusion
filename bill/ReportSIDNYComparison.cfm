<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getOpenBillingStartDates" returnvariable="billingDates"></cfinvoke>
<cfinvoke component="LookUp" method="getLatestBillingStartDate" returnvariable="latestMonth"></cfinvoke>
<cfparam name="selectedBillingDate" default="#latestMonth#">
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

<div class="callout primary">Discrepancy Report between Billing System and SIDNY</div>
<div class="callout">
<ul><li>Displays student entries which are assigned to a different program in SIDNY than the Billing Application assigned.
        The billing application determines YtC programs based on class composition in addition to the SIDNY assignment.</li>
	<li>It also shows student entries which have no entry in this current billing period, but are still showing as active in SIDNY.
    	(These latter ones show up with "Missing!" in the current program.</li>
	<li>To change the current program assignment, click the "G Number" of the student, and edit the program in the next screen.</li>
</ul>
</div>
<div class="callout row">
<form action="ReportSIDNYComparison.cfm" method="post">
	<label for="billingStartDate">
	<div class="small-2 columns">
		Month Start Date:
	</div>
	<div class="small-4 columns">
			<select name="billingStartDate" id="billingStartDate" onchange="this.form.submit()">
				<option disabled selected value="" > --Select Month Start Date-- </option>
			<cfoutput query="billingDates">
				<option value="#billingStartDate#" <cfif billingStartDate EQ selectedBillingDate> selected </cfif>  > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
			</cfoutput>
			</select>
	</div>
	<div class="small-6 columns">
	</div>
	</label>
</form>
</div>
<table id="dt_table">
<thead>
<tr>
	<th>G Number</th>
	<th>First Name</th>
	<th>Last Name</th>
	<th>SIDNY Program Assignment</th>
	<th>Billing Program Assignment</th>
</tr>
<tbody>
</table>
<cfsavecontent variable="pcc_scripts">
<script>
	var billingStartDate = '<cfoutput>#selectedBillingDate#</cfoutput>';
	$(document).ready(function() {
	    table = $('#dt_table').DataTable({
			ajax:{
				url: "report.cfc?method=sidnyBillingComparison",
				data: {billingStartDate: billingStartDate},
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			paging:false,
			columnDefs:[
	    		{targets:0,
	    		render: function ( data, type, row ) {
	    			if(row[5]){
	    				return '<a href="programStudent.cfm?billingStudentId=' + row[5] + '" target="_blank">' + data + '</a>';
	    			} else {
	    				return data;
	    			}
	    		  }
	    		}
	    	],
			language: {loadingRecords: 'Please wait...updating...will take a few minutes...'
						,emptyTable: 'No data for the selected month start date.'},
	    });
	  });
</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">