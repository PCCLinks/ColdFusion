<!--- header --->
<cfinclude template="includes/header.cfm" />


<!--- main content --->
<style>
table.dataTable.caseload thead tr th {
    background-color: #4CAF50;
    color: white;
    text-align: left;
    border-bottom: 1px solid #ddd;
}
table.dataTable tbody tr td {
    padding-left: 20px;
}
input.gridfilter{
	margin-bottom: 0px !important;
	padding: 4px;
}
.dt-buttons{
	float:right !important;
}
.dataTables_wrapper .dataTables_processing{
	top: 70% !important;
	height: 50px !important;
	background-color: lightGray;
}
.dataTables_length select {
	width:auto !important;
}
</style>

<div id="caseload">
	<table id="dt_table_caseload" class="hover caseload" >
		<caption class="visually-hide">Future Connect Caseload</caption>
		<thead>
			<tr>
				<!--- note this order should match the order in the query in fc.getCaseloadList --->
				<th><span style="font-size:x-large;font-weight:bold;color:red">*</span></th>
				<th>Name</th>
				<th>G</th>
				<th>Cohort</th>
				<th>ASAP</th>
				<th>Status</th>
				<th>Coach</th>
				<th>Max Reg Term</th>
				<th>Last Contact</th>
				<th>Credits</th>
				<th></th>
			</tr>
		</thead>
		<tbody>

		<!--- handled by ajax query in datatable definition --->
		</tbody>
	</table>
</div>

<div id="student" style="display:none;"><cfinclude template="student.cfm"></div>
<div id="report" style="display:none;"><cfinclude template="report.cfm"></div>
<div id="dashboard" style="display:none;"></div>
<div id="import" style="display:none;"></div>

<cfsavecontent variable="pcc_scripts">
<script >

	// CASELOAD FUNCTIONS
	var txt_includeAllFilter = "show archives";
	var txt_excludeArchive = "exclude archives";
	var txt_includeAllCoaches = "all coaches";
	var txt_myCaseload = "my caseload";
	var txt_flaggedOnly = "*";
	var txt_clearFlagged = "clear *"

	//column integers
	//note contactid is the column used for flagged, column flagged is hidden
	var idx_contactid = 0;
	var idx_stu_name = 1;
	var idx_bannerGNumber = 2;
	var idx_cohort = 3;
	var idx_ASAP_status = 4;
	var idx_statusinternal = 5;
	var idx_coach = 6;
	var idx_maxterm = 7;
	var idx_lastContactDate = 8;
	var idx_creditsEarned = 9;
	//these are all hidden
	var idx_pidm = 10;
	var idx_in_contract = 11;
	var idx_pcc_email = 12;
	var idx_flagged = 13;
	var idx_deleteStatus = 14;

	var currentIndex = 0;
	var selectedPidm = 0;
	var selectedMaxTerm = 0;
	var selectedContactId = 0;
	var dt_caseload;

	$(document).ready(function() {
		initializeCaseloadTable();
		loaded.push(CASELOAD_DIV);
		//this loads the student.cfm too
		loaded.push(STUDENT_DIV);
		loadedScreen = CASELOAD_DIV;
	} );


	//initialize table
	function initializeCaseloadTable(){
		//alert('initialize');
		$.fn.dataTable.ext.errMode = 'throw';

		dt_caseload = $('#'+ DT_TABLE).DataTable( {
			processing:true,
			ajax:{
				url:"fc.cfc?method=getCaseloadList",
				dataSrc:'DATA',
				columns:'COLUMN',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},

			select: {
            	style: 'os',
            	selector: 'td:nth-child(10)'
        	},
        	language:{ processing: "<img src='<cfoutput>#pcc_source#</cfoutput>/images/ajax-loader.gif' height=35 width=35 style='opacity:0.5;'>&nbsp;&nbsp;Loading data..."},
			lengthMenu: [[10, 20, 50, 100, -1], [10, 20, 50, 100, "All"]],
			order: [[ idx_coach, "asc" ],[idx_cohort, "desc"] ],
			columnDefs: [
         		{targets:[idx_in_contract,idx_pcc_email, idx_flagged, idx_deleteStatus], visible:false},

				<!--server code determines:-->
				<!--if user is a coach, show flag checkbox otherwise,  contactid column hidden-->
         		<cfif Session.userPosition EQ "Coach">
				{targets:idx_contactid,
				 	sortable:false,
				 	render: function ( data, type, row ) {
				 				checked = "";
				 				if(row[idx_flagged]==1){
				 					checked = "checked";
				 				}
                  				return '<input class="flag-contact" id=' + data + ' type="checkbox" onclick="javascript:saveFlag(this)" value=' + row[idx_flagged] + ' ' + checked + ' >';
             				}
				 	},
				 <cfelse>
				 {targets:[idx_contactid], visible:false},
				 </cfif>

				 //editable link column is not sortable
				 {targets:idx_pidm,
				 	sortable:false,
				 	render: function ( data, type, row, meta ) {
				 				if(row[idx_deleteStatus] == -1){
				 					return '<span style="color:red">deleted</span>';
				 				}else{
	                  				return '<a href="javascript:goToDetail(' + data + ', \'' + row[idx_maxterm] +'\', ' + row[idx_contactid] + ', ' + meta.row + ')">Edit</a>';
				 				}
             				}
				 	}
				],
			dom: '<"top"iB>rt<"bottom"flp>',
			buttons: [

            	//Export Grid Button
            	{
            	  extend: 'csv',
            	  text: 'export',
                  exportOptions: { columns: [idx_pcc_email, idx_stu_name, idx_bannerGNumber,
                  					idx_cohort, idx_ASAP_status, idx_statusinternal, idx_coach,
                  					idx_maxterm, idx_lastContactDate] }
            	},
            	//Copy Email Button
            	{
            	  extend: 'copy',
            	  text: 'copy email',
                  exportOptions: { columns: [idx_pcc_email] }
            	},
            	//Filter Button
            	{
            	<cfoutput>
				<cfif Session.userPosition EQ "Coach">
            	  text: txt_includeAllFilter,
            	<cfelse>
				  text: txt_excludeArchive,
				</cfif>
				</cfoutput>
            	  action: function( e, dt, node, config ){
					filterContract(dt, this);
            	  }
            	},
            	<cfoutput><cfif Session.userPosition EQ "Coach">
            	//Flag Button
            	{
            	  text: txt_flaggedOnly,
            	  action: function( e, dt, node, config ){
            	  	filterFlagged(dt, this);
            	  }
            	},
            	//Coaches Button
            	{
            	  text: txt_includeAllCoaches,
            	  action: function( e, dt, node, config ){
            	  	filterCoach(dt, this);
            	  }
            	},
            	</cfif></cfoutput>
            ],

            <!-- conditional coloring based on value-->
            rowCallback: function(row, data, index){
            	color = '';
				idx_td_ASAP = $('#ASAP').parent().index();
            	if(data[idx_ASAP_status] == "SU"){
            		color = '#f78989';
            	}
            	if(data[idx_ASAP_status] == "AP"){
            		color = '#eab24c';
            	}
            	if(data[idx_ASAP_status] == "AW"){
            		color = '#f9f96f';
            	}
            	if(color.length>0){
            		//find the cell for idx_ASAP_status and set the background to the specified color
    				$(row).find('td:eq(' + idx_td_ASAP + ')').css('background-color', '"' + color +'"' );
            	}
         	},
         	initComplete: function(){
         		initializeCaseload();
         	}

		}); //end initialize

	}

	function initializeCaseload(){

		<cfif Session.userPosition EQ "Coach">
		//attached to checkbox click for setting the "flag"
 		//$('#' + DT_TABLE).find('td').click(function(){
 		//	saveFlag(this);
 		//});
 		</cfif>

		//hide main filter
		$(".dataTables_filter").hide();

		// Setup - add a text input to each header cell
		$('#'+ DT_TABLE + ' thead th').each( function () {
			var title = $(this).text();
			if (title.length > 0 && title != '*') {
			$(this).html( '<input class="gridfilter" type="text" placeholder="'+title+'" id="'+title+'" />' );
			}
		} ); //end add filter

		// Apply the search
		dt_caseload.columns().every( function () {
			var that = this;
			$( 'input', this.header() ).on( 'keyup change', function () {
				//credits column search we handle differently than the other columns, so skip
				if(this.id == "Credits")
					return;

				//allowing for a "not equals" search
				//if user has entered "!" as the first character, going to apply regEx
				//to cause that value to be excluded from the search
				var value = this.value;
				var isRegEx = false;
				//user entered "!" as first character, apply regex, by adding characters to the value in the field
				if(value.charAt(0)=="!"){
						value = '^(?'+ value + ')';
						isRegEx = true;
				}
				//apply search
				if ( that.search() !== value ) {
					that
						.search( value, isRegEx, !isRegEx )
						.draw();
				}
			} );

			//stop it from sorting when you click into the header
			$( 'input', this.header() ).on('click', function(e) {
        		e.stopPropagation();
    		});
		});// end search

		//filter if "in or out of contract" - filter to in contract for coaches
		<cfoutput>
		<cfif Session.userPosition EQ "Coach">
		dt_caseload.column(idx_in_contract).search("Yes").draw();
		</cfif>
		</cfoutput>

		//filter coach, if user is coach
		<cfoutput>
		<cfif Session.userPosition EQ "Coach">
		dt_caseload.column(idx_coach).search("#Session.userDisplayName#").draw();
        $('##Coach').val("#Session.userDisplayName#");
		</cfif>
		</cfoutput>

		//attach to the credits fields
		$('#minCredits, #maxCredits, #Credits').keyup( function() {
        	dt_caseload.draw();
    	} );

    	//Custom filtering function which will search data in column four between two values
		$.fn.dataTable.ext.search.push(
		    function( settings, data, dataIndex ) {
		    	if( $('#Credits').val().charAt(0) == ">"){
		    		var min = parseInt( $('#Credits').val().substring(1), 10 )+1;
		    	}
		    	if( $('#Credits').val().charAt(0) == "<"){
		    		var max = parseInt( $('#Credits').val().substring(1), 10 )-1;
		    	}
		        var credits = parseFloat( data[idx_creditsEarned] ) || 0;

		        if ( ( isNaN( min ) && isNaN( max ) ) ||
		             ( isNaN( min ) && credits <= max ) ||
		             ( min <= credits   && isNaN( max ) ) ||
		             ( min <= credits   && credits <= max ) )
		        {
		            return true;
		        }
		        return false;
		    }
		);

	} //END INITIALIZE CASELOAD


  // save flag checkbox changes
   function saveFlag(checkBox){
		flagged = (checkBox.checked ? 1 : 0);

		//set the underlying data in the flagged column for filtering
		row = checkBox.parentElement.parentElement;
		var rowData = dt_caseload.row(row).data();
		rowData[idx_flagged] = flagged;
		dt_caseload.row(row).data(rowData).draw();

		//save flag to record, id = contactid
		$.ajax({
			url: "fc.cfc?method=updateFlagContact",
			type: "POST",
			async: false,
			data: { contactid: checkBox.id, flagged:flagged },
			error: function (jqXHR, exception) {
		        handleAjaxError(jqXHR, exception);
			}
		});
	}


	function filterContract(dt, button) {
		filter =  button.text() == txt_includeAllFilter ? "" : "Yes";
		dt_caseload.column(idx_in_contract).search(filter).draw();
		buttonText = button.text() == txt_includeAllFilter ? txt_excludeArchive : txt_includeAllFilter;
        button.text(buttonText);
	}

	function filterFlagged(dt, button) {
		filter =  button.text() == txt_flaggedOnly ? "1" : "";
		dt_caseload.column(idx_flagged).search(filter).draw();
		buttonText = button.text() == txt_flaggedOnly ? txt_clearFlagged : txt_flaggedOnly;
        button.text(buttonText);
	}

	function filterCoach(dt, button){
		<cfoutput>
		var userDisplayName = "#Session.userDisplayName#";
		</cfoutput>
		filter =  button.text() == txt_myCaseload ? userDisplayName : "";
		dt_caseload.column(idx_coach).search(filter).draw();
        button.text(button.text() == txt_myCaseload ? txt_includeAllCoaches : txt_myCaseload);
        $('#Coach').val(filter);
    }

    function goToDetail(pidm, maxterm, contactid, rowIndex){
		$("body").css("cursor", "progress");
		currentIndex = rowIndex;
		selectedContactId = contactid;
		selectedPidm = pidm;
		selectedPidmMaxTerm = maxterm;
		dt_caseload.rows(currentIndex).select();
		showScreen(STUDENT_DIV);
	}


	function refreshCaseload(){
		$.ajax({
            type: 'post',
            url: 'fc.cfc?method=getCaseloadList',
            data: {contactId:selectedContactId, isAjax:'yes'},
            datatype:'json',
            async:false,
            success: function (data, textStatus, jqXHR) {
            	var row = jQuery.parseJSON(data);
            	dt_caseload.row(currentIndex).data(row.DATA[0]);
		    },
            error: function (xhr, textStatus, thrownError) {
				 handleAjaxError(xhr, textStatus, thrownError);
			}
		 });
	}


</script>

</cfsavecontent>


<!--- footer --->
<cfinclude template="includes/footer.cfm" />
