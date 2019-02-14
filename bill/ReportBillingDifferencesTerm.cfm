<cfinclude template="includes/header.cfm">


<cfinvoke component="Report" method="getBillingDifferencesTerm" returnvariable="data"></cfinvoke>

<!--- adjusted month to show order for program year ie. June - Dec - May, Jan = 101, Feb 102 etc --->
<cfset adjMaxMonth = data.adjMaxMonth>
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
			<th style="border-bottom-style:solid">Summer Credit</th>
			<th style="border-bottom-style:solid">Summer Days</th>
			<cfif adjMaxMonth GT 9 >
			<th style="border-bottom-style:solid">Fall Credit</th>
			<th style="border-bottom-style:solid">Fall Days</th>
			<th style="border-bottom-style:solid">Fall Credit Overage</th>
			<th style="border-bottom-style:solid">Fall Days Overage</th>
			</cfif>
			<cfif adjMaxMonth GT 101 >
			<th style="border-bottom-style:solid">Winter Credit</th>
			<th style="border-bottom-style:solid">Winter Days</th>
			<th style="border-bottom-style:solid">Winter Credit Overage</th>
			<th style="border-bottom-style:solid">Winter Days Overage</th>
			</cfif>
			<cfif adjMaxMonth GT 104 >
			<th style="border-bottom-style:solid">Spring Credit</th>
			<th style="border-bottom-style:solid">Spring Days</th>
			<th style="border-bottom-style:solid">Spring Credit Overage</th>
			<th style="border-bottom-style:solid">Spring Days Overage</th>
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
			<td><a href="javascript:showDetails('#bannerGNumber#', 6)">#SummerCredits#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 6)">#SummerDays#</a></td>
			<cfif adjMaxMonth GT 9 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 9)">#FallCredits#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 9)">#FallDays#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 9)">#FallCreditsOverage#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 9)">#FallDaysOverage#</a></td>
			</cfif>
			<cfif adjMaxMonth GT 101 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 1)">#WinterCredits#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 1)">#WinterDays#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 1)">#WinterCreditsOverage#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 1)">#WinterDaysOverage#</a></td>
			</cfif>
			<cfif adjMaxMonth GT 104 >
			<td><a href="javascript:showDetails('#bannerGNumber#', 3)">#SpringCredits#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 3)">#SpringDays#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 3)">#SpringCreditsOverage#</a></td>
			<td><a href="javascript:showDetails('#bannerGNumber#', 3)">#SpringDaysOverage#</a></td>
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
			$.get('Report.cfc?method=getLastBillingGeneratedMessage&includeTitle=false&includeCorrections=false&billingType=term&programYear=<cfoutput>#programyear#</cfoutput>', function(data){
				$('#heading').html(data);
			});
		}

		function showDetails(bannerGNumber, monthNumber){
			reportBillingAuditLogInclude_getAuditData(bannerGNumber, monthNumber);

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