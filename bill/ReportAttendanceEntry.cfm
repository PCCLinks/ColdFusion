<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getLatestAttendanceDates" returnvariable="dates"></cfinvoke>

<cfinvoke component="Report" method="attendanceEntry" returnvariable="data">
	<cfinvokeargument name="billingStartDate" value="#dates.billingStartDate#">
</cfinvoke>
<cfset Session.attendanceEntryPrint = data>

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
<cfoutput>
<cfset title = "Attendance Entry for #DateFormat(dates.billingStartDate,'mm-dd-yy')# to #DateFormat(dates.billingEndDate,'mm-dd-yy')#">
<cfset Session.attendanceEntryTitle = title>
<div class="callout primary">#title#</div>
</cfoutput>
<table id="dt_table">
	<thead>
		<tr>
			<th>CRN</th>
			<th>CRSE</th>
			<th>SUBJ</th>
			<th>Title</th>
			<th>G</th>
			<th>Firstname</th>
			<th>Lastname</th>
			<th>Attendance</th>
			<th>Scheduled</th>
			<th>Exclude Student</th>
			<th>Exclude Class</th>
		</tr>
	</thead>
	<tbody>
		<cfoutput query="data">
		<tr>
			<td><a href='AttendanceEntry.cfm?crn=#crn#&billingStartDate=#dates.billingStartDate#' target="_blank">#crn#</a></td>
			<td>#crse#</td>
			<td>#subj#</td>
			<td>#title#</td>
			<td><a href='javascript:goToBillingRecord(#billingStudentId#);'>#bannerGNumber#</a></td>
			<td>#firstname#</td>
			<td>#lastname#</td>
			<td>#NumberFormat(attendance,'99.99')#</td>
			<td>#NumberFormat(MaxPossibleAttendance,'99.99')#</td>
			<td>#includestudent#</td>
			<td>#includeclass#</td>
		</tr>
		</cfoutput>
	</tbody>
</table>


<cfsavecontent variable="pcc_scripts">
	<script>
		$(document).ready(function() {
		    $('#dt_table').DataTable({
		    	dom: '<"top"iBf>rt<"bottom"lp>',
				buttons:[
					{ text: "export",
            	  		action: function( e, table, node, config ){
							window.open('includes/ReportAttendanceEntryPrintInclude.cfm');
            	  		}
            	  }
            	  ],
            	columns:[{data:'crn'},{data:'crse'},{data:'subj'},{data:'title'},{data:'bannerGNumber'}
            			,{data:'firstname'},{data:'lastname'},{data:'attendance'},{data:'maxpossibleattendance'}
            			,{data:'includestudent'},{data:'includeclass'}],
            	rowGroup: {
    				dataSrc: 'crn'
    			}
		    });
		} );
	function goToBillingRecord(billingStudentId){
		window.open('programStudentDetail.cfm?billingStudentId='+billingStudentId+'&showNext=true#Billing');
	}

	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">