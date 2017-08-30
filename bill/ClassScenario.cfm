<cfinvoke component="LookUp" method="getScenarios" returnvariable="qryScenario"></cfinvoke>

<cfsavecontent variable="scenarioList">
	<label>Term:<br/>
		<select name="scenario" id="scenario" onkeydown="javascript:enterScenario();"/>
			<option disabled selected value="" >
				--Select Scenario--
			</option>
			<cfoutput query="qryScenario">
			<option  value="#billingScenarioID#" >#billingScenarioName#</option>
			</cfoutput>
		</select>
	</label>
</cfsavecontent>

<cfinvoke component="programBilling" method="getScenarioCourses" returnvariable="data">
	<cfinvokeargument name="term" value="#Session.term#">
</cfinvoke>


	<table id="dt_table">
		<thead>
			<th>CRN</th>
			<th>Scenario</th>
		</thead>
		<tbody>
			<cfoutput query="data">
			<tr>
				<td><input id="CRN"></td>
				<td><cfoutput>#scenarioList#</cfoutput></td>
			</tr>
			</cfoutput>
		</tbody>
	</table>