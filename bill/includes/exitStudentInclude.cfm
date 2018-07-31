
<style>
	a.inactive{
		color:darkgray;
	}
</style>
<!-- Billing Tabs -->
<ul class="tabs" data-tabs id="billing-tabs" ></ul>

<!-- billing tab content -->
<div class="tabs-content" data-tabs-content="billing-tabs" id="billing-tabs-content"></div>

<div id="billabledays" style="display:none"></div>


<script>

var idx_dt_billingStudentId = 1;
var idx_dt_billingStartDate = 2;
var idx_dt_exitDate = 3;
var idx_dt_exitReasonCode = 4;
var idx_dt_adjDaysPerMonth = 5;
var idx_dt_billingEndDate = 6;
var idx_dt_includeFlag = 7;
var ids;
var selectedBillingStudentId;
var customDialog;

function populateStudent(programYear){
	var htmlTabs = '';
	var htmlTabContent = '';
	var buildContent = [];
	var elem = new Foundation.Tabs($('#billing-tabs'));
	ids = [];

	$.get('programBilling.cfc?method=getBillingStudentByContactId&contactId=' + selectedGridData[idx_grid_contactId] + '&programYear=' + programYear)
		.then(function(billingStudentData){
				var data = $.parseJSON(billingStudentData).DATA;
				var columns = $.parseJSON(billingStudentData).COLUMNS;
				$.each(data, function(index, row){
					ids.push(row[idx_dt_billingStudentId]);

					var exitDate = '';
					var exitReasonCode = '';
	       			htmlTabs = htmlTabs + '<li class="tabs-title" >';
	       			htmlTabs = htmlTabs + '<a href="#' + row[idx_dt_billingStudentId] + 'T" id="billTab' + row[idx_dt_billingStudentId] + '"'
	       								+ (row[idx_dt_includeFlag]==0 ? 'class="inactive"' : '')
	       								+ '>' + row[idx_dt_billingStartDate] + '</a></li>';

					var url = 'includes/exitReasonInclude.cfm';
	       			var postData = buildPostData(row, columns);
	       			var r = $.post(url, postData, function(exitReasonHtml){
							    htmlTabContent = htmlTabContent + '<div class= "tabs-panel" id="' + row[idx_dt_billingStudentId] + 'T" >'+ exitReasonHtml + '</div>';
							 });
					buildContent.push(r);

				})
	}).then(function(){
		$.when.apply(null, buildContent).done(function(){
			$('#billing-tabs').html(htmlTabs);
			$('#billing-tabs-content').html(htmlTabContent);
			elem = new Foundation.Tabs($('#billing-tabs'));

			$('#billTab'+getLastActive()).click();

			$('.fdatepicker').fdatepicker({
				format: 'yyyy-mm-dd',
				disableDblClickSelection: true,
				leftArrow:'<<',
				rightArrow:'>>',
				closeIcon:'X',
				closeButton: true
			});
		});
	});

}
function getDetail(url){
	var content;
	$.get(url, function(exitReasonHtml){
	    return exitReasonHtml;
	 });
}


function saveExitStudentValues(frmId){
 	var billingStudentId = frmId.replace('frm','');

 	//validate that we want to clear out this entry
	if(getIncludeFlag(billingStudentId) == 0){
		$( "#validateDialog" ).css("display","none");
		$( "#validateDialog" ).html("Are you sure you want to EXCLUDE this entry from billing?<br><br>This will REMOVE the exit information for this billing period.");
		var d = $( "#validateDialog" ).dialog({
			  title: "Are you sure?",
			  modal: true,
			  autoOpen: false,
			  width: 400,
			  height:300,
			  buttons: {
			      "Yes, I'm sure": function() {
			      		$( this ).dialog( "close" );
			      		clearExitData(billingStudentId);
						$('#billTab'+billingStudentId).addClass("inactive");
			      		doSave(frmId);
			      },
			      "Cancel": function() {
			      		$('#includeFlag'+id).prop('checked', true);
						$('#billTab'+billingStudentId).removeClass("inactive");
			        	$( this ).dialog( "close" );
			      }
			    }
		});
		d.dialog("open");
	}else{
		if(exitDateNotInBillingPeriod(billingStudentId)){
			$( "#validateDialog" ).css("display","none");
			$( "#validateDialog" ).html("The exit date must be within the billing period.<br>  Please select the tab with the billing period that fits this exit date.");
			var d = $( "#validateDialog" ).dialog({
			  title: "Invalid Exit Date",
			  modal: true,
			  autoOpen: false,
			  width: 350,
			  height:250,
			  buttons: {
			      "OK": function() {
			      		clearExitData(billingStudentId);
			        	$( this ).dialog( "close" );
			      }
			    }
			});
			d.dialog("open");
		}else{
			doSave(frmId);
		}
	}
}
function doSave(frmId){
	var frm = $('#'+frmId);
 	var billingStudentId = frmId.replace('frm','');

 	var frmFields = frm.serialize();
 	if(!frmFields.includes("includeFlag")){
 		frmFields = frmFields + '&includeFlag=0';
 	}else{
 		frmFields = frmFields.replace("includeFlag=on", "includeFlag=1");
 	}

    $.ajax({
       	url: 'report.cfc?method=updatebillingStudentRecordExit',
       	type: 'POST',
       	data: frmFields,
       	success: function (data, textStatus, jqXHR) {
       		updateGridRow(billingStudentId);
    	},
		error: function (jqXHR, exception) {
      		handleAjaxError(jqXHR, exception);
		}
	});

}
function updateGridRow(billingStudentId){
 	var includeFlag = getIncludeFlag(billingStudentId);
	if(selectedGridData[idx_grid_billingStudentId] == billingStudentId){
       	if(includeFlag){
			selectedGridData[idx_grid_exitDate] = getExitDate(billingStudentId)
			selectedGridData[idx_grid_adjustedDays] = getAdjustedDaysPerMonth(billingStudentId);
			selectedGridData[idx_grid_bsExitReasonDesc] = getExitReasonCode(billingStudentId);
			$('#billTab'+billingStudentId).removeClass("inactive");
    	}else{
    		setToLastActiveRow();
      	}
    }else{
		if(includeFlag){
    		setToLastActiveRow();
		}
	}

	selectedGridRow.data(selectedGridData);
	$('#billTab'+selectedGridData[idx_grid_billingStudentId]).click();

}


function buildPostData(row, columns){
	var postData = '';
	$.each(row, function(index, col){
		postData = postData + '&' + columns[index] + '=' + col;
	});
	return postData;
}
function getBillingStartDate(billingStudentId){
	return $('#billingStartDate'+billingStudentId).val();
}
function getBillingEndDate(billingStudentId){
	return $('#billingEndDate'+billingStudentId).val();
}
function getExitDate(billingStudentId){
	return $('#exitDate'+billingStudentId).val();
}
function getAdjustedDaysPerMonth(billingStudentId){
	return $('#adjustedDaysPerMonth'+billingStudentId).val();
}
function getExitReasonCode(billingStudentId){
	if($('#billingStudentExitReasonCode' + billingStudentId + ' option:selected').val()){
		return $('#billingStudentExitReasonCode' + billingStudentId + ' option:selected').text();
	}else{
		return '';
	}
}
function getIncludeFlag(billingStudentId){
	return $('#includeFlag'+billingStudentId).prop('checked')
}
function clearExitData(billingStudentId){
	$('#exitDate'+billingStudentId).val('');
	$('#adjustedDaysPerMonth'+billingStudentId).val('');
	$('#billingStudentExitReasonCode' + billingStudentId).val('');
}

function setAdjustedDaysPerMonth(billingStudentId, value){
	return $('#adjustedDaysPerMonth'+billingStudentId).val(value);
}
function getLastActive(){
	lastActiveId = -1;
	$.each(ids, function(index, id){
		if(getIncludeFlag(id)){
			lastActiveId = id;
			//id's are in descending order, so only need first match
			return false;
		}
	});
	return lastActiveId;
}
function setToLastActiveRow(){
	var lastActiveId = getLastActive();
	if(lastActiveId != -1){
		selectedGridData[idx_grid_billingStudentId] = lastActiveId;
		selectedGridData[idx_grid_billingStartDate] = getBillingStartDate(lastActiveId);
		selectedGridData[idx_grid_exitDate] = getExitDate(lastActiveId);
		selectedGridData[idx_grid_bsExitReasonDesc] = getExitReasonCode(lastActiveId);
		selectedGridData[idx_grid_adjustedDays] = getAdjustedDaysPerMonth(lastActiveId);
		$('#billTab'+lastActiveId).removeClass("inactive");
	}
}
function exitDateNotInBillingPeriod(billingStudentId){
	var bStart = getBillingStartDate(billingStudentId);
	var bEnd = getBillingEndDate(billingStudentId);
	var exitDate = getExitDate(billingStudentId);

	if(exitDate < bStart || exitDate > bEnd){
		return true;
	}else{
		return false;
	}
}
function setBillableDays(billingStudentId){
	selectedBillingStudentId = billingStudentId;
	var billingStartDate = getBillingStartDate(billingStudentId);
	var exitDate = getExitDate(billingStudentId);
	$.get('includes/billableDaysInclude.cfm?billingStartDate=' + billingStartDate + '&billingEndDate=' + exitDate, function(data){
		$('#billabledays').html(data);
		customDialog = $('#billabledays' ).dialog({
			  title: "Set Days",
			  modal: true,
			  autoOpen: false,
			  width: 750,
			  height:500
		});
		customDialog.dialog("open");
	}).done(function(){
		buildCalendar(saveBillableDays);
		$('#billabledays').css("display", "block");
	});

}
function saveBillableDays(numDays){
	setAdjustedDaysPerMonth(selectedBillingStudentId, numDays);
	doSave("frm" + selectedBillingStudentId);
	customDialog.dialog( "close" );
	$('#billabledays').css("display", "none");
}

</script>

