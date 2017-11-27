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

<style>
.dataTables_wrapper .dataTables_processing{
	top: 30% !important;
	height: 50px !important;
	background-color: lightGray;
}
</style>

<!-- Filter -->
<div class="row">
	<div class="small-2 columns">
		<label for="Term">Term:
			<select name="term" id="term">
				<option value="" > --Select All Terms-- </option>
			<cfoutput query="terms">
				<option value="#term#" <cfif Variables.MaxTerm EQ #term#> selected </cfif> > #termDescription# </option>
			</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-3 columns">
		<label for="Program">Program:
			<select name="program" id="program">
				<option disabled <cfif Variables.Program EQ ""> selected </cfif> value="" > --Select Program-- </option>
				<cfoutput query="programs">
					<option value="#programName#" <cfif Variables.Program EQ #programName#> selected </cfif> > #programName# </option>
				</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-7 columns">
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
					<th id="Program">Term</th>
					<th id="FYTotalNoOfCredits">FY Total Credits</th>
					<th id="CurrentTermNoOfCredits">Current Term Credits</th>
					<th id="BillingStatus">Billing Status</th>
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
					<th><input type="text" placeholder="Term" /></th>
					<th><input type="text" placeholder="FY Total Credits" /></th>
					<th><input type="text" placeholder="Current Term Credits" /></th>
					<th><input type="text" placeholder="Billing Status" /></th>
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
		$.fn.dataTable.ext.errMode = 'throw';
		$(document).ready(function() {
			setUpTable();
			$('#program').change(function(){
				table.ajax.reload();
			});
			$('#term').change(function(){
				table.ajax.reload();
			});
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
				dom: '<"top"i>rt<"bottom"flp>',
				language:{ processing: "Loading data..."},
				columnDefs:[
	                {	targets: indexOfGNumber,
	                	render: function ( data, type, row ) {
                  				return '<a href="javascript:goToDetail(' + row[indexOfBillingStudentId] + ');" >' + row[indexOfGNumber] + '</a>';
             					}
         				},
         				{targets: indexOfBillingStudentId, visible: false}
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
		}
		function getParameters(){
		 	return { term: $('#term').val(), program: $('#program').val()};
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

	</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
