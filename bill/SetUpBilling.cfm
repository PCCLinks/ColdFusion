<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="qryPrograms"></cfinvoke>
<html>
<head>
 <link rel="stylesheet" href="css/foundation.css">
  <script src="js/vendor/modernizr.js"></script>
  <script src="js/vendor/jquery.js"></script>
</head>
<body>
<nav class="top-bar" >
    <ul class="menu">
     	 <li><a href="Billing.cfm">Home</a></li>
     	 <li><a href="SetUpBilling.cfm">Generate</a></li>
     	 <li><a href="ProgramStudent.cfm">Submit Billing</a></li>
     	 <li><a href="Reconcile.cfm">Reconcile Previous Billing</a></li>
     	 <li><a href="BillingSummary.cfm">Reports</a></li>
	  </ul>
</nav>
<div class="callout primary">
<form id="pageForm" action="javascript:setUpBilling();" method="post">
	<div class="row">
		<div class="small-3 columns">
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
		</div>
		<div class="small-2 columns">
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
</div>
<div  id="progressBar" class="success progress" role="progressbar" tabindex="0" aria-valuenow="0" aria-valuemin="0" aria-valuetext="0 percent" aria-valuemax="100">
  <div class="progress-meter" style="width: 0%">
    <p class="progress-meter-text">0%</p>
  </div>
</div>

</body>
<footer>
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
		        var msg = '';
		        if (jqXHR.status === 0) {
		            msg = 'Not connect.\n Verify Network.';
		        } else if (jqXHR.status == 404) {
		            msg = 'Requested page not found. [404]';
		        } else if (jqXHR.status == 500) {
		            msg = 'Internal Server Error [500].';
		        } else if (exception === 'parsererror') {
		            msg = 'Requested JSON parse failed.';
		        } else if (exception === 'timeout') {
		            msg = 'Time out error.';
		        } else if (exception === 'abort') {
		            msg = 'Ajax request aborted.';
		        } else {
		            msg = 'Uncaught Error.\n' + jqXHR.responseText;
		        }
		        alert(msg);
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
		}else{
			window.location="Billing.cfm";
		}
	}
</script>
</footer>
</html>