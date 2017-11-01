<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>
<cfinvoke component="LookUp" method="getAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>
<cfinvoke component="LookUp" method="getLatestDateAttendanceMonth" returnvariable="latestMonth"></cfinvoke>
<!-- Filter -->
<div class="row">
	<div class="small-2 columns">
		<label for="billingStartDate">Month Start Date:
			<select name="billingStartDate" id="billingStartDate">
				<option disabled selected value="" > --Select Month Start Date-- </option>
			<cfoutput query="billingDates">
				<option value="#billingStartDate#" <cfif billingStartDate EQ latestMonth> selected </cfif>  > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
			</cfoutput>
			</select>
		</label>
	</div>
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
	<div class="small-7 columns">
	</div>
</div> <!-- end Filter row -->
<table id="dt_table">
	<thead>
		<tr>
			<th>Last Name</th>
			<th>First Name</th>
			<th>Entry Date</th>
			<th>Exit Date</th>
			<th>Large Grp.</th>
			<th>Inter. Grp.</th>
			<th>Small Grp.</th>
			<th>Tutorial</th>
		</tr>
		<!---<tr id="searchRow">
			<th><input type="text" placeholder="Last Name"></th>
			<th><input type="text" placeholder="First Name" /></th>
			<th><input type="text" placeholder="DOB" /></th>
			<th><input type="text" placeholder="Grade" /></th>
			<th><input type="text" placeholder="Entry Date" /></th>
			<th><input type="text" placeholder="Exit Date" /></th>
			<th><input type="text" placeholder="Exit Status" /></th>
			<th><input type="text" placeholder="Program" /></th>
			<th><input type="text" placeholder="District" /></th>
		</tr>--->
	</thead>
	<tbody>
		<!---<cfoutput query="data">
		<tr>
			<td>#lastname#</td>
			<td>#firstname#</td>
			<td>#dob#</td>
			<td>#grade#</td>
			<td>#entrydate#</td>
			<td>#exitdate#</td>
			<td>#exitreason#</td>
			<td>#program#</td>
			<td>#schooldistrict#</td>
		</tr>
		</cfoutput>--->
	</tbody>
</table>



<cfsavecontent variable="pcc_scripts">
	<script>
		$(document).ready(function() {
		    $('#dt_table').DataTable({
		    	processing:true,
				ajax:{
					url: 'report.cfc?method=admReport',
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
			param = '&billingStartDate=' + $('#billingStartDate').val();
			if($('#district').val() != null)
				param = param + '&districtid=' + $('#district').val();
			if($('#program').val() != null)
				param = param + '&program=' + $('#program').val();
		 	return param;
		}


		} );


	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">