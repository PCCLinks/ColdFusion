<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getScenarios" returnvariable="qryScenarios"></cfinvoke>


<div class= "callout display">
	<div class="row">
		<div class="small-3 columns">
			<label>Term:<br/>
				<select name="term" id="term" onchange="getScenarios()"/>
					<option disabled selected value="" >
						--Select Term--
					</option>
					<cfoutput query="qryTerms">
					<option  value="#term#" >#term#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<div id="linkToShowAddScenario" class="small-2 columns">
			<br>
			<a href="javascript:showAddScenario();">Add Scenario</a>
		</div>
		<div id="linkToShowEditScenario" class="small-2 columns">
			<br>
			<a href="javascript:showEditScenario();">Edit Scenario</a>
		</div>
		<div id="linkToShowClassScenarios" class="small-2 columns">
			<br>
			<a href="javascript:showClassScenario();">Show Class Scenarios</a>
		</div>
		<div class="small-4 columns"></div>
</div>
<br>
<div class= "callout display" id="addScenarioDisplay">
	<div class="row">
		<div class="small-2 columns"><label>Scenario: <input id="billingScenarioName"></label></div>
		<div class="small-1 columns"><label>Ind %: <input id="indPercent" style="width:50px;"></label></div>
		<div class="small-1 columns"><label>Small %: <input id="smallPercent" style="width:50px;"></label></div>
		<div class="small-1 columns"><label>Inter %: <input id="interPercent" style="width:50px;"></label></div>
		<div class="small-1 columns"><label>Large %: <input id="largePercent" style="width:50px;"></label></div>
		<div class="small-6 columns">
			<input type="button" value="Add Scenario" id="addScenario" onClick="javascript:addScenario();">
		</div>
	</div>
</div>
<br>
<div class= "callout display" id="editScenarioDisplay">
	<div class="row">
		<div class="small-3 columns">
			<label>Scenario:<br/>
				<select name="billingScenarioSelect" id="billingScenarioSelect" onchange="populateScenario()"/>
					<option disabled selected value="" >
						--Select Scenario--
					</option>
					<cfoutput query="qryScenarios">
					<option  value="#billingScenarioName#" >#billingScenarioName#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<div class="small-1 columns"><label>Ind %: <input id="indPercentEdit" style="width:50px;"></label></div>
		<div class="small-1 columns"><label>Small %: <input id="smallPercentEdit" style="width:50px;"></label></div>
		<div class="small-1 columns"><label>Inter %: <input id="interPercentEdit" style="width:50px;"></label></div>
		<div class="small-1 columns"><label>Large %: <input id="largePercentEdit" style="width:50px;"></label></div>
		<div class="small-5 columns">
			<br><input type="button" value="Save Scenario" id="saveScenario" onClick="javascript:saveScenario();">
		</div>
	</div>
</div>

<div class="row" id="addClassToScenario">
	<div class="small-6 columns">
		<div id="dataTable"></div>
	</div>
</div>

<cfsavecontent variable="pcc_scripts">
<script>

	$(document).ready(function() {
		showClassScenario();
	});
	function showAddScenario(){
		$('#addScenarioDisplay').show();
		$('#addClassToScenario').hide();
		$('#editScenarioDisplay').hide();

		$('#linkToShowAddScenario').hide();
		$('#linkToShowEditScenario').show();
		$('#linkToShowClassScenarios').show();
	}
	function showClassScenario(){
		$('#addClassToScenario').show();
		$('#addScenarioDisplay').hide();
		$('#editScenarioDisplay').hide();

		$('#linkToShowClassScenarios').hide();
		$('#linkToShowAddScenario').show();
		$('#linkToShowEditScenarios').show();
	}
	function showEditScenario(){
		$('#editScenarioDisplay').show();
		$('#addScenarioDisplay').hide();
		$('#addClassToScenario').hide();

		$('#linkToShowEditScenarios').hide();
		$('#linkToShowAddScenario').show();
		$('#linkToShowClassScenarios').show();
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
            	showClassScenario();
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
            url: 'AddClassToScenario.cfm?term=' + term,
            success: function (data, textStatus, jqXHR) {
				$('#dataTable').html(data);
			},
            error: function (xhr, textStatus, thrownError) {
				 handleAjaxError(xhr, textStatus, thrownError);
			}
          });
	}
	function enterScenario(crn){
			var billingScenarioId = $('#' + crn + 'Select').val();
			var term = $('#term').val();
			$.ajax({
	            type: 'post',
	            url: 'programBilling.cfc?method=saveClassScenario',
	            data: {term: term, crn: crn, billingScenarioId: billingScenarioId},
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
	function  insertItem(billingStudentID)
	{
		var crn = '99999';
		var subj = 'TUT';
		var crse = '99999';
		var title = 'Tutor Roll';
		var typecode = 'ATTENDANCE'
		$.ajax({
            type: 'post',
            url: 'programBilling.cfc?method=insertClass',
            data: {billingStudentId: billingStudentID, crn: crn, subj: subj, crse: crse, title: title, typecode: typecode, isAjax:'true'},
            datatype:'json',
            success: function(billingStudentItemID){
            	$('#' + billingStudentID).parent().html('<a href="javascript:removeItem(' + billingStudentItemID + ');" id=' + billingStudentID + '>Remove Entry</a>');
            },
            error: function (jqXHR, exception) {
				handleAjaxError(jqXHR, exception);
			}
        });
	}

	function  removeItem(billingStudentItemID, billingStudentID)
	{
		var response = window.confirm('Are you sure you want to remove this item?');
		if(response)
		{
			$.ajax({
	            type: 'post',
	            url: 'programBilling.cfc?method=removeItem',
	            data: {billingStudentItemID: billingStudentItemID, isAjax:'true'},
	            datatype:'json',
	            success: function(){
	            	$('#' + billingStudentID).parent().html('<input type="checkbox" id=' + billingStudentID + ' onclick="javascript:insertItem(' + billingStudentID + ');">');
	            },
	            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
				}
        });
		}
	}

</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">