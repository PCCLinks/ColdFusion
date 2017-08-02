<cfinclude template="includes/header.cfm" />
<cfset Variables.CRN = Session.crn>
<cfset Variables.Term = Session.term>
<cfset Variables.BillingDate = Session.billingDate >

<cfinvoke component="SetUpBilling" method="setUpBillingClassAttendanceForMonth"  returnvariable="data">
	<cfinvokeargument name="term" value="#Variables.Term#">
	<cfinvokeargument name="crn" value="#Variables.CRN#">
	<cfinvokeargument name="billingdate" value="#Variables.BillingDate#">
</cfinvoke>

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
<cfoutput>Term: #Variables.Term#&nbsp;Class:#data.subj#-#data.crse#&nbsp;#data.title#&nbsp;(#Variables.crn#)</cfoutput>
</div>


<b>
<div class="row">
	<div class="medium-4 columns">Student</div>
	<div class="medium-8 columns">Attendance for <cfoutput>#Variables.BillingDate#</cfoutput></div>
</div>
</b>
<cfoutput query="data">
<div class="row">
	<div class="medium-1 columns">#firstname#</div>
	<div class="medium-2 columns">#lastname#</div>
	<div class="medium-1 columns">#bannerGNumber#</div>
	<div class="medium-8 columns"><input name="courseValue" value="#CourseValue#" id='#billingStudentItemId#'></div>
</div>
</cfoutput>


<cfsavecontent variable="pcc_scripts">
<script>
	$(document).ready(function() {
		$('input').blur(function(){
			var id = this.id;
			var v = this.value;
			$.blockUI({ message: 'Saving...' });
			$.ajax({
	            type: 'post',
	            url: 'setUpBilling.cfc?method=updateAttendance',
	            data: {billingStudentItemId: id, courseValue: v},
	            datatype:'json',
	            error: function (xhr, textStatus, thrownError) {
					 handleAjaxError(xhr, textStatus, thrownError);
				}
	        });
			$.unblockUI();
		});
	});
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
