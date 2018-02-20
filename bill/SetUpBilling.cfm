<cfsetting requesttimeout="180">
<cfinclude template="includes/header.cfm" />

<cfinvoke component="LookUp" method="getCurrentYearTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getNextTermToBill" returnvariable="nextTerm"></cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="qryPrograms"></cfinvoke>

<style>
.progress-meter-text{
	transform:none !important;
	top:auto !important;
}

</style>

<div class="callout primary">
<h4><cfoutput>Set Up #url.type# Billing</h4></cfoutput>
<!--- query parameters --->
<form id="pageForm" action="javascript:setUpBilling();" >
	<cfoutput><input type="hidden" name="type" value="#url.type#"></cfoutput>
	<div class="row">
		<div class="small-3 columns">
			<label>Term:<br/>
				<select name="term" id="term" >
					<option disabled value="" >
						--Select Term--
					</option>
					<cfoutput query="qryTerms">
					<option  value="#term#" <cfif qryTerms.term EQ nextTerm.term>selected</cfif> >#termDescription#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<cfoutput>
		<div class="small-3 columns">
			<label>Term Begin Date:<br/>
				<input name="termBeginDate" id="termBeginDate" type="text"  readonly="true" value="#DateFormat(nextTerm.termBeginDate,'mm/dd/yyyy')#"/>
			</label>
		</div>
		<div class="small-3 columns">
			<label>Term Drop Date:<br/>
				<input name="termDropDate" id="termDropDate" type="text" readonly="true" value="#DateFormat(nextTerm.termDropDate,'mm/dd/yyyy')#"/>
			</label>
		</div>
		<div class="small-3 columns">
			<label>Term End Date:<br/>
				<input name="termEndDate" id="termEndDate" type="text" readonly="true" value="#DateFormat(nextTerm.termEndDate, 'mm/dd/yyyy')#"/>
			</label>
		</div>
		</cfoutput>
	</div>
	<div class="row">
		<cfoutput>
		<div class="small-4 columns">
			<label>Billing Start Date:<br/>
				<input name="billingStartDate" id="billingStartDate" type="text" class="fdatepicker" <cfif url.type EQ 'Term'>value="#DateFormat(nextTerm.termBeginDate,'mm/dd/yyyy')#" </cfif>/>
			</label>
		</div>
		<div class="small-4 columns">
			<label>Billing End Date:<br/>
				<input name="billingEndDate" id="billingEndDate" type="text" class="fdatepicker" <cfif url.type EQ 'Term'>value="#DateFormat(DateAdd("d",-2, nextTerm.termEndDate),'mm/dd/yyyy')#"</cfif> />
			</label>
		</div>
		<div class="small-4 columns">
			<label><br/><input class="button" type="submit" name="submit" value="Generate Billing" /></label>
		</div>
		</cfoutput>
	</div>
</form>
<!--- end query parameters --->
</div> <!-- end div callout primary -->

<!-- progress bar -->
<div class="success progress" role="progressbar" tabindex="0" aria-valuenow="0" aria-valuemin="0" aria-valuetext="0 percent" aria-valuemax="500">
  <span class="progress-meter" style="width: 0%">
    <p class="progress-meter-text">0%</p>
  </span>
</div>


<cfsavecontent variable="pcc_scripts">
<script type="text/javascript">
	$(document).ready(function(){
		selectedTerm = <cfoutput>#nextTerm.term#</cfoutput>;
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
		 	setDate(termValue, 'TermDropDate', 'termDropDate');
		 	setDate(termValue, 'TermEndDate', 'termEndDate');
		 	$('#billingStartDate').val('');
		 	$('#billingEndDate').val('');
		 }
	 );
	});

	function saveSessionToServer(){
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  		$.post("SaveSession.cfm", data);
	}
	var serverBillingSetupComplete = 0;
	function setUpBilling(){
		var urlValue = '<cfoutput><cfif url.type EQ 'Term'>SetUpBilling.cfc?method=setUpBilling<cfelse>SetUpBilling.cfc?method=setUpMonthlyBilling</cfif></cfoutput>';
		$.ajax({
			url: urlValue,
			dataType: "json",
			type: "POST",
			async: true,
			data: $('#pageForm').serialize(),
			success:function(data){
				serverBillingSetupComplete = data;
			},
			error: function (jqXHR, exception) {
				//alert('Error');
				handleAjaxError(jqXHR, exception);
			}
		});
		showStatus(0, 0);
	}
	function getCount(){
		var currentCount = 0;
		$.ajax({
			url: "SetUpBilling.cfc?method=getInsertCount&term="+selectedTerm + '&billingStartDate=' + $('#billingStartDate').val(),
			dataType: "json",
			type: "GET",
			cache:false,
			async: false,
			success:function(data){
				currentCount = data;
			},
			error: function (jqXHR, exception) {
				//alert('Error');
				handleAjaxError(jqXHR, exception);
			}
		});
		return currentCount;
	}
	function showStatus(){
		if(serverBillingSetupComplete == 0){
			numberComplete = getCount();
			var p = $('.success progress');
			p.attr('aria-valuenow', numberComplete);
			if(numberComplete == 0){
				p.attr('aria-valuetext', '........getting banner data......this can take 2-3 minutes....');
				$('.progress-meter-text').text('........getting banner data......this can take 2-3 minutes....');
				$('.progress-meter').css('width', 100);
			}else{
				p.attr('aria-valuetext', numberComplete + ' processed');
				$('.progress-meter').css('width', (numberComplete/500)*100 + '%');
				$('.progress-meter-text').text('........' + numberComplete + ' processed out of an estimated 500......');
			}
			setTimeout(function(){showStatus();},10000);
		}else if(serverBillingSetupComplete != 1){
			jqDef = new $.Deferred(),
        	jqXHR = jqDef.promise();
        	jqXHR.statusText = "Error with SetUpBilling.";
		}else{
			window.location="index.cfm";
		}
	}

</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">