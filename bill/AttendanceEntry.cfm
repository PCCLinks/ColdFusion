<cfinclude template="includes/header.cfm" />

<cfinvoke component="LookUp" method="getLatestDateAttendanceMonth"  returnvariable="attendanceMonth"></cfinvoke>
<cfparam name="selectedBillingStartDate" default = #attendanceMonth# >
<cfif structKeyExists(url, "billingStartDate")>
	<cfset Variables.billingStartDate = url.billingStartDate>
</cfif>

<cfparam name="selectedCRN" default="">
<cfif structKeyExists(url, "crn")>
	<cfset Variables.selectedCRN = url.crn>
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

<!---
<cfinvoke component="SetUpBilling" method="getClassAttendanceForEdit"  returnvariable="data">
	<cfinvokeargument name="crn" value="#Variables.CRN#">
	<cfinvokeargument name="term" value="#Variables.Term#">
	<cfinvokeargument name="billingdate" value="#Variables.BillingDate#">
</cfinvoke>


<cfquery name="heading" dbtype="query">
	select crn, crse, subj, title
	from data
	group by crn, crse, subj, title
</cfquery>
--->

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
			<input id="btnSaveClass" type="button" class="button" value="Save" onClick="javascript:addClass();">
			<input id="btnShowStudent" type="button" class="button" value="Add/Remove Students" onClick="javascript:showStudents();">
			<input id="btnShowAttendance" type="button" class="button" value="Enter Attendance" onClick="javascript:showAttendance();">
		</div>
	</div>
</div>

<div id="attendanceEntry"></div>
<div id="addStudent"></div>
<div id="addClass"></div>

<cfsavecontent variable="pcc_scripts">
<script>
	var crn = '<cfoutput>#selectedCRN#</cfoutput>';
	$(document).ready(function() {
		getCRN(crn);
		if(crn != ''){
			getCRNChanged(crn);
		}
		$('#btnAddLab').hide();
		$('#btnSaveClass').hide();
		$('#btnShowStudent').hide();
		$('#btnShowAttendance').hide();

	});

	function addClass(){
		$.ajax({
        	url: "includes/addNewClassInclude.cfm?billingStartDate=" + $('#billingStartDate').val(),
       		cache: false
    	}).done(function(data) {
			$('#attendanceHeader').hide();
			$('#attendanceEntry').hide();
			$('#addClass').show();
        	$("#addClass").html(data);
    	});
	}
	function getCRN(crn){
		var url = "includes/crnForTermInclude.cfm?billingStartDate=" + $('#billingStartDate').val();
		if(crn){
			url = url + '&crn=' + crn;
		}
		$.ajax({
        	url: url,
       		cache: false
    	}).done(function(data) {
        	$("#crnselect").html(data);
    	});
	}
	function getCRNChanged(crnparam){
		crn = $('#crn').val();
		if(crnparam){
			crn = crnparam;
		}
		$.ajax({
        	url: "includes/attendanceEntryInclude.cfm?billingStartDate="+$('#billingStartDate').val()+'&crn='+ crn,
       		cache: false
    	}).done(function(data) {
        	$('#attendanceEntry').html(data);
			$('#addStudent').hide();
			$('#attendanceEntry').show();
			$('#btnAddLab').show();
			$('#btnShowStudent').show();
			$('#btnShowAttendance').hide();
    	});
	}
	function saveEntry(id){
		var attendance = $('#attendance'+id).val();
		var maxPossAttendance = $('#numberOfDays'+id).val();
		$.ajax({
	          type: 'post',
	          url: 'programBilling.cfc?method=updateAttendance',
	          data: {billingStudentItemId: id, attendance: attendance, maxPossibleAttendance: maxPossAttendance},
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
		$('#btnShowStudent').hide();
		$('#btnShowAttendance').show();
		$('#btn').val('Show Attendance');
		$.ajax({
        	url: 'includes/AddStudentsToClassInclude.cfm?billingStartDate=' + $('#billingStartDate').val() + '&crn='+$('#crn').val(),
       		cache: false
    	}).done(function(data) {
        	$("#addStudent").html(data);
    	});
	}
	function showAttendance(selectedCRN){
		$('#attendanceHeader').show();
		$('#attendanceEntry').show();
		$('#addStudent').hide();
		$('#addClass').hide();
	    getCRN(selectedCRN);
		getCRNChanged(selectedCRN);
	}
	function addLab(){
		var crn = $('#crn').val();
		var response = window.confirm('Add Lab for CRN ' + crn);
		if(response)
		{
			$.ajax({
	            type: 'post',
	            url: 'programBilling.cfc?method=addLab',
	            data: {crn: crn, billingStartDate: $('#billingStartDate').val(), isAjax:'true'},
	            datatype:'text/plain',
	            success: function(newCRN){
	            	getCRN(newCRN);
	            	getCRNChanged(newCRN);
	            },
	            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
				}
        });
		}
	}
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
