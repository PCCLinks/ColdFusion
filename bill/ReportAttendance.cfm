
<cfinclude template="includes/header.cfm">
<cfinvoke component="ProgramBilling" method="getLatestDateAttendanceMonth"  returnvariable="attendanceMonth"></cfinvoke>
<cfinvoke component="Report" method="attendanceReport" returnvariable="data">
	<cfinvokeargument name="monthStartDate" value="#attendanceMonth#">
	<cfinvokeargument name="term" value="#Session.term#">
	<cfinvokeargument name="program" value="#Session.program#">
	<cfinvokeargument name="schooldistrict" value="#Session.schooldistrict#">
</cfinvoke>
<cfset Session.attendanceReportPrintTable = data>


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
</style>

	<div class="row" id="tableheader">
		<table width="100%" style="border-style:none;">
			<tr>
				<td class="bottom-border" style="text-align:left; font-size:8px">
					<cfoutput>#Session.schooldistrict#</cfoutput>
				</td>
				<td class="bottom-border" style="text-align:right; font-size:8px">
					Alternative Education Program
				</td>
			</tr>
			<tr>
				<td colspan="2" class="no-border" style="text-align:center; font-size:12px">
					<h4>Monthly Attendance And Days Enrolled - Public School Days</h4>
					<cfoutput><b>All Students at #Session.Program# between #data.ReportingStartDate# and #data.ReportingEndDate#</b></cfoutput>
				</td>
			</tr>
		</table>
	</div>

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

<table id="dt_table" class="hover">
	<thead>
		<tr>
			<th style="border-bottom-style:solid">Student</th>
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
		<tr>
			<th colspan="18">No Plan Assigned</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="data">
		<tr>
			<td style="text-align:left">#name#</td>
			<td style="text-align:left">#DateFormat(dob,"m/d/y")#</td>
			<td style="text-align:left">#DateFormat(enrolleddate,"m/d/y")#</td>
			<td style="text-align:left">#DateFormat(exitdate,"m/d/y")#</td>
			<td><cfif JunbillingStudentId GT 0><a href='javascript:goToDetail(#JunbillingStudentId#);'>#Jun#</a><cfelse>0</cfif></td>
			<td><cfif JulbillingStudentId GT 0><a href='javascript:goToDetail(#JulbillingStudentId#);' >#Jul#</a><cfelse>0</cfif></td>
			<td><cfif AugbillingStudentId GT 0><a href='javascript:goToDetail(#AugbillingStudentId#);'>#Aug#</a><cfelse>0</cfif></td>
			<td><cfif SeptbillingStudentId GT 0><a href='javascript:goToDetail(#SeptbillingStudentId#);'>#Sept#</a><cfelse>0</cfif></td>
			<td><cfif OctbillingStudentId GT 0><a href='javascript:goToDetail(#OctbillingStudentId#);'>#Oct#</a><cfelse>0</cfif></td>
			<td><cfif NovbillingStudentId GT 0><a href='javascript:goToDetail(#NovbillingStudentId#);'>#Nov#</a><cfelse>0</cfif></td>
			<td><cfif DecbillingStudentId GT 0><a href='javascript:goToDetail(#DecbillingStudentId#);'>#Dec#</a><cfelse>0</cfif></td>
			<td><cfif JanbillingStudentId GT 0><a href='javascript:goToDetail(#JanbillingStudentId#);'>#Jan#</a><cfelse>0</cfif></td>
			<td><cfif FebbillingStudentId GT 0><a href='javascript:goToDetail(#FebbillingStudentId#);'>#Feb#</a><cfelse>0</cfif></td>
			<td><cfif MarbillingStudentId GT 0><a href='javascript:goToDetail(#MarbillingStudentId#);'>#Mar#</a><cfelse>0</cfif></td>
			<td><cfif AprbillingStudentId GT 0><a href='javascript:goToDetail(#AprbillingStudentId#);'>#Apr#</a><cfelse>0</cfif></td>
			<td><cfif MaybillingStudentId GT 0><a href='javascript:goToDetail(#MaybillingStudentId#);'`>#May#</a><cfelse>0</cfif></td>
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
			<td style="border-top-style:">Total:#Variables.count#</td>
			<td></td>
			<td></td>
			<td></td>
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


	<cfsavecontent variable="pcc_scripts">
	<script>

		$(document).ready(function() {
		    setUpTable();

		} );

		function setUpTable(){
			$('#dt_table').DataTable( {
		    	dom: '<"top"iBf>rt<"bottom"lp>',
		    	bSort:false,
			    buttons: [
		          {	extend:'print',
		            autoPrint:false,
		            header:true,
		            footer:true,
		            orientation:'portrait',
		           // Set up some custom HTML for printing
		            customize: function ( win ) {
		            	//set body font size and type
		            	$(win.document.body)
		                        .css( 'font-size', '8pt' )
		                        .css('font-family', 'Times New Roman');

						//sets same fonts for the table
		                $(win.document.body).find( 'table' )
		              			.css( 'font-size', 'inherit' );

		              	var dt_table = $('#dt_table').html();
		              	var printTable = '';
		              	$.ajax({
				            type: 'get',
				            url: 'AttendanceReportPrintTable.cfm',
							async: false,
				            success: function (data, textStatus, jqXHR) {
				            	printTable = data;
							},
				            error: function (xhr, textStatus, thrownError) {
								 handleAjaxError(xhr, textStatus, thrownError);
							}
				          });
		              	$(win.document.body).find('table').replaceWith(printTable);

						$(win.document.body).find('a').each(function(){
																	this.outerHTML = this.innerHTML;
															});


						//adding in the document header
		     			 $(win.document.body).find('h1').replaceWith('<style> .no-border{border-style:none !important} .bottom-border{ 	border-top-style:none;	border-left-style:none; border-right-style:none; border-bottom-style:solid; } </style><div class="row">' + $('#tableheader').html() + '</div><br><br>');
		            } //end customize
		        }, //end print button definition
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
	 	window.open('billingStudentRecord.cfm?billingStudentId='+billingStudentId,'_blank');
	}

	</script>
	</cfsavecontent>
<cfinclude template="includes/footer.cfm">