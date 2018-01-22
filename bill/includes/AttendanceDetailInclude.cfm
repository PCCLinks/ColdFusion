
<cfinvoke component="pcclinks.bill.Report" method="attendanceReportDetail" returnvariable="data">
	<cfinvokeargument name="billingStudentId" value="#attributes.billingStudentId#">
</cfinvoke>

<style>

table.attendance thead, table.attendance thead th, table.attendance tbody td, table.attendance tfoot td{
	padding:4px;
	background-color:white;
	border-style:solid;
	border-width:1px;
	border-color:lightgray;
	margin:0px;
	border-collapse: collapse;
}
table.attendance{
	border-collapse: collapse;
}
</style>

<b>Attendance Details</b><br>
<table class="attendance" >
	<thead>
		<tr>
			<th>CRN</th>
			<th>Attnd</th>
			<th>Ind</th>
			<th>Small</th>
			<th>Inter</th>
			<th>Large</th>
			<th>CM</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr>
			<td><a href='AttendanceEntry.cfm?crn=#crn#&billingStartDate=#billingStartDate#' target="_blank">#crn#</a></td>
			<td>#attendance#</td>
			<td>#ind#</td>
			<td>#small#</td>
			<td>#inter#</td>
			<td>#large#</td>
			<td>#cm#</td>
		</tr>
	</cfoutput>
	</tbody>
	<tfoot>
		<tr>
			<cfquery dbtype="query" name="dataTotal">
				select SmGroupPercent, InterGroupPercent, LargeGroupPercent, CMPercent, GeneratedBilledAmount, GeneratedOverageAmount,
					sum(attendance) attendance, sum(ind) ind, sum(small) small, sum(inter) inter, sum(large) large, sum(cm) CM
				from data
				group by SmGroupPercent, InterGroupPercent, LargeGroupPercent, CMPercent, GeneratedBilledAmount, GeneratedOverageAmount
			</cfquery>
			<cfoutput query="dataTotal">
			<td></td>
			<td>#attendance#</td>
			<td>#ind#</td>
			<td>#small#</td>
			<td>#inter#</td>
			<td>#large#</td>
			<td>#cm#</td>
			</cfoutput>
		</tr>
	</tfoot>
</table>
<table class="attendance" >
	<thead>
		<tr>
			<th>CRN</th>
			<th>Scnrio</th>
			<th>Ind %</th>
			<th>Small %</th>
			<th>Inter %</th>
			<th>Large %</th>
			<th>CM %</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr>
			<td>#crn#</td>
			<td>#Scenario#</td>
			<td>#IndPercent#</td>
			<td>#SmallPercent#</td>
			<td>#InterPercent#</td>
			<td>#LargePercent#</td>
			<td>#(IndPercent + SmallPercent + InterPercent + LargePercent)/10#</td>
		</tr>
	</cfoutput>
	</tbody>
</table>
<table class="attendance" >
	<thead><cfoutput query="dataTotal">
		<tr>
			<th>Indiv</th>
			<th>Small * #SmGroupPercent#</th>
			<th>Inter * #InterGroupPercent#</th>
			<th>Large * #LargeGroupPercent#</th>
			<th>CM Total * #CMPercent#</th>
			<th>Total</th>
			<th>Ovrg</th>
			<th>PPS Days</th>
		</tr></cfoutput>
	</thead>
	<tbody>
		<tr>
		<cfoutput query="dataTotal">
			<td>#Ind#</td>
			<td>#Small*SmGroupPercent#</td>
			<td>#Inter*InterGroupPercent#</td>
			<td>#Large*LargeGroupPercent#</td>
			<td>#(Ind+Small+Inter+Large)*CMPercent#</td>
			<td>#NumberFormat(GeneratedBilledAmount+GeneratedOverageAmount,'9.99')#</td>
			<td>#GeneratedOverageAmount#</td>
			<td>#GeneratedBilledAmount#</td>
		</cfoutput>
		</tr>
	</tbody>
</table>

<!-- ending page -->
