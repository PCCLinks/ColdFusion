<cfset data = Session.reportAttendanceData>

<table id="dt_table" class="hover stripe">
	<thead>
		<tr>
			<th style="border-bottom-style:solid">Student</th>
			<th style="border-bottom-style:solid">G</th>
			<th style="border-bottom-style:solid">DOB</th>
			<th style="border-bottom-style:solid">Entry Date</th>
			<th style="border-bottom-style:solid">Exit Date</th>
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
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr>
			<td style="text-align:left"><a href='javascript:goToDetail(#billingStudentIdMostCurrent#)'>#name#</a></td>
			<td style="text-align:left">#bannerGNumber#</td>
			<td style="text-align:left">#DateFormat(dob,"m/d/y")#</td>
			<td style="text-align:left">#DateFormat(enrolleddate,"m/d/y")#</td>
			<td style="text-align:left">#DateFormat(exitdate,"m/d/y")#</td>
			<td><cfif Jun GT 0>#Jun#<cfelse>0</cfif></td>
			<td><cfif Jul GT 0>#Jul#<cfelse>0</cfif></td>
			<td><cfif Aug GT 0>#Aug#<cfelse>0</cfif></td>
			<td><cfif Sept GT 0>#Sept#<cfelse>0</cfif></td>
			<td><cfif Oct GT 0>#Oct#<cfelse>0</cfif></td>
			<td><cfif Nov GT 0>#Nov#<cfelse>0</cfif></td>
			<td><cfif Dcm GT 0>#Dcm#<cfelse>0</cfif></td>
			<td><cfif Jan GT 0>#Jan#<cfelse>0</cfif></td>
			<td><cfif Feb GT 0>#Feb#<cfelse>0</cfif></td>
			<td><cfif Mar GT 0>#Mar#<cfelse>0</cfif></td>
			<td><cfif Apr GT 0>#Apr#<cfelse>0</cfif></td>
			<td><cfif May GT 0>#May#<cfelse>0</cfif></td>
			<td>#Attnd#</td>
			<td>#Enrl#</td>
		</tr>
	</cfoutput>
	</tbody>
	<tfoot>
		<cfquery dbtype="query" name="totals">
			select count(*) cnt, sum(Jun) Jun, sum(Jul) Jul, sum(Aug) Aug,
				sum(Sept) Sept, sum(Oct) Oct, sum(Nov) Nov, sum(Dcm) Dcm,
				sum(Jan) Jan, sum(Feb) Feb, sum(Mar) Mar, sum(Apr) Apr,
				sum(May) May,
				sum(attnd) Attnd, sum(enrl) enrl
			from data
		</cfquery>
		<cfquery name="ovrd">
			select *
			from billingStudentTotalOverride
			where schooldistrict = <cfqueryparam value="#data.schooldistrict#">
				and Program = <cfqueryparam value="#data.Program#">
				and ProgramYear = '2017/2018'
		</cfquery>
		<cfoutput query="totals">
		<tr>
			<td style="border-top-style:">Total:#cnt#</td>
			<td colspan="4"></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Jun) GT 0>#ovrd.Jun#<cfelse>#Jun#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Jul) GT 0>#ovrd.Jul#<cfelse>#Jul#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Aug) GT 0>#ovrd.Aug#<cfelse>#Aug#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Sept) GT 0>#ovrd.Sept#<cfelse>#Sept#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Oct) GT 0>#ovrd.Oct#<cfelse>#Oct#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Nov) GT 0>#ovrd.Nov#<cfelse>#Nov#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Dcm) GT 0>#ovrd.Dcm#<cfelse>#Dcm#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Jan) GT 0>#ovrd.Jan#<cfelse>#Jan#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Feb) GT 0>#ovrd.Feb#<cfelse>#Feb#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Mar) GT 0>#ovrd.Mar#<cfelse>#Mar#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.Apr) GT 0>#ovrd.Apr#<cfelse>#Apr#</cfif></td>
			<td style="border-top-style:solid"><cfif len(ovrd.May) GT 0>#ovrd.May#<cfelse>#May#</cfif></td>
			<td style="border-top-style:solid">#Attnd#</td>
			<td style="border-top-style:solid">#Enrl#</td>
		</tr>
		</cfoutput>
	</tfoot>
</table>