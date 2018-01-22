<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method = "getProgramYearTerms" returnvariable="terms"></cfinvoke>
<cfinvoke component="ProgramBilling" method="groupBySchoolDistrictAndProgram"  returnvariable="qryData">
	<cfinvokeargument name="term" value="#terms.CurrentTerm#">
	<cfinvokeargument name="billingType" value="#url.type#">
</cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>
<cfinvoke component="LookUp" method="getOpenTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getOpenAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>


<div class="callout primary">
	<div class="row">
		<div class="medium-7 columns">
			<cfoutput>Billing for Program Year: #terms.ProgramYear#</cfoutput>
		</div>
		<div class="medium-2 columns">
			<input class="button" value="Calculate Billing" onClick="javascript:showCalculateBilling();">
		</div>
		<div class="medium-3 columns">
			<input class="button" value="Close Billing Cycle" onClick="javascript:showCloseBillingCycle();">
		</div>
	</div>
</div>

<!-- CLOSE BILLING CYCLE -->
<div class="callout" id="closeBillingCycle">
<form id="frmCloseBillingCycle" action="report.cfc?method=closeBillingCycle" method="post">
	<input type="hidden" name="billingType" id="billingType" value=<cfoutput>"#url.type#"</cfoutput>>
	<div class="row">
		<cfif url.type EQ "attendance">
		<div class="small-3 columns">
			<label for="billingStartDate">Month Start Date:
				<select name="billingStartDate" id="billingStartDate">
					<option disabled selected value="" > --Select Month Start Date-- </option>
				<cfoutput query="billingDates">
					<option value="#billingStartDate#"  > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
				</cfoutput>
				</select>
			</label>
		</div>
		<cfelse>
		<div class="small-3 columns">
			<label>Term:<br/>
				<select name="term" id="term" >
					<option disabled selected value="" >
						--Select Term--
					</option>
					<cfset i = 1>
					<cfoutput query="qryTerms">
					<option  value="#term#" <cfif i EQ 1>selected</cfif>>#termDescription#</option>
					<cfset i = i + 1>
					</cfoutput>
				</select>
			</label>
		</div>
		</cfif>
		<div class="small-6 columns">
			<div id="saveMessagefrmCloseBillingCycle">&nbsp;</div>
			<input class="button" value="Close Billing Cycle" onClick='javascript:saveValues("frmCloseBillingCycle");' />
			<input class="button secondary" value="Cancel" onClick='javascript:closeForm();' />
		</div>
	</div>
</form>
</div>
<!-- END CLOSE BILLING CYCLE -->

<!-- CALCULATE BILLING -->
<div class="callout" id="calculateBilling">
<!--- query parameters --->
<form id="frmCalculateBilling" action="report.cfc?method=calculateBilling" method="post">
	<input type="hidden" name="billingType" id="billingType" value=<cfoutput>"#url.type#"</cfoutput>>
	<div class="row">
		<cfif url.type EQ 'attendance'>
			<div class="small-4 columns">
				<label for="billingStartDate">Month Start Date:
					<select name="billingStartDate" id="billingStartDate">
						<option disabled selected value="" > --Select Month Start Date-- </option>
					<cfoutput query="billingDates">
						<option value="#billingStartDate#"  > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
					</cfoutput>
					</select>
				</label>
			</div>
			<div class="small-3 columns">
				<label># of Max Days for Billing Period: <input name="maxDaysPerBillingPeriod" id="maxDaysPerBillingPeriod" type="text" /></label>
			</div>
		<cfelse>
			<div class="small-2 columns">
				<label>Term:<br/>
					<select name="term" id="term" >
						<option disabled selected value="" >
							--Select Term--
						</option>
					<cfset i = 1>
					<cfoutput query="qryTerms">
					<option  value="#term#" <cfif i EQ 1>selected</cfif>>#termDescription#</option>
					<cfset i = i + 1>
					</cfoutput>
					</select>
				</label>
			</div>
			<div class="small-3 columns">
				<label># of Max Credits Per Term: <input name="maxCreditsPerTerm" id="maxCreditsPerTerm" type="text" value="36"/></label>
			</div>
			<div class="small-2 columns">
				<label># of Max Days Per Year: <input name="maxDaysPerYear" id="maxDaysPerYear" type="text" value="175"/></label>
			</div>
		</cfif>
		<div class="small-5 columns">
			<div id="saveMessagefrmCalculateBilling">&nbsp;</div>
				<input class="button" value="Calculate Billing" onClick='javascript:saveValues("frmCalculateBilling");' />
				<input class="button secondary" value="Cancel" onClick='javascript:closeForm();' />
			</div>
		</div>
	</div>
</form>
</div>
<!-- END CALCULATE BILLING  -->


<div class="row">
       <table id="dt_table" class="hover" cellspacing="0" width="100%">
           <thead>
               <tr>
                <th id="SchoolDistrict">School District</th>
				<th id="Program">Program</th>
				<cfif terms.CurrentTerm GTE terms.Term1><th id="SummerNoOfCredits">Summer</th></cfif>
				<cfif terms.CurrentTerm GTE terms.Term2><th id="FallNoOfCredits">Fall</th></cfif>
				<cfif terms.CurrentTerm GTE terms.Term3><th id="WinterNoOfCredits">Winter</th></cfif>
				<cfif terms.CurrentTerm GTE terms.Term4><th id="SpringNoOfCredits">Spring</th></cfif>
               </tr>
           </thead>
           <tbody>
			<cfif not isNull(qryData)>
               <cfoutput query="qryData">
                   <tr>
                       <td>#schoolDistrict#</td>
					<td>#program#</td>
					<cfif terms.CurrentTerm GTE terms.Term1>
						<td>
							<cfif LEN(SummerAmount) EQ 0>0
							<cfelse>#NumberFormat(SummerAmount,'_')#</cfif>
						</td>
					</cfif>
					<cfif terms.CurrentTerm GTE terms.Term2 >
						<td>
							<cfif LEN(FallAmount) EQ 0>
								<cfif terms.CurrentTerm GTE terms.Term2 AND (LEN(SummerAmount) GT 0 AND LEN(FallAmount) EQ 0) >
									<span style="color:red">0</span>
								<cfelse>
									0
								</cfif>
							<cfelse>
								#NumberFormat(FallAmount,'_')#
							</cfif>
						</td>
					</cfif>
					<cfif terms.CurrentTerm GTE terms.Term3>
						<td>
							<cfif LEN(WinterAmount) EQ 0>
								<cfif terms.CurrentTerm GTE terms.Term3 AND (LEN(FallAmount) GT 0 AND LEN(WinterAmount) EQ 0)>
									<span style="color:red">0</span>
								<cfelse>
									0
								</cfif>
							<cfelse>
								#NumberFormat(WinterAmount,'_')#
							</cfif>
						</td>
					</cfif>
					<cfif terms.CurrentTerm GTE terms.Term4>
						<td>
							<cfif LEN(SpringAmount) EQ 0>
								<cfif terms.CurrentTerm GTE terms.Term4 AND (LEN(WinterAmount) GT 0 AND LEN(SpringAmount) EQ 0)>
									<span style="color:red">0</span>
								<cfelse>
									0
								</cfif>
							<cfelse>
								#NumberFormat(SpringAmount,'_')#
							</cfif>
						</td>
					</cfif>
                   </tr>
               </cfoutput>
			</cfif>
           </tbody>
       </table>
   </div>

<cfsavecontent variable="pcc_scripts">
<script type="text/javascript">
	$(document).ready(function() {
		$('#calculateBilling').hide();
		$('#closeBillingCycle').hide();

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
	});
	function closeForm(){
		$('#calculateBilling').hide();
		$('#closeBillingCycle').hide();
	}
	function goToBillingReport(schooldistrict, program){
		var url = 'ReportTerm.cfm';
		if(program.indexOf('Attendance')>0)
			url = 'ReportAttendance.cfm';
		window.location=url+'?term=<cfoutput>#terms.CurrentTerm#</cfoutput>&schooldistrict='+schooldistrict+'&program='+program
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
	        	var d = new Date();
				$('#saveMessage'+formName).html('Completed  ' + addZero(d.getHours()) + ':' + addZero(d.getMinutes()) + ':' + addZero(d.getSeconds()));
	    	},
			error: function (jqXHR, exception) {
	      		handleAjaxError(jqXHR, exception);
			}
	    });
	}
	/*
	function generateBilling(){
		$.ajax({
			url: 'report.cfc?method=generateBilling',
			async: true,
			type:'post',
			data:{billingType:<cfoutput>'#url.type#', term: '#terms.CurrentTerm#', maxDaysPerMonth: </cfoutput>},
			success:function(){
				alert('Billing Generated');
			},
			error: function (jqXHR, exception) {
				handleAjaxError(jqXHR, exception);
			}
		});
	}*/
	function showCloseBillingCycle(){
		$('#closeBillingCycle').show();
		$('#calculateBilling').hide();
	}
	function showCalculateBilling(){
		$('#calculateBilling').show();
		$('#closeBillingCycle').hide();
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