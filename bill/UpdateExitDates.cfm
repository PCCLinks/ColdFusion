<cfinclude template="includes/header.cfm" />

<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getLatestAttendanceDates" returnvariable="qryBillingDates"></cfinvoke>

<cfif CGI.REQUEST_METHOD EQ "POST">
	<cfinvoke component="ProgramBilling" method="updateExitDates">
		<cfinvokeargument name="termBeginDate" value="#form.termBeginDate#">
		<cfinvokeargument name="termEndDate" value="#form.termEndDate#">
		<cfinvokeargument name="billingStartDate" value="#form.billingStartDate#">
		<cfinvokeargument name="billingEndDate" value="#form.billingEndDate#">
	</cfinvoke>
</cfif>

<div class="callout primary">
<h4><cfoutput>Update Exit Dates from SIDNY</h4></cfoutput>
<!--- query parameters --->
<form id="pageForm" action="updateExitDates.cfm" method="post">
	<div class="row">
		<div class="small-3 columns">
			<label>Term:<br/>
				<select name="term" id="term" >
					<option disabled selected value="" >
						--Select Term--
					</option>
					<cfoutput query="qryTerms">
					<option  value="#term#" <cfif qryTerms.term EQ qryBillingDates.term>selected</cfif> >#termDescription#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<cfoutput>
		<div class="small-3 columns">
			<label>Term Begin Date:<br/>
				<input name="termBeginDate" id="termBeginDate" type="text"  readonly="true" value="#DateFormat(qryBillingDates.termBeginDate,'mm/dd/yyyy')#"/>
			</label>
		</div>
		<div class="small-3 columns">
			<label>Term End Date:<br/>
				<input name="termEndDate" id="termEndDate" type="text" readonly="true" value="#DateFormat(qryBillingDates.termEndDate,'mm/dd/yyyy')#"/>
			</label>
		</div>
		</cfoutput>
		<div class="small-3 columns"></div>
	</div>
	<div class="row">
		<cfoutput>
		<div class="small-4 columns">
			<label>Attendance Billing Start Date:<br/>
				<input name="billingStartDate" id="billingStartDate" type="text" class="fdatepicker" value="#DateFormat(qryBillingDates.billingStartDate,'mm/dd/yyyy')#"/>
			</label>
		</div>
		<div class="small-4 columns">
			<label>Attendance Billing End Date:<br/>
				<input name="billingEndDate" id="billingEndDate" type="text" class="fdatepicker" value="#DateFormat(qryBillingDates.billingEndDate,'mm/dd/yyyy')#"/>
			</label>
		</div>
		<div class="small-4 columns">
			<label><br/><input class="button" type="submit" name="submit" value="Update Exit Dates" /></label>
		</div>
		</cfoutput>
	</div>
</form>
<!--- end query parameters --->
</div> <!-- end div callout primary -->

<cfif CGI.REQUEST_METHOD EQ "POST">Completed <cfoutput>#DateFormat(Now(),"hh:mm:ss")#</cfoutput></cfif>



<cfsavecontent variable="pcc_scripts">
<script type="text/javascript">
	$(document).ready(function(){
		function setDate(term, displayField, idName){
			selectedTerm = term;
	        var url = 'LookUp.cfc?method=getFilteredTerm&term=' + term + '&displayField='+ displayField + '&ReturnFormat=json';
	        $.ajax({
	            url: url,
	            dataType: 'json',
	            success: function(response){
	            	$('#' + idName).val(response);
	            },
	            error: function(ErrorMsg){
	                console.log('Error');
	            }
	        })
    	}
		 $('body').on('change', '#term', function(e) {
		 	termValue = $('#term').val();
		 	billingStartDate = $('#billingStartDate').val();
		 	sessionStorage.setItem("term",termValue);
		 	saveSessionToServer();
		 	setDate(termValue, 'TermBeginDate', 'termBeginDate');
		 	setDate(termValue, 'TermEndDate', 'TermEndDate');
		 }
	 );
	});

	function saveSessionToServer(){
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  		$.post("SaveSession.cfm", data);
	}
	var serverBillingSetupComplete = 0;


</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">