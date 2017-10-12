<cfinvoke component="ProgramBilling" method="getBillingStudentRecord" returnvariable="qryBillingStudentRecord">
	<cfinvokeargument name="billingStudentId" value="#attributes.billingStudentID#">
</cfinvoke>

<cfoutput query="qryBillingStudentRecord">
<div class="callout">Billing for Period #DateFormat(billingStartDate,'m/d/y')#
	<form id="frmbillingStudentRecord" action="programBilling.cfc?method=updateBillingStudentRecord">
		<input type="hidden" name="billingStudentId" value="#billingStudentId#"><br>
		<div class="callout">
		<div class="row">
			<div class="small-6 columns">
				Billed Credits
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedBilledUnits,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;<input style="width:65px;" name="correctedBilledUnits" value="#correctedBilledUnits#"></label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledUnits,'_._')#</label>
			</div>
			<div class="small-6 columns">
				Overage Credits
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedOverageUnits,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;<input style="width:65px;" name="correctedOverageUnits" value="#correctedOverageUnits#"></label>
				<label>Final Billed:&nbsp;#NumberFormat(finalOverageUnits,'_._')#</label>
			</div>
		</div>
		</div>
		<div class="callout">
		<div class="row">
			<div class="small-6 columns">
				Billed Amount
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedBilledAmount,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;<input style="width:65px;" name="correctedBilledAmount" value="#correctedBilledAmount#"></label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledAmount,'_._')#</label>
			</div>
			<div class="small-6 columns">
				Overage Amount
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedOverageAmount,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;<input style="width:65px;" name="correctedOverageAmount" value="#correctedOverageAmount#"></label>
				<label>Final Billed:&nbsp;#NumberFormat(finalOverageAmount,'_._')#</label>
			</div>
		</div>
		</div>
		<div class="row">
			<input type="button" value="Save correction" onClick="javascript:frmBillingStudentRecordSaveValues();">
		</div>
	</form>
</div>
</cfoutput>
		<script>
			function frmBillingStudentRecordSaveValues(){
			 	var $form = $('#frmbillingStudentRecord');
	            $.ajax({
	                url: $form.attr('action'),
	                type: 'POST',
	                data: $form.serialize(),
					error: function (jqXHR, exception) {
				        handleAjaxError(jqXHR, exception);
					}
	            });
			}
		</script>