<cfinvoke component="ProgramBilling" method="getBillingStudentForYear" returnvariable="data">
	<cfinvokeargument name="term" value="#attributes.term#">
	<cfinvokeargument name="contactid" value="#attributes.contactid#">
</cfinvoke>


<cfset Variables.isAttendance = false>
<cfset currentKey = attributes.term>
<cfif data.program CONTAINS "attendance" >
	<cfset Variables.isAttendance = true>
	<cfinvoke component="Lookup" method="getMaxBillingStartDateForTerm" returnvariable="currentKey">
		<cfinvokeargument name="term" value="#attributes.Term#">
	</cfinvoke>
</cfif>

<ul class="tabs" data-tabs id="billing-tabs">
	<cfoutput query="data">
		<cfif isAttendance>
			<cfset key = DateFormat(billingStartDate,'m-d-yy')>
		<cfelse>
			<cfset key = term>
		</cfif>
		<cfif key EQ currentKey>
  			<li class="tabs-title is-active"><a href="###billingStudentId#" aria-selected="true">#key#</a></li>
		<cfelse>
			<li class="tabs-title"><a href="###billingStudentId#">#key#</a></li>
		</cfif>
	</cfoutput>

</ul>


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
	function updateCorrectedBilledAmount(maxNumberOfCreditsPerTerm, maxNumberOfDaysPerYear){
		var correctedBilledUnits = $('#correctedBilledUnits').val();
		var r = confirm("Update Corrected Billed Amount?");
		if(r == true){
			if(correctedBilledUnits == ""){
				$('#correctedBilledAmount').val("");
			}else{
				$('#correctedBilledAmount').val(correctedBilledUnits/maxNumberOfCreditsPerTerm*maxNumberOfDaysPerYear);
			}
		}
	}
	function updateCorrectedOverageAmount(maxNumberOfCreditsPerTerm, maxNumberOfDaysPerYear){
		var correctedOverageUnits = $('#correctedOverageUnits').val();
		var r = confirm("Update Corrected Overage Amount?");
		if(r == true){
			if(correctedOverageUnits == ""){
				$('#correctedOverageAmount').val("");
			}else{
				$('#correctedOverageAmount').val(correctedOverageUnits/maxNumberOfCreditsPerTerm*maxNumberOfDaysPerYear);
			}
		}
	}
	function updateBilledAmountAttendance(){
		var adjustedDaysPerMonth = $('#adjustedDaysPerMonth').val();
		//if(adjustedDaysPerMonth == 0 || !adjustedDaysPerMonth){
		//	var maxDaysPerMonth = $('#maxDaysPerMonth').val();
		//	$('#correctedBilledAmount').val("");
		//}else{
			if($('#generatedBilledAmount').val() > adjustedDaysPerMonth){
				$('#correctedBilledAmount').val(adjustedDaysPerMonth);
			}else{
				$('#correctedBilledAmount').val("");
			}
		//}
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

	function addZero($time) {
	  if ($time < 10) {
	    $time = "0" + $time;
	  }
	  return $time;
	}
</script>
