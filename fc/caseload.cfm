<cfinvoke component="fc" method="getCaseload" returnvariable="qryData" />





<!--- header --->
<cfinclude template="includes/header.cfm" />

<!--- main content --->
<style>
table thead tr th {
    background-color: #4CAF50;
    color: white;
	padding: 8px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}
</style>
<!--- filter row --->
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
</div> <!--- end filter row --->

<!--- output qryData --->
<cfoutput>
	<div>
		<table id="dt_table" cellspacing="1" width="95%" class="hover" ;>
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
				<cfloop query="qryData">
                    <tr>
	                    <td>#DateFormat(qryData.LASTCONTACTDATE,'m/d/y')#</td>
                        <td>#qryData.COACH#</td>
						<td>#qryData.COHORT#</td>
                        <td>#qryData.STU_ID#</td>
                        <td>#qryData.STU_NAME#</td>
						<!--- conditional coloring based on value
                    	--->
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
                </cfloop>
			</tbody>
		</table>
	</div>
</cfoutput>

<!--- script referenced in include footer --->
<cfsavecontent variable="pcc_scripts">
<script>
	$(document).ready(function() {
		//intialize table
		$('#dt_table').DataTable( {
			lengthMenu: [[100, 50, -1], [100, 50, "All"]],
			order: [[ 1, "asc" ],[2, "desc"] ],
			columnDefs: [{targets: 7,visible:false},{targets: 8,visible:false}],
			dom: '<"top"B>rt<"bottom"iflp><"clear">',
			buttons: [
            {
                extend: 'copy',
                text: 'Copy PCCemail',
                exportOptions: {
                    columns: [8]
            	}
            }]


		}); //end intialize

		//hide main filter
		$(".dataTables_filter").hide();

		filterContract();

		// Setup - add a text input to each header cell
		$('#dt_table thead th').each( function () {
			var title = $(this).text();
			if (title.length > 0) {
			$(this).html( '<input type="text" placeholder="'+title+'" />' );
			}
		} ); //end add filter

		// Apply the search
		var table = $('#dt_table').DataTable();
		table.columns().every( function () {
			var that = this;
			$( 'input', this.header() ).on( 'keyup change', function () {
				if ( that.search() !== this.value ) {
					that
						.search( this.value )
						.draw();
				}
			} );
		});// end search


		$('.contractFilter').change(function(){
			filterContract();
		});

	} ); //end document ready

	function filterContract() {
		var table = $('#dt_table').DataTable();
		filter =  $('#contractNo').is(':checked') ? "Yes" : "";
		table.column(7).search(filter).draw();
	}

	function goToDetail(bannerGNumber){
		var dt = $('#dt_table').DataTable();
		var gList = dt.columns({search:'applied'}).data()[0];
		var url = 'student.cfm';
		var form = $('<form action="' + url + '" method="post">' +
 				'<input type="text" name="bannerGNumber" value="' + bannerGNumber + '" />' +
 				'</form>');
		$('body').append(form);
		form.submit();
	}

</script>
</cfsavecontent>

<!--- footer --->
<cfinclude template="includes/footer.cfm" />
