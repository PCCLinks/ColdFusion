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
		<label for="program">Program:
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
		<table id="dt_table" class="hover" cellspacing="0" style="width:100%">
			<thead>
				<tr id="headerRow">
					<th id="coachHeader">Coach</th>
					<th id="bannergnumberHeader">G</th>
					<th id="firstnameHeader">First name</th>
					<th id="lastnameHeader">Last name</th>
					<th id="schooldistrictHeader">School District</th>
					<th id="programHeader">Program</th>
					<th >Review with Coach</th>
					<td id="reviewnotesHeader">Notes</th>
					<th  ></th>
				</tr>
				<tr id="searchRow">
					<th><input type="text" placeholder="Coach" id="coach"></th>
					<th><input type="text" placeholder="G" id="bannergnumber"/></th>
					<th><input type="text" placeholder="First name" id="firstname"/></th>
					<th><input type="text" placeholder="Last name" id="lastname" /></th>
					<th><input type="text" placeholder="School District" id="schooldistrict" /></th>
					<th><input type="text" placeholder="Program" id="program"/></th>
					<th class="notForPrint"><input type="text" placeholder="Review Y/N" /></th>
					<th><input type="text" placeholder="Notes" id="reviewnotes"/></th>
					<th class="notForPrint"></th>
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
		var indexOfProgram = 5;
		var indexOfReviewWithCoach = 6;
		var indexOfBillingStudentId = 8;
		var table;
		var txtShowCoachReview = 'Show Only To Be Reviewed';
		var txtShowAll = 'Show All Students';

		$.fn.dataTable.ext.errMode = 'throw';
		$(document).ready(function() {
			setUpTable();
			$('#program').change(function(){
				table.column(indexOfProgram).search($('#program').val()).draw();
			});
			table.column(indexOfReviewWithCoach).search("Y").draw();
		});
		function setUpTable(program){
			table = $('#dt_table').DataTable({
				processing:true,
				ajax:{
					url: "programbilling.cfc?method=getProgramReviewList",
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
            	//Review Only Students Button
            	{
            	  text: txtShowAll,
            	  action: function( e, table, node, config ){
					filterShowAll(table, this);
            	  }
            	},
				{extend: 'excel',
            		text: 'export',
            		exportOptions:{
            			columns: ':not(.notForPrint)',
  						format: {
	                         header:  function (data, columnIdx) {
	                         	if(data){
	                         		var id = $(data).attr("id");
	                         		return $('#'+ id +"Header").html();
	                         	}else{
	                         		return data;
	                         	}
                        	}
  						},
            		},
  					title: 'Billing Review',
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
		}
		function getParameters(){
		 	return {term: '<cfoutput>#Variables.maxTerm#</cfoutput>', program: $('#program').val()};
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
		function filterShowAll(table, button) {
			filter =  button.text() == txtShowCoachReview ? "Y" : "";
			table.column(indexOfReviewWithCoach).search(filter).draw();
			$('#termPlaceholder').val(filter);
			buttonText = button.text() == txtShowCoachReview ? txtShowAll : txtShowCoachReview;
	        button.text(buttonText);
		}

	</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
