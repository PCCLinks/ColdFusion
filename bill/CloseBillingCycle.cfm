<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>

<div class="callout primary">

<!--- query parameters --->
<form id="pageForm" action="javascript:closeBillingCycle();" method="post">
<input type="hidden" name="billingType" id="billingType" value=<cfoutput>"#url.type#"</cfoutput>>
<div class="row">
	<div class="small-3 columns">
		<label>Term:<br/>
			<select name="term" id="term"/>
				<option disabled selected value="" >
					--Select Term--
				</option>
				<cfoutput query="qryTerms">
				<option  value="#term#" >#term#</option>
				</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-3 columns">
		<label><cfif url.type EQ "term">Term Enrollment Date<cfelse>Month Start Date</cfif>:<br/>
			<input name="billingStartDate" id="billingStartDate" type="text" />
		</label>
	</div>
	<div class="small-3 columns">
		<label><br/><input class="button" type="submit" name="submit" value="Close Billing Cycle" /></label>
	</div>
	<div id="savemessage"></div>
</div>

<cfsavecontent variable="pcc_scripts">
<script type="text/javascript">
	$('#billingStartDate').datepicker({ dateFormat: 'mm/dd/yy' });
	function closeBillingCycle(){
		var r = confirm("Are you sure you want to close this billing cycle?");
		if(r){
			var $form = $('#pageForm');
		    $.ajax({
		       	url: 'programBilling.cfc?method=closeBillingCycle',
		       	type: 'POST',
		       	data: $form.serialize(),
		       	success: function (data, textStatus, jqXHR) {
		        	var d = new Date();
					$('#savemessage').html('<br>Billing cycle closed.');
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