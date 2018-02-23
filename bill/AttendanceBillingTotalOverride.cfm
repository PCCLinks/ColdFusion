<cfinclude template="includes/header.cfm">

<cfquery name="data">
select *
from billingStudentTotalOverride
order by schooldistrict, program
</cfquery>

<div class="callout primary">Override Attendance Program Totals</div>

<form>
<table>
<thead>
<tr>
	<th>School District</th>
	<th>Program</th>
	<th>June</th>
	<th>July</th>
	<th>August</th>
	<th>September</th>
	<th>October</th>
	<th>November</th>
	<th>December</th>
</tr>
</thead>
<tbody>
<cfoutput query="data">
<tr>
	<td>#schooldistrict#</td>
	<td>#program#</td>
	<td><input id="#program#.#schooldistrict#.Jun" value="#Jun#" style="width:100px"></td>
	<td><input id="#program#.#schooldistrict#.Jul" value="#Jul#" style="width:100px"></td>
	<td><input id="#program#.#schooldistrict#.Aug" value="#Aug#" style="width:100px"></td>
	<td><input id="#program#.#schooldistrict#.Sept" value="#Sept#" style="width:100px"></td>
	<td><input id="#program#.#schooldistrict#.Oct" value="#Oct#" style="width:100px"></td>
	<td><input id="#program#.#schooldistrict#.Nov" value="#Nov#" style="width:100px"></td>
	<td><input id="#program#.#schooldistrict#.Dcm" value="#Dcm#" style="width:100px"></td>
</tr>
</cfoutput>
</tbody>
</table>
</form>

<cfsavecontent variable="pcc_scripts">
<script>
	$(document).ready(function() {
		$('form :input').change(function(){
			saveEntry(this);
		});
	});
	function saveEntry(target){
		var parts = target.id.split('.');
		var program = parts[0];
		var schooldistrict = parts[1];
		var month = parts[2];
		var value = target.value;


		$.ajax({
			url: "report.cfc?method=updateOverrideTotal",
			type: "POST",
			async: false,
			data: { program: program, schooldistrict:schooldistrict, month:month, value:value },
			error: function (jqXHR, exception) {
		        handleAjaxError(jqXHR, exception);
			}
		});
	}
</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">