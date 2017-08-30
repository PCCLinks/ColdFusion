
<cfinclude template="includes/header.cfm">
<cfinvoke component="ProgramBilling" method="getLatestDateAttendanceMonth"  returnvariable="attendanceMonth"></cfinvoke>
<cfinvoke component="ProgramBilling" method="attendanceReport" returnvariable="data">
	<cfinvokeargument name="monthStartDate" value="#attendanceMonth#">
	<cfinvokeargument name="program" value="#Session.program#">
	<cfinvokeargument name="schooldistrict" value="#Session.schooldistrict#">
</cfinvoke>

<div class="callout primary">
<div class="row">
<cfoutput>
	<div class="small-4 columns">
		<label>Month Start Date:&nbsp;<input name="billingStartDate" id="billingStartDate" value="#DateFormat(attendanceMonth,'m/d/yyyy')#"></label>
	</div>
</cfoutput>
</div>
</div>


<table>
	<thead>
		<th>First Name</th>
		<th>Last Name</th>
		<th>G Number</th>
		<th>Attendance</th>
		<th>Ind</th>
		<th>Small</th>
		<th>Inter</th>
		<th>Large</th>
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr>
			<td>#firstname#</td>
			<td>#lastname#</td>
			<td>#bannergnumber#</td>
			<td>#attendance#</td>
			<td>#ind#</td>
			<td>#small#</td>
			<td>#inter#</td>
			<td>#large#</td>
		</tr>
	</cfoutput>
	</tbody>
</table>


<cfinclude template="includes/footer.cfm">