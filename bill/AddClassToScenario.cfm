<cfinvoke component="LookUp" method="getScenarios" returnvariable="qryScenario"></cfinvoke>

<cfinvoke component="programBilling" method="getScenarioCourses" returnvariable="data">
	<cfinvokeargument name="term" value="#url.term#">
</cfinvoke>

<style>
.scenario{
	border-bottom-style:solid;
	border-bottom-width:1px;
	border-bottom-color:lightgray;
	width:
}
select{
	margin-bottom:0px;
}

</style>


	<table id="dt_table" class="compact">
		<thead>
			<th>CRN</th>
			<th>Scenario</th>
		</thead>
		<tbody>
			<cfoutput query="data">
			<tr >
				<td class="scenario"><input id="#CRN#" value="#CRN#" style="border-style:none"></td>
				<td class="scenario">
					<select id="#CRN#Select" onchange="javascript:enterScenario('#CRN#');">
						<option disabled selected value="" >
							--Select Scenario--
						</option>
						<cfloop query="qryScenario">
							<option value="#billingScenarioID#" <cfif qryScenario.billingScenarioID EQ data.billingScenarioID> selected </cfif>>#billingScenarioName#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			</cfoutput>
		</tbody>
	</table>


	<script>
		<cfoutput>var term = #url.term#</cfoutput>
		$(document).ready(function() {
			$.fn.dataTable.ext.errMode = 'throw';
			$('#dt_table').dataTable({
				paging:false,
				searching:false
			});
		/*function enterScenario(crn){
			var billingScenarioId = $('#' + crn).val();
			$.ajax({
	            type: 'get',
	            url: 'saveClassScenario.cfm?term=' + term + '&crn=' + crn + '&billingScenarioByCourseId='+billingScenarioByCourseId,
	            error: function (xhr, textStatus, thrownError) {
					 handleAjaxError(xhr, textStatus, thrownError);
				}
	          });
		}*/
	});
	</script>