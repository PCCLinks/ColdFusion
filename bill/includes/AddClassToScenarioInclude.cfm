<cfinvoke component="pcclinks.bill.LookUp" method="getScenarios" returnvariable="qryScenario"></cfinvoke>

<cfinvoke component="pcclinks.bill.programBilling" method="getScenarioCourses" returnvariable="data">
	<cfinvokeargument name="term" value="#url.term#">
</cfinvoke>

<style>
.scenario readonly{
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
			<th>SUBJ</th>
			<th>CRSE</th>
			<th>Title</th>
			<th>CRN</th>
			<th>Scenario</th>
			<th style="width:150px">Students</th>
		</thead>
		<tbody>
			<cfoutput query="data">
			<tr >
				<td class="scenario">#SUBJ#</td>
				<td class="scenario">#CRSE#</td>
				<td class="scenario">#Title#</td>
				<td class="scenario"><input id="#CRN#" value="#CRN#" style="border-style:none; background-color:transparent;width:100px;" readonly></td>
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
				<td><div id="students#crn#"><a href="javascript:getStudents(#CRN#, #url.term#)">Students</a></div>
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
		function getStudents(crn, term){
			$.ajax({
	            type: 'get',
	            url: 'includes/StudentsForCRNInclude.cfm?term=' + term + '&crn=' + crn,
	            success: function (data, textStatus, jqXHR) {
					$('#students'+crn).html('<a href="javascript:closeStudents(' + crn + ', ' + term + ')">Close</a><br/>' + data);
				},
	            error: function (xhr, textStatus, thrownError) {
					 handleAjaxError(xhr, textStatus, thrownError);
				}
	          });
		}
		function closeStudents(crn, term){
			$('#students'+crn).html('<a href="javascript:getStudents(' + crn + ', ' + term + ')">Students</a>');
		}
	</script>