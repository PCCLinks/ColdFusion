<cfset data = Session.attendanceReportPrintTable>


<cfset Variables.count = 0>
<cfset Variables.jan = 0>
<cfset Variables.feb = 0>
<cfset Variables.mar = 0>
<cfset Variables.apr = 0>
<cfset Variables.may = 0>
<cfset Variables.jun = 0>
<cfset Variables.jul = 0>
<cfset Variables.aug = 0>
<cfset Variables.sept = 0>
<cfset Variables.oct = 0>
<cfset Variables.nov = 0>
<cfset Variables.dec = 0>
<cfset Variables.attnd = 0>
<cfset Variables.enrl = 0>

<table id="printtable">
	<thead>
		<tr>
			<th colspan="6" style="text-align:left">Student</th>
			<th colspan="2" style="text-align:left">Apprv. Status</th>
			<th colspan="2" style="text-align:left">DOB</th>
			<th colspan="2" style="text-align:left">Entry Date</th>
			<th colspan="2" style="text-align:left">Exit Date</th>
			<th colspan="2"></th>
		</tr>
		<tr>
			<th style="border-bottom-style:solid"></th>
			<th style="border-bottom-style:solid"></th>
			<th style="border-bottom-style:solid">Jun</th>
			<th style="border-bottom-style:solid">Jul</th>
			<th style="border-bottom-style:solid">Aug</th>
			<th style="border-bottom-style:solid">Sept</th>
			<th style="border-bottom-style:solid">Oct</th>
			<th style="border-bottom-style:solid">Nov</th>
			<th style="border-bottom-style:solid">Dec</th>
			<th style="border-bottom-style:solid">Jan</th>
			<th style="border-bottom-style:solid">Feb</th>
			<th style="border-bottom-style:solid">Mar</th>
			<th style="border-bottom-style:solid">Apr</th>
			<th style="border-bottom-style:solid">May</th>
			<th style="border-bottom-style:solid">Attend</th>
			<th style="border-bottom-style:solid">Enrl</th>
		</tr>
		<tr>
			<th colspan="16">No Plan Assigned</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr>
			<td colspan="6" style="text-align:left"><a href='attendanceReportDetail.cfm?billingStudentId=#billingStudentId#' target='_blank'>#name#</a></td>
			<td colspan="2" style="text-align:left">Approved</td>
			<td colspan="2" style="text-align:left">#DateFormat(dob,"m/d/y")#</td>
			<td colspan="2" style="text-align:left">#DateFormat(enrolleddate,"m/d/y")#</td>
			<td colspan="2" style="text-align:left">#DateFormat(exitdate,"m/d/y")#</td>
			<td colspan="2"></td>
		</tr>
		<tr>
			<td colspan="2"></td>
			<td>#Jun#</td>
			<td>#Jul#</td>
			<td>#Aug#</td>
			<td>#Sept#</td>
			<td>#Oct#</td>
			<td>#Nov#</td>
			<td>#Dec#</td>
			<td>#Jan#</td>
			<td>#Feb#</td>
			<td>#Mar#</td>
			<td>#Apr#</td>
			<td>#May#</td>
			<td>#Attnd#</td>
			<td>#Enrl#</td>
		</tr>

		<cfset Variables.count = Variables.count+1>
		<cfset Variables.jan = Variables.jan+#jan#>
		<cfset Variables.feb = Variables.feb+#feb#>
		<cfset Variables.mar = Variables.mar+#mar#>
		<cfset Variables.apr = Variables.apr+#apr#>
		<cfset Variables.may = Variables.may+#may#>
		<cfset Variables.jun = Variables.jun+#jun#>
		<cfset Variables.jul = Variables.jul+#jul#>
		<cfset Variables.aug = Variables.aug+#aug#>
		<cfset Variables.sept = Variables.sept+#sept#>
		<cfset Variables.oct = Variables.oct+#oct#>
		<cfset Variables.nov = Variables.nov+#nov#>
		<cfset Variables.dec = Variables.dec+#dec#>
		<cfset Variables.attnd = Variables.attnd+#attnd#>
		<cfset Variables.enrl = Variables.enrl+#enrl#>
	</cfoutput>
	</tbody>
	<tfoot>
		<cfoutput>
		<tr>
			<td style="border-top-style:">Total:</td>
			<td style="border-top-style:solid">#Variables.count#</td>
			<td style="border-top-style:solid">#Variables.Jun#</td>
			<td style="border-top-style:solid">#Variables.Jul#</td>
			<td style="border-top-style:solid">#Variables.Aug#</td>
			<td style="border-top-style:solid">#Variables.Sept#</td>
			<td style="border-top-style:solid">#Variables.Oct#</td>
			<td style="border-top-style:solid">#Variables.Nov#</td>
			<td style="border-top-style:solid">#Variables.Dec#</td>
			<td style="border-top-style:solid">#Variables.Jan#</td>
			<td style="border-top-style:solid">#Variables.Feb#</td>
			<td style="border-top-style:solid">#Variables.Mar#</td>
			<td style="border-top-style:solid">#Variables.Apr#</td>
			<td style="border-top-style:solid">#Variables.May#</td>
			<td style="border-top-style:solid">#Variables.Attnd#</td>
			<td style="border-top-style:solid">#Variables.Enrl#</td>
		</tr>
		</cfoutput>
	</tfoot>
</table>
