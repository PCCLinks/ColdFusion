<!DOCTYPE html>
<!---<cfdump var="#Session#">--->
<cfif IsDefined("Session.Term")>
	<cfset varMaxTerm = Session.Term>
<cfelse>
	<cfquery datasource="fc" name="maxTermQuery">
		SELECT MAX(Term) Term
		FROM pcc_links.BillingStudent
	</cfquery>
	<cfset varMaxTerm = maxTermQuery.Term>
	<cfset Session.Term = varMaxTerm>
</cfif>
<cfset varProgram = "">
<cfif IsDefined("Session.Program")>
	<cfif LEN(Session.Program) GT 0 >
		<cfset varProgram = Session.Program>
	</cfif>
</cfif>
<cfswitch expression="#right(varMaxTerm, 1)#">
	<cfcase value="4">
		<cfset maxquarter=2>
	</cfcase>
	<cfcase value="1">
		<cfset maxquarter=3>
	</cfcase>
	<cfcase value="2">
		<cfset maxquarter=4>
	</cfcase>
	<cfdefaultcase>
		<cfset maxquarter=1>
	</cfdefaultcase>
</cfswitch>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs">
</cfinvoke>

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
     	 <li><a href="Billing.cfm">Home</a></li>
     	 <li><a href="SetUpBilling.cfm">Generate</a></li>
     	 <li><a href="ProgramStudent.cfm">Submit Billing</a></li>
     	 <li><a href="Reconcile.cfm">Reconcile Previous Billing</a></li>
     	 <li><a href="BillingSummary.cfm">Reports</a></li>
	  </ul>
</nav>
		<div class="row">

				<div class="small-2 columns">
					<cfoutput>
						<label>
							Term:
							<input type="text" name="term"  id="term" readonly value="#varMaxTerm#">
						</label>
					</cfoutput>
				</div>
				<div class="small-3 columns">
					<label>
						Program:
						<select name="program" id="program">
							<option disabled <cfif varProgram EQ "">selected</cfif> value="" >
								--Select Program--
							</option>
							<cfoutput query="programs">
								<option value="#programName#" <cfif varProgram EQ #programName#>selected</cfif>>
									#programName#
								</option>
							</cfoutput>
						</select>
					</label>
				</div>
				<div class="small-7 columns"></div>
			<cfoutput>

		</div>
		<div class="row"> <div class="small-12 columns">
			<table id="dt_table" class="hover" cellspacing="0" width="100%">
			<thead>
				 <tr id="headerRow">
				 	<th id="bannerGNumber">G</th>
				 	<th id="LASTNAME">Last name</th>
				 	<th id="currentSchoolDistrict">Current School District</th>
				 	<th id="CurrentEnrolledDate">Current Enrolled Date</th>
				 	<th id="CurrentExitDate">Current Exit Date</th>
				 	<th id="CurrentProgram" >Current Program</th>
				 	<th id="FYTotalNoOfCredits">FY Total Credits</th>
				 	<th id="CurrentTermNoOfCredits">Current Term Credits</th>
				 	<th id="BillingStatus">Billing Status</th>
				 </tr>
				 <tr id="searchRow">
				 	<th><input type="text" placeholder='G' /></th>
				 	<th><input type="text" placeholder='Last name' /></th>
				 	<th><input type="text" placeholder='Current School District' /></th>
				 	<th><input type="text" placeholder='Current Enrolled Date' /></th>
				 	<th><input type="text" placeholder='Current Exit Date' /></th>
				 	<th><input type="text" placeholder='Current Program' /></th>
				 	<th><input type="text" placeholder='FY Total Credits' /></th>
				 	<th><input type="text" placeholder='Current Term Credits' /></th>
				 	<th><input type="text" placeholder='Billing Status'/></th>
				 </tr>
			</thead>
			 <tbody>
			 <cfif not isNull(qryData)>
			 	<cfloop query="qryData">
				<tr>
					<td>#qryData.bannerGNumber#</td>
					<td>#qryData.LASTNAME#</td>
					<td>#qryData.currentSchoolDistrict#</td>
					<td>#qryData.CurrentEnrolledDate#</td>
					<td>#qryData.CurrentExitDate#</td>
					<td>#qryData.CurrentProgram#</td>
					<td>#qryData.FYTotalNoOfCredits#</td>
					<td>#qryData.CurrentTermNoOfCredits#</td>
					<td>#qryData.BillingStatus#</td>
				 </tr>
			 </cfloop>
		 </cfif>
	</tbody>
</table>
</div></div>
</body>
</cfoutput>

<footer>
	<script type="text/javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
	<script type="text/javascript" src="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.js"></script>
	<script type="text/javascript" charset="utf8" src="js/jquery.blockUI.js"></script>
	<script>
		$(document).ready(function() {
			<cfif len(#varProgram#) GT 0>
			getData();
			</cfif>
			$('#program').change(function(){
				sessionStorage.setItem("program",$('#program').val());
				saveSessionToServer();
				setTimeout(getData, 10);
			});
		});
		function saveSessionToServer(){
			var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  			$.post("SaveSession.cfm", data);
		}
		function getData(){
			var cols = $('#headerRow th');
			var colnames = [];
			$.each(cols, function() {
				colnames.push(this.id);
			});
			$.ajax({
				url: "programbilling.cfc?method=selectprogramstudentlist",
					dataType: "json",
					type: "POST",
					async: false,
					data: { term: '<cfoutput>#varMaxterm#</cfoutput>', program: $('#program').val(), columns: JSON.stringify(colnames)},
					success: function(data) {
						setUpTable(data);
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
		}
		function setUpTable(data){
			$('#dt_table').dataTable({
				destroy: true,
				lengthMenu: [[100, 50, -1], [100, 50, "All"]],
				bSortClasses: false,
				columnDefs:[
	                {	targets: 0,
	                	render: function ( data, type, row ) {
                  				return '<a href="javascript:goToDetail(\'' + row[0] + '\');" >' + row[0] + '</a>';
             					}
         					}
         				],
				data: data.DATA
			});
			table = $('#dt_table').DataTable();
			// Apply the search
			table.columns().every( function () {
				var that = this;
				$( 'input', this.header() ).on( 'keyup change', function () {
					if (that.search() !== this.value ) {
							that.search( this.value ).draw();
					}
				});
			});
		}

		function goToDetail(bannerGNumber){
			var dt = $('#dt_table').DataTable();
			var list = dt.columns({search:'applied'}).data()[0];
			sessionStorage.setItem("bannerGNumber", bannerGNumber);
			sessionStorage.setItem("gList", list);
			saveSessionToServer();
			setTimeout(goToDetailPage,20);
		}
		function goToDetailPage(){
			window.location('ProgramStudentDetail.cfm');
		}
	</script>
</footer>

</html>
