
<cfinclude template="includes/header.cfm">
<cfinvoke component="ProgramBilling" method="attendanceReportDetail" returnvariable="data">
	<cfinvokeargument name="billingStudentId" value="#url.billingStudentId#">
</cfinvoke>

<div class="callout primary">
<div class="row">
<cfoutput>
	<div class="small-4 columns">#data.firstname#&nbsp;#data.lastname#&nbsp;(#data.bannerGNumber#)</div>
	<div class="small-8 columns">
		<label>Month Start Date:#DateFormat(data.billingStartDate,'m/d/y')#</label>
	</div>
</cfoutput>
</div>
</div>


<table>
	<thead>
		<tr>
			<th>CRN</th>
			<th>Attendance</th>
			<th>Ind</th>
			<th>Small</th>
			<th>Inter</th>
			<th>Large</th>
			<th>Total</th>
			<th>Scenario</th>
			<th>Ind %</th>
			<th>Small %</th>
			<th>Inter %</th>
			<th>Large %</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr>
			<td><a href='AttendanceDetail.cfm?crn=#crn#&billingStartDate=#billingStartDate#'>#crn#</a></td>
			<td>#attendance#</td>
			<td>#ind#</td>
			<td>#small#</td>
			<td>#inter#</td>
			<td>#large#</td>
			<td>#ind+small+inter+large#</td>
			<td>#billingScenarioName#</td>
			<td>#IndPercent#</td>
			<td>#SmallPercent#</td>
			<td>#InterPercent#</td>
			<td>#LargePercent#</td>
		</tr>
	</cfoutput>
	</tbody>
	<tfoot>
		<tr>
			<cfquery dbtype="query" name="dataTotal">
				select sum(attendance) attendance, sum(ind) ind, sum(small) small, sum(inter) inter, sum(large) large, sum(ind+small+inter+large) total
				from data
			</cfquery>
			<cfoutput query="dataTotal">
			<td></td>
			<td>#attendance#</td>
			<td>#ind#</td>
			<td>#small#</td>
			<td>#inter#</td>
			<td>#large#</td>
			<td>#total#</td>
			<td colspan="5"></td>
			</cfoutput>
		</tr>
	</tfoot>
</table>

<table>
	<thead>
		<tr>
			<th>Indiv</th>
			<th>Small * 0.333</th>
			<th>Inter * 0.222</th>
			<th>Large * 0.167</th>
			<th>CM Total * 0.0167</th>
			<th>PPS Days</th>
		</tr>
	</thead>
	<tbody>
		<tr>
		<cfoutput query="dataTotal">
			<td>#Ind#</td>
			<td>#Small*0.333#</td>
			<td>#Inter*0.222#</td>
			<td>#Large*0.167#</td>
			<td>#(Ind+Small+Inter+Large)*0.0167#</td>
			<td>#NumberFormat(Ind + Small*0.333 + Inter*0.222 + Large*0.167 + (Ind+Small+Inter+Large)*0.0167,'9.99')#</td>
		</cfoutput>
		</tr>
	</tbody>
</table>


<cfinclude template="includes/footer.cfm">