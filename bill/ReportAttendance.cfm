
<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getLatestDateAttendanceMonth"  returnvariable="attendanceMonth"></cfinvoke>
<cfinvoke component="Report" method="attendanceReport" returnvariable="data">
	<cfinvokeargument name="monthStartDate" value="#attendanceMonth#">
	<cfinvokeargument name="term" value="#url.term#">
	<cfinvokeargument name="program" value="#url.program#">
	<cfinvokeargument name="schooldistrict" value="#url.schooldistrict#">
</cfinvoke>
<cfset Session.reportAttendancePrintTable = data>


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
					<cfoutput><b>All Students at #url.Program# between #data.BillingStartDate# and #data.BillingEndDate#</b></cfoutput>
				</td>
			</tr>
		</table>
	</div>

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
			<td style="text-align:left">#name#</td>
			<td style="text-align:left">#bannerGNumber#</td>
			<td style="text-align:left">#DateFormat(dob,"m/d/y")#</td>
			<td style="text-align:left">#DateFormat(enrolleddate,"m/d/y")#</td>
			<td style="text-align:left">#DateFormat(exitdate,"m/d/y")#</td>
			<td><cfif JunbillingStudentId GT 0><a href='javascript:goToDetail(#JunbillingStudentId#);'>#Jun#</a><cfelse>0</cfif></td>
			<td><cfif JulbillingStudentId GT 0><a href='javascript:goToDetail(#JulbillingStudentId#);' >#Jul#</a><cfelse>0</cfif></td>
			<td><cfif AugbillingStudentId GT 0><a href='javascript:goToDetail(#AugbillingStudentId#);'>#Aug#</a><cfelse>0</cfif></td>
			<td><cfif SeptbillingStudentId GT 0><a href='javascript:goToDetail(#SeptbillingStudentId#);'>#Sept#</a><cfelse>0</cfif></td>
			<td><cfif OctbillingStudentId GT 0><a href='javascript:goToDetail(#OctbillingStudentId#);'>#Oct#</a><cfelse>0</cfif></td>
			<td><cfif NovbillingStudentId GT 0><a href='javascript:goToDetail(#NovbillingStudentId#);'>#Nov#</a><cfelse>0</cfif></td>
			<td><cfif DecbillingStudentId GT 0><a href='javascript:goToDetail(#DecbillingStudentId#);'>#Dcm#</a><cfelse>0</cfif></td>
			<td><cfif JanbillingStudentId GT 0><a href='javascript:goToDetail(#JanbillingStudentId#);'>#Jan#</a><cfelse>0</cfif></td>
			<td><cfif FebbillingStudentId GT 0><a href='javascript:goToDetail(#FebbillingStudentId#);'>#Feb#</a><cfelse>0</cfif></td>
			<td><cfif MarbillingStudentId GT 0><a href='javascript:goToDetail(#MarbillingStudentId#);'>#Mar#</a><cfelse>0</cfif></td>
			<td><cfif AprbillingStudentId GT 0><a href='javascript:goToDetail(#AprbillingStudentId#);'>#Apr#</a><cfelse>0</cfif></td>
			<td><cfif MaybillingStudentId GT 0><a href='javascript:goToDetail(#MaybillingStudentId#);'`>#May#</a><cfelse>0</cfif></td>
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
		<cfoutput query="totals">
		<tr>
			<td style="border-top-style:">Total:#cnt#</td>
			<td colspan="4"></td>
			<td style="border-top-style:solid">#Jun#</td>
			<td style="border-top-style:solid">#Jul#</td>
			<td style="border-top-style:solid">#Aug#</td>
			<td style="border-top-style:solid">#Sept#</td>
			<td style="border-top-style:solid">#Oct#</td>
			<td style="border-top-style:solid">#Nov#</td>
			<td style="border-top-style:solid">#Dcm#</td>
			<td style="border-top-style:solid">#Jan#</td>
			<td style="border-top-style:solid">#Feb#</td>
			<td style="border-top-style:solid">#Mar#</td>
			<td style="border-top-style:solid">#Apr#</td>
			<td style="border-top-style:solid">#May#</td>
			<td style="border-top-style:solid">#Attnd#</td>
			<td style="border-top-style:solid">#Enrl#</td>
		</tr>
		</cfoutput>
	</tfoot>
</table>


	<cfsavecontent variable="pcc_scripts">
	<script>

		$(document).ready(function() {
		    setUpTable();

		} );

		function setUpTable(){
			$('#dt_table').DataTable( {
		    	dom: '<"top"iBf>rt<"bottom"lp>',
		    	bSort:false,
		        scrollY: "400px",
		        scrollX: true,
		        scrollCollapse: true,
		        paging: false,
        		fixedColumns:true,
			    buttons: [
		        	{text:'print',
		         		action: function(){
		         		window.open('ReportAttendancePrintTable.cfm');
		         	}
		         }
		    ] //end buttons
			});
		}

	function getPrintTableHTML(){
		return $.ajax({
            type: 'get',
            url: 'AttendanceReportPrintTable.cfm',
			async: false,
            success: function (data, textStatus, jqXHR) {
            	return data;
			},
            error: function (xhr, textStatus, thrownError) {
				 handleAjaxError(xhr, textStatus, thrownError);
			}
          });
	}
	function goToDetail(billingStudentId){
		sessionStorage.clear();
		sessionStorage.setItem('returnToReport', '<cfoutput>#cgi.script_name#?#cgi.query_string#</cfoutput>');
		sessionStorage.setItem("showNext", true);
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
		$.post("SaveSession.cfm", data, function(){
			window.open('programStudentDetail.cfm?billingStudentId='+billingStudentId);
		});
	}

	</script>
	</cfsavecontent>
<cfinclude template="includes/footer.cfm">