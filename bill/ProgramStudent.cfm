<cfinclude template="includes/header.cfm" />

<!--- If not passed in, get the last term in the data --->
<cfif structKeyExists(Session, "Term")>
	<cfset Variables.MaxTerm = Session.Term>
<cfelse>
	<cfquery name="maxTermQuery">
		SELECT MAX(Term) Term
		FROM billingStudent
	</cfquery>
	<cfset Variables.MaxTerm = maxTermQuery.Term>
	<cfset Session.Term = maxTermQuery.Term>
</cfif>

<!--- Program --->
<cfset Variables.Program = "">
<cfif structKeyExists(Session, "Program")>
	<cfset  Variables.Program = Session.Program>
</cfif>

<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>

<!-- Filter -->
<div class="row">
	<div class="small-2 columns">
		<cfoutput>
			<label for="Term">Term:
				<input type="text" name="term" id="term" readonly value="#Variables.MaxTerm#" />
			</label>
		</cfoutput>
	</div>
	<div class="small-3 columns">
		<label for="Program">Program:
			<select name="program" id="program">
				<option disabled <cfif Variables.Program EQ ""> selected </cfif> value="" > --Select Program-- </option>
				<cfoutput query="programs">
					<option value="#programName#" <cfif Variables.Program EQ #programName#> selected </cfif> > #programName# </option>
				</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-7 columns">
	</div>
</div> <!-- end Filter row -->

<div class="row">
	<div class="small-12 columns">
		<table id="dt_table" class="hover" cellspacing="0" width="100%">
			<caption class="visually-hide">"Program data"</caption>
			<thead>
				<tr id="headerRow">
					<th id="bannerGNumber">G</th>
					<th id="LASTNAME">Last name</th>
					<th id="currentSchoolDistrict">Current School District</th>
					<th id="CurrentEnrolledDate">Current Enrolled Date</th>
					<th id="CurrentExitDate">Current Exit Date</th>
					<th id="CurrentProgram">Current Program</th>
					<th id="FYTotalNoOfCredits">FY Total Credits</th>
					<th id="CurrentTermNoOfCredits">Current Term Credits</th>
					<th id="BillingStatus">Billing Status</th>
				</tr>
				<tr id="searchRow">
					<th><input type="text" placeholder="G" /></th>
					<th><input type="text" placeholder="Last name" /></th>
					<th><input type="text" placeholder="Current School District" /></th>
					<th><input type="text" placeholder="Current Enrolled Date" /></th>
					<th><input type="text" placeholder="Current Exit Date" /></th>
					<th><input type="text" placeholder="Current Program" /></th>
					<th><input type="text" placeholder="FY Total Credits" /></th>
					<th><input type="text" placeholder="Current Term Credits" /></th>
					<th><input type="text" placeholder="Billing Status" /></th>
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
	</div>
</div>

<cfsavecontent variable="pcc_scripts">
	<script>
		$(document).ready(function() {
			<cfif len(#Variables.Program#) GT 0>
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
			$.blockUI({ message: '<h1>Just a moment...</h1>' });
			$.ajax({
				url: "programbilling.cfc?method=selectprogramstudentlist",
					dataType: "json",
					type: "POST",
					async: false,
					data: { term: '<cfoutput>#Variables.Maxterm#</cfoutput>', program: $('#program').val(), columns: JSON.stringify(colnames)},
					success: function(data) {
						setUpTable(data);
					},
					error: function (jqXHR, exception) {
				        handleAjaxError(jqXHR, exception);
					}
			});
			$.unblockUI();
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
			var gList = dt.columns({search:'applied'}).data()[0];
			var url = 'saveSession.cfm';
			var form = $('<form action="' + url + '" method="post">' +
  				'<input type="text" name="bannerGNumber" value="' + bannerGNumber + '" />' +
  				'<input type="text" name="gList" value=' +  JSON.stringify(gList) + '/>' +
  				'<input type="text" name="location" value="ProgramStudentDetail.cfm"/>' +
  				'</form>');
			$('body').append(form);
			form.submit();
		}

	</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
