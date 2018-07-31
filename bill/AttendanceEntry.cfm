<cfinclude template="includes/header.cfm" />

<cfinvoke component="LookUp" method="getFirstOpenAttendanceDate"  returnvariable="attendanceDate"></cfinvoke>
<cfparam name="selectedBillingStartDate" default = #attendanceDate# >
<cfif structKeyExists(url, "billingStartDate")>
	<cfset Variables.selectedBillingStartDate = url.billingStartDate>
</cfif>

<cfparam name="selectedCRN" default="">
<cfif structKeyExists(url, "crn")>
	<cfset Variables.selectedCRN = url.crn>
<cfelse>
	<cfif structKeyExists(Session, "selectedCRN")>
		<cfset Variables.selectedCRN = Session.selectedCRN>
	</cfif>
</cfif>


<cfinvoke component="LookUp" method="getAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>


<style>
.columns.display{
	border-bottom-color:gray;
	border-bottom-width:1px;
	border-bottom-style:solid;
	padding-right:0px;
	background-color: rgb(238,238,238);

}
.columns{
	padding-top: 3px;
	padding-bottom:3px;
}



</style>


<div class="callout" id="attendanceHeader">
	<div class="row">
		<div class="small-5 medium-3 columns">
			<label for="billingStartDate">Month Start Date:
				<select name="billingStartDate" id="billingStartDate" onChange="javascript:getCRN()">
					<option disabled selected value="" > --Select Month Start Date-- </option>
				<cfoutput query="billingDates">
					<option value="#billingStartDate#" <cfif billingStartDate EQ selectedBillingStartDate> selected </cfif>  > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
				</cfoutput>
				</select>
			</label>
		</div>
		<div class="small-6 medium-4 columns" id="crnselect"></div>
		<div class="small-1 medium-5 columns"><br>
			<input id="btnAddClass" type="button" class="button" value="Add New Class" onClick="javascript:addClass();">
			<input id="btnAddLab" type="button" class="button" value="Add Lab" onClick="javascript:addLab();">
			<input id="btnAddStudent" type="button" class="button" value="Add Student" onClick="javascript:addStudent();">
			<input id="btnShowAttendance" type="button" class="button" value="Enter Attendance" onClick="javascript:showAttendance();">
		</div>
	</div>
</div>

<div id="attendanceEntry"></div>
<div id="addStudent"></div>
<div id="addClass"></div>

<cfsavecontent variable="pcc_scripts">
<script>
	var selectedCRN = '<cfoutput>#selectedCRN#</cfoutput>';

	var addBillingStudentTable = null;
	$(document).ready(function() {
		getCRN();
		if(selectedCRN != ''){
			getAttendanceEntryInclude();
		}

		//#showHideButtons(showAddClass, showAddLab, showShowStudent, showShowAttendance)
		showHideButtons(true, false, false, false);

	});

	function addClass(){

		$('#attendanceHeader').hide();
		$('#attendanceEntry').hide();
		$('#addClass').show();

		$.ajax({
        	url: "includes/addNewClassInclude.cfm?billingStartDate=" + $('#billingStartDate').val(),
       		cache: false
    	}).done(function(data) {
        	$("#addClass").html(data);
    	});
	}
	function getCRN(){
		var url = "includes/crnForTermInclude.cfm?billingStartDate=" + $('#billingStartDate').val();
		if(selectedCRN){
			url = url + '&crn=' + selectedCRN;
		}
		$.ajax({
        	url: url,
       		cache: false
    	}).done(function(data) {
        	$("#crnselect").html(data);
        	getCRNChanged();
    	});
	}
	function getCRNChanged(){
		selectedCRN = $('#crn').val();
		getAttendanceEntryInclude();
	}
	function getAttendanceEntryInclude(){
		$.ajax({
        	url: "includes/attendanceEntryInclude.cfm?billingStartDate="+$('#billingStartDate').val()+'&crn='+ selectedCRN,
       		cache: false
    	}).done(function(data) {
        	$('#attendanceEntry').html(data);
			$('#addStudent').hide();
			$('#attendanceEntry').show();
			loadMissingStudents();

			//#showHideButtons(showAddClass, showAddLab, showShowStudent, showShowAttendance)
			showHideButtons(true, true, true, false);
    	});
	}
	function saveEntry(id){
		var attendance = $('#attendance'+id).val();
		var maxPossAttendance = $('#numberOfDays'+id).val();
		var notes = $('#notes'+id).val();
		$.ajax({
	          type: 'post',
	          url: 'programBilling.cfc?method=updateAttendance',
	          data: {billingStudentItemId: id, attendance: attendance, maxPossibleAttendance: maxPossAttendance, notes: notes},
	          datatype:'json',
	          error: function (jqXHR, exception) {
				handleAjaxError(jqXHR, exception);
			}
		});
	}
	function doPaste(billingStudentItemId){
		var data = $('#paste'+billingStudentItemId).val();
		//$.blockUI({ message: 'Saving...' });
		$.ajax({
	    	type: 'post',
	        url: 'programBilling.cfc?method=updateAttendanceDetail',
	        data: {detailValues: data, billingStudentItemId: billingStudentItemId},
	        datatype:'json',
	        success: function(data, success){
	          	$('#detail'+billingStudentItemId)
	           		.load('includes/billingStudentItemDetailInclude.cfm?billingStudentItemId='+billingStudentItemId
	           				, function(){
	           					$(this).foundation();
	           				}
	           			);
	           		var obj = JSON.parse(data);
					$('#attendance'+billingStudentItemId).val(obj.attendance);
					$('#numberOfDays'+billingStudentItemId).val(obj.numberOfDays);
	           },
	            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
				}
	        });
			//$.unblockUI();
	}
	function showStudents(){
		$('#addStudent').show();
		$('#attendanceEntry').hide();

		//#showHideButtons(showAddClass, showAddLab, showShowStudent, showShowAttendance)
		showHideButtons(false, false, false, true);

		$.ajax({
        	url: 'includes/AddStudentsToClassInclude.cfm?billingStartDate=' + $('#billingStartDate').val() + '&crn='+selectedCRN,
       		cache: false
    	}).done(function(data) {
        	$("#addStudent").html(data);
    	});
	}
	function showAttendance(){
		if(selectedCRN == ""){
			$('#attendanceHeader').show();
			$('#addStudent').hide();
			$('#addClass').hide();

			//#showHideButtons(showAddClass, showAddLab, showShowStudent, showShowAttendance)
			showHideButtons(true, false, false, false);
		}else{
			$('#attendanceHeader').show();
			$('#attendanceEntry').show();
			$('#addStudent').hide();
			$('#addClass').hide();
			getAttendanceEntryInclude();
		}
	}
	function addLab(){
		var response = window.confirm('Add Lab for CRN ' + selectedCRN);
		if(response)
		{
			$.ajax({
	            type: 'post',
	            url: 'programBilling.cfc?method=addLab',
	            data: {crn: selectedCRN, billingStartDate: $('#billingStartDate').val()},
	            datatype:'text/plain',
	            success: function(newCRN){
	            	selectedCRN = newCRN;
	            	getCRN();
	            },
	            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
				}
        });
		}
	}
	function showHideButtons(showAddClass, showAddLab, showShowStudent, showShowAttendance){
		if(showAddClass){
			$('#btnAddClass').show();
		}else{
			$('#btnAddClass').hide();
		}

		if(showAddLab){
			$('#btnAddLab').show();
		}else{
			$('#btnAddLab').hide();
		}

		if(showShowStudent){
			$('#btnShowStudent').show();
		}else{
			$('#btnShowStudent').hide();
		}

		if(showShowAttendance){
			$('#btnShowAttendance').show();
		}else{
			$('#btnShowAttendance').hide();
		}
	}

	function removeItem(billingStudentItemID, billingStudentID)
	{
		var response = window.confirm('Are you sure you want to remove this item?');
		if(response)
		{
			$.blockUI({ message: '<h1>Just a moment...</h1>' });
			$.ajax({
	            type: 'post',
	            url: 'programBilling.cfc?method=setBillingStudentItemInactive',
	            data: {billingStudentItemID: billingStudentItemID},
	            datatype:'json',
	            async:false,
	            success: function(){
	            	$('#' + billingStudentID).parent().html('<input type="checkbox" id=' + billingStudentID + ' onclick="javascript:insertItem(' + billingStudentID + ', ' + billingStudentItemID + ');">');
	            },
	            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
				}
        	});
        	//refresh page
        	getAttendanceEntryInclude();
        	$.unblockUI();
		}
	}
	function addStudent(){
		var data = $.param({selectedCRN:selectedCRN, addStudentReturnPage:'attendanceEntry.cfm'});
  		$.post("SaveSession.cfm", data, function(){
  			window.location	='addStudent.cfm?type=Attendance';
  		});
	}
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
