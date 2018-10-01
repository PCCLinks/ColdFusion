
<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getFirstOpenAttendanceDateorLastClosed"  returnvariable="attendanceMonth"></cfinvoke>
<cfinvoke component="Report" method="attendanceReport" returnvariable="data">
	<cfinvokeargument name="billingStartDate" value="#attendanceMonth#">
	<cfinvokeargument name="programYear" value="#url.programYear#">
	<cfinvokeargument name="program" value="#url.program#">
	<cfinvokeargument name="schooldistrict" value="#url.schooldistrict#">
</cfinvoke>
<cfset Session.reportAttendancePrintTable = data>
<cfinvoke component="Report" method="getReportList"  returnvariable="reportListData">
	<cfinvokeargument name="programYear" value="#url.programYear#">
	<cfinvokeargument name="billingType" value="#url.type#">
</cfinvoke>

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
<div class="off-canvas-wrapper">
<div class="off-canvas-wrapper-inner" data-off-canvas-wrapper>
<div class="off-canvas position-left" id="offCanvasLeft" data-off-canvas>
<ul class="menu vertical">
<cfif not isNull(reportListData)>
	<cfoutput query="reportListData">
	<li><a href="ReportAttendance.cfm?schooldistrict=#schoolDistrict#&program=#program#&type=#url.type#&programYear=#url.programYear#">#schoolDistrict# - #program#</a></li>
     </cfoutput>
</cfif>
</ul> <!-- end of menu -->
</div> <!-- end of class=off-canvas position-left -->

<!--MAIN REPORT -->
<div class="off-canvas-content" data-off-canvas-content>
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
				<cfoutput><b>All Students at #url.Program# between #DateFormat(data.ReportStartDate,'m/d/yyyy')# and #DateFormat(data.ReportEndDate,'m/d/yyyy')#</b></cfoutput>
			</td>
		</tr>
	</table>
</div> <!-- end of class=off-canvas-content -->
</div> <!-- end of class=off-canvas-wrapper-inner -->
</div> <!-- end of class=off-canvas-wrapper -->

<!-- Fire Off-canvas -->
<button type="button" class="button alert" data-toggle="offCanvasLeft">Show Report List</button>

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


	function goToDetail(billingStudentId){
		window.open('javascript:getBillingStudent(' + billingStudentId + ', true);');
	}

	</script>
	</cfsavecontent>
<cfinclude template="includes/footer.cfm">