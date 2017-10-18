<!---<cfdump var="#Session#">--->
<cfset programValue="" >
<cfif isDefined("Session.Program") >
	<cfset programValue="#Session.Program#" >
</cfif>
<cfset schooldistrictValue="" >
<cfif isDefined("Session.schooldistrict") >
	<cfset schooldistrictValue="#Session.schooldistrict#" >
</cfif>
<cfset termValue="" >
<cfif isDefined("Session.term") >
	<cfset termValue="#Session.term#" >
</cfif>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>
<cfinvoke component="LookUp" method = "getProgramYearTerms" term="#termValue#" returnvariable="terms"></cfinvoke>

<html>
<head>
 <link rel="stylesheet" href="css/foundation.css">
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.15/css/dataTables.foundation.min.css">
  <script src="js/vendor/modernizr.js"></script>
  <script src="js/vendor/jquery.js"></script>
<script src="https://code.jquery.com/jquery-1.12.4.js"></script>

</head>
<body>
<nav class="top-bar">
    <ul class="menu">
     	 <li><a href="Billing.cfm">Home</a></li>
     	 <li><a href="SetUpBilling.cfm">Generate</a></li>
     	 <li><a href="ProgramStudent.cfm">Submit Billing</a></li>
     	 <li><a href="Reconcile.cfm">Reconcile Previous Billing</a></li>
     	 <li><a href="BillingSummary.cfm">Reports</a></li>
	  </ul>
</nav>
<form action="studentbilling.cfm" method="get">
	<div class="row">
		<div class="small-2 columns">
			<cfoutput><label>Term:
				<input type="text" name="term"  id="term" readonly value="#termValue#"></label></cfoutput>
		</div>
		<div class="small-3 columns">
			<label>Program:
				<select name="program" id="program"/>
					<cfoutput query="programs">
						<option value="#programName#" <cfif programName EQ programValue>selected</cfif> >
							#programName#
						</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<div class="small-2 columns">
			<label>School District:
				<select name="schooldistrict" id="schooldistrict"/>
					<cfoutput query="schools">
						<option  value="#schooldistrict#" <cfif schooldistrict EQ schooldistrictValue>selected</cfif>>
							#schooldistrict#
						</option>
					</cfoutput>
				</select>
			</label>
		</div>
	</div>
</form>
<cfoutput>
	<div class="row">
        <table id="dt_table" class="hover" cellspacing="0" width="100%">
            <thead>
                <tr id="headerRow">
                    <th id="bannerGNumber">G</th>
                    <th id="FIRSTNAME">First name</th>
                    <th id="LASTNAME">Last name</th>
                    <th id="CurrentSchoolDistrict">Current School District</th>
                    <th id="CurrentEnrolledDate">Current Enrolled Date</th>
					<th id="CurrentExitDate">Current Exit Date</th>
					<th id="CurrentProgram">Current Program</th>
					<th id="SummerNoOfCredits">Summer</th>
					<cfif #termValue# GTE #terms.term2#><th id="FallNoOfCredits">Fall</th></cfif>
					<cfif #termValue# GTE #terms.term3#><th id="WinterNoOfCredits">Winter</th></cfif>
					<cfif #termValue# GTE #terms.term4#><th id="SpringNoOfCredits">Spring</th></cfif>
                </tr>
            </thead>
            <tbody>
				<cfif not isNull(qryData)>
                	<cfloop query="qryData">
                    <tr>
                        <td>#bannerGNumber#</td>
                        <td>#FIRSTNAME#</td>
                        <td>#LASTNAME#</td>
                        <td>#CurrentSchoolDistrict#</td>
                        <td>#CurrentEnrolledDate#</td>
						<td>#CurrentExitDate#</td>
						<td>#CurrentProgram#</td>
						<td>
							<cfif LEN(SummerNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(SummerNoOfCredits,'_')#
							</cfif>
						</td>
						<cfif #termValue# GTE #terms.term2#>
						<td>
							<cfif LEN(FallNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(FallNoOfCredits,'_')#</cfif>
						</td>
						</cfif>
						<cfif #termValue# GTE #terms.term3#>
						<td>
							<cfif LEN(WinterNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(WinterNoOfCredits,'_')#</cfif>
						</td>
						</cfif>
						<cfif #termValue# GTE #terms.term4#>
						<td>
							<cfif LEN(SpringNoOfCredits) EQ 0>0
							<cfelse>#NumberFormat(SpringNoOfCredits,'_')#</cfif>
						</td>
						</cfif>
                    </tr>
                	</cfloop>
				</cfif>
            </tbody>
        </table>
    </div>
</cfoutput>
</body>
<footer>
<script type="text/javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
	<script type="text/javascript" src="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.js"></script>
	<script type="text/javascript" charset="utf8" src="js/jquery.blockUI.js"></script>
	<script>
		$(document).ready(function() {
			$.fn.dataTable.ext.errMode = 'throw';
			setUpTableData();
			$('#program').change(function(){
				sessionStorage.setItem("program",$('#program').val());
				saveSessionToServer();
				$('#dt_table').DataTable().ajax.reload();
			});
			$('#schooldistrict').change(function(){
				sessionStorage.setItem("schooldistrict",$('#schooldistrict').val());
				saveSessionToServer();
				$('#dt_table').DataTable().ajax.reload();
			});
		});
		function saveSessionToServer(){
			var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  			$.post("SaveSession.cfm", data);
		}

		function setUpTable(){
			$('#dt_table').DataTable({
				processing:true,
				ajax:{
					url:"programbilling.cfc?method=selectprogramstudentlist",
					data: { term: '<cfoutput>#termValue#</cfoutput>', program: $('#program').val(), schooldistrict: $('#schooldistrict').val()},
					dataSrc:'DATA',
					error: function (xhr, textStatus, thrownError) {
					        handleAjaxError(xhr, textStatus, thrownError);
						}
				},
				language:{ processing: "Loading data..."},
				bSortClasses: false
			});
		}


	function goToDetail(pidm, maxterm, contactid){
		sessionStorage.setItem("bannerGNumber", bannerGNumber);
		sessionStorage.setItem("selectedTerm", term);
		saveSessionToServer();
		var url = 'StudentBillingDetail.cfm';
		var form = $('<form action="' + url + '" method="post">' +
 				'<input type="hidden" name="bannerGNumber" value="' + bannerGNumber + '" />' +
 				'<input type="hidden" name="selectedTerm" value="' + selectedTerm + '" />' +
  				'</form>');
		$('body').append(form);
		form.submit();
	}

	</script>
</footer>
</html>