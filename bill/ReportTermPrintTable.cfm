<cfset data = Session.reportTermData>
<style>

		table thead th, table tbody td, table tfoot td {
			border-color:black;
			border-style:solid solid none none;
			border-width: 0.5px;
			padding:4px;
		}
		table{
			margin:0px;
			border-collapse: collapse;
		}
		table tbody td, table tfoot td{
			text-align:right;
		}
		.bold-left-border{
			border-left-style:solid;
			border-left-width:2px;
		}
		.bold-right-border{
			border-right-width:1px;
			border-right-style:solid;
		}

		.border-bottom-only{
			border-bottom-style:solid;
			border-bottom-width:1px;
			border-top-style:none;
			border-left-style:none;
			border-right-style:none;
		}
		.border-no-left{
			border-left-style:none;
		}
		.border-no-right{
			border-right-style:none;
		}
		.no-border{
			border-color:none;
			border-style:none;
			border-width: 0px;
		}
		.border-no-top{
			border-top-style:none;
		}
		.max-billing{
			text-align:center;
			border-left-style:none;
			border-right-style:none;
			border-bottom-style:none;
		}

	</style>

<table id="printtable" style="page-break-inside: avoid;font-size:0.8em;font-family:serif;width:100%">
	<thead ><cfoutput>
			<tr>
				<th class="border-bottom-only" style="text-align:left; font-size:x-small" colspan="9">
					<cfoutput>#data.schooldistrict#</cfoutput>
				</th>
				<th class="border-bottom-only" style="text-align:right; font-size:x-small" colspan="10">
					Alternative Education Program
				</th>
			</tr>
			<tr><th colspan="19" class="no-border"></th></tr>
			<tr>
				<th class="no-border" style="text-align:center" colspan="19">
					<h3 style="margin:0px">College Quarterly Credit - Equivalent Instructional Days</h3>
					<cfoutput><b>All Students at <cfif data.Program EQ "gtc">PCC/HSC<cfelse>#data.Program#</cfif> for #data.BillingStartDate# and #data.BillingEndDate#</b></cfoutput>
					<br><br>
				</th>
			</tr></cfoutput>
		<tr id="dt-header">
			<th class="no-border" >Student</th>
			<th id="SummerNoOfCredits" colspan="2" class="no-border" >SUMMER</th>
			<th colspan="4" id="FallNoOfCredits" class="no-border" >FALL</th>
			<th colspan="4" id="WinterNoOfCredits" class="no-border" >WINTER</th>
			<th colspan="4" id="SpringNoOfCredits" class="no-border" >SPRING</th>
			<th colspan="4" class="no-border" ></th>
		</tr>
		<tr>
	        <th class="border-left-none  border-no-top" style="white-space:nowrap">Entry Date - Exit Date</th>
			<!-- SUMMER -->
			<th class="bold-left-border border-no-top">Credits</th>
			<th class="border-no-top">Days</th>
			<!-- FALL -->
			<th class="bold-left-border border-no-top border-no-right">Credits</th>
			<th class="border-no-left border-no-top">Over</th>
			<th class="border-no-top border-no-right">Days</th>
			<th class="border-no-left border-no-top">Over</th>
			<!-- WINTER -->
			<th class="bold-left-border border-no-top border-no-right">Credits</th>
			<th class="border-no-top border-no-left">Over</th>
			<th class="border-no-top border-no-right">Days</th>
			<th class="border-no-left border-no-top">Over</th>
			<!-- SPRING -->
			<th class="bold-left-border border-no-top border-no-right">Credits</th>
			<th class="border-no-top">Over</th>
			<th class="border-no-top border-no-right">Days</th>
			<th class="border-no-left border-no-top">Over</th>
			<!-- ROW TOTALS -->
			<th class="border-no-top bold-left-border">Total<br/>Credit</th>
			<th class="border-no-top" >Max<br/>Total<br/>Credit</th>
			<th class="border-no-top" >Total<br/>Days</th>
			<th class="border-no-top" >Max<br/>Bill<br/>Days</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="data">
	    <tr style="page-break-inside: avoid;">
	        <td style="text-align:left">
		        <div style="white-space:nowrap;padding:6px"><div><b>#LASTNAME#, #FIRSTNAME#</b></div>
						&nbsp;&nbsp;&nbsp;#EntryDate# <cfif ExitDate NEQ "">- #ExitDate#</cfif></div>
			</td>
			<!-- SUMMER -->
			<td class="bold-left-border">#NumberFormat(SummerNoOfCredits,'_._')#</td>
			<td>#NumberFormat(SummerNoOfDays,'_._')#</td>
			<!-- FALL -->
			<td class="bold-left-border border-no-right">#NumberFormat(FallNoOfCredits,'_._')#</td>
			<td class="border-no-left"><cfif FallNoOfCreditsOver NEQ 0>#NumberFormat(FallNoOfCreditsOver,'_._')#</cfif></td>
			<td class="border-no-right">#NumberFormat(FallNoOfDays,'_._')#</td>
			<td class="border-no-left"><cfif FallNoOfDaysOver NEQ 0>#NumberFormat(FallNoOfDaysOver,'_._')#</cfif></td>
			<!-- WINTER -->
			<td class="bold-left-border border-no-right">#NumberFormat(WinterNoOfCredits,'_._')#</td>
			<td class="border-no-left"><cfif WinterNoOfCreditsOver NEQ 0>#NumberFormat(WinterNoOfCreditsOver,'_._')#</cfif></td>
			<td class="border-no-right">#NumberFormat(WinterNoOfDays,'_._')#</td>
			<td class="border-no-left"><cfif WinterNoOfDaysOver NEQ 0>#NumberFormat(WinterNoOfDaysOver,'_._')#</cfif></td>
			<!-- SPRING -->
			<td class="bold-left-border border-no-right">#NumberFormat(SpringNoOfCredits,'_._')#</td>
			<td class="border-no-left"><cfif SpringNoOfCreditsOver NEQ 0>#NumberFormat(SpringNoOfCreditsOver,'_._')#</cfif></td>
			<td class=" border-no-right">#NumberFormat(SpringNoOfDays,'_._')#</td>
			<td class="border-no-left"><cfif SpringNoOfDaysOver NEQ 0>#NumberFormat(SpringNoOfDaysOver,'_._')#</cfif></td>
			<!-- Total Credits -->
			<td class="bold-left-border">#NumberFormat(FYTotalNoOfCredits,'_._')#</td>
			<!-- Max Total Credits -->
			<td>#NumberFormat(FYMaxTotalNoOfCredits,'_._')#</td>
			<!-- Total Days -->
			<td>#NumberFormat(FYTotalNoOfDays,'_._')#</td>
			<!-- Max Total Days -->
			<td>#NumberFormat(FYMaxTotalNoOfDays,'_._')#</td>
		</tr>
	</cfoutput>
	<!-- FOOTER -->
	<cfquery dbtype="query" name="totals">
	select sum(SummerNoOfCredits) SummerNoOfCredits, sum(SummerNoOfDays) SummerNoOfDays
			,CAST(sum(FallNoOfCredits) as decimal) FallNoOfCredits, CAST(sum(FallNoOfCreditsOver) as decimal) FallNoOfCreditsOver
			,sum(FallNoOfDays) FallNoOfDays, sum(FallNoOfDaysOver) FallNoOfDaysOver
			,sum(WinterNoOfCredits) WinterNoOfCredits, sum(WinterNoOfCreditsOver) WinterNoOfCreditsOver
			,sum(WinterNoOfDays) WinterNoOfDays, sum(WinterNoOfDaysOver) WinterNoOfDaysOver
			,sum(SpringNoOfCredits) SpringNoOfCredits, sum(SpringNoOfCreditsOver) SpringNoOfCreditsOver
			,sum(SpringNoOfDays) SpringNoOfDays, sum(SpringNoOfDaysOver) SpringNoOfDaysOver
			,sum(FYTotalNoOfCredits) FYTotalNoOfCredits, sum(FYMaxTotalNoOfCredits) FYMaxTotalNoOfCredits
			,sum(FYTotalNoOfDays) FYTotalNoOfDays, sum(FYMaxTotalNoOfDays) FYMaxTotalNoOfDays
	from data
	</cfquery>
	<cfoutput query="totals">
	<tr id="dt-footer1">
	<td><b>Totals</b></td>
	<!--- have to use DecimalFormat or does not round properly --->
	<!-- SUMMER -->
	<td class="bold-left-border">#NumberFormat(DecimalFormat(SummerNoOfCredits),'_._')#</td>
	<td>#NumberFormat(DecimalFormat(SummerNoOfDays),'_._')#</td>
	<!-- FALL -->
	<td class="bold-left-border border-no-right">#NumberFormat(Replace(DecimalFormat(FallNoOfCredits),",",""),'_._')#</td>
	<td class="border-no-left">#NumberFormat(DecimalFormat(FallNoOfCreditsOver),'_._')#</td>
	<td class=" border-no-right">#NumberFormat(Replace(DecimalFormat(FallNoOfDays),',',''),'_._')#</td>
	<td class="border-no-left">#NumberFormat(DecimalFormat(FallNoOfDaysOver),'_._')#</td>
	<!-- WINTER -->
	<td class="bold-left-border border-no-right">#NumberFormat(DecimalFormat(WinterNoOfCredits),'_._')#</td>
	<td class="border-no-left">#NumberFormat(DecimalFormat(WinterNoOfCreditsOver),'_._')#</td>
	<td class=" border-no-right">#NumberFormat(DecimalFormat(WinterNoOfDays),'_._')#</td>
	<td class="border-no-left">#NumberFormat(DecimalFormat(WinterNoOfDaysOver),'_._')#</td>
	<!-- SPRING -->
	<td class="bold-left-border border-no-right">#NumberFormat(DecimalFormat(SpringNoOfCredits),'_._')#</td>
	<td class="border-no-left">#NumberFormat(DecimalFormat(SpringNoOfCreditsOver),'_._')#</td>
	<td class=" border-no-right">#NumberFormat(DecimalFormat(SpringNoOfDays),'_._')#</td>
	<td class="border-no-left">#NumberFormat(DecimalFormat(SpringNoOfDaysOver),'_._')#</td>
	<!-- Grand Totals -->
	<td class="bold-left-border">#NumberFormat(Replace(DecimalFormat(FYTotalNoOfCredits),',',''),'_._')#</td>
	<td>#NumberFormat(Replace(DecimalFormat(FYMaxTotalNoOfCredits),',',''),'_._')#</td>
	<td>#NumberFormat(Replace(DecimalFormat(FYTotalNoOfDays),',',''),'_._')#</td>
	<td>#NumberFormat(Replace(DecimalFormat(FYMaxTotalNoOfDays),',',''),'_._')#</td>
	</tr>
	<tr id="dt-footer2">
	<td><b>Max Billing</b></td>
	<!-- Summer -->
	<td colspan="2" class="max-billing" >#NumberFormat(Replace(DecimalFormat(SummerNoOfDays),',',''),'_._')#</td>
	<!-- Fall -->
	<td colspan="4" class="max-billing">#NumberFormat(Replace(DecimalFormat(FallNoOfDays-FallNoOfDaysOver),',',''),'_._')#</td>
	<!-- Winter -->
	<td colspan="4" class="max-billing">#NumberFormat(Replace(DecimalFormat(WinterNoOfDays-WinterNoOfDaysOver),',',''),'_._')#</td>
	<!-- Spring -->
	<td colspan="4" class="max-billing">#NumberFormat(Replace(DecimalFormat(SpringNoOfDays-SpringNoOfDaysOver),',',''),'_._')#</td>
	<td class="no-border" colspan="4"></td>
	</tr>
	</cfoutput>
</table>


