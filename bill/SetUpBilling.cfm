<cfsetting requesttimeout="180">
<cfinclude template="includes/header.cfm" />

<cfinvoke component="LookUp" method="getCurrentYearTerms" returnvariable="qryTerms"></cfinvoke>
<cfif url.type EQ 'Term'>
	<cfinvoke component="LookUp" method="getNextTermToBill" returnvariable="termToBill"></cfinvoke>
	<cfset billingStartDate = ''>
<cfelse>
	<cfinvoke component="LookUp" method="getNextAttendanceDatesToBill" returnvariable="attendanceData"></cfinvoke>
	<cfset termToBill = attendanceData.Term>
	<cfset billingStartDate = attendanceData.billingStartDate>
</cfif>
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
	<cfoutput><input type="hidden" name="billingType" value="#url.type#"></cfoutput>
	<div class="row">
		<div class="small-3 columns">
			<label>Term:<br/>
				<select name="term" id="term" >
					<option disabled value="" >
						--Select Term--
					</option>
					<cfoutput query="qryTerms">
					<option  value="#term#" <cfif qryTerms.term EQ termToBill>selected</cfif> >#termDescription#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<cfoutput>
		<div class="small-3 columns">
			<label>Term Begin Date:<br/>
				<input name="termBeginDate" id="termBeginDate" type="text"  readonly="true" />
			</label>
		</div>
		<div class="small-3 columns">
			<label>Term End Date:<br/>
				<input name="termEndDate" id="termEndDate" type="text" readonly="true" />
			</label>
		</div>
		<div class="small-3 columns">
			<label>Term Drop Date:<br/>
				<input name="termDropDate" id="termDropDate" type="text" readonly="true" />
			</label>
		</div>
		</cfoutput>
	</div>
	<div class="row">
		<div class="small-3 columns">
			<label>Billing Start Date:<br/>
				<input name="billingStartDate" id="billingStartDate" type="text" class="fdatepicker" />
			</label>
		</div>
		<div class="small-3 columns">
			<label>Billing End Date:<br/>
				<input name="billingEndDate" id="billingEndDate" type="text" class="fdatepicker"/>
			</label>
		</div>
		<div class="small-6 columns"></div>
	</div>
	<div class="row">
	<cfif url.type EQ 'Term'>
		<cfoutput>
		<div class="small-3 columns">
			<label>## of Max Credits Per Year: <input name="maxBillableCreditsPerTerm" id="maxBillableCreditsPerTerm" type="text" value="36"/></label>
		</div>
		<div class="small-3 columns">
			<label>## of Max Days Per Year: <input name="maxBillableDaysPerYear" id="maxBillableDaysPerYear" type="text" value="175"/></label>
		</div>
		</cfoutput>
	<cfelse>
		<div class="small-3 columns">
			<label># of Billable Days for the Month:
				<input name="MaxBillableDaysPerBillingPeriod" id="MaxBillableDaysPerBillingPeriod" type="text"  />
			</label>
		</div>
		<div class="small-3 columns" style="margin-top:25px">
				<input class="button" onclick="javascript:setBillableDays()" value="Set Billable Days" style="background-color:gray" >
		</div>
	</cfif>
		<div class="small-3 columns" style="margin-top:25px">
			<input class="button" type="submit" name="submit" value="<< Generate Billing >>" />
		</div>
		<div class="small-3 columns"></div>
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

<div id="billabledays" style="display:none"></div>
<cfsavecontent variable="pcc_scripts">
<script type="text/javascript">
	var billingType;
	$(document).ready(function(){
		<cfoutput>
		billingType = '#url.type#';
		if(billingType == 'Term'){
			setTermDates('#termToBill#');
		}else{
			setAttendanceDates('#termToBill#','#billingStartDate#');
		}
		</cfoutput>

		 $('#term').on('change', function(e) {
			 	if(billingType == 'Term'){
			 		setTermDates($('#term').val());
			 	}else{
			 		setAttendanceDates($('#term').val(),'');
			 	}
		 	}
	 	);
	});

	function setTermDates(term){
        var url = 'LookUp.cfc?method=getBannerCalendarEntry&term=' + term;
        $.ajax({
            url: url,
            dataType: 'json',
            success: function(termData){
            	$.each(termData.COLUMNS, function(index, col){
            		v = termData.DATA[0][index];
            		switch(col){
            			case "TERMBEGINDATE":
            				$("#termBeginDate").val(v);
            				$("#billingStartDate").val(v);
            				break;
            			case "TERMENDDATE":
            				$("#termEndDate").val(v);
            				$("#billingEndDate").val(v);
            				break;
            			case "TERMDROPDATE":
            				$("#termDropDate").val(v);
            				break;
            		}
            	});
            },
            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
			}
        })
   	}
   	function setAttendanceDates(term, billingStartDate){
		selectedTerm = term;
        var url = 'LookUp.cfc?method=getAttendanceDatesToBill&term=' + term;
        if(billingStartDate.length > 0){
        	url = url  + '&billingStartDate=' + billingStartDate;
        }
        $.ajax({
            url: url,
            dataType: 'json',
            success: function(termData){
            	$.each(termData.COLUMNS, function(index, col){
            		v = termData.DATA[0][index];
            		switch(col){
            			case "TERMBEGINDATE":
            				$("#termBeginDate").val(v);
            				break;
            			case "TERMENDDATE":
            				$("#termEndDate").val(v);
            				break;
            			case "TERMDROPDATE":
            				$("#termDropDate").val(v);
            				break;
            			case "NEXTBEGINDATE":
            				$("#billingStartDate").val(v);
            				break;
            			case "NEXTENDDATE":
            				$("#billingEndDate").val(v);
            				break;
            			case "MAXBILLABLEDAYSPERBILLINGPERIOD":
            				$("#MaxBillableDaysPerBillingPeriod").val(v);
            				break;
            		}
            	});
            },
            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
			}
        })
   	}
	function setBillableDays(){
		if($('#billingStartDate').val() === "" || $('#billingEndDate').val()=== ""){
			alert("Please first select billing start and end dates.");
		}else{
			$.get('includes/billableDaysInclude.cfm?billingStartDate=' + $('#billingStartDate').val() + '&billingEndDate=' + $('#billingEndDate').val(), function(data){
				$('#billabledays').html(data);
			}).done(function(){
				buildCalendar(saveBillableDays);
				$('#billabledays').css("display", "block");
			})
		}
	}
	function saveBillableDays(numDays){
		$('#MaxBillableDaysPerBillingPeriod').val(numDays);
		$('#billabledays').css("display", "none");
	}
	var serverBillingSetupComplete = 0;
	function setUpBilling(){
		var urlValue = 'SetUpBilling.cfc?method=<cfoutput><cfif url.type EQ 'Term'>setUpTermBilling<cfelse>setUpMonthlyAttendanceBilling</cfif></cfoutput>';
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
				handleAjaxError(jqXHR, exception);
			}
		});
		showStatus(0, 0);
	}

	function showStatus(){
		var numberComplete = 0;
		if(serverBillingSetupComplete == 0){
			$.get('SetUpBilling.cfc?method=getInsertCount',function(data){
				numberComplete = data;
			}).done(function(){
				var p = $('.success progress');
				p.attr('aria-valuenow', numberComplete);
				if(numberComplete == 0){
					p.attr('aria-valuetext', '........getting banner data......this can take 2-3 minutes....');
					$('.progress-meter-text').text('........getting banner data......this can take 2-3 minutes....');
					$('.progress-meter').css('width', 100);
				}else{
					p.attr('aria-valuetext', numberComplete + ' processed');
					$('.progress-meter').css('width', (numberComplete/500)*100 + '%');
					$('.progress-meter-text').text('........' + numberComplete + ' processed......');
				}
				setTimeout(function(){showStatus();},10000);
			});
		}else{
			if(serverBillingSetupComplete != 1){
				jqDef = new $.Deferred(),
				jqXHR = jqDef.promise();
	        	jqXHR.statusText = "Error with SetUpBilling.";
			}else{
				window.location=<cfoutput>"index.cfm?Type=#url.type#";</cfoutput>
			}
		}
	}

</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">