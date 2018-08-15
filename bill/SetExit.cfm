<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>
<cfinvoke component="pcclinks.bill.LookUp" method="getExitReasons" returnvariable="exitReasons"></cfinvoke>
<cfinvoke component="Lookup" method="getCurrentProgramYear" returnvariable="programyear"></cfinvoke>

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
	<div id="validateDialog"></div>
<div class="callout primary">
<div class="row">
	<div class="small-6 columns">
	<p><b>Update Exit Date and Reason</b></p>
	<label for="billingStartDate">Attendance Entry for:&nbsp;&nbsp;
	<select name="billingStartDate" id="billingStartDate" onChange="javascript:filter();" style="width:200px">
		<option selected value="" selected > --Select All-- </option>
		<cfoutput query="billingDates">
			<option value="#billingStartDate#"> #DateFormat(billingStartDate,'yyyy-mm-dd')# </option>
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
			<th>Billing Date</th>
			<th>Exit Date</th>
			<th>Exit Reason</th>
			<th>Adj Days</th>
			<th>SIDNY Exit Date</th>
			<th>SIDNY Exit Reason</th>
			<th>Attendance</th>
			<th>Program</th>
			<th>District</th>
		</tr>
		</thead>
		<tbody>
		</tbody>
	</table>
</div>
<div id="edit" class="large-5 columns">
	<br><br>

	<div class="callout primary" id="studentDetail">
		<div id="selectedGNumber"></div>
		<div id="target"><cfinclude template="includes/exitStudentInclude.cfm"></div>
	</div>
</div>
</div>


<cfsavecontent variable="pcc_scripts">
<script>
	var table;
	var idx_grid_billingStudentId = 0;
	var idx_grid_billingStartDate = 1;
	var idx_grid_exitDate = 2;
	var idx_grid_bsExitReasonDesc = 3;
	var idx_grid_adjustedDays = 4;
	var idx_grid_sidnyExitDate = 5;
	var idx_grid_sidnyExitReason = 6;
	var idx_grid_attendance = 7;
	var idx_grid_program = 8;
	var idx_grid_schooldistrict = 9;
	var idx_grid_firstname = 10;
	var idx_grid_lastname = 11;
	var idx_grid_bannerGNumber = 12;
	var idx_grid_exitStatusReasonId = 13;
	var idx_grid_SidnyExitKeyStatusReasonID = 14;
	var idx_grid_contactId = 15;
	var idx_grid_reasonCode = 16;
	var idx_grid_sidnySecondaryReason = 17;
	var idx_grid_sidnyExitNote = 18;

	var currentIndex = 0;

	var selectedGridRow;
	var selectedGridData;


	$(document).ready(function() {
	    table = $('#dt_table').DataTable({
			ajax:{
				url: "programbilling.cfc?method=getExitDateList",
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			select: {
            	style: 'os'
        	},
        	lengthMenu: [[100, 50, , 10, 5, -1], [100, 50, 10, 5, "All"]],
			language: {emptyTable: 'Please wait...updating...will take a few minutes...'},
	    	dom: '<"top"if>rt<"bottom"lp>',
	    	columnDefs:[
	    		{targets:idx_grid_billingStudentId,
	    		render: function ( data, type, row ) {
	    			return row[idx_grid_firstname] + ' ' + row[idx_grid_lastname] + '<br>' + row[idx_grid_bannerGNumber];
	    			}
	    		},
        		{targets:[10,11,12,13,14,15,16,17,18], visible:false}
        	],
        	rowCallback: function(row, data, index){
            	color = '';
            	if(data[idx_grid_sidnyExitDate] <  data[idx_grid_billingStartDate] || data[idx_grid_sidnyExitDate] != data[idx_grid_exitDate]){
            		color = '#f78989';
            	}
            	if(color.length>0){
            		//find the cell for idx_sidnyExitDate and set the background to the specified color
    				$(row).find('td:eq(' + idx_grid_sidnyExitDate + ')').css('background-color', '"' + color +'"' );
            	}else{
            		$(row).find('td:eq(' + idx_grid_sidnyExitDate + ')').css('background-color', "" );
            	}
        	},
	        scrollX:        true,
	        pageLength:5,
	        fixedColumns:   {
	            leftColumns: 1,
	        },
        	order: [[idx_grid_sidnyExitDate, 'desc']],
        	initComplete:function( settings, json){
        		currentIndex = table.rows({search:'applied'}).indexes()[0];
        		table.rows(currentIndex).select();
        		$('#waitMsg').hide();
	    	}

	    });
		table.on( 'select', function ( e, dt, type, indexes ) {
			selectedGridRow =  table.row( indexes );
		    selectedGridData = table.row( indexes ).data();
           	getStudent();
        } );

    	table.on( 'user-select', function ( e, dt, type, cell, originalEvent ) {
    		var rowIdx = cell.index().row;

	        if ( $(table.row(rowIdx).node()).hasClass("selected") ) {
	            e.preventDefault();
	        }
    	} );

    	table.on( 'page.dt', function ( e, dt, type, indexes ) {
        	if ( table.rows( '.selected' ).any() ) {
        		table.rows('.selected').deselect();
        	}
        } );

		$(".dataTables_filter :input").keypress(function(){
			if ( table.rows( '.selected' ).any() ) {
        		table.rows('.selected').deselect();
        	}
		})

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
		if(d != ''){
			d = d.replace(' 00:00:00.0','');
			table.columns(idx_grid_billingStartDate).search(d).draw();
		}else{
			table.columns(idx_grid_billingStartDate).search('').draw();
		}
	}
	function getStudent(){
		var heading = '<b>' + selectedGridData[idx_grid_firstname] + ' ' +  selectedGridData[idx_grid_lastname] + '</b> (<a href="javascript:getBillingStudent(' + selectedGridData[idx_grid_billingStudentId] + ', true);" target="_blank">' + selectedGridData[idx_grid_bannerGNumber] + ')</a><br>';
		heading += selectedGridData[idx_grid_program] + ' / ' + selectedGridData[idx_grid_schooldistrict] + '<br>';
		heading += 'Attendance: ' + (selectedGridData[idx_grid_attendance] ? selectedGridData[idx_grid_attendance] : "") + '<br>';
		heading += '<div class="callout primary"><b>SIDNY Exit: </b>' + (selectedGridData[idx_grid_sidnyExitDate] ? selectedGridData[idx_grid_sidnyExitDate] : "") + '<br>';
		heading += '<b>Reason: </b>' + (selectedGridData[idx_grid_sidnyExitReason] ? selectedGridData[idx_grid_sidnyExitReason] : "") + '<br>';
		heading += '<b>Sec. Reason: </b>' + (selectedGridData[idx_grid_sidnySecondaryReason] ? selectedGridData[idx_grid_sidnySecondaryReason] : "") + '<br>';
		heading += '<b>Exit Note: </b>' + (selectedGridData[idx_grid_sidnyExitNote] ? selectedGridData[idx_grid_sidnyExitNote] : "") + '</div>';
		$("#selectedGNumber").html(heading);
		exitStudentInclude_populateStudent('<cfoutput>#programyear#</cfoutput>');
	}



</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">