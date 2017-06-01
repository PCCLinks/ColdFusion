<cfsavecontent variable="pcc_menu">
<nav class="top-bar" >
    <ul class="menu">
	  <li><img src="/PCCLinks/images/fclogo.png"/></li>
      <li><a href="dashboard.cfm">Home</a></li>
      <li class="active"><a href="caseload.cfm">Caseload</a></li>
	</ul>
</nav>
</cfsavecontent>
<cfinclude template="includes/header.cfm" />

<cfinvoke component="fc" method="getCases2" returnvariable="qryData">

<div class = "row">
	<div class = "medium-3 columns"></div>
	<div class="medium-3 columns">
	  <span class = "radios">
	  <legend>Include out-of-contract students</legend>
	  <input type="radio" name="contractFilter" class="contractFilter" value="No" id="contractNo"  checked="checked"><label for="contractNo">No</label>
	  <input type="radio" name="contractFilter" class="contractFilter" value="Yes" id="contractYes"><label for="contractYes">Yes</label>
	</span>
	</div>
</div>

<cfoutput><div id="dt_div">
        <table id="dt_table" cellspacing="1" width="95%" class="hover";>
            <thead>
                <tr>
                    <th>Campus</th>
                    <th>Coach</th>
					<th>Cohort</th>
                    <th>G</th>
                    <th>Last name</th>
                    <th>First Name</th>
                    <th>ASAP</th>
                    <th>Status</th>
                    <th>Contract</th>
					<th></th>
					<th></th>
				</tr>
            </thead>

			<tfoot>
                <tr>
                    <th>Campus</th>
                    <th>Coach</th>
					<th>Cohort</th>
                    <th>G</th>
                    <th>Last name</th>
                    <th>First Name</th>
                    <th>ASAP</th>
                    <th>Status</th>
                    <th>Contract</th>
					<th></th>
					<th></th>
                </tr>
            </tfoot>



            <tbody>
                <cfloop query="qryData">
                    <tr <cfif ASAP_STATUS eq "SU"> style = "background-color:red;"
						<cfelseif ASAP_STATUS eq "AP"> style = "background-color:orange;"
						<cfelseif ASAP_STATUS eq "AW"> style = "background-color:yellow;"
						</cfif>>
                        <td>#qryData.CAMPUS#</td>
                        <td>#qryData.COACH#</td>
						<td>#qryData.COHORT#</td>
                        <td>#qryData.G#</td>
                        <td>#qryData.LAST_NAME#</td>
                        <td>#qryData.FIRST_NAME#</td>
                        <td>#qryData.ASAP_STATUS#</td>
                        <td>#qryData.STATUSABCX#</td>
						<td>#qryData.IN_CONTRACT#</td>
						<td>#qryData.EditLink#</td>
						<td>#qryData.Student_dashboard#</td>
                    </tr>
                </cfloop>
            </tbody>
        </table>
    </div>
</body>
</cfoutput>

<cfsavecontent variable="pcc_scripts">
<script>

	$(document).ready(function() {
		//intialize table
		$('#dt_table').DataTable( {
			lengthMenu: [[100, 50, -1], [100, 50, "All"]],
			order: [[ 1, "desc" ],[0, "desc"],[2, "asc"] ],
			columnDefs: [{targets: 8,visible:false}],
			dom: '<"top">rt<"bottom"iflp><"clear">',
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
		table.column(8).search(filter).draw();
	}

</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm" />
