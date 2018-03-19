
<cfoutput>
<form id="frm#url.billingStudentID#" >
	<input type="hidden" id="billingStudentId#url.billingStudentId#" name="billingStudentId" value="#url.billingStudentId#">

	<!-- EXIT STATUS -->
	<div class="callout">
		<div class="row">
			<div class="small-12 columns">
				<label>Exit Date:<br>
					<input id="exitDate#url.billingStudentId#" name="exitDate" value="#DateFormat(url.exitDate,'yyyy-mm-dd')#"
						onChange='javascript:saveValues("frm#url.billingStudentId#")' class="fdatepicker"
					>
				</label>
			</div>
		</div>
		<br>
		<div class="row">
			<div class="small-12 columns">
				<label>Exit Reason:<br>
				<select name="billingStudentExitReasonCode" id="billingStudentExitReasonCode#url.billingStudentId#" style="max-width:85%"
						onChange='javascript:saveValues("frm#url.billingStudentId#")'>
					<option  selected value="" >
						--Select Exit Reason--
					</option>
					<cfloop query="#Session.Lookup.GetExitReason#">
						<option value="#billingStudentExitReasonCode#" <cfif #billingStudentExitReasonCode# EQ #url.billingStudentExitReasonCode#> selected </cfif> > #billingStudentExitReasonDescription# </option>
					</cfloop>
				</select>
				</label>
			</div>
		</div>
	</div> <!-- END EXIT STATUS -->
	<div class="callout">
		<div class="row">
			<div class="small-12 columns">
				<label>
					Adj Days For Month:<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="If the student should be billed for less than the whole month, enter the max number of days here." ><img src="/pcclinks/images/tooltip.png" width="25" height="25"></span>
					<br>
					<input  name="adjustedDaysPerMonth" id="adjustedDaysPerMonth#url.billingStudentId#" value="#url.adjustedDaysPerMonth#"
							 onBlur='javascript:saveValues("frm#url.billingStudentId#");'
					>
				</label>
			</div>
		</div>
	</div>
</form>
</cfoutput>
<script>
$(document).ready(function(){
	$('.fdatepicker').fdatepicker({
		format: 'yyyy-mm-dd',
		disableDblClickSelection: true,
		leftArrow:'<<',
		rightArrow:'>>',
		closeIcon:'X',
		closeButton: true
	});
})

</script>



