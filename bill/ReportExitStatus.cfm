<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>
<cfinvoke component="LookUp" method="getProgramYear" returnvariable="programyear"></cfinvoke>
<cfinvoke component="LookUp" method="getCurrentProgramYear" returnvariable="currentyear"></cfinvoke>
<!-- Filter -->
<div class="row">
	<div class="small-2 columns">
		<label for="District">District:
			<select name="district" id="district">
				<option disabled selected value="" > --Select District-- </option>
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
	<div class="small-4 columns">
	</div>
</div> <!-- end Filter row -->
<table id="dt_table">
	<thead>
		<tr>
			<th>Last Name</th>
			<th>First Name</th>
			<th>DOB</th>
			<th>Grade</th>
			<th>Entry Date</th>
			<th>Exit Date</th>
			<th>Program</th>
			<th>District</th>
			<th>Exit Status</th>
		</tr>
	</thead>
</table>



<cfsavecontent variable="pcc_scripts">
	<script>

		$(document).ready(function() {
		    $('#dt_table').DataTable({
		    	processing:true,
				ajax:{
					url: 'report.cfc?method=exitStatusReport',
					data: getParameters,
					dataSrc:'DATA',
					error: function (xhr, textStatus, thrownError) {
					        handleAjaxError(xhr, textStatus, thrownError);
					}
				},
				dom: '<"top"iB>rt<"bottom"flp>',
				language:{ processing: "Loading data..."},
				buttons:[
					{extend: 'csv',
            	  		text: 'export'
            	  	}
            	  ]
		    });

			//hide main filter
			$(".dataTables_filter").hide();

			table = $('#dt_table').DataTable();
			$('#program').change(function(){
				table.ajax.reload();
			});
			$('#district').change(function(){
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