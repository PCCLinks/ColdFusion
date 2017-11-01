<cfinclude template="includes/header.cfm" />

<!--- Get Page Header Data --->


<cfinvoke component="Report" method="getBillingStudentRecord" returnvariable="qryBillingStudentRecord">
	<cfinvokeargument name="billingStudentId" value="#url.billingStudentID#">
</cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getExitReasons" returnvariable="exitReasons"></cfinvoke>

<cfoutput query="qryBillingStudentRecord">

<cfset readonly = false>
<cfif BillingStatus EQ 'BILLED'><cfset readonly = true></cfif>

<cfoutput><div><a href='#session.returnToReport#' class="button">Return to report</a> </div></cfoutput>
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
			<div class="small-1 columns"><a href="javascript:goToDetail('#bannerGNumber#',#term#)">#bannerGNumber#</a></div>
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
				<cfelse><input id="exitDate" name="exitDate" value="#DateFormat(EXITDATE,"m/d/yy")#" style="width:75px;" type="text">
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
					<cfelse><input style="width:65px;" name="correctedBilledUnits" id="correctedBilledUnits" value="#correctedBilledUnits#"
									onchange="javascript:updateCorrectedBilledAmount(#maxCreditsPerTerm#, #maxDaysPerYear#);">
					</cfif>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledUnits,'_._')#</label>
			</div>
			<div class="small-6 columns">
				Overage Credits
				<label>Generated:&nbsp;&nbsp;#NumberFormat(generatedOverageUnits,'_._')#</label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedOverageUnits#
					<cfelse><input style="width:65px;" name="correctedOverageUnits" id="correctedOverageUnits" value="#correctedOverageUnits#"
								onchange="javascript:updateCorrectedOverageAmountTerm(#maxCreditsPerTerm#, #maxDaysPerYear#);">
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
				<label>Generated:&nbsp;&nbsp;
					<input id="generatedBilledAmount" name="generatedBilledAmount" value="#NumberFormat(generatedBilledAmount,'_._')#" readonly></label>
				<label>Corrected:&nbsp;&nbsp;&nbsp;
					<cfif readonly>#correctedBilledAmount#
					<cfelse><input style="width:65px;" name="correctedBilledAmount" id="correctedBilledAmount" value="#correctedBilledAmount#">
					</cfif>
				</label>
				<label>Final Billed:&nbsp;#NumberFormat(finalBilledAmount,'_._')#</label>
				<label>Corrected Post Billed Amount:&nbsp;&nbsp;&nbsp;
					<input style="width:65px;" name="postBillCorrectedBilledAmount" id="postBillCorrectedBilledAmount" value="#postBillCorrectedBilledAmount#">
				</label>
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
	<cfif qryBillingStudentRecord.program CONTAINS 'attendance'>
	<div class="callout">
		<div class="row">
			<div class="small-3 columns">
				<label>Max Days For Month:
					<input id="maxDaysPerMonth" name="maxDaysPerMonth" value="#maxDaysPerMonth#" readonly></label>
				</label>
				<label>
					Adjusted Days For Month: <input style="width:65px;" name="adjustedDaysPerMonth" id="adjustedDaysPerMonth" value="#adjustedDaysPerMonth#"
												onchange="javascript:updateBilledAmountAttendance();">
				</label>
			</div>
			<div class="small-9 columns">
				<label>Exit Reason:
				<cfif readonly>
					#billingStudentExitReasonCode#
				<cfelse>
				<select name="billingStudentExitReasonCode" id="billingStudentExitReasonCode" style="max-width:600px">
					<option disabled selected value="" >
						--Select Exit Reason--
					</option>
					<cfloop query="exitReasons">
						<option value="#billingStudentExitReasonCode#" <cfif #qryBillingStudentRecord.billingStudentExitReasonCode# EQ #billingStudentExitReasonCode#> selected </cfif> > #billingStudentExitReasonDescription# </option>
					</cfloop>
				</select>
				</cfif>
				</label>
			</div>
		</div>
	</div>
	</cfif>
	<div class="callout">
		<div class="row">
			<div class="small-2 columns">Internal Billing Notes</div>
			<div class="small-10 columns">
				<input name="billingNotes" value="#billingNotes#"  style="width:700px;">
			</div>
		</div>
		<!---<div class="row">&nbsp;</div>
		<div class="row">
			<div class="small-2 columns">Invoice Notes</div>
			<div class="small-10 columns">
				<input name="invoiceNotes" value="#invoiceNotes#" style="width:700px;">
			</div>
		</div>--->
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

	<cfif qryBillingStudentRecord.program CONTAINS 'attendance'>
		<div class="callout">
			<cfinclude template="includes/AttendanceDetailInclude.cfm" />
		</div>
	</cfif>
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
</cfsavecontent>



<cfinclude template="includes/footer.cfm" />