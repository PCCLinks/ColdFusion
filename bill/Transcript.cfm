<cfinclude template="includes/header.cfm">


<cfinvoke component="LookUp" method="getCurrentProgramYear"  returnvariable="programYear"></cfinvoke>
<cfinvoke component="Lookup" method="getLastTermClosed" returnvariable="lastTermClosed" />
<style>

	.dataTables_info{
		margin-right:10px !important;
	}
	.dataTables_wrapper .dataTables_filter{
		float:left;
		text-align:left;
	}
	.dataTables_filter input{
		width:75%;
		display: inline-block;
	}
	select {
		width:auto;
	}
	input{
		display:inline-block;
		width:auto;
	}

</style>

<div class="row">
	<div class="small-6 columns">
		<table id="dt_table">
			<thead>
				<tr>
					<th id="firstname">First name</th>
					<th id="lastname">Last name</th>
					<th id="bannerGNumber">G</th>
					<th id="SchoolDistrict">School District</th>
					<th id="Program">Program</th>
					<th id="coach">Coach</th>
				</tr>
				<tr id="searchRow">
					<th><input type="text" placeholder="First Name"></th>
					<th><input type="text" placeholder="Last Name"></th>
					<th><input type="text" placeholder="G"></th>
					<th><input type="text" placeholder="School District"></th>
					<th><input type="text" placeholder="Program"></th>
					<th><input type="text" placeholder="Coach"></th>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
	<div class="small-1 columns"></div>
	<br><br>
	<div class="small-5 columns">
		<div class="callout primary" id="selectedGNumber">Select a Student from the left</div>
		<div id="target"></div>
	</div>
</div>


<cfsavecontent variable="pcc_scripts">
<script>
	var currentRow;
	var currentBillingStudentId;
	var table;
	$(document).ready(function() {
		table = $('#dt_table').DataTable({
				processing:true,
				ajax:{
					url: "programbilling.cfc?method=getTranscriptStudentList",
					data: <cfoutput>{term: #Variables.lastTermClosed.maxTerm#}</cfoutput>,
					dataSrc:'DATA',
					error: function (xhr, textStatus, thrownError) {
					        handleAjaxError(xhr, textStatus, thrownError);
						}
				},
				dom: '<"top"i>rt<"bottom"flp>',
				saveState: true,
				language:{ processing: "Loading data..."},
				columnDefs:[
	                {	targets: 2,
	                	render: function ( data, type, row ) {
                  				return '<a href="javascript:getStudent(\'' + row[2] + '\');" >' + row[2] + '</a>';
             					}
         				}
         		]
			});
			// Apply the search
			table.columns().every( function () {
				var that = this;
				$( 'input', this.header() ).on( 'keyup change', function () {
					if (that.search() !== this.value ) {
							that.search( this.value ).draw();
					}
				});
			});
		//$('#dt_table').DataTable({
			//order:[[4, 'desc'],[1],[0]],
		//});
		//table = $('#dt_table').DataTable();
		$('#dt_table tbody').on( 'click', 'tr', function () {
    		currentRow =this;
		} );
	});

	function getStudent(bannerGNumber){
		currentBannerGNumber = bannerGNumber;
		var heading = '<b>' + table.cell(currentRow, 0).data() + ' ' + table.cell(currentRow, 1).data() + '</b>'
							+ ' (' + table.cell(currentRow,2).data().replace('getStudent','goToDetail') + ') '
							+ '<br><b>Program:</b> ' + table.cell(currentRow,4).data();

		$.ajax({
        	url: "includes/transcriptTabsInclude.cfm?bannerGNumber=" + bannerGNumber + "&programYear=<cfoutput>#programYear#&lasttermbilled=#Variables.lastTermClosed.maxTerm#</cfoutput>",
       		cache: false
    	}).done(function(data) {
        	$("#selectedGNumber").html(heading);
        	$("#target").html(data);
    	});
	}
	function goToDetail(billingStudentId){
		window.open('programStudentDetail.cfm?billingStudentId='+billingStudentId+'&showNext=false');
	}


</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">