<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method = "getProgramYear" returnvariable="programYears"></cfinvoke>
<cfinvoke component="LookUp" method = "getProgramYearTerms" returnvariable="terms"></cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>
<cfinvoke component="LookUp" method="getOpenTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getOpenAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>
<cfif url.type EQ 'Term'>
	<cfinvoke component="pcclinks.bill.LookUp" method="getOpenTerms" returnvariable="openTerms"></cfinvoke>
	<cfset openBillingStartDate = openTerms.billingStartDate>
<cfelse>
	<cfinvoke component="pcclinks.bill.LookUp" method="getFirstOpenAttendanceDate" returnvariable="openBillingStartDate"></cfinvoke>
</cfif>
<cfinvoke component="Lookup" method="getCurrentProgramYear" returnvariable="currentProgramYear"></cfinvoke>

<style>
h4{
	margin-top:15px;
}
.nopadding{
	padding-top:0px;
	padding-bottom:0px;
}
</style>

<div class="row">
	<div class="small-12 columns">
		<label for="programYear">Program Year:
			<select name="programyear" id="programYear" >
				<option disabled selected value="" > --Select Program Year-- </option>
			<cfoutput query="programYears">
				<option value="#programYear#" <cfif programYear EQ currentProgramYear>selected</cfif> >#ProgramYear# </option>
			</cfoutput>
			</select>
		</label>
	</div>
</div>
<div class="row">
	<div class="small-6 columns">
			<div class="row">
				<div id="heading" class="small-12 columns"></div>
			</div>
		</div>
	<div class="small-6 columns">
			<div class="row">
				<div class="small-12 columns">
					<h4>Reports</h4>
					<div class="callout secondary">
					<ul class="menu vertical" id="menucontents">

					</ul> <!-- end of menu -->
					</div>
			</div>
		</div>
	</div>
</div>

<!-- CALCULATE BILLING -->
<div class="callout" id="calculateBilling"></div>

<!-- CLOSE BILLING CYCLE -->
<div class="callout" id="closeBillingCycle"></div>

<!-- OPEN BILLING CYCLE -->
<div class="callout" id="openBillingCycle"></div>



<cfsavecontent variable="pcc_scripts">
<script type="text/javascript">
	$(document).ready(function() {
		$('#dt_table').dataTable({
			paging:false,
			searching:false,
			columnDefs:[
                {	targets: 0,
                	render: function ( data, type, row ) {
                  				return '<a href="javascript:goToBillingReport(\'' + row[0] + '\', \'' + row[1] + '\');" >' + row[0] + '</a>';
             				}
         		}
         	]
		});
		refresh();

		$('#programYear').change(function() {
    		refresh(false,'');
		});

	});
	function closeForm(idName){
		$('#' + idName).hide();
	}
	function goToBillingReport(schooldistrict, program){
		var url = 'ReportTerm.cfm';
		if(program.indexOf('Attendance')>0)
			url = 'ReportAttendance.cfm';
		window.location=url+'?programYear=' + $('#programYear').val() + '&type=<cfoutput>#url.type#</cfoutput>&schooldistrict='+schooldistrict+'&program='+program;
		/*sessionStorage.setItem('schooldistrict', schooldistrict);
		sessionStorage.setItem('program', program);
		sessionStorage.setItem('term', <cfoutput>#terms.CurrentTerm#</cfoutput>);
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
		var url = 'ReportTerm.cfm';
		if(program.indexOf('Attendance')>0)
			url = 'ReportAttendance.cfm'
  		$.post("SaveSession.cfm", data, function(){
	  		window.location=url;
  		});*/
	}
	function saveValues(formName){
	 	var $form = $('#'+formName);
	    $.ajax({
	       	url:$form.attr('action'),
	       	type: 'POST',
	       	data: $form.serialize(),
	       	success: function (data, textStatus, jqXHR) {
				refresh(true, formName);
	    	},
			error: function (jqXHR, exception) {
	      		handleAjaxError(jqXHR, exception);
			},
	    });
	}
	function refresh(withSaveMessage, formName){
		$.get('Report.cfc?method=getLastBillingGeneratedMessage&billingType=<cfoutput>#url.type#</cfoutput>&programYear=' + $('#programYear').val(), function(data){
			$('#heading').html(data);
		}).done(function(){
			if(withSaveMessage){
				showSaveMessage(formName);
			}
		});

		$.get('Report.cfc?method=getReportList&billingType=<cfoutput>#url.type#</cfoutput>&programYear=' + $('#programYear').val(), function(data){
			var items = JSON.parse(data).DATA;
			var html = '';
			$.each(items, function(index, value){
				html = html + '<li><a href="javascript:goToBillingReport(\'' + value[0] + '\', \'' + value[1] + '\')">';
				html = html + value[0] + ' - ' + value[1] + '</a></li>';
			});
			$('#menucontents').html(html).foundation();
		});


		$.get('includes/calculateBillingInclude.cfm?type=<cfoutput>#url.type#&openBillingStartDate=#openBillingStartDate#</cfoutput>', function(data){
			$('#calculateBilling').html(data);
		}).done(function(){
			if(withSaveMessage){
				showSaveMessage(formName);
			}
		});
		$.get('includes/closeBillingCycleInclude.cfm?type=<cfoutput>#url.type#&openBillingStartDate=#openBillingStartDate#</cfoutput>', function(data){
			$('#closeBillingCycle').html(data);
		}).done(function(){
			if(withSaveMessage){
				showSaveMessage(formName);
			}
		});
		$.get('includes/openBillingCycleInclude.cfm?type=<cfoutput>#url.type#&openBillingStartDate=#openBillingStartDate#</cfoutput>', function(data){
			$('#openBillingCycle').html(data);
		}).done(function(){
			if(withSaveMessage){
				showSaveMessage(formName);
			}
		});
	}
	function showSaveMessage(formName){
		var d = new Date();
		$('#saveMessage'+formName).html('Completed  ' + addZero(d.getHours()) + ':' + addZero(d.getMinutes()) + ':' + addZero(d.getSeconds()));
	}
	function showForm(idName){
		$('#'+idName).show();
	}
	function closeForm(idName){
		$('#'+idName).hide();
	}

	function addZero($time) {
  		if ($time < 10) {
    		$time = "0" + $time;
  		}
  		return $time;
	}

	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">