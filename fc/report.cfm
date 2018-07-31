<!--- pulled into a div in caseload.cfm, so no need for headers or footers --->

<table id="dt_table_report" class="hover" ;>
	<caption class="visually-hide">Future Connect Caseload</caption>
	<thead>
		<tr>
			<!--- note this order should match the order in the query in fc.getReportList --->
			<th>Name</th>
			<th>G</th>
			<th>Cohort</th>
			<th>ASAP</th>
			<th>Status</th>
			<th>Coach</th>
			<th>Max Reg Term</th>
			<th>Last Contact</th>
			<th>Credits Earned</th>
			<th>Gender</th>
			<th>Race</th>
			<th>High School</th>
			<th>Parental Status</th>
			<th>Career Plan</th>
			<th>Academic Hold</th>
			<th>GPA</th>
			<th>Reading Placement</th>
			<th>Writing Placement</th>
			<th>Math Placement</th>
			<th>Exit Reason</th>
			<th>Cell Phone</th>
			<th>Phone 2</th>
			<th>Email PCC</th>
			<th>Email Personal</th>
			<th>Preferred Name</th>
			<th>Weekly Work Hours</th>
			<th>In Contract</th>
			<th>Funding Source</th>
			<th>Decree Declared</th>
			<th>EFC</th>
			<th>Foster Care Y/N</th>
		</tr>
	</thead>
	<tfoot>
	<tr>
			<th><input type="text" placeholder="Name" /></th>
			<th><input type="text" placeholder="G"  /></th>
			<th><input type="text" placeholder="Cohort" id="cohort" /></th>
			<th><input type="text" placeholder="ASAP" id="ASAP_STATUS" /></th>
			<th><input type="text" placeholder="Status" id="statusInternal" /></th>
			<th><input type="text" placeholder="Coach"  /></th>
			<th><input type="text" placeholder="Max Reg Term" id="MaxTerm" /></th>
			<th><input type="text" placeholder="Last Contact" id="lastContactDate" /></th>
			<th><input type="text" placeholder="Credits Earned" id="O_EARNED" /></th>
			<th><input type="text" placeholder="Gender" id="gender" /></th>
			<th><input type="text" placeholder="Race" id="REP_RACE" /></th>
			<th><input type="text" placeholder="High School" id="HighSchool" /></th>
			<th><input type="text" placeholder="Parental Status" id="parentalStatus" /></th>
			<th><input type="text" placeholder="Career Plan" id="careerPlan" /></th>
			<th><input type="text" placeholder="Academic Hold" id="RE_HOLD" /></th>
			<th><input type="text" placeholder="GPA" id="O_GPA" /></th>
			<th><input type="text" placeholder="Reading Placement" id="te_read" /></th>
			<th><input type="text" placeholder="Writing Placement" id="te_write" /></th>
			<th><input type="text" placeholder="Math Placement" id="te_math" /></th>
			<th><input type="text" placeholder="Exit Reason" id="exitReason" /></th>
			<th><input type="text" placeholder="Cell Phone" id="cellPhone" /></th>
			<th><input type="text" placeholder="Phone 2" id="phone2" /></th>
			<th><input type="text" placeholder="Email PCC" id="PCC_EMAIL" /></th>
			<th><input type="text" placeholder="Email Personal" id="emailPersonal" /></th>
			<th><input type="text" placeholder="Preferred Name" id="preferredName" /></th>
			<th><input type="text" placeholder="Weekly Work Hours" id="weeklyWorkHours" /></th>
			<th><input type="text" placeholder="In Contract" id="in_contract" /></th>
			<th><input type="text" placeholder="Funding Source" id="FundedBy" /></th>
			<th><input type="text" placeholder="Decree Declared" id="P_DEGREE" /></th>
			<th><input type="text" placeholder="EFC" id="EFC" /></th>
			<th><input type="text" placeholder="Foster Care Y/N" id="FosterCareYN" /></th>
		</tr>
	</tfoot>
	<tbody>

		<!--- handled by ajax query in datatable definition --->
	</tbody>
</table>

<script type="text/javascript">
function loadReport(){
	dt_report = $('#dt_table_report').DataTable( {
		processing:true,
		ajax:{
			url:"fc.cfc?method=getReportList",
			dataSrc:'DATA',
			error: function (xhr, textStatus, thrownError) {
			        handleAjaxError(xhr, textStatus, thrownError);
			}
		},
		language:{ processing: "<img src='images/ajax-loader.gif' height=35 width=35 style='opacity:0.5;'>&nbsp;&nbsp;Loading data..."},
		columnDefs:[{targets:[6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], visible:false}],
		dom: '<"top"iB>rt<"bottom"lp>',
		buttons: [

			//allows for column visibility toggle
			'colvis',

           	//Export Grid Button
           	{
           	  extend: 'csv',
           	  text: 'export',
           	  exportOptions: {
                   columns: ':visible'
               }
           	},
           ],
	}); //end initialize


	// Apply the search
	dt_report.columns().every( function () {
		var that = this;
		$( 'input', this.footer() ).on( 'keyup change', function () {
            if ( that.search() !== this.value ) {
                that.search( this.value ).draw();
            }
       	} );

	});// end search

	$('#dt_table_report').width("100%");
}


</script>


