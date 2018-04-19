
<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getFirstOpenAttendanceDate"  returnvariable="attendanceMonth"></cfinvoke>
<cfinvoke component="Report" method="attendanceReport" returnvariable="data">
	<cfinvokeargument name="billingStartDate" value="#attendanceMonth#">
	<cfinvokeargument name="term" value="#url.term#">
	<cfinvokeargument name="program" value="#url.program#">
	<cfinvokeargument name="schooldistrict" value="#url.schooldistrict#">
</cfinvoke>
<cfset Session.reportAttendancePrintTable = data>
<cfinvoke component="LookUp" method="getReportDates"  returnvariable="reportDates">
	<cfinvokeargument name="term" value="#url.term#">
	<cfinvokeargument name="billingStartDate" value="#attendanceMonth#">
</cfinvoke>
<cfset Session.reportDatesAttendanceData = reportDates>

<style>
	.dataTables_wrapper .dataTables_processing{
		top: 70% !important;
		height: 50px !important;
		background-color: lightGray;
	}
	.dataTables_info{
		margin-right:10px !important;
	}
	select {
		width:auto !important;
	}
	input{
		display:inline-block !important;
		width:auto !important;
	}
	table.dataTable tbody td, table.dataTable tfoot td {
		text-align:right;
		padding-right:10px;
	}
</style>
	<div class="row" id="tableheader">
		<table width="100%" style="border-style:none;">
			<tr>
				<td class="bottom-border" style="text-align:left; font-size:12px">
					<cfoutput>#url.schooldistrict#</cfoutput>
				</td>
				<td class="bottom-border" style="text-align:right; font-size:12px">
					Alternative Education Program
				</td>
			</tr>
			<tr>
				<td colspan="2" class="no-border" style="text-align:center; font-size:12px">
					<h4>Monthly Attendance And Days Enrolled - Public School Days</h4>
					<cfoutput><b>All Students at #url.Program# between #DateFormat(reportDates.ReportStartDate,'m/d/yyyy')# and #DateFormat(reportDates.ReportMonthEndDate,'m/d/yyyy')#</b></cfoutput>
				</td>
			</tr>
		</table>
	</div>

<input class="button" id="recalculate" value="Recalculate" onClick="javascript: reCalculate();">
<input class="button" id="print" value="Print Friendly Version" onClick="javascript: print();">
<!---<input class="button" id="exportToExcel" value="Export to Excel" onClick="javascript: exportToExcel();">--->
	<div id="displayTable">
	<cfinclude template="includes\reportAttendanceDisplayTableInclude.cfm">
	</div>
	<cfsavecontent variable="pcc_scripts">
	<script>

		$(document).ready(function() {
		    setUpTable();

		} );

		function setUpTable(){
			$('#dt_table').DataTable( {
		    	dom: '<"top"if>rt<"bottom"lp>',
		    	bSort:false,
		        scrollY: "400px",
		        scrollX: true,
		        scrollCollapse: true,
		        paging: false,
        		fixedColumns:true
			});
		}

	function print(){
		window.open('ReportAttendancePrintTable.cfm');
	}
	function exportToExcel(){
		window.open('ReportAttendanceExcelExport.cfm');
	}

	function reCalculate(){
     	$.ajax({
			url: "report.cfc?method=reCalculateBilling",
			data: <cfoutput>{term: #url.term#, billingType: 'attendance', billingStartDate: '#attendanceMonth#',
								program: '#url.program#', schooldistrict: '#url.schooldistrict#'},</cfoutput>
			type: "POST",
     		success: function(){
			$.ajax({
	        	url: 'includes/reportAttendanceDisplayTableInclude.cfm?',
	       		cache: false
		    	}).done(function(data) {
		        	$("#displayTable").html(data);
		        	setUpTable();
		    	}); //end done
     				}, //end function success
			error: function (jqXHR, exception) {
	        	handleAjaxError(jqXHR, exception);
			} //end error
      	})//end ajax
     } //end recalculate button

	function goToDetail(billingStudentId){
		window.open('programStudentDetail.cfm?billingStudentId=' + billingStudentId + '&showNext=true#Billing');
	}

	</script>
	</cfsavecontent>
<cfinclude template="includes/footer.cfm">