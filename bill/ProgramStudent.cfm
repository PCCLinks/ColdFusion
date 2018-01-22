<cfinclude template="includes/header.cfm" />

<cfinvoke component="LookUp" method="getMaxTerm" returnvariable="maxTerm"></cfinvoke>
<cfset Variables.MaxTerm = #maxTerm#>
<cfset Session.Term = Variables.MaxTerm>

<!--- Program --->
<cfset Variables.Program = "">
<cfif structKeyExists(Session, "Program")>
	<cfset  Variables.Program = Session.Program>
</cfif>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getCurrentYearTerms" returnvariable="terms"></cfinvoke>
<cfinvoke component="LookUp" method="getCurrentProgramYear" returnvariable="programYear"></cfinvoke>

<style>
.dataTables_wrapper .dataTables_processing{
	top: 30% !important;
	height: 50px !important;
	background-color: lightGray;
}
.dt-buttons{
	float:right !important;
}
</style>

<!-- Filter -->
<div class="row"><!--->
	<div class="small-3 columns">
		<label for="Term">Latest Term:
			<select name="term" id="term">
				<option value="" > --Select Last Term Billed-- </option>
			<cfoutput query="terms">
				<option value="#term#" <cfif Variables.MaxTerm EQ #term#> selected </cfif> > #termDescription# </option>
			</cfoutput>
			</select>
		</label>
	</div>--->
	<div class="small-4 columns">
		<label for="Program">Program:
			<select name="program" id="program">
				<option disabled <cfif Variables.Program EQ ""> selected </cfif> value="" > --Select Program-- </option>
				<cfoutput query="programs">
					<option value="#programName#" <cfif Variables.Program EQ #programName#> selected </cfif> > #programName# </option>
				</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-8 columns">
	</div>
</div> <!-- end Filter row -->

<div class="row">
	<div class="small-12 columns">
		<table id="dt_table" class="hover" cellspacing="0" width="100%">
			<caption class="visually-hide">"Program data"</caption>
			<thead>
				<tr id="headerRow">
					<th id="coach">Coach</th>
					<th id="bannerGNumber">G</th>
					<th id="firstname">First name</th>
					<th id="LASTNAME">Last name</th>
					<th id="SchoolDistrict">School District</th>
					<th id="EnrolledDate">Enrolled Date</th>
					<th id="ExitDate">Exit Date</th>
					<th id="Program">Program</th>
					<th id="Program">Latest Term</th>
					<th id="CurrentTermNoOfCredits">Current Term Credits</th>
					<th id="PrevTermNoOfCredits">Prev Term Credits</th>
					<th id="BillingStatus">Last Billing Status</th>
					<th id="BillingStudentId"></th>
				</tr>
				<tr id="searchRow">
					<th><input type="text" placeholder="Coach"></th>
					<th><input type="text" placeholder="G" /></th>
					<th><input type="text" placeholder="First name" /></th>
					<th><input type="text" placeholder="Last name" /></th>
					<th><input type="text" placeholder="School District" /></th>
					<th><input type="text" placeholder="Enrolled Date" /></th>
					<th><input type="text" placeholder="Exit Date" /></th>
					<th><input type="text" placeholder="Program" /></th>
					<th><input type="text" id="termPlaceholder" placeholder="Term" value="<cfoutput>#Variables.MaxTerm#</cfoutput>" /></th>
					<!---><th><input type="text" placeholder="Term" value=<cfoutput>#Variables.MaxTerm#</cfoutput> /></th>--->
					<th><input type="text" placeholder="Current Term Credits" /></th>
					<th><input type="text" placeholder="Prev Term Credits" /></th>
					<th><input type="text" id="billingStatusPlaceholder" placeholder="Billing Status" /></th>

					<th></th>
				</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
</div>

<cfsavecontent variable="pcc_scripts">
	<script>
		var indexOfGNumber = 1;
		var indexOfBillingStudentId = 12;
		var table;
		var txtShowActive = 'Show Active Only';
		var txtShowAll = 'Include Non-Active Students';
		var txtShowInProgress = 'Needs Review Only';
		var txtShowAllStatus = 'Include Already Reviewed';

		$.fn.dataTable.ext.errMode = 'throw';
		$(document).ready(function() {
			setUpTable();
			$('#program').change(function(){
				table.column(7).search($('#program').val()).draw();
			});
			table.column(8).search("<cfoutput>#Variables.MaxTerm#</cfoutput>").draw();
			//$('#term').change(function(){
			//	table.column(8).search($('#term').val()).draw();
			//});
		});
		function setUpTable(program){
			table = $('#dt_table').DataTable({
				processing:true,
				ajax:{
					url: "programbilling.cfc?method=getProgramStudentList",
					data: getParameters,
					dataSrc:'DATA',
					error: function (xhr, textStatus, thrownError) {
					        handleAjaxError(xhr, textStatus, thrownError);
						}
				},
				dom: '<"top"iB>rt<"bottom"flp>',
				language:{ processing: "Loading data..."},
				columnDefs:[
	                {	targets: indexOfGNumber,
	                	render: function ( data, type, row ) {
                  				return '<a href="javascript:goToDetail(' + row[indexOfBillingStudentId] + ');" >' + row[indexOfGNumber] + '</a>';
             					}
         				},
         				{targets: indexOfBillingStudentId, visible: false}
         			],
         		buttons: [
            	//Active Students Button
            	{
            	  text: txtShowAll,
            	  action: function( e, table, node, config ){
					filterShowActive(table, this);
            	  }
            	},
            	//Reviewed Students Button
            	{
            	  text: txtShowInProgress,
            	  action: function( e, table, node, config ){
					filterShowReview(table, this);
            	  }
            	}
            	]
			});
			//hide main filter
			$(".dataTables_filter").hide();
			table = $('#dt_table').DataTable();
			// Apply the search
			table.columns().every( function () {
				var that = this;
				$( 'input', this.header() ).on( 'keyup change', function () {
					if (that.search() !== this.value ) {
							that.search( this.value ).draw();
					}
				});
			});
			//table.column(8).search(<cfoutput>#Variables.MaxTerm#</cfoutput>).draw();
		}
		function getParameters(){
		 	return {programYear: '<cfoutput>#Variables.programYear#</cfoutput>', program: $('#program').val()};
		}
		function goToDetail(billingStudentId){
			var dt = $('#dt_table').DataTable();
			var billingStudentList = dt.columns({search:'applied'}).data()[indexOfBillingStudentId];
			sessionStorage.setItem("billingStudentList", billingStudentList);
			var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  			$.post("SaveSession.cfm", data, function(){
  				window.location	='programStudentDetail.cfm?billingStudentId='+billingStudentId+'&showNext=true';
  			});
		}
		function filterShowActive(table, button) {
			filter =  button.text() == txtShowActive ? "<cfoutput>#Variables.MaxTerm#</cfoutput>" : "";
			table.column(8).search(filter).draw();
			$('#termPlaceholder').val(filter);
			buttonText = button.text() == txtShowActive ? txtShowAll : txtShowActive;
	        button.text(buttonText);
		}
		function filterShowReview(table, button) {
			filter =  button.text() == txtShowInProgress ? "IN PROGRESS" : "";
			table.column(11).search(filter).draw();
			$('#billingStatusPlaceholder').val(filter);
			buttonText = (button.text() == txtShowAllStatus ? txtShowInProgress : txtShowAllStatus);
	        button.text(buttonText);
		}

	</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
