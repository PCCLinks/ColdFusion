<!--- header --->
<cfinclude template="includes/header.cfm" />

<!--- main content --->
<style>
table.dataTable thead tr th {
    background-color: #4CAF50;
    color: white;
    text-align: left;
    border-bottom: 1px solid #ddd;
}
table.dataTable tbody tr td {
    padding-left: 20px;
}
input{
	margin-bottom: 0px !important;
	padding: 4px;
}
.dt-buttons{
	float:right !important;
}
select {
	width:auto !important;
}
</style>
<!--- filter row
<div class="row">
	<div class="medium-3 columns">
	</div>
	<div class="medium-3 columns">
		<span class="radios">
			<legend>
				Include out-of-contract students
			</legend>
			<input type="radio" name="contractFilter" class="contractFilter" value="No" id="contractNo" checked="checked" />
			<label for="contractNo">
				No
			</label>
			<input type="radio" name="contractFilter" class="contractFilter" value="Yes" id="contractYes" />
			<label for="contractYes">
				Yes
			</label>
		</span>
	</div>
</div> <!--- end filter row --->--->

<!--- output qryData --->
<cfoutput>
<table id="dt_table" class="hover" ;>
	<caption class="visually-hide">Future Connect Caseload</caption>
	<thead>
		<tr>
			<th>Last Contact</th>
			<th>Coach</th>
			<th>Cohort</th>
			<th>G</th>
			<th>Name</th>
			<th>ASAP</th>
			<th>Status</th>
			<th>Contract </th>
			<th>PCCEmail </th>
			<th></th>
		</tr>
	</thead>
	<tbody>
	<!---<cfloop query="qryData">
    	<tr>
      		<td>#DateFormat(qryData.LASTCONTACTDATE,'m/d/y')#</td>
      		<td>#qryData.COACH#</td>
      		<td>#qryData.COHORT#</td>
      		<td>#qryData.STU_ID#</td>
      		<td>#qryData.STU_NAME#</td>
      		<!--- conditional coloring based on value--->
      		<td
      			<cfif ASAP_STATUS eq "SU"> style = "background-color: ##f78989;"
				<cfelseif ASAP_STATUS eq "AP"> style = "background-color: ##eab24c;"
				<cfelseif ASAP_STATUS eq "AW"> style = "background-color: ##f9f96f;"
				</cfif>
			>#qryData.ASAP_STATUS#</td>
      		<td>#qryData.STATUSINTERNAL#</td>
      		<td>#qryData.IN_CONTRACT#</td>
      		<td>#qryData.PCC_EMAIL#</td>
      		<td>#qryData.EditLink#</td>
      	</tr>
    </cfloop>--->
	</tbody>
</table>
</cfoutput>

<!--- script referenced in include footer --->
<cfsavecontent variable="pcc_scripts">
<script>
	var includeAllFilter = "include out-of-contract";
	var excludeOutOfContract = "exclude out-of-contract";
	var includeAllCoaches = "all coaches";
	var myCaseload = "my caseload";

	//column integers
	var idx_lastContactDate = 0;
	var idx_coach = 1;
	var idx_cohort = 2;
	var idx_bannerGNumber = 3;
	var idx_stu_name = 4;
	var idx_ASAP_status = 5;
	var idx_statusinternal = 6;
	var idx_pidm = 7;
	var idx_in_contract = 8
	var idx_pcc_email = 9;
	var idx_maxterm = 10;

	$(document).ready(function() {
		//intialize table
		$.fn.dataTable.ext.errMode = 'throw';
		dt = $('#dt_table').DataTable( {
			processing:true,
			ajax:{
				url:"fc.cfc?method=getCaseloadList",
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			lengthMenu: [[100, 50, -1], [100, 50, "All"]],
			order: [[ idx_coach, "asc" ],[idx_cohort, "desc"] ],
			columnDefs: [
         		 {targets:idx_in_contract, visible:false},
				 {targets:idx_pcc_email, visible:false},
				 {targets:idx_maxterm, visible:false},
				 //editable link column is not sortable
				 {targets:idx_pidm,
				 	sortable:false,
				 	render: function ( data, type, row ) {
                  				return '<a href="javascript:goToDetail('+data+', ' + row[idx_maxterm] +')">Edit</a>';
             				}
				 	}
				],
			dom: '<"top"iB>rt<"bottom"flp>',
			buttons: [
            	//Copy Email Button
            	{
            	  extend: 'copy',
            	  text: 'Copy Email',
                  exportOptions: { columns: [idx_pcc_email] }
            	},
            	//Filter Button
            	{
            	  text: includeAllFilter,
            	  action: function( e, dt, node, config ){
					filterContract(dt, this);
            	  }
            	}
            	<cfoutput><cfif Session.userPosition EQ "Coach">
				,
            	//Coaches Button
            	{
            	  text: includeAllCoaches,
            	  action: function( e, dt, node, config ){
            	  	filterCoach(dt, this);
            	  }
            	}
            	</cfif></cfoutput>
            ],
            <!--- conditional coloring based on value--->
            rowCallback: function(row, data, index){
            	if(data[idx_ASAP_status] == "SU"){
    				$(row).find('td:eq(idx_ASAP_status)').css('background-color', '#f78989');
            	}
            	if(data[idx_ASAP_status] == "AP"){
    				$(row).find('td:eq(idx_ASAP_status)').css('background-color', '#eab24c');
            	}
            	if(data[idx_ASAP_status] == "AW"){
    				$(row).find('td:eq(idx_ASAP_status)').css('background-color', '#f9f96f');
            	}
         	},
		}); //end intialize


		//var dt = $('#dt_table').DataTable();
		//hide main filter
		$(".dataTables_filter").hide();

		// Setup - add a text input to each header cell
		$('#dt_table thead th').each( function () {
			var title = $(this).text();
			if (title.length > 0) {
			$(this).html( '<input type="text" placeholder="'+title+'" id="'+title+'" />' );
			}
		} ); //end add filter

		// Apply the search
		dt.columns().every( function () {
			var that = this;
			$( 'input', this.header() ).on( 'keyup change', function () {
				if ( that.search() !== this.value ) {
					that
						.search( this.value )
						.draw();
				}
			} );
		});// end search

		//filter contract
		dt.column(idx_in_contract).search("Yes").draw();

		//filter coach, if user is coach
		<cfoutput>
		<cfif Session.userPosition EQ "Coach">
		dt.column(idx_coach).search("#Session.userDisplayName#").draw();
        $('##Coach').val("#Session.userDisplayName#");
		</cfif>
		</cfoutput>

	} ); //end document ready

	function filterContract(dt, button) {
		filter =  button.text() == includeAllFilter ? "" : "Yes";
		dt.column(idx_in_contract).search(filter).draw();
		buttonText = button.text() == includeAllFilter ? excludeOutOfContract : includeAllFilter;
        button.text(buttonText);
	}
	function filterCoach(dt, button){
		<cfoutput>
		var userDisplayName = "#Session.userDisplayName#";
		</cfoutput>
		filter =  button.text() == myCaseload ? userDisplayName : "";
		dt.column(idx_coach).search(filter).draw();
        button.text(button.text() == myCaseload ? includeAllCoaches : myCaseload);
        $('#Coach').val(filter);
    }

	function goToDetail(pidm, maxterm){
		var dt = $('#dt_table').DataTable();
		var gList = dt.columns({search:'applied'}).data()[0];
		var url = 'student.cfm';
		var form = $('<form action="' + url + '" method="post">' +
 				'<input type="text" name="pidm" value="' + pidm + '" />' +
 				'<input type="text" name="maxterm" value="' + maxterm + '" />' +
 				'</form>');
		$('body').append(form);
		form.submit();
	}

</script>
</cfsavecontent>

<!--- footer --->
<cfinclude template="includes/footer.cfm" />
