<cfinclude template="includes/header.cfm">

<cfinvoke component="Report" method="getBillingDiffMaxMonth" returnvariable="maxMonth"></cfinvoke>

<cfif url.type EQ 'Term'>
	<cfinvoke component="Report" method="getBillingDifferencesTerm" returnvariable="data"></cfinvoke>
<cfelse>
	<cfinvoke component="Report" method="getBillingDifferencesAttendance" returnvariable="data"></cfinvoke>
</cfif>
<cfinvoke component="Lookup" method="getCurrentProgramYear" returnvariable="programyear"></cfinvoke>

<div class="callout primary"><b><p>Billing Differences Report</p></b>
<div id="heading"></div>
</div>

<div id="auditLog" style="display:none">
	<cfinclude template="includes/reportBillingAuditLogInclude.cfm">
</div>

<table id="dt_table" class="hover stripe">
	<thead>
		<tr>
			<th style="border-bottom-style:solid">School District</th>
			<th style="border-bottom-style:solid">Program</th>
			<th style="border-bottom-style:solid">Student</th>
			<th style="border-bottom-style:solid">G Number</th>
			<th style="border-bottom-style:solid">Jun</th>
			<cfif maxMonth GT 6 >
			<th style="border-bottom-style:solid">Jul</th>
			</cfif>
			<cfif maxMonth GT 7 >
			<th style="border-bottom-style:solid">Aug</th>
			</cfif>
			<cfif maxMonth GT 8 >
			<th style="border-bottom-style:solid">Sept</th>
			</cfif>
			<cfif maxMonth GT 9 >
			<th style="border-bottom-style:solid">Oct</th>
			</cfif>
			<cfif maxMonth GT 10 >
			<th style="border-bottom-style:solid">Nov</th>
			</cfif>
			<cfif maxMonth GT 11 >
			<th style="border-bottom-style:solid">Dec</th>
			</cfif>
			<cfif maxMonth GT 12 >
			<th style="border-bottom-style:solid">Jan</th>
			</cfif>
			<cfif maxMonth GT 21 >
			<th style="border-bottom-style:solid">Feb</th>
			</cfif>
			<cfif maxMonth GT 22 >
			<th style="border-bottom-style:solid">Mar</th>
			</cfif>
			<cfif maxMonth GT 23 >
			<th style="border-bottom-style:solid">Apr</th>
			</cfif>
			<cfif maxMonth GT 24 >
			<th style="border-bottom-style:solid">May</th>
			</cfif>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr>
			<td style="text-align:left">#SchoolDistrict#</td>
			<td style="text-align:left">#Program#</td>
			<td style="text-align:left">#firstname# #lastname#</td>
			<td style="text-align:left">#bannerGNumber#</td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 6)">#June#</a></td>
			<cfif maxMonth GT 6 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 7)">#July#</a></td>
			</cfif>
			<cfif maxMonth GT 7 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 8)">#August#</a></td>
			</cfif>
			<cfif maxMonth GT 8 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 9)">#September#</a></td>
			</cfif>
			<cfif maxMonth GT 9 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 10)">#October#</a></td>
			</cfif>
			<cfif maxMonth GT 10 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 11)">#November#</a></td>
			</cfif>
			<cfif maxMonth GT 11 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 12)">#December#</a></td>
			</cfif>
			<cfif maxMonth GT 12 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 1)">#January#</a></td>
			</cfif>
			<cfif maxMonth GT 21 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 2)">#February#</a></td>
			</cfif>
			<cfif maxMonth GT 122 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 3)">#March#</a></td>
			</cfif>
			<cfif maxMonth GT 23 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 4)">#April#</a></td>
			</cfif>
			<cfif maxMonth GT 24 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 5)">#May#</a></td>
			</cfif>
		</tr>
	</cfoutput>
	</tbody>
</table>



<cfsavecontent variable="pcc_scripts">
	<script>
		var table;
		$.fn.dataTable.ext.errMode = 'throw';
		$(document).ready(function() {
		    table = $('#dt_table').DataTable({
		    	processing:true,
				dom: '<"top"iB>rt<"bottom"flp>',
				buttons:['excel']
		    });

			//hide main filter
			$(".dataTables_filter").hide();

			table = $('#dt_table').DataTable();
			updateHeader();

		} );

		function updateHeader(){
			$.get('Report.cfc?method=getLastBillingGeneratedMessage&includeTitle=false&billingType=attendance&programYear=<cfoutput>#programyear#</cfoutput>', function(data){
				$('#heading').html(data);
			});
		}

		function showDetails(bannerGNumber, monthNumber){
			getAuditData(bannerGNumber, monthNumber);

			var d = $( "#auditLog" ).dialog({
			  title: "Audit Log Details for " + bannerGNumber,
			  modal: true,
			  autoOpen: false,
			  width: 1000,
			  height:500,
			  buttons: {
			      "Close": function() {
			        	$( this ).dialog( "close" );
			      }
			    }
			});
			d.dialog("open");
		}

	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">