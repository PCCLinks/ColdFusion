<cfinvoke component="pcclinks.bill.LookUp" method="getScenarios" returnvariable="qryScenario"></cfinvoke>

<cfinvoke component="pcclinks.bill.programBilling" method="getScenarioCourses" returnvariable="data">
	<cfinvokeargument name="term" value="#url.term#">
</cfinvoke>

<style>
.scenario{
	border-bottom-style:solid;
	border-bottom-width:1px;
	border-bottom-color:lightgray;
	width:auto;
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
					<select id="#EncodeForHtml(Replace(CRN," ","_","all"))#Select" onchange="javascript:enterScenario('#EncodeForHtml(CRN)#','#billingScenarioByCourseId#');">
						<option <cfif data.billingScenarioID EQ "">selected</cfif> value="" >
							--No Scenario - Select To Set--
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

	});
	</script>