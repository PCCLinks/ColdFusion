<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getFirstOpenAttendanceDates" returnvariable="dates"></cfinvoke>
<cfinvoke component="LookUp" method="getAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>

<cfparam name="billingStartDate" default="#dates.billingStartDate#">
<cfif isDefined("Form.billingStartDate")>
	<cfset Variables.billingStartDate = Form.billingStartDate>
</cfif>

<cfinvoke component="Report" method="attendanceEntry" returnvariable="data">
	<cfinvokeargument name="billingStartDate" value="#Variables.billingStartDate#">
</cfinvoke>


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
<cfset title = "Attendance Entry for #DateFormat(Variables.billingStartDate,'mm-dd-yy')#">
<cfset Session.attendanceEntryTitle = title>
<form action="ReportAttendanceEntry.cfm" method="post">
<div class="callout primary">
	<label for="billingStartDate">Attendance Entry for:&nbsp;&nbsp;
		<select name="billingStartDate" id="billingStartDate" onChange="javascript:this.form.submit()" style="width:200px">
			<option disabled selected value="" > --Select Month Start Date-- </option>
			<cfoutput query="billingDates">
				<option value="#billingStartDate#" <cfif billingStartDate EQ Variables.billingStartDate> selected </cfif>  > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
			</cfoutput>
		</select>
	</label>
</div>
<div class="callout"><div class="row">
	<div class="large-2 columns"><a class="group-by" data-column="0" data-src="crn">Group by CRN</a></div>
	<div class="large-3 columns"><a class="group-by" data-column="3" data-src="schooldistrict">Group by School District</a></div>
	<div class="large-3 columns"><a class="group-by" data-column="4" data-src="program">Group by Program</a></div>
	<div class="large-4 columns"><a class="group-by" data-column="5" data-src="bannerGNumber">Group by Student</a></div>
</div></div>
</form>
<table id="dt_table">
	<thead>
		<tr>
			<th>CRN</th>
			<th>Crse</th>
			<th>Subj</th>
			<th>District</th>
			<th>Program</th>
			<th>G</th>
			<th>First Name</th>
			<th>Last Name</th>
			<th>Program Exit</th>
			<th>Current Exit</th>
			<th>Attend.</th>
			<th>Sched.</th>
			<th>Notes</th>
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
			<td>#schooldistrict#</td>
			<td>#program#</td>
			<td><a href='javascript:getBillingStudent(#billingStudentId#, true);'>#bannerGNumber#</a></td>
			<td>#firstname#</td>
			<td>#lastname#</td>
			<td>#DateFormat(exitDate,'m/d/yyyy')#</td>
			<td>#DateFormat(sidnyExitDate,'m/d/yyyy')#</td>
			<td>#NumberFormat(attendance,'99.99')#</td>
			<td>#NumberFormat(MaxPossibleAttendance,'99.99')#</td>
			<td>#notes#</td>
			<td>#includestudent#</td>
			<td>#includeclass#</td>
		</tr>
		</cfoutput>
	</tbody>
</table>


<cfsavecontent variable="pcc_scripts">
	<script>
		$(document).ready(function() {
		    var table = $('#dt_table').DataTable({
		    	dom: '<"top"iBf>rt<"bottom"lp>',
				buttons:[
					{ text: "export",
            	  		action: function( e, table, node, config ){
							window.open('includes/ReportAttendanceEntryPrintInclude.cfm');
            	  		}
            	  }
            	  ],
            	columns:[{data:'crn'},{data:'crse'},{data:'subj'}
            			,{data:'schooldistrict'}, {data:'program'},{data:'bannerGNumber'}
            			,{data:'firstname'},{data:'lastname'},{data:'attendance'},{data:'maxpossibleattendance'}
            			,{data:'notes'}, {data:'includestudent'},{data:'includeclass'}, {data:'exitDate'}
            			,{data:'sidnyExitDate'}],
            	rowGroup: {
    				dataSrc: 'crn'
    			},
    			columDefs:[{target:3, visible:false}]
		    });

		    $('a.group-by').on( 'click', function (e) {
				e.preventDefault();
				table.column($(this).data('column')).order('asc');
				table.rowGroup().dataSrc( $(this).data('src') );
				table.order.fixed( {pre: [[ $(this).data('column')*1, 'asc' ]]} ).draw();
			});
		} );


	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">