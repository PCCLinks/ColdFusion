
<cfinclude template="includes/header.cfm">
<cfinvoke component="ProgramBilling" method="getLatestDateAttendanceMonth"  returnvariable="attendanceMonth"></cfinvoke>
<cfinvoke component="ProgramBilling" method="attendanceReport" returnvariable="data">
	<cfinvokeargument name="monthStartDate" value="#attendanceMonth#">
	<cfinvokeargument name="program" value="#Session.program#">
	<cfinvokeargument name="schooldistrict" value="#Session.schooldistrict#">
</cfinvoke>

<style>

		table tbody td, table tfoot td{
			text-align:right;
		}
		/*table thead th, table tbody td, table tfoot td {
			border-color:black;
			border-style:solid solid none none;
			border-width: 0.5px;
			background-color:white;
		}*/
		.no-border{
			border-color:none;
			border-style:none;
			border-width: 0px;
		}
		.bold-left-border{
			border-left-width:1px;
			border-left-style:solid;
		}
		.bold-right-border{
			border-right-width:1px;
			border-right-style:solid;
		}
		.border-no-bottom{
			border-bottom-style:none;
		}
		.border-no-top{
			border-top-style:none;
		}

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
		.tdAlignLeft{
			text-align:left;
		}
		td{
			border-style:none;
		}
	</style>


	<div class="row" id="tableheader">
		<table width="100%" style="border-style:none;">
			<tr>
				<td class="bottom-border" style="text-align:left; font-size:x-small">
					<cfoutput>#Session.schooldistrict#</cfoutput>
				</td>
				<td class="bottom-border" style="text-align:right; font-size:x-small">
					Alternative Education Program
				</td>
			</tr>
			<tr>
				<td class="no-border" style="text-align:center">
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

<table id="dt_table" class="hover compact">
<thead><tr><th></th></tr></thead>
<tbody><tr><td>

<table id="maindata">
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
</td></tr></tbody></table>


	<cfsavecontent variable="pcc_scripts">
	<script>

		$(document).ready(function() {
		    setUpTable();

		} );

		function setUpTable(){
			$('#dt_table').DataTable( {
		    	dom: '<"top"iBf>rt<"bottom"lp>',
		    	bSort:false,
				bFilter:false,
				bInfo:false,
				lengthChange:false,
				paging:false,
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

		              	var mainData = $('#maindata').html();
		              	$(win.document.body).find('table').replaceWith('<table>' + mainData + '</table>');

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

	</script>
	</cfsavecontent>
<cfinclude template="includes/footer.cfm">