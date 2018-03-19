<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getLatestAttendanceDates" returnvariable="dates"></cfinvoke>

<cfinvoke component="LookUp" method="getAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getExitReasons" returnvariable="exitReasons"></cfinvoke>
<cfset Session.Lookup.GetExitReason = exitReasons>

<style>

	.dataTables_info{
		margin-right:10px !important;v
	}
	.dataTables_filter input{
		width:75%;
		display: inline-block;
	}
	.dataTables_length select {
		width:auto;
	}
	table.dataTable thead th.tooltipformat {
		color:gray;
		font-size:x-small;
		border-bottom-style:none;
		padding-bottom:0px;
	}
</style>

<div class="callout primary">
<div class="row">
	<div class="small-6 columns">
	<p><b>Update Exit Date and Reason</b></p>
	<label for="billingStartDate">Attendance Entry for:&nbsp;&nbsp;
	<select name="billingStartDate" id="billingStartDate" onChange="javascript:filter();" style="width:200px">
		<option disabled selected value="" > --Select Month Start Date-- </option>
		<cfoutput query="billingDates">
			<option value="#billingStartDate#" <cfif billingStartDate EQ dates.billingStartDate> selected </cfif>  > #DateFormat(billingStartDate,'yyyy-mm-dd')# </option>
		</cfoutput>
	</select>
	</div>
	<div id="waitMsg" class="small-6 columns" style="vertical-align:middle;height:100%;color:blue">Please wait...updating...will take a few minutes...</div>
</div>
</div>

<div class="row">
<div id="grid" class="large-7 columns">
	<table id="dt_table" class="display">
		<thead>
		<tr>
			<th style="border-bottom-style:none"></th>
			<th colspan="2" class="tooltipformat">
				<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Click a row to edit information on the right." >
					<img src="/pcclinks/images/tooltip.png" width="15" height="15">Click row...
				</span>
			</th>
			<th colspan="7" class="tooltipformat">
				<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Scroll to the right to sort by attendance." >
					<img src="/pcclinks/images/tooltip.png" width="15" height="15">Attendance...
				</span>
			</th>
		</tr>
		<tr>
			<th>Name</th>
			<th>Program</th>
			<th>District</th>
			<th>Billing Date</th>
			<th>Exit Date</th>
			<th>Exit Reason</th>
			<th>Adj Days</th>
			<th>SIDNY Exit Date</th>
			<th>SIDNY Exit Reason</th>
			<th>Attendance</th>
		</tr>
		</thead>
		<tbody>
		</tbody>
	</table>
</div>
<div id="edit" class="large-5 columns">
	<br><br><br><br><br><br><br><br>
	<div class="callout primary">
		<div id="selectedGNumber"></div>
		<div id="target"></div>
	</div>
</div>
</div>


<cfsavecontent variable="pcc_scripts">
<script>
	var table;
	var idx_billingStudentId = 0;
	var idx_program = 1;
	var idx_schooldistrict = 2;
	var idx_billingStartDate = 3;
	var idx_exitDate = 4;
	var idx_bsExitReasonDesc = 5;
	var idx_adjustedDays = 6;
	var idx_sidnyExitDate = 7;
	var idx_sidnyExitReason = 8;
	var idx_attendance = 9;
	var idx_firstname = 10;
	var idx_lastname = 11;
	var idx_bannerGNumber = 12;
	var idx_exitStatusReasonId = 13;
	var idx_SidnyExitKeyStatusReasonID = 14;
	var idx_contactId = 15;
	var idx_reasonCode = 16;

	var currentIndex = 0;

	$(document).ready(function() {
	    table = $('#dt_table').DataTable({
			ajax:{
				url: "programbilling.cfc?method=getExitDateList3",
				data: {billingStartDate:'<cfoutput>#DateFormat(dates.billingStartDate,"yyyy-mm-dd")#</cfoutput>'},
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			select: {
            	style: 'single'
        	},
			language: {emptyTable: 'Please wait...updating...will take a few minutes...'},
	    	dom: '<"top"if>rt<"bottom"lp>',
	    	columnDefs:[
	    		{targets:idx_billingStudentId,
	    		render: function ( data, type, row ) {
	    			return row[idx_firstname] + ' ' + row[idx_lastname] + '<br>' + row[idx_bannerGNumber];
	    			}
	    		},
        		{targets:[10,11,12,13,14,15,16], visible:false}
        	],
        	//scrollY:        "300px",
	        scrollX:        true,
	        //scrollCollapse: true,
	       // paging:         false,
	       pageLength:5,
	        fixedColumns:   {
	            leftColumns: 1,
	        },
        	order: [[idx_sidnyExitDate, 'desc']],
        	initComplete:function( settings, json){
        		currentIndex = table.rows({search:'applied'}).indexes()[0];
        		table.rows(currentIndex).select();
        		getStudent();
        		$('#waitMsg').hide();
	    	}

	    });
		//$('#dt_table tbody').on( 'click', 'tr', function () {
			//if ( $(this).hasClass('selected') ) {
           // 	$(this).removeClass('selected');
        	//}
       		//else {
            	//table.$('tr.selected').removeClass('selected');
            	//$(this).addClass('selected');
         //   	currentRow = this;
    	//		getStudent();
        	//}
		//} );
		table.on( 'select', function ( e, dt, type, indexes ) {
			currentIndex = indexes[0];
           	getStudent();
        } )

		filter();
	} );

	function toggleGrid(){
		var lnk = $('#resizeEdit');
		if(lnk.text() == "Make Bigger"){
			$('#grid').css("width", "35%");
			$('#edit').css("width", "65%");
			lnk.text("Make Smaller");
		}else{
			$('#grid').css("width", "65%");
			$('#edit').css("width", "35%");
			lnk.text("Make Bigger");
		}
	}
	function filter(){
		var d = $('#billingStartDate').val();
		d = d.replace(' 00:00:00.0','');
		table.columns(idx_billingStartDate) .search(d) .draw();
	}
	function getStudent(){
		rowData = table.rows( currentIndex ).data()[0];
		var heading = '<b>' + rowData[idx_firstname] + ' ' +  rowData[idx_lastname] + '</b> (<a href="programStudentDetail.cfm?billingStudentId=' + rowData[idx_billingStudentId] + '" target="_blank">' + rowData[idx_bannerGNumber] + ')</a><br>';
		heading += '<b>Billing Period:</b> ' + rowData[idx_billingStartDate] + '<br>';
		heading += rowData[idx_program] + ' / ' + rowData[idx_schooldistrict] + '<br>';
		heading += 'Attendance: ' + (rowData[idx_attendance] ? rowData[idx_attendance] : "") + '<br>';
		heading += '<b>SIDNY Exit: </b>' + (rowData[idx_sidnyExitDate] ? rowData[idx_sidnyExitDate] : "") + '<br>';
		heading += '<b>SIDNY Reason: </b>' + (rowData[idx_sidnyExitReason] ? rowData[idx_sidnyExitReason] : "") + '<br>';

		var url = "includes/exitReasonInclude.cfm?billingStudentId=" + rowData[idx_billingStudentId];
		var v = rowData[idx_adjustedDays] ? rowData[idx_adjustedDays] : '';
		url +=  '&adjustedDaysPerMonth=' + v;
	 	v = rowData[idx_exitDate] ? rowData[idx_exitDate] : '';
		url +=  '&exitDate=' + v;
	 	v = rowData[idx_reasonCode] ? rowData[idx_reasonCode] : '';
		url +=  '&billingStudentExitReasonCode=' + v;

		$.ajax({
			url: url,
       		cache: false,
			error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
				}
    	}).done(function(data) {
        	$("#selectedGNumber").html(heading);
        	$("#target").html(data);
    	});
	}
	function saveValues(frmId){
	 	var frm = $('#'+frmId);
	 	var id = frmId.substring(3,10);
	    $.ajax({
	       	url: 'report.cfc?method=updatebillingStudentRecordExit',
	       	type: 'POST',
	       	data: frm.serialize(),
	       	success: function (data, textStatus, jqXHR) {
				table.cell(currentIndex, idx_exitDate).data($('#exitDate'+id).val()).draw('page');
				table.cell(currentIndex, idx_adjustedDays).data($('#adjustedDaysPerMonth'+id).val()).draw('page');
				table.cell(currentIndex, idx_bsExitReasonDesc).data($('#billingStudentExitReasonCode' + id + ' option:selected').text()).draw('page');
				table.cell(currentIndex, idx_reasonCode).data($('#billingStudentExitReasonCode' + id + ' option:selected').val()).draw('page');
	    	},
			error: function (jqXHR, exception) {
	      		handleAjaxError(jqXHR, exception);
			}
		});
	}

	function addZero($time) {
	  if ($time < 10) {
	    $time = "0" + $time;
	  }
	  return $time;
	}
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">