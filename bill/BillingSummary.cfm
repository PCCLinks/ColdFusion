<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method = "getProgramYearTerms" returnvariable="terms"></cfinvoke>
<cfinvoke component="ProgramBilling" method="groupBySchoolDistrictAndProgram"  returnvariable="qryData">
	<cfinvokeargument name="term" value="#terms.CurrentTerm#">
</cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>


<div class="row">
	<div class="callout primary">
		<cfoutput>Billing for Program Year: #terms.ProgramYear#</cfoutput>
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
                       <td>#qryData.schoolDistrict#</td>
					<td>#qryData.program#</td>
					<cfif terms.CurrentTerm GTE terms.Term1>
						<td>
							<cfif LEN(qryData.SummerNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(qryData.SummerNoOfCredits,'_')#</cfif>
						</td>
					</cfif>
					<cfif terms.CurrentTerm GTE terms.Term2 >
						<td>
							<cfif LEN(qryData.FallNoOfCredits) EQ 0>
								<cfif terms.CurrentTerm GTE terms.Term2 AND (LEN(qryData.SummerNoOfCredits) GT 0 AND LEN(qryData.FallNoOfCredits) EQ 0) >
									<span style="color:red">0</span>
								<cfelse>
									0
								</cfif>
							<cfelse>
								#NumberFormat(qryData.FallNoOfCredits,'_')#
							</cfif>
						</td>
					</cfif>
					<cfif terms.CurrentTerm GTE terms.Term3>
						<td>
							<cfif LEN(qryData.WinterNoOfCredits) EQ 0>
								<cfif terms.CurrentTerm GTE terms.Term3 AND (LEN(qryData.FallNoOfCredits) GT 0 AND LEN(qryData.WinterNoOfCredits) EQ 0)>
									<span style="color:red">0</span>
								<cfelse>
									0
								</cfif>
							<cfelse>
								#NumberFormat(qryData.WinterNoOfCredits,'_')#
							</cfif>
						</td>
					</cfif>
					<cfif terms.CurrentTerm GTE terms.Term4>
						<td>
							<cfif LEN(qryData.SpringNoOfCredits) EQ 0>
								<cfif terms.CurrentTerm GTE terms.Term4 AND (LEN(qryData.WinterNoOfCredits) GT 0 AND LEN(qryData.SpringNoOfCredits) EQ 0)>
									<span style="color:red">0</span>
								<cfelse>
									0
								</cfif>
							<cfelse>
								#NumberFormat(qryData.SpringNoOfCredits,'_')#
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
  		$.post("SaveSession.cfm", data, function(){
	  		window.location='BillingReport.cfm'
  		});
	}

	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">