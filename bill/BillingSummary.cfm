<!DOCTYPE html>
<!---<cfdump var="#Session#">--->
<cfquery datasource="fc" name="maxTermQuery">
		SELECT ProgramQuarter, ProgramYear, maxTerm.Term MaxTerm
		FROM pcc_links.BannerCalendar c
			JOIN (SELECT MAX(Term) Term
				FROM pcc_links.BillingStudent) maxTerm ON c.Term = maxTerm.Term
</cfquery>
<cfinvoke component="ProgramBilling" method="groupBySchoolDistrictAndProgram"  returnvariable="qryData">
	<cfinvokeargument name="term" value="#maxTermQuery.MaxTerm#">
</cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>
<html>
	<head>
		<link rel="stylesheet" href="css/foundation.css">
		<script src="js/vendor/jquery.js"></script>
		<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
		<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.css"/>
	</head>
<body>
<nav class="top-bar" >
    <ul class="menu">
     	 <li><a href="SetUpBilling.cfm">Generate</a></li>
     	 <li><a href="ProgramStudent.cfm">Submit Billing</a></li>
     	 <li><a href="Reconcile.cfm">Reconcile Previous Billing</a></li>
     	 <li><a href="BillingSummary.cfm">Reports</a></li>
	  </ul>
</nav>
<div class="row">
	<div class="callout primary">
		<cfoutput>Billing for Program Year: #maxTermQuery.ProgramYear#</cfoutput>
	</div>
</div>
<div class="row">
       <table id="dt_table" class="hover" cellspacing="0" width="100%">
           <thead>
               <tr>
                <th id="SchoolDistrict">School District</th>
				<th id="Program">Program</th>
				<cfif maxTermQuery.ProgramQuarter GTE 1><th id="SummerNoOfCredits">Summer</th></cfif>
				<cfif maxTermQuery.ProgramQuarter GTE 2><th id="FallNoOfCredits">Fall</th></cfif>
				<cfif maxTermQuery.ProgramQuarter GTE 3><th id="WinterNoOfCredits">Winter</th></cfif>
				<cfif maxTermQuery.ProgramQuarter GTE 4><th id="SpringNoOfCredits">Spring</th></cfif>
               </tr>
           </thead>
           <tbody>
			<cfif not isNull(qryData)>
               <cfoutput query="qryData">
                   <tr>
                       <td>#qryData.schoolDistrict#</td>
					<td>#qryData.program#</td>
					<cfif maxTermQuery.ProgramQuarter GTE 1>
						<td>
							<cfif LEN(qryData.SummerNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(qryData.SummerNoOfCredits,'_')#</cfif>
						</td>
					</cfif>
					<cfif #maxTermQuery.ProgramQuarter# GTE 2 >
						<td>
							<cfif LEN(qryData.FallNoOfCredits) EQ 0>
								<cfif maxTermQuery.ProgramQuarter EQ 2 AND (LEN(qryData.SummerNoOfCredits) GT 0 AND LEN(qryData.FallNoOfCredits) EQ 0) >
									<span style="color:red">0</span>
								<cfelse>
									0
								</cfif>
							<cfelse>
								#NumberFormat(qryData.FallNoOfCredits,'_')#
							</cfif>
						</td>
					</cfif>
					<cfif #maxTermQuery.ProgramQuarter# GTE 3>
						<td>
							<cfif LEN(qryData.WinterNoOfCredits) EQ 0>
								<cfif maxTermQuery.ProgramQuarter EQ 3 AND (LEN(qryData.FallNoOfCredits) GT 0 AND LEN(qryData.WinterNoOfCredits) EQ 0)>
									<span style="color:red">0</span>
								<cfelse>
									0
								</cfif>
							<cfelse>
								#NumberFormat(qryData.WinterNoOfCredits,'_')#
							</cfif>
						</td>
					</cfif>
					<cfif #maxTermQuery.ProgramQuarter# GTE 4>
						<td>
							<cfif LEN(qryData.SpringNoOfCredits) EQ 0>
								<cfif maxTermQuery.ProgramQuarter EQ 4 AND (LEN(qryData.WinterNoOfCredits) GT 0 AND LEN(qryData.SpringNoOfCredits) EQ 0)>
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
</body>
<footer>
	<script type="text/javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
	<script type="text/javascript" src="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.js"></script>
	<script type="text/javascript" charset="utf8" src="js/jquery.blockUI.js"></script>

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
		sessionStorage.setItem('term', <cfoutput>#maxTermQuery.MaxTerm#</cfoutput>);
		saveSessionToServer();
		setTimeout(goToBillingReportPage,10);
	}
	function goToBillingReportPage(){
		window.location = "BillingReport.cfm";
	}
	function saveSessionToServer(){
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  		$.post("SaveSession.cfm", data);
	}
	</script>
</footer>
</html>