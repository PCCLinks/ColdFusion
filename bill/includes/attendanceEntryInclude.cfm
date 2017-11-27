<cfinvoke component="pcclinks.bill.ProgramBilling" method="getClassAttendanceForMonth"  returnvariable="data">
	<cfinvokeargument name="crn" value="#url.CRN#">
	<cfinvokeargument name="billingStartDate" value="#url.billingStartDate#">
</cfinvoke>

<div class="callout primary">
<cfoutput>Date: #DateFormat(url.billingStartDate,'m/d/yy')#&nbsp;Class:#data.subj#-#data.crse#&nbsp;#data.title#&nbsp;(#url.crn#)</cfoutput>
</div>


<cfoutput query="data">
<div class="row">
	<div class="small-12 medium-12 columns display readonly">#data.lastname#, #data.firstname# (#data.bannerGNumber#)</div>
</div>
<div class="row">
	<div class="column small-3 large-1" >Attendance: <input onBlur="saveEntry(#data.billingStudentItemId#);" value="#NumberFormat(Attendance,"0")#" id='attendance#data.billingStudentItemId#' style="width:50px"></div>
	<div class="column small-3 large-1" >Scheduled: <input onBlur="saveEntry(#data.billingStudentItemId#);" value="#NumberFormat(MaxPossibleAttendance,"0")#" id='numberOfDays#data.billingStudentItemId#' style="width:50px"></div>
	<div class="column small-6 large-10">
		Paste Entry: <input id='paste#data.billingStudentItemId#' tyep="text" >
		<a href="javascript:doPaste(#data.billingStudentItemId#);">Save Paste</a>
	</div>
</div>
<div class="row align-right">
	<div class="column small-6 large-2"></div>
	<div class="column small-6 large-10" id="detail#data.billingStudentItemId#">
		<cfmodule template="billingStudentItemDetailInclude.cfm" billingStudentItemId = "#data.billingStudentItemId#"
		>
	</div>
</div>
</cfoutput>