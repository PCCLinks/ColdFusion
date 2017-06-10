<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="qryPrograms"></cfinvoke>
<cfinclude template="includes/header.cfm" />
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
</div>
<div  id="progressBar" class="success progress" role="progressbar" tabindex="0" aria-valuenow="0" aria-valuemin="0" aria-valuetext="0 percent" aria-valuemax="100">
  <div class="progress-meter" style="width: 0%">
    <p class="progress-meter-text">0%</p>
  </div>
</div>

<cfsavecontent variable="pcc_scripts">
<script type="text/javascript">
	$(document).ready(function(){
		function setDate(term, displayField, idName){
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
				handleAjaxError(jqXHR, exception);
			}
		});
		showStatus(0, 0);
	}
	function showStatus(percentComplete, waitCount){
		if(serverBillingSetupComplete == 0 && waitCount <= 8){
			percentComplete += 10;
			var p = $('.success progress');
			p.attr('aria-valuenow', percentComplete);
			p.attr('aria-valuetext', percentComplete + ' percent');
			p.attr('aria-valuenow', percentComplete);
			$('.progress-meter').css('width', percentComplete + '%');
			$('.progress-meter-text').text(percentComplete + '%');
			waitCount++;
			setTimeout(function(){showStatus(percentComplete, waitCount);},1000);
		}else if(serverBillingSetupComplete == -1){
		}else{
			window.location="index.cfm";
		}
	}
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">