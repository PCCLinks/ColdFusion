<cfset data = Session.reportAttendancePrintTable>


<style>

		table thead th, table tbody td {
			padding:4px;
		}
		table{
			margin:0px;
			border-collapse: collapse;
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
		.tdmonth{
			width:45px;
			text-align:right;
		}

	</style>

<table id="printtable">
<thead ><cfoutput>
			<tr>
				<th class="border-bottom-only" style="text-align:left; font-size:x-small" colspan="9">
					<cfoutput>#data.schooldistrict#</cfoutput>
				</th>
				<th class="border-bottom-only" style="text-align:right; font-size:x-small" colspan="10">
					Alternative Education Program
				</th>
			</tr>
			<tr><th colspan="16" class="no-border"></th></tr>
			<tr>
				<th class="no-border" style="text-align:center" colspan="19">
					<h3 style="margin:0px">Monthly Attendance And Days Enrolled - Public School Days</h3>
					<cfoutput><b>All Students at <cfif data.Program EQ "gtc">PCC/HSC<cfelse>#data.Program#</cfif> Between #data.BillingStartDate# and #data.BillingEndDate#</b></cfoutput>
				</th>
			</tr></cfoutput>
		<tr>
			<th colspan="6" style="text-align:left">Student</th>
			<th colspan="2" style="text-align:left">Apprv.&nbsp;Status</th>
			<th colspan="2" style="text-align:left">DOB</th>
			<th colspan="2" style="text-align:left">Entry Date</th>
			<th colspan="2" style="text-align:left">Exit Date</th>
			<th colspan="2"></th>
		</tr>
		<tr>
			<th style="border-bottom-style:solid"></th>
			<th style="border-bottom-style:solid"></th>
			<th style="border-bottom-style:solid" class="tdmonth">Jun</th>
			<th style="border-bottom-style:solid" class="tdmonth">Jul</th>
			<th style="border-bottom-style:solid" class="tdmonth">Aug</th>
			<th style="border-bottom-style:solid" class="tdmonth">Sept</th>
			<th style="border-bottom-style:solid" class="tdmonth">Oct</th>
			<th style="border-bottom-style:solid" class="tdmonth">Nov</th>
			<th style="border-bottom-style:solid" class="tdmonth">Dec</th>
			<th style="border-bottom-style:solid" class="tdmonth">Jan</th>
			<th style="border-bottom-style:solid" class="tdmonth">Feb</th>
			<th style="border-bottom-style:solid" class="tdmonth">Mar</th>
			<th style="border-bottom-style:solid" class="tdmonth">Apr</th>
			<th style="border-bottom-style:solid" class="tdmonth">May</th>
			<th style="border-bottom-style:solid" class="tdmonth">Attend</th>
			<th style="border-bottom-style:solid" class="tdmonth">Enrl</th>
		</tr>
		<tr>
			<th colspan="16" style="text-align:left">No Plan Assigned</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr><td colspan="16">
		<table style= "page-break-inside: avoid;">
			<tr>
				<td colspan="8" style="text-align:left">#name#</td>
				<td colspan="2" style="text-align:left">#DateFormat(dob,"m/d/y")#</td>
				<td colspan="2" style="text-align:left">#DateFormat(enrolleddate,"m/d/y")#</td>
				<td colspan="2" style="text-align:left">#DateFormat(exitdate,"m/d/y")#</td>
				<td colspan="2"></td>
			</tr>
			<tr>
				<td colspan="2" style="width:60px"></td>
				<td class="tdmonth">#Jun#</td>
				<td class="tdmonth">#Jul#</td>
				<td class="tdmonth">#Aug#</td>
				<td class="tdmonth">#Sept#</td>
				<td class="tdmonth">#Oct#</td>
				<td class="tdmonth">#Nov#</td>
				<td class="tdmonth">#Dcm#</td>
				<td class="tdmonth">#Jan#</td>
				<td class="tdmonth">#Feb#</td>
				<td class="tdmonth">#Mar#</td>
				<td class="tdmonth">#Apr#</td>
				<td class="tdmonth">#May#</td>
				<td class="tdmonth">#Attnd#</td>
				<td class="tdmonth">#Enrl#</td>
			</tr>
		</table>
		</td></tr>
	</cfoutput>
	<tr>
		<cfquery dbtype="query" name="totals">
				select count(*) cnt, sum(Jun) Jun, sum(Jul) Jul, sum(Aug) Aug,
					sum(Sept) Sept, sum(Oct) Oct, sum(Nov) Nov, sum(Dcm) Dcm,
					sum(Jan) Jan, sum(Feb) Feb, sum(Mar) Mar, sum(Apr) Apr,
					sum(May) May,
					sum(attnd) Attnd, sum(enrl) enrl
				from data
		</cfquery>
		<cfoutput query="totals">
		<tr>
			<td style="border-top-style:solid;width:30px" >Total:</td>
			<td style="border-top-style:solid;width:18px" >#cnt#</td>
			<td style="border-top-style:solid" class="tdmonth">#Jun#</td>
			<td style="border-top-style:solid" class="tdmonth">#Jul#</td>
			<td style="border-top-style:solid" class="tdmonth">#Aug#</td>
			<td style="border-top-style:solid" class="tdmonth">#Sept#</td>
			<td style="border-top-style:solid" class="tdmonth">#Oct#</td>
			<td style="border-top-style:solid" class="tdmonth">#Nov#</td>
			<td style="border-top-style:solid" class="tdmonth">#Dcm#</td>
			<td style="border-top-style:solid" class="tdmonth">#Jan#</td>
			<td style="border-top-style:solid" class="tdmonth">#Feb#</td>
			<td style="border-top-style:solid" class="tdmonth">#Mar#</td>
			<td style="border-top-style:solid" class="tdmonth">#Apr#</td>
			<td style="border-top-style:solid" class="tdmonth">#May#</td>
			<td style="border-top-style:solid" class="tdmonth">#Attnd#</td>
			<td style="border-top-style:solid" class="tdmonth">#Enrl#</td>
		</tr>
		</cfoutput>
</table>
