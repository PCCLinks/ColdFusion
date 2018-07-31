<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>
<cfinvoke component="LookUp" method="getProgramYear" returnvariable="programyear"></cfinvoke>
<cfinvoke component="LookUp" method="getCurrentProgramYear" returnvariable="currentyear"></cfinvoke>

<style>
	.dataTables_wrapper .dataTables_processing{
		top: 70% !important;
		height: 50px !important;
		background-color: lightGray;
	}
	.dataTables_info{
		margin-right:10px !important;
	}
	select {
		width:auto !important;
	}
	input{
		display:inline-block !important;
		width:auto !important;
	}
	table.dataTable tbody td, table.dataTable tfoot td {
		text-align:right;
		padding-right:10px;
	}
</style>

<div class="callout primary">Enrollment Report</div>
<!-- Filter -->
<div class="row">
	<div class="small-3 columns">
		<label for="District">District:
			<select name="district" id="district">
				<option disabled selected > --Select District-- </option>
			<cfoutput query="schools">
				<option value="#keySchoolDistrictID#" > #schooldistrict# </option>
			</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-3 columns">
		<label for="Program">Program:
			<select name="program" id="program">
				<option disabled  selected > --Select Program-- </option>
				<cfoutput query="programs">
					<option value="#programName#" > #programName# </option>
				</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-3 columns">
		<label for="ProgramYear">Year:
			<select name="programyear" id="programyear">
				<cfoutput query="programyear">
					<option value="#ProgramYear#" <cfif programyear EQ currentyear>selected</cfif> > #ProgramYear# </option>
				</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-3 columns">
	</div>
</div> <!-- end Filter row -->
<table id="dt_table">
	<thead>
		<tr>
			<th class="notForPrint"></th>
			<th class="notForPrint">District</th>
			<th>Program</th>
			<th>Last Name</th>
			<th>First Name</th>
			<th>Grade</th>
			<th>Entry Date</th>
			<th>Exit Date</th>
			<th>Exit Status</th>
			<th>Resource Spec</th>
			<th>LEP</th>
			<th>Gender</th>
			<th>DOB</th>
			<th>Address</th>
			<th>City</th>
			<th>State</th>
			<th>Zip</th>
			<th>Banner G-Number</th>
			<th></th>
		</tr>
	</thead>
</table>



<cfsavecontent variable="pcc_scripts">
	<script>
		var idx_contactid = 0;
		var idx_program = 2;
		var idx_districtid = 18;

		$(document).ready(function() {
		    $('#dt_table').DataTable({
		    	processing:true,
				ajax:{
					url: 'report.cfc?method=enrollmentReport',
					data: getParameters,
					dataSrc:'DATA',
					error: function (xhr, textStatus, thrownError) {
					        handleAjaxError(xhr, textStatus, thrownError);
					}
				},
				dom: '<"top"iBf>rt<"bottom"lp>',
				language:{ processing: 'Please wait...updating...will take a few minutes...'},
				buttons:[
					{extend: 'excel',
            	  		text: 'export',
            	  		title: getTitle,
		            	exportOptions:{
		            		columns: ':not(.notForPrint)',
		            	},
            	  	}
            	  ],
            	columnDefs:[
            		{targets:idx_contactid,
				 		render: function ( data, type, row ) {
                  				return '<a href="billingStudentProfile.cfm?contactId=' + data + '" >Click to Edit</a>';
             				}
				 	},
				 	{targets: idx_districtid, visible: false}
				 ]
		    });

			function getTitle(){
				var d = new Date();
				return $("#district option:selected").text() + '-' + d.getMonth() + d.getDay() + d.getFullYear();

			}

			//hide main filter
			//$(".dataTables_filter").hide();

			table = $('#dt_table').DataTable();
			$('#program').change(function(){
				var smart = false;
				if($('#program').val() === 'YtC'){
					smart = true;
				}
				table.column(idx_program).search($('#program').val(), smart).draw();
			});
			$('#district').change(function(){
				table.column(idx_districtid).search($('#district').val(), true).draw();
			});
			$('#programyear').change(function(){
				table.ajax.reload();
			});


		function getParameters(){
			param = '';
			if($('#district').val() != null)
				param = param + '&districtid=' + $('#district').val();
			if($('#program').val() != null)
				param = param + '&program=' + $('#program').val();
			param = param + '&programyear=' + $('#programyear').val();
		 	return param;
		}


		} );


	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">