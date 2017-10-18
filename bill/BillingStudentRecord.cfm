<cfinclude template="includes/header.cfm" />

<!--- Get Page Header Data --->


<cfinvoke component="ProgramBilling" method="getBillingStudentRecord" returnvariable="qryBillingStudentRecord">
	<cfinvokeargument name="billingStudentId" value="#url.billingStudentID#">
</cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfoutput query="qryBillingStudentRecord">

<cfset readonly = false>
<cfif BillingStatus EQ 'COMPLETE'><cfset readonly = true></cfif>

<div class="callout">
<form id="frm" action="javascript:saveValues();" method="post">
	<input type="hidden" name="billingStudentId" value="#billingStudentId#"><br>
	<!---<cfset Variables.BillingStatus = #BillingStatus#>--->
	<div class=<cfif readonly>"callout alert"<cfelse>"callout primary"</cfif> >
		<div class="row">
			<div class="snall-12 columns">
				<b>Billing for Period #DateFormat(billingStartDate,'m/d/y')#</b>
			</div>
		</div>
		<div class="row">
			<div class="small-1 columns"><b>G</b></div>
			<div class="small-2 columns"><b>Name</b></div>
			<div class="small-3 columns"><b>Program</b></div>
			<div class="small-1 columns"><b>Exit Date </b></div>
			<div class="small-1 columns"><b>Term</b></div>
			<div class="small-1 columns"><b>School</b></div>
			<div class="small-1 columns"><b>Status</b></div>
			<div class="small-2 columns"><b>Include in Billing</b></div>
		</div>
		<div class="row">
			<div class="small-1 columns">#bannerGNumber#</div>
			<div class="small-2 columns">#FIRSTNAME# #LASTNAME#</div>
			<div class="small-3 columns">
				<cfif readonly>
					#program#
				<cfelse>
				<select name="program" id="program">
					<cfloop query="programs">
						<option value="#programName#" <cfif #qryBillingStudentRecord.program# EQ #programName#> selected </cfif> > #programName# </option>
					</cfloop>
				</select>
				</cfif>
			</div>
			<div class="small-1 columns">
				<cfif readonly><cfif LEN(#EXITDATE#) EQ 0>None<cfelse>#DateFormat(EXITDATE,"m/d/yy")#</cfif>
				<cfelse><input id="exitDate" name="exitDate" value="#DateFormat(EXITDATE,"m/d/yy")#" style="width:75px;">
				</cfif>
			</div>
			<div class="small-1 columns">#term#</div>
			<div class="small-1 columns">#schooldistrict#</div>
			<div class="small-1 columns">#billingstatus#</div>
			<div class="small-2 columns">
				<input type="checkbox" name="includeFlag" <cfif #includeFlag# EQ 1>checked</cfif>>
			</div>
		</div>
	</div> <!-- end header data -->
	<cfif qryBillingStudentRecord.program DOES NOT CONTAIN 'attendance'>
	<div class="callout">
		<div class="row">
			<div class="small-6 columns">
				Billed Credits
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedBilledUnits,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedBilledUnits#
					<cfelse><input style="width:65px;" name="correctedBilledUnits" id="correctedBilledUnits" value="#correctedBilledUnits#" onchange="javascript:updateCorrectedBilledAmount();">
					</cfif>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledUnits,'_._')#</label>
			</div>
			<div class="small-6 columns">
				Overage Credits
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedOverageUnits,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedOverageUnits#
					<cfelse><input style="width:65px;" name="correctedOverageUnits" id="correctedOverageUnits" value="#correctedOverageUnits#" onchange="javascript:updateCorrectedOverageAmount();">
					</cfif>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalOverageUnits,'_._')#</label>
			</div>
		</div>
	</div>
	</cfif>
	<div class="callout">
		<div class="row">
			<div class="small-6 columns">
				Billed Amount
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedBilledAmount,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedBilledAmount#
					<cfelse><input style="width:65px;" name="correctedBilledAmount" id="correctedBilledAmount" value="#correctedBilledAmount#">
					</cfif>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledAmount,'_._')#</label>
			</div>
			<div class="small-6 columns">
				Overage Amount
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedOverageAmount,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedOverageAmount#
					<cfelse><input style="width:65px;" name="correctedOverageAmount" id="correctedOverageAmount" value="#correctedOverageAmount#">
					</cfif>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalOverageAmount,'_._')#</label>
			</div>
		</div>
	</div>
	<div class="callout">
		<div class="row">
			<div class="small-2 columns">Internal Billing Notes</div>
			<div class="small-10 columns">
				<input name="billingNotes" value="#billingNotes#"  style="width:700px;">
			</div>
		</div>
		<div class="row">&nbsp;</div>
		<div class="row">
			<div class="small-2 columns">Invoice Notes</div>
			<div class="small-10 columns">
				<input name="invoiceNotes" value="#invoiceNotes#" style="width:700px;">
			</div>
		</div>
	</div>
	<div class="row">
		<div class="small-12 columns" style="color:red">
			#ErrorMessage#
		</div>
	</div>
	<div class="row">
		<div class="small-8 columns">&nbsp;</div>
		<div class="small-2 columns">
			<input type="submit" value="Save Changes" class="button" >
		</div>
		<div class="small-2 columns" id="savemessage"></div>
	</div>
	</form>

	<div class="callout">
		<cfif qryBillingStudentRecord.program CONTAINS 'attendance'>
			<cfinclude template="includes/AttendanceDetailInclude.cfm" />
		</cfif>
	</div>
</div>
</cfoutput>

<cfsavecontent variable="pcc_scripts">
<script>

$('#exitDate').fdatepicker({ format: 'mm/dd/yy',
	disableDblClickSelection: true,
	leftArrow:'<<',
	rightArrow:'>>',
	closeIcon:'X',
	closeButton: true });

function saveValues(){
 	var $form = $('#frm');
    $.ajax({
       	url: 'programBilling.cfc?method=updateBillingStudentRecord',
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
function updateCorrectedBilledAmount(){
	var correctedBilledUnits = $('#correctedBilledUnits').val();
	var r = confirm("Update Corrected Billed Amount?");
	if(r == true){
		if(correctedBilledUnits == ""){
			$('#correctedBilledAmount').val("");
		}else{
			$('#correctedBilledAmount').val(correctedBilledUnits/36*175);
		}
	}
}

function updateCorrectedOverageAmount(){
	var correctedOverageUnits = $('#correctedOverageUnits').val();
	var r = confirm("Update Corrected Overage Amount?");
	if(r == true){
		if(correctedOverageUnits == ""){
			$('#correctedOverageAmount').val("");
		}else{
			$('#correctedOverageAmount').val(correctedOverageUnits/36*175);
		}
	}
}

function addZero($time) {
  if ($time < 10) {
    $time = "0" + $time;
  }
  return $time;
}
</script>
</cfsavecontent>



<cfinclude template="includes/footer.cfm" />