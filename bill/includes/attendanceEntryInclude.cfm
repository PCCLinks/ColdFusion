<cfinvoke component="pcclinks.bill.ProgramBilling" method="getClassAttendanceForMonth"  returnvariable="data">
	<cfinvokeargument name="crn" value="#url.CRN#">
	<cfinvokeargument name="billingStartDate" value="#url.billingStartDate#">
</cfinvoke>

<div class="callout primary">
<cfoutput>Date: #DateFormat(url.billingStartDate,'m/d/yy')#&nbsp;Class:
	<cfif data.subj EQ url.crn>#url.crn#
	<cfelse>#data.subj#-#data.crse#&nbsp;#data.title#&nbsp;(#url.crn#)
	</cfif>
</cfoutput>
</div>


<cfoutput query="data">
<div class="row">
	<div class="small-8 medium-9 columns display readonly">#data.lastname#, #data.firstname# <cfif len(data.exitDate) GT 0><span style="color:red">Exit Date: #DateFormat(data.exitDate,'m/d/yy')#</span></cfif> (#data.bannerGNumber#)</div>
	<div class="small-3 medium-3 columns display"><a href="javascript:removeItem(#data.billingStudentItemId#, #data.billingStudentId#)">Remove from Class</a></div>
</div>
<div class="row">
	<div class="column small-2 large-1" >Attendance: <input onBlur="saveEntry(#data.billingStudentItemId#);" value="#NumberFormat(Attendance,"0")#" id='attendance#data.billingStudentItemId#' style="width:50px"></div>
	<div class="column small-2 large-1" >Scheduled: <input onBlur="saveEntry(#data.billingStudentItemId#);" value="#NumberFormat(MaxPossibleAttendance,"0")#" id='numberOfDays#data.billingStudentItemId#' style="width:50px"></div>
	<div class="column small-4 large-4">
		Paste Entry: <input id='paste#data.billingStudentItemId#'  >
		<a href="javascript:doPaste(#data.billingStudentItemId#);">Save Paste</a>
	</div>
	<div class="column small-4 large-6">
		Notes: <input value="#billingStudentItemNotes#" onblur="saveEntry(#data.billingStudentItemId#);" id="notes#data.billingStudentItemId#" style="width:80%">
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