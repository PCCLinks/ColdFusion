<cfinvoke component="ProgramBilling" method="getBillingStudentForYear" returnvariable="data">
	<cfinvokeargument name="term" value="#attributes.term#">
	<cfinvokeargument name="contactid" value="#attributes.contactid#">
</cfinvoke>

<cfparam name="currentKey" default="#attributes.currentKey#">
<cfparam name="isAttendance" default="#attributes.isAttendance#" type="boolean">

<!-- Start of UI -->

<!-- Billing Tabs -->
<ul class="tabs" data-tabs id="billing-tabs">
	<cfoutput query="data">
		<cfset key = DateFormat(billingStartDate,'m-d-yy')>
		<cfset liClass = "tabs-title">
		<cfif key EQ currentKey><cfset liClass = liClass & " is-active"></cfif>
  		<li class="#liClass#"><a href="###billingStudentId#" aria-selected="true">#key#<br><span style="color:gray">#term#</span></a></li>
	</cfoutput>
</ul>

<!-- billing tab content -->
<div class="tabs-content" data-tabs-content="billing-tabs">
<cfoutput query="data">
  	<div class= "tabs-panel<cfif term EQ attributes.term> is-active</cfif>" id="#billingStudentId#">
    	<cfmodule template="billingStudentRecordInclude.cfm" billingStudentId = #billingStudentId#>
  	</div>
</cfoutput>
</div>


<script>
	function saveValues(frmId){
	 	var $form = $('#'+frmId);
	    $.ajax({
	       	url: 'report.cfc?method=updateBillingStudentRecord',
	       	type: 'POST',
	       	data: $form.serialize(),
	       	success: function (data, textStatus, jqXHR) {
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

	function goToDetail(bannerGNumber, term){
		sessionStorage.setItem('bannerGNumber', bannerGNumber);
		sessionStorage.setItem('term', term);
		sessionStorage.setItem('showNext',false);
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
		$.post("SaveSession.cfm", data, function(){
			window.open('programStudentDetail.cfm');
		});
	}

</script>
