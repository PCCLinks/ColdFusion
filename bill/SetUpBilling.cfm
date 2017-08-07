<cfsetting requesttimeout="180">
<cfinclude template="includes/header.cfm" />

<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="qryPrograms"></cfinvoke>

<style>
.progress-meter-text{
	transform:none !important;
	top:auto !important;
}

</style>

<div class="callout primary">

<!--- query parameters --->
<form id="pageForm" action="javascript:setUpBilling();" method="post">
	<div class="row">
		<!---<div class="small-3 columns">
			<label>Program:<br/>
				<select name="program" id="program"/>
					<option disabled selected value="" >
						--Select Program--
					</option>
					<cfoutput query="qryPrograms">
						<option value="#programName#" >#programName#</option>
					</cfoutput>
				</select>
			</label>
		</div> --->
		<div class="small-5 columns">
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
		<cfoutput>
		<div class="small-2 columns">
			<label>Term Begin Date:<br/>
				<input name="termBeginDate" id="termBeginDate" type="text"  readonly="true"/>
			</label>
		</div>
		<div class="small-2 columns">
			<label>Term Drop Date:<br/>
				<input name="termDropDate" id="termDropDate" type="text" readonly="true"/>
			</label>
		</div>
		<div class="small-3 columns">
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
	var selectedTerm;
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
		 	sessionStorage.setItem("term",termValue);
		 	saveSessionToServer();
		 	setDate(termValue, 'TermBeginDate', 'termBeginDate');
		 	setDate(termValue, 'TermDropDate', 'termDropDate');
		 }
	 );
	});
	function saveSessionToServer(){
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  		$.post("SaveSession.cfm", data);
	}
	var serverBillingSetupComplete = 0;
	function setUpBilling(){
		$.ajax({
			url: "SetUpBilling.cfc?method=setUpBilling",
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
			url: "SetUpBilling.cfc?method=getInsertCount&term="+selectedTerm,
			dataType: "json",
			type: "GET",
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
	function showStatus1(percentComplete, waitCount){
		if(serverBillingSetupComplete == 0 && waitCount <= 8){
			percentComplete += 5;
			var p = $('.success progress');
			p.attr('aria-valuenow', percentComplete);
			p.attr('aria-valuetext', percentComplete + ' percent');
			p.attr('aria-valuenow', percentComplete);
			$('.progress-meter').css('width', percentComplete + '%');
			$('.progress-meter-text').text(percentComplete + '%');
			waitCount++;
			setTimeout(function(){showStatus(percentComplete, waitCount);},25000);
		}else if(serverBillingSetupComplete == 0 && waitCount >8){
			jqDef = new $.Deferred(),
        	jqXHR = jqDef.promise();
        	jqXHR.statusText = "Error with SetUpBilling. WaitCount timed out and did not return a success code.";
		}else{
			window.location="index.cfm";
		}
	}
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">