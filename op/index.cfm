<cfinvoke component="OP" method="getTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="OP" method="getCurrentTerm" returnvariable="currentTerm"></cfinvoke>

<cfsavecontent variable="pcc_menu">
<li>
	<label>Term:
		<select name="term" id="term" style="width:200px" onchange="javascript:doRefresh();">
			<option disabled value="" >
				--Select Term--
			</option>
			<cfoutput query="qryTerms">
			<option  value="#termcode#" <cfif qryTerms.termcode EQ currentTerm>selected</cfif> >#termDesc#</option>
			</cfoutput>
		</select>
	</label>
</li>
<li>
	<label style="margin:25px">Limit to Students Receiving Funds: <input type="checkbox" id="paidterm"  onclick="javascript:filterPaidTerm();"></label>
</li>
</cfsavecontent>

<cfinclude template="includes/header.cfm" />


<style>
table.dataTable tbody tr td {
    padding-left: 20px;
}
input.gridfilter{
	margin-bottom: 0px !important;
	padding: 4px;
}
.dt-buttons{
	float:right !important;
}
.dataTables_wrapper .dataTables_processing{
	top: 30% !important;
	height: 50px !important;
	background-color: lightGray;
}
.dataTables_length select {
	width:auto !important;
}
</style>

<table id="dt_table_report" class="hover" ;>
	<caption class="visually-hide">Oregon Promise Caseload</caption>
	<thead>
		<tr>
			<!--- note this order should match the order in the query in fc.getReportList --->
			<th>Name</th>
			<th>Student ID</th>
			<th>Cohorts</th>
			<th>1st OPG Term</th>
			<th>SAP: CAST</th>
			<th>CR Attempted</th>
			<th>CG100?</th>
			<th>Paid (Term)</th>
			<th>Email</th>
			<th>Phone</th>
			<th>Term</th>
			<th>Aidy Enrl</th>
			<th>Award (Term)</th>
			<th>Paid (AIDY)</th>
			<th>Advisor</th>
			<th>Degree</th>
			<th>Major</th>
			<th>Campus</th>
			<th>CR GPA</th>
			<th>CR Attempted Cat</th>
			<th>Enrl. St.</th>
			<th>CR Enrl.</th>
			<th>SAP: ASTD</th>
			<th>SAP: PREV</th>
			<th>Gender</th>
			<th>Age</th>
			<th>Age Cat.</th>
			<th>Citz.</th>
			<th>Rep. Race</th>
			<th>Asian</th>
			<th>Native</th>
			<th>Black</th>
			<th>Hispanic</th>
			<th>Islander</th>
			<th>White</th>
			<th>HS Code</th>
			<th>HS Name</th>
			<th>HS City</th>
			<th>HS State</th>
			<th>HS Grad. Date</th>
			<th>HS Dplm.</th>
		</tr>
	</thead>
	<tfoot>
	<tr>
		<th><input type="text" placeholder="Name" /></th>
		<th><input type="text" placeholder="Student ID" /></th>
		<th><input type="text" placeholder="Cohorts" /></th>
		<th><input type="text" placeholder="1st OPG Term" /></th>
		<th><input type="text" placeholder="SAP: CAST" /></th>
		<th><input type="text" placeholder="CR Attempted" /></th>
		<th><input type="text" placeholder="CG100?" /></th>
		<th><input type="text" placeholder="Paid (Term)" /></th>
		<th><input type="text" placeholder="Email" /></th>
		<th><input type="text" placeholder="Phone" /></th>
		<th><input type="text" placeholder="Term" /></th>
		<th><input type="text" placeholder="Aidy Enrl." /></th>
		<th><input type="text" placeholder="Award (Term)" /></th>
		<th><input type="text" placeholder="Paid (AIDY)" /></th>
		<th><input type="text" placeholder="Advisor" /></th>
		<th><input type="text" placeholder="Degree" /></th>
		<th><input type="text" placeholder="Major" /></th>
		<th><input type="text" placeholder="Campus" /></th>
		<th><input type="text" placeholder="CR GPA" /></th>
		<th><input type="text" placeholder="CR Attempted Cat" /></th>
		<th><input type="text" placeholder="Enrl. St." /></th>
		<th><input type="text" placeholder="CR Enrl." /></th>
		<th><input type="text" placeholder="SAP: ASTD" /></th>
		<th><input type="text" placeholder="SAP: PREV" /></th>
		<th><input type="text" placeholder="Gender" /></th>
		<th><input type="text" placeholder="Age" /></th>
		<th><input type="text" placeholder="Age Cat." /></th>
		<th><input type="text" placeholder="Citz." /></th>
		<th><input type="text" placeholder="Rep. Race" /></th>
		<th><input type="text" placeholder="Asian" /></th>
		<th><input type="text" placeholder="Native" /></th>
		<th><input type="text" placeholder="Black" /></th>
		<th><input type="text" placeholder="Hispanic" /></th>
		<th><input type="text" placeholder="Islander" /></th>
		<th><input type="text" placeholder="White" /></th>
		<th><input type="text" placeholder="HS Code" /></th>
		<th><input type="text" placeholder="HS Name" /></th>
		<th><input type="text" placeholder="HS City" /></th>
		<th><input type="text" placeholder="HS State" /></th>
		<th><input type="text" placeholder="HS Grad. Date" /></th>
		<th><input type="text" placeholder="HS Dplm." /></th>
	</tr>
	</tfoot>
	<tbody>

		<!--- handled by ajax query in datatable definition --->
	</tbody>
</table>

<script type="text/javascript">

	var dt_report;
	var idx_paid_term=7;
	var idx_pcc_email=8;

	$(document).ready(function() {
		loadReport();
	});

	function loadReport(){
		dt_report = $('#dt_table_report').DataTable( {
			processing:true,
			ajax:{
				url:"op.cfc?method=getList",
				data: getParameters,
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
				}
			},
			language:{ processing: "<img src='images/ajax-loader.gif' height=35 width=35 style='opacity:0.5;'>&nbsp;&nbsp;Loading data..."},
			columnDefs:[{targets:[8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40], visible:false}],
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
            	//Copy Email Button
            	{
            	  extend: 'copy',
            	  text: 'copy email',
                  exportOptions: { columns: [idx_pcc_email] }
            	},
	           ],
		}); //end initialize


		// Apply the search
		dt_report.columns().every( function () {
		var that = this;
			$( 'input', this.footer() ).on( 'keyup change', function () {
				//allowing for a "not equals" search
				//if user has entered "!" as the first character, going to apply regEx
				//to cause that value to be excluded from the search
				var value = this.value;
				var isRegEx = false;
				//user entered "!" as first character, apply regex, by adding characters to the value in the field
				if(value.charAt(0)=="!"){
						value = '^(?'+ value + ')';
						isRegEx = true;
				}
				//apply search
				//https://datatables.net/reference/api/search()
				//search( input , regex, smart )
				//regex: Treat as a regular expression (true) or not (default, false).
				//smart: Perform smart search (default, true) or not (false). See below for a description of smart searching.
					// Note that to perform a smart search, DataTables uses regular expressions, so if enable regular expressions using the second parameter to this method,
					//you will likely want to disable smart searching as the two regular expressions might otherwise conflict and cause unexpected results.
				if ( that.search() !== value ) {
					that
						.search( value, isRegEx, !isRegEx )
						.draw();
				}
			} );

			//stop it from sorting when you click into the header
			$( 'input', this.header() ).on('click', function(e) {
        		e.stopPropagation();
    		});

	});// end search

	$('#dt_table_report').width("100%");
}

function doRefresh(){
	dt_report.ajax.reload();
}
function getParameters(){
	return {'term':$('#term').val()};
}
function filterPaidTerm(){
	filter =  $('#paidterm').prop('checked') == true ? "^[1-9][0-9]*$" : "";
	dt_report.column(idx_paid_term).search(filter, true, false).draw();

}


</script>


<cfinclude template="includes/footer.cfm" />