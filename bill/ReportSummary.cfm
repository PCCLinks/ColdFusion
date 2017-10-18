<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method = "getProgramYearTerms" returnvariable="terms"></cfinvoke>
<cfinvoke component="ProgramBilling" method="groupBySchoolDistrictAndProgram"  returnvariable="qryData">
	<cfinvokeargument name="term" value="#terms.CurrentTerm#">
	<cfinvokeargument name="billingType" value="#url.type#">
</cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>



<div class="callout primary">
	<div class="row">
		<div class="medium-7 columns">
			<cfoutput>Billing for Program Year: #terms.ProgramYear#</cfoutput>
		</div>
		<div class="medium-2 columns">
			<input class="button" value="Generate Billing" onClick="javascript:generateBilling();">
		</div>
		<div class="medium-3 columns">
			<input class="button" value="Close Billing Cycle" onClick="javascript:closeBillingCycle();">
		</div>
	</div>
</div>


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
	<script>
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
	});
	function goToBillingReport(schooldistrict, program){
		sessionStorage.setItem('schooldistrict', schooldistrict);
		sessionStorage.setItem('program', program);
		sessionStorage.setItem('term', <cfoutput>#terms.CurrentTerm#</cfoutput>);
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
		var url = 'ReportTerm.cfm';
		if(program.indexOf('Attendance')>0)
			url = 'ReportAttendance.cfm'
  		$.post("SaveSession.cfm", data, function(){
	  		window.location=url;
  		});
	}
	function generateBilling(){
		$.ajax({
			url: 'report.cfc?method=generateBilling',
			async: true,
			type:'post',
			data:{billingType:<cfoutput>'#url.type#', term: '#terms.CurrentTerm#'</cfoutput>},
			success:function(){
				alert('Billing Generated');
			},
			error: function (jqXHR, exception) {
				handleAjaxError(jqXHR, exception);
			}
		});
	}
	function closeBillingCycle(){
		window.open('CloseBillingCycle.cfm?type=<cfoutput>#url.type#</cfoutput>', '_blank');
	}

	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">