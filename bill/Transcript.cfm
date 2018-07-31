<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getCurrentYearTerms" returnvariable="qryTerms"></cfinvoke>
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
	table.dataTable thead th.tooltipformat {
		color:gray;
		font-size:x-small;
		border-bottom-style:none;
		padding-bottom:0px;
	}

</style>

<div class="callout primary">
	<label><b>Credit Students Billed in Term:&nbsp;</b>
		<select name="term" id="termSelect" >
			<option disabled value="" >
				--Select Term--
			</option>
			<cfoutput query="qryTerms">
			<option  value="#term#" <cfif qryTerms.term EQ lastTermClosed>selected</cfif> >#termDescription#</option>
			</cfoutput>
		</select>
	</label>
</div>
<div class="row">
	<div class="small-8 columns">
		<table id="dt_table">
			<thead>
				<tr><th colspan="2" class="tooltipformat">
						<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Sort multiple columns by holding down the <shift> key while clicking sort icon ^." >Sort multiple columns...</span>
					</th>
					<th class="tooltipformat">
						<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Click the GNumber to show the transcript on the righthand side" >Click...</span>
					</th>
					<th colspan="3" class="tooltipformat">
						<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Filter school, program or other entries by entering the information into the header boxes below." >Filter school, program...</span>
					</th>
					<th class="tooltipformat">
						<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Enter N to see all entries not yet checked. Y to see checked entries." >Filter...</span>
					</th>
				</tr>
				<tr>
					<th id="firstname">First name</th>
					<th id="lastname">Last name</th>
					<th id="bannerGNumber">G</th>
					<th id="SchoolDistrict">School District</th>
					<th id="Program">Program</th>
					<th id="coach">Coach</th>
					<th id="creditsEntered">Credits<br/>Entered</th>
				</tr>
				<tr id="searchRow">
					<th><input type="text" placeholder="First Name"></th>
					<th><input type="text" placeholder="Last Name"></th>
					<th><input type="text" placeholder="G"></th>
					<th><input type="text" placeholder="School District"></th>
					<th><input type="text" placeholder="Program"></th>
					<th><input type="text" placeholder="Coach"></th>
					<th><input type="text" placeholder="Y/N" id="CreditsEntered"></th>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
	<div class="small-1 columns"></div><br>
	<div class="small-4 columns">
		<div class="callout primary" id="selectedGNumber">Display Student Transcript by clicking a "G" Number from the list.</div>
		<div id="target"></div>
	</div>
</div>


<cfsavecontent variable="pcc_scripts">
<script>
	var currentRow;
	var table;
	var selectedTerm = '<cfoutput>#Variables.lastTermClosed#</cfoutput>';
	var idx_gnumber = 2;
	var idx_billingStudentId = 6;
	var idx_creditsEntered = 7;
	var idx_pidm = 8;

	$(document).ready(function() {
		table = $('#dt_table').DataTable({
				processing:true,
				ajax:{
					url: "programbilling.cfc?method=getTranscriptStudentList",
					data: function(d){
						d.term = selectedTerm;
						},
					dataSrc:'DATA',
					error: function (xhr, textStatus, thrownError) {
					        handleAjaxError(xhr, textStatus, thrownError);
						}
				},
				dom: '<"top"i>rt<"bottom"flp>',
				saveState: true,
				language:{ processing: "Loading data..."},
				columnDefs:[
	                {	targets: idx_gnumber,
	                	render: function ( data, type, row ) {
                  				return '<a href="javascript:getStudent(\'' + row[idx_pidm] + '\');" >' + row[idx_gnumber] + '</a>';
             					}
         				},
         			{	targets: idx_billingStudentId,
	                	render: function ( data, type, row ) {
                  				 var entry = '<input type="checkbox" id=' + data;
                  				 if(row[idx_creditsEntered] == 1)
                  				 	entry = entry + ' checked ';
                  				 entry = entry + ' onchange="javascript:creditEnteredChanged(' + data + ',this)">';
                  				 return entry;
             					}
         			},
         			{ targets:idx_creditsEntered, visible:false},
         			{ targets:idx_pidm, visible:false}

         		]
			});
			// Apply the search
			table.columns().every( function () {
				var that = this;
				$( 'input', this.header() ).on( 'keyup change', function () {
					if(this.id == "CreditsEntered"){
						var filter = "";
						var v = this.value.toUpperCase();
						v = v.substr(0,1);
						if(v == "Y"){
							var filter = 1;
						}else{
							if(v == "N"){
								var filter = 0;
							}
						}
						table.column(idx_creditsEntered).search(filter).draw();
					}else{
						if (that.search() !== this.value ) {
							that.search( this.value ).draw();
						}
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

		$('#termSelect').change(function(){
				selectedTerm = this.value;
				table.ajax.reload();
		});


	});

   	function creditEnteredChanged(billingStudentId, checkBox){
			//cb = $(this).find('input:checkbox');
			flagged = (checkBox.checked ? 1 : 0);

			//set the underlying data in the flagged column for filtering
			row = checkBox.parentElement.parentElement;
			var rowData = table.row(row).data();
			rowData[idx_creditsEntered] = flagged;
			table.row(row).data(rowData).draw();

			$.ajax({
				url: "programbilling.cfc?method=updateStudentBillingCreditEntered",
				type: "POST",
				async: false,
				data: { billingstudentid: billingStudentId, value:flagged },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
		} //end save checkbox changes
	function getParameters(){
	 	return {term: selectedTerm};
	}
	function getStudent(pidm){
		var heading = '<b>' + table.cell(currentRow, 0).data() + ' ' + table.cell(currentRow, 1).data() + '</b>'
							+ ' (' + table.cell(currentRow,2).data().replace('getStudent','goToDetail') + ') '
							+ '<br><b>Program:</b> ' + table.cell(currentRow,4).data();

		$.ajax({
        	url: "includes/transcriptTabsInclude.cfm?pidm=" + pidm + "&programYear=<cfoutput>#programYear#</cfoutput>&selectedTerm=" + selectedTerm,
       		cache: false
    	}).done(function(data) {
        	$("#selectedGNumber").html(heading);
        	$("#target").html(data);
    	});
	}



</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">