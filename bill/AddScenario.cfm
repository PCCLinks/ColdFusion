<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getScenarios" returnvariable="qryScenarios"></cfinvoke>
<cfinvoke component="LookUp" method="getMaxTerm" returnvariable="maxTerm"></cfinvoke>


<div class= "callout display">
	<div class="row">
		<div class="small-4 medium-4 columns">
			<label>Term:<br/>
				<select name="term" id="term" onchange="getScenarios()">
					<option disabled value="" >
						--Select Term--
					</option>
					<cfoutput query="qryTerms">
					<option  value="#term#" <cfif maxTerm EQ term>selected</cfif>>#termDescription#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<div id="btnToShowAddScenario" class="small-4 medium-2 columns">
			<br><input type="button" class="button" onClick="javascript:show('add scenario');" value="Add Scenario">
		</div>
		<div id="btnToShowEditScenario" class="small-4 medium-2 columns">
			<br><input type="button" class="button" onClick="javascript:show('edit scenario');" value="Edit Scenario">
		</div>
		<div id="btnToShowClassScenarios" class="small-4 medium-2 columns">
			<br><input type="button" class="button" onClick="javascript:show('add class to scenario');" value="Show Class Scenarios">
		</div>
		<div class="small-4 medium-2 columns"></div>
	</div>
</div>
<br>
<div class= "callout display" id="addScenarioDisplay">
	<div class="row">
		<div class="small-2 columns"><label>Scenario: <input id="billingScenarioName" type="text"></label></div>
		<div class="small-1 columns"><label>Ind %: <input id="indPercent" style="width:50px;" type="text"></label></div>
		<div class="small-1 columns"><label>Small %: <input id="smallPercent" style="width:50px;" type="text"></label></div>
		<div class="small-1 columns"><label>Inter %: <input id="interPercent" style="width:50px;" type="text"></label></div>
		<div class="small-1 columns"><label>Large %: <input id="largePercent" style="width:50px;" type="text"></label></div>
		<div class="small-6 columns">
			<br><input type="button" class="button" value="Save" id="addScenario" onClick="javascript:addScenario();">
		</div>
	</div>
</div>
<br>
<div class= "callout display" id="editScenarioDisplay">
	<div class="row">
		<div class="small-3 columns">
			<label>Scenario:<br/>
				<select name="billingScenarioSelect" id="billingScenarioSelect" onchange="populateScenario()">
					<option disabled selected value="" >
						--Select Scenario--
					</option>
					<cfoutput query="qryScenarios">
					<option  value="#billingScenarioName#" >#billingScenarioName#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<div class="small-1 columns"><label>Ind %: <input id="indPercentEdit" style="width:50px;" type="text"></label></div>
		<div class="small-1 columns"><label>Small %: <input id="smallPercentEdit" style="width:50px;" type="text"></label></div>
		<div class="small-1 columns"><label>Inter %: <input id="interPercentEdit" style="width:50px;" type="text"></label></div>
		<div class="small-1 columns"><label>Large %: <input id="largePercentEdit" style="width:50px;" type="text"></label></div>
		<div class="small-5 columns">
			<br><input type="button" class="button" value="Save" id="saveScenario" onClick="javascript:saveScenario();">
		</div>
	</div>
</div>

<div class="row" id="addClassToScenario">
	<div class="small-12 columns">
		<div id="dataTable"></div>
	</div>
</div>

<cfsavecontent variable="pcc_scripts">
<script>

	$(document).ready(function() {
		show('add class to scenario');
		getScenarios();
	});
	function show(group){
		if(group == "add scenario"){
			$('#addScenarioDisplay').show();
			$('#editScenarioDisplay').hide();
			$('#addClassToScenario').hide();

			$('#btnToShowClassScenarios').show();
			$('#btnToShowAddScenario').hide();
			$('#btnToShowEditScenario').hide();
		}
		if(group == "edit scenario"){
			$('#editScenarioDisplay').show();
			$('#addScenarioDisplay').hide();
			$('#addClassToScenario').hide();

			$('#btnToShowClassScenarios').show();
			$('#btnToShowAddScenario').hide();
			$('#btnToShowEditScenario').hide();
		}
		if(group == "add class to scenario"){
			$('#addClassToScenario').show();
			$('#editScenarioDisplay').hide();
			$('#addScenarioDisplay').hide();

			$('#btnToShowClassScenarios').hide();
			$('#btnToShowAddScenario').show();
			$('#btnToShowEditScenario').show();
		}

	}

	function addScenario(){
		var billingScenarioName = $('#billingScenarioName').val();
		var indPercent = $('#indPercent').val();
		var smallPercent = $('#smallPercent').val();
		var interPercent = $('#interPercent').val();
		var largePercent = $('#largePercent').val();
		$.ajax({
            type: 'post',
            url: 'programBilling.cfc?method=insertScenario',
            data: {billingScenarioName: billingScenarioName, indPercent: indPercent, smallPercent: smallPercent, interPercent: interPercent, largePercent: largePercent, isAjax:'true'},
            datatype:'json',
            success: function(){
            	getScenarios();
            	show('add class to scenario');
            },
            error: function (jqXHR, exception) {
				handleAjaxError(jqXHR, exception);
			}
        });

	}
	function saveScenario(){
		var billingScenarioName = $('#billingScenarioSelect').val();
		var indPercent = $('#indPercentEdit').val();
		var smallPercent = $('#smallPercentEdit').val();
		var interPercent = $('#interPercentEdit').val();
		var largePercent = $('#largePercentEdit').val();
		$.ajax({
            type: 'post',
            url: 'programBilling.cfc?method=saveScenario',
            data: {billingScenarioName: billingScenarioName, indPercent: indPercent, smallPercent: smallPercent, interPercent: interPercent, largePercent: largePercent, isAjax:'true'},
            datatype:'json',
            error: function (jqXHR, exception) {
				handleAjaxError(jqXHR, exception);
			}
        });

	}
	function getScenarios(){
		var term = $('#term').val();
		$.ajax({
            type: 'get',
            url: 'includes/AddClassToScenarioInclude.cfm?term=' + term,
            success: function (data, textStatus, jqXHR) {
				$('#dataTable').html(data);
			},
            error: function (xhr, textStatus, thrownError) {
				 handleAjaxError(xhr, textStatus, thrownError);
			}
          });
	}
	function enterScenario(crn,billingScenarioByCourseId){
			//var billingScenarioId = $('#' + crn.replace(" ","_") + 'Select').val();
			var selectName = crn.split(' ').join('_') + 'Select';
			var billingScenarioId = $('#' + selectName).val();
			var term = $('#term').val();
			$.ajax({
	            type: 'post',
	            url: 'programBilling.cfc?method=saveClassScenario',
	            data: {term: term, crn: crn, billingScenarioId: billingScenarioId, billingScenarioByCourseId: billingScenarioByCourseId},
	            error: function (xhr, textStatus, thrownError) {
					 handleAjaxError(xhr, textStatus, thrownError);
				}
	          });
	}
	function populateScenario(){
			var billingScenarioName = $('#billingScenarioSelect').val();
			$.ajax({
	            type: 'post',
	            url: 'LookUp.cfc?method=getScenarios&queryFormat=column',
	            data: {billingScenarioName: billingScenarioName},
	            dataType: 'json',
	            success:function(data){
					$('#indPercentEdit').val(data.DATA.INDPERCENT);
					$('#smallPercentEdit').val(data.DATA.SMALLPERCENT);
					$('#interPercentEdit').val(data.DATA.INTERPERCENT);
					$('#largePercentEdit').val(data.DATA.LARGEPERCENT);

	            },
	            error: function (xhr, textStatus, thrownError) {
					 handleAjaxError(xhr, textStatus, thrownError);
				}
	          });
	}


</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">