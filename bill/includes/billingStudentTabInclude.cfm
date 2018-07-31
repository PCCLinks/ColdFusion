

<cfparam name="selectedBillingStudentId" default="#Session.mostRecentTermBillingStudentId#">
<cfparam name="data" default="#Session.qryBillingStudentEntries#" type="query">

<!-- Start of UI -->

<!-- Billing Tabs -->
<ul class="tabs" data-tabs id="billing-tabs" >
	<cfoutput query="data">
		<cfset key = #billingStudentId# & "B">
		<cfset liClass = "tabs-title">
		<cfif billingStudentId EQ selectedBillingStudentId><cfset liClass = liClass & " is-active"></cfif>
  		<li class="#liClass#"><a href="###billingStudentId#B" aria-selected="true">#DateFormat(billingStartDate,'m-d-yy')#<br><span style="color:gray">#term#</span></a></li>
	</cfoutput>
</ul>

<!-- billing tab content -->
<div class="tabs-content" data-tabs-content="billing-tabs">
<cfoutput query="data">
  	<div class= "tabs-panel<cfif billingStudentId EQ selectedBillingStudentId> is-active</cfif>" id="#billingStudentId#B" >
    	<cfmodule template="billingStudentRecordInclude.cfm" billingStudentId = #data.billingStudentId#>
  	</div>
</cfoutput>
</div>

<!-- scripts from billingStudentTabInclude.cfm -->
<script>
function billingStudentTabInit(){
	$(document).on("saveAction", function(e){
		billingStudentTabSaveEventHandler(e);
	});
}

function saveBillingStudentRecord(frmId){
 	var $form = $('#'+frmId);
 	var dataArray = $form.serializeArray();
 	var billingStudentId;
 	var includeFlag = "off";
    $.ajax({
       	url: 'report.cfc?method=updateBillingStudentRecord',
       	type: 'POST',
       	data: $form.serialize(),
       	success: function (data, textStatus, jqXHR) {

       		$.each(dataArray, function(i, field){
       			if(field.name == "billingStudentId"){
       				billingStudentId = field.value;
       			}
       		});
       		$.each(dataArray, function(i, field){
       			if(field.name === "includeFlag"){
       				includeFlag = "on";
       			}
       			callSaveActionEvent(billingStudentId, field.name, field.value, "billingStudentTabInclude");
			});

			//checkbox is not checked
			if(includeFlag == "off"){
       			callSaveActionEvent(billingStudentId, "includeFlag", false, "billingStudentTabInclude");
			}

        	var d = new Date();
			$('#savemessage').html('Saved ' + addZero(d.getHours()) + ':' + addZero(d.getMinutes()) + ':' + addZero(d.getSeconds()));
    	},
		error: function (jqXHR, exception) {
      		handleAjaxError(jqXHR, exception);
		}
    });
}
function updateCorrectedBilledAmount(maxNumberOfCreditsPerTerm, maxNumberOfDaysPerYear, id){
	var correctedBilledUnits = $('#correctedBilledUnits' + id).val();
	if(correctedBilledUnits == ""){
		$('#correctedBilledAmount' + id).val("");
	}else{
		$('#correctedBilledAmount' + id).val(correctedBilledUnits/maxNumberOfCreditsPerTerm*maxNumberOfDaysPerYear);
	}
	saveValues('frm' + id);
}
function updateCorrectedOverageAmount(maxNumberOfCreditsPerTerm, maxNumberOfDaysPerYear, id){
	var correctedOverageUnits = $('#correctedOverageUnits' + id).val();
	if(correctedOverageUnits == ""){
		$('#correctedOverageAmount' + id).val("");
	}else{
		$('#correctedOverageAmount' + id).val(correctedOverageUnits/maxNumberOfCreditsPerTerm*maxNumberOfDaysPerYear);
	}
	saveValues('frm' + id);
}
function updateBilledAmountAttendance(id){
	var adjustedDaysPerMonth = $('#adjustedDaysPerMonth' + id).val();
	if($('#generatedBilledAmount' + id).val() > adjustedDaysPerMonth){
		$('#correctedBilledAmount' + id).val(adjustedDaysPerMonth);
	}else{
		$('#correctedBilledAmount' + id).val("");
	}
	saveValues('frm' + id);
}
function billingStudentTabSaveEventHandler(e){
	if(e.caller != "billingStudentTabInclude"){
		var billingStudentId = e.billingStudentId;
		switch(e.field){
			case 'exitDate':
				$('#exitDateB'+billingStudentId).val(e.value);
				break;
			case 'Program':
				$('#programB'+billingStudentId).val(e.value);
				break;
			case "includeFlag":
				$('#includeFlagB'+billingStudentId).prop("checked", e.value);
				break;
		}
	}
}


</script>