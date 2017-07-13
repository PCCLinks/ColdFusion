<!--- header --->
<cfinclude template="includes/header.cfm" />

<!--- main content --->
<style>
table.dataTable thead tr th {
    background-color: #4CAF50;
    color: white;
    text-align: left;
    border-bottom: 1px solid #ddd;
}
table.dataTable tbody tr td {
    padding-left: 20px;
}
input{
	margin-bottom: 0px !important;
	padding: 4px;
}
.dt-buttons{
	float:right !important;
}
select {
	width:auto !important;
}
.dataTables_wrapper .dataTables_processing{
	top: 70% !important;
	height: 50px !important;
	background-color: lightGray;
}
</style>
<!--- filter row
<div class="row">
	<div class="medium-3 columns">
	</div>
	<div class="medium-3 columns">
		<span class="radios">
			<legend>
				Include out-of-contract students
			</legend>
			<input type="radio" name="contractFilter" class="contractFilter" value="No" id="contractNo" checked="checked" />
			<label for="contractNo">
				No
			</label>
			<input type="radio" name="contractFilter" class="contractFilter" value="Yes" id="contractYes" />
			<label for="contractYes">
				Yes
			</label>
		</span>
	</div>
</div> <!--- end filter row --->--->

<!--- output qryData --->
<cfoutput>
<table id="dt_table" class="hover" ;>
	<caption class="visually-hide">Future Connect Caseload</caption>
	<thead>
		<tr>
			<th><span style="font-size:x-large;font-weight:bold;color:red">*</th>
			<th>Coach</th>
			<th>Cohort</th>
			<th>G</th>
			<th>Name</th>
			<th>ASAP</th>
			<th>Status</th>
			<th>Last Contact</th>
			<th></th>
		</tr>
	</thead>
	<tbody>
	<!---<cfloop query="qryData">
    	<tr>
      		<td>#DateFormat(qryData.LASTCONTACTDATE,'m/d/y')#</td>
      		<td>#qryData.COACH#</td>
      		<td>#qryData.COHORT#</td>
      		<td>#qryData.STU_ID#</td>
      		<td>#qryData.STU_NAME#</td>
      		<!--- conditional coloring based on value--->
      		<td
      			<cfif ASAP_STATUS eq "SU"> style = "background-color: ##f78989;"
				<cfelseif ASAP_STATUS eq "AP"> style = "background-color: ##eab24c;"
				<cfelseif ASAP_STATUS eq "AW"> style = "background-color: ##f9f96f;"
				</cfif>
			>#qryData.ASAP_STATUS#</td>
      		<td>#qryData.STATUSINTERNAL#</td>
      		<td>#qryData.IN_CONTRACT#</td>
      		<td>#qryData.PCC_EMAIL#</td>
      		<td>#qryData.EditLink#</td>
      	</tr>
    </cfloop>--->
	</tbody>
</table>
</cfoutput>

<!--- script referenced in include footer --->
<cfsavecontent variable="pcc_scripts">
<script>
	var txt_includeAllFilter = "include out-of-contract";
	var txt_excludeOutOfContract = "exclude out-of-contract";
	var txt_includeAllCoaches = "all coaches";
	var txt_myCaseload = "my caseload";
	var txt_flaggedOnly = "*";
	var txt_clearFlagged = "clear *"

	//column integers
	//note contactid is the column used for flagged, column flagged is hidden
	var idx_contactid = 0;
	var idx_coach = 1;
	var idx_cohort = 2;
	var idx_bannerGNumber = 3;
	var idx_stu_name = 4;
	var idx_ASAP_status = 5;
	var idx_statusinternal = 6;
	var idx_lastContactDate = 7;
	//these are all hidden
	var idx_pidm = 8;
	var idx_in_contract = 9;
	var idx_pcc_email = 10;
	var idx_maxterm = 11;
	var idx_flagged = 12;

	$(document).ready(function() {
		//intialize table
		$.fn.dataTable.ext.errMode = 'throw';

		dt = $('#dt_table').DataTable( {
			processing:true,
			ajax:{
				url:"fc.cfc?method=getCaseloadList",
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			language:{ processing: "Loading data..."},
			lengthMenu: [[100, 50, -1], [100, 50, "All"]],
			order: [[ idx_coach, "asc" ],[idx_cohort, "desc"] ],
			columnDefs: [
         		 {targets:[idx_in_contract,idx_pcc_email,idx_maxterm,idx_flagged], visible:false},

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
				 	render: function ( data, type, row ) {
                  				return '<a href="javascript:goToDetail('+data+', ' + row[idx_maxterm] +', ' + row[idx_contactid] + ')">Edit</a>';
             				}
				 	}
				],
			dom: '<"top"iB>rt<"bottom"flp>',
			buttons: [

            	//Copy Email Button
            	{
            	  extend: 'copy',
            	  text: 'copy email',
                  exportOptions: { columns: [idx_pcc_email] }
            	},
            	//Filter Button
            	{
            	  text: txt_includeAllFilter,
            	  action: function( e, dt, node, config ){
					filterContract(dt, this);
            	  }
            	}
            	<cfoutput><cfif Session.userPosition EQ "Coach">
				,
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
            	}
            	</cfif></cfoutput>
            ],
            <!--- conditional coloring based on value--->
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
		}); //end initialize

 		$('#dt_table').find('td').click(function(){
 			saveFlag(this);
 		});

		//var dt = $('#dt_table').DataTable();
		//hide main filter
		$(".dataTables_filter").hide();

		// Setup - add a text input to each header cell
		$('#dt_table thead th').each( function () {
			var title = $(this).text();
			if (title.length > 0 && title != '*') {
			$(this).html( '<input type="text" placeholder="'+title+'" id="'+title+'" />' );
			}
		} ); //end add filter

		// Apply the search
		dt.columns().every( function () {
			var that = this;
			$( 'input', this.header() ).on( 'keyup change', function () {
				if ( that.search() !== this.value ) {
					that
						.search( this.value )
						.draw();
				}
			} );
			//stop it from sorting when you click into the header
			$( 'input', this.header() ).on('click', function(e) {
        		e.stopPropagation();
    		});
		});// end search

		//filter contract
		dt.column(idx_in_contract).search("Yes").draw();

		//filter coach, if user is coach
		<cfoutput>
		<cfif Session.userPosition EQ "Coach">
		dt.column(idx_coach).search("#Session.userDisplayName#").draw();
        $('##Coach').val("#Session.userDisplayName#");
		</cfif>
		</cfoutput>

	} ); //end document ready

   // save flag checkbox changes
   function saveFlag(checkBox){
		$.blockUI({ message: 'Just a moment...' });
		flagged = (checkBox.checked ? 1 : 0);

		//set the underlying data in the flagged column for filtering
		var table = $('#dt_table').DataTable();
		row = checkBox.parentElement.parentElement;
		var rowData = table.row(row).data();
		rowData[idx_flagged] = flagged;
		table.row(row).data(rowData).draw();

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
		$.unblockUI();
	}
	function filterContract(dt, button) {
		filter =  button.text() == txt_includeAllFilter ? "" : "Yes";
		dt.column(idx_in_contract).search(filter).draw();
		buttonText = button.text() == txt_includeAllFilter ? txt_excludeOutOfContract : txt_includeAllFilter;
        button.text(buttonText);
	}
	function filterFlagged(dt, button) {
		filter =  button.text() == txt_flaggedOnly ? "1" : "";
		dt.column(idx_flagged).search(filter).draw();
		buttonText = button.text() == txt_flaggedOnly ? txt_clearFlagged : txt_flaggedOnly;
        button.text(buttonText);
	}
	function filterCoach(dt, button){
		<cfoutput>
		var userDisplayName = "#Session.userDisplayName#";
		</cfoutput>
		filter =  button.text() == txt_myCaseload ? userDisplayName : "";
		dt.column(idx_coach).search(filter).draw();
        button.text(button.text() == txt_myCaseload ? txt_includeAllCoaches : txt_myCaseload);
        $('#Coach').val(filter);
    }

	function goToDetail(pidm, maxterm, contactid){
		sessionStorage.setItem('pidm', pidm);
		sessionStorage.setItem('maxterm', maxterm);
		//sessionStorage.setItem('contactid', contactid);
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  		$.post("SaveSession.cfm", data, function(){
  			window.location	='student.cfm';
  		});
	}

</script>
</cfsavecontent>

<!--- footer --->
<cfinclude template="includes/footer.cfm" />
