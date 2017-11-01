<cfinclude template="includes/header.cfm" />
<cfif StructKeyExists(form, "billingStartDate")>
	<cfset billingStartDate = "#form.billingStartDate#">
<cfelse>
	<cfinvoke component="LookUp" method="getLatestDateAttendanceMonth"  returnvariable="attendanceMonth"></cfinvoke>
	<cfset billingStartDate = "#attendanceMonth#">
</cfif>
<cfinvoke component="ProgramBilling" method="getAttendanceClassesForMonth"  returnvariable="data">
	<cfinvokeargument name="billingStartDate" value="#Variables.billingStartDate#">
</cfinvoke>

<div class="callout primary">
<div class="row">
<cfoutput>
<form name="frm" action="AttendanceSummary.cfm" method="post">
	<div class="small-4 columns">
		<label>Month Start Date:&nbsp;<input name="billingStartDate" id="billingStartDate" value="#DateFormat(Variables.billingStartDate,'m/d/yyyy')#"></label>
	</div>
	<div class="small-8 columns">
		<input class="button" type="submit" name="submit" value="Get List of Classes" />
	</div>
</form>
</cfoutput>
</div>
</div>

<table name="dt_table">
	<thead>
		<tr>
			<th>SUBJ</th>
			<th>CRSE</th>
			<th>Title</th>
			<th>CRN</th>
			<th>All Months</th>
		</tr>
	</thead>
	<tbody>
		<cfoutput query="data">
		<tr>
			<td>#SUBJ#</td>
			<td>#CRSE#</td>
			<td>#Title#</td>
			<td><a href="javascript:getAttendanceDetail('#CRN#')">#CRN#</a></td>
			<td><a href="javascript:getAttendanceGrid('#CRN#')">Entries for Term</a></td>
		</tr>
		</cfoutput>
	</tbody>
</table>
<cfsavecontent variable="pcc_scripts">
<script>
	$('#billingStartDate').datepicker({ dateFormat: 'mm/dd/yy' });
	function getAttendanceDetail(crn){
		window.location	= 'AttendanceDetail.cfm?crn=' + crn + '&billingStartDate=' + $('#billingStartDate').val();
	}
	function getAttendanceGrid(crn){
		goToDetail(crn, 'AttendanceGrid.cfm');
	}
	function goToDetail(crn, page){
		sessionStorage.setItem("billingStartDate", $('#billingStartDate').val());
		sessionStorage.setItem('CRN', crn);
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  		$.post("SaveSession.cfm", data, function(){
  			window.location	= page;
  		});
	}

</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
