<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getLatestAttendanceDates" returnVariable="dates"></cfinvoke>


<cfinvoke component="ProgramBilling" method="getExitDateList2" returnvariable="data">
	<cfinvokeargument name="billingStartDate" value="#dates.billingStartDate#">
	<cfinvokeargument name="billingEndDate" value="#dates.billingEndDate#">
</cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>

<div class="callout primary">Set Exit Dates & Reason</div>
<!-- Filter -->
<div class="row">
	<cfoutput>
	<div class="small-4 columns">
		<label>Billing Start Date:<br/>
			<input name="billingStartDate" id="billingStartDate" type="text" class="fdatepicker" value="#DateFormat(dates.termBeginDate,'mm/dd/yyyy')#" />
		</label>
	</div>
	<div class="small-4 columns">
		<label>Billing End Date:<br/>
			<input name="billingEndDate" id="billingEndDate" type="text" class="fdatepicker" value="#DateFormat(DateAdd("d",-2, dates.termEndDate),'mm/dd/yyyy')#" />
		</label>
	</div>
	<div class="small-2 columns">
		<label for="District">District:
			<select name="district" id="district">
				<option disabled selected value="" > --Select District-- </option>
			<cfloop query="schools">
				<option value="#keySchoolDistrictID#" > #schooldistrict# </option>
			</cfloop>
			</select>
		</label>
	</div>
	</cfoutput>
</div>
<table id="dt_table">
	<thead>
		<tr>
			<th>Name</th>
			<th>G</th>
			<th>Program</th>
			<th>Billing Period</th>
			<th>Exit Date</th>
			<th>Exit Reason</th>
			<th>SIDNY Exit Reason</th>
			<th>SIDNY Exit Reason</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr>
			<td>#firstname# #lastname#</td>
			<td><a href='javascript:getStudent(#billingStudentId#)'>#bannerGNumber#</a></td>
			<td>#program#</td>
			<td>#billingStartDate#</td>
			<td>#exitdate#</td>
			<td>#exitStatusReasonDescription#</td>
			<td>#SidnyExitDate#</td>
			<td>#sidnyExitReason#</td>
		</tr>
	</cfoutput>
	</tbody>
</table>


<cfsavecontent variable="pcc_scripts">
<script>
$(document).ready(function() {
	$('#dt_table').DataTable({
    	processing:true,
		ajax:{
			url: 'programBilling.cfc?method=getExitDateList2',
			data: getParameters,
			dataSrc:'DATA',
			error: function (xhr, textStatus, thrownError) {
			        handleAjaxError(xhr, textStatus, thrownError);
			}
		},
		dom: '<"top"iB>rt<"bottom"flp>',
		language:{ processing: "Loading data..."}
    });

	//hide main filter
	//$(".dataTables_filter").hide();

	table = $('#dt_table').DataTable();
	$('#billingStartDate').change(function(){
		table.ajax.reload();
	});
	$('#program').change(function(){
		table.ajax.reload();
	});
	$('#district').change(function(){
		table.ajax.reload();
	});
});


</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">