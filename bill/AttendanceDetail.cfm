<cfinclude template="includes/header.cfm" />

<cfinvoke component="ProgramBilling" method="getClassAttendanceForMonth"  returnvariable="data">
	<cfinvokeargument name="crn" value="#Session.CRN#">
	<cfinvokeargument name="billingStartDate" value="#Session.billingStartDate#">
</cfinvoke>

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

<div class="callout primary">
<cfoutput>Date: #DateFormat(Session.billingStartDate,'m/d/yy')#&nbsp;Class:#data.subj#-#data.crse#&nbsp;#data.title#&nbsp;(#Session.crn#)</cfoutput>
</div>


<b>
<div class="row">
	<div class="small-2 columns">Student</div>
	<div class="small-1 columns">Attendance</div>
	<div class="small-1 columns"># Days</div>
	<div class="small-5 columns">Details</div>
	<div class="small-3 columns">Paste copied data</div>
</div>
</b>
<cfoutput query="data">
<div class="row">
	<div class="small-2 columns display readonly">#data.lastname#, #data.firstname# (#data.bannerGNumber#)</div>
	<div class="small-1 columns" ><input  value="#NumberFormat(CourseValue,"0")#" id='attendance#data.billingStudentItemId#' style="width:80px"></div>
	<div class="small-1 columns" ><input value="#NumberFormat(Amount2,"0")#" id='numberOfDays#data.billingStudentItemId#' style="width:80px"></div>
	<div class="small-5 columns" id="detail#data.billingStudentItemId#">
		<cfmodule template="billingStudentItemDetail.cfm" billingStudentItemId = "#data.billingStudentItemId#"
		>
	</div>
	<div class="small-3 columns" style="padding-left:0px;">
		<input id='paste#data.billingStudentItemId#'>
		<a href="javascript:doPaste(#data.billingStudentItemId#);">Save Paste</a>
	</div>
</div>
</cfoutput>

<cfsavecontent variable="pcc_scripts">
<script>
	$(document).ready(function() {
		$('input').blur(function(){
			var inputName = this.id;
			if(inputName.substring(0,10) == 'attendance'){
				var inputType = 'attendance';
			}else{
				var inputType = 'numberDays';
			}
			var id = this.id.replace(inputType,'');
			var cv = $('#attendace'+id).val();
			var a = $('#numberOfDays'+id).val();
			//$.blockUI({ message: 'Saving...' });
			$.ajax({
	            type: 'post',
	            url: 'programBilling.cfc?method=updateAttendance',
	            data: {billingStudentItemId: id, courseValue: cv, amount2: a},
	            datatype:'json',
	            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
				}
	        });
			//$.unblockUI();
		});

	});
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
	           		.load('billingStudentItemDetail.cfm?billingStudentItemId='+billingStudentItemId
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
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
