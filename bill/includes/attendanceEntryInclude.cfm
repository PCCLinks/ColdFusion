<cfinvoke component="pcclinks.bill.ProgramBilling" method="getClassAttendanceForMonth"  returnvariable="data">
	<cfinvokeargument name="crn" value="#url.CRN#">
	<cfinvokeargument name="billingStartDate" value="#url.billingStartDate#">
</cfinvoke>
<cfinvoke component="pcclinks.bill.ProgramBilling" method="getBannerClassForTerm"  returnvariable="bannerdata">
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
	<cfset enrolledTag = "&nbsp;">
	<cfif bannerdata.recordcount GT 0>
		<cfquery name="banner" dbtype="query">
			select *
			from bannerdata
			where stu_id = <cfqueryparam value="#data.bannerGNumber#">
		</cfquery>
		<cfif banner.recordcount EQ 0>
			<cfset enrolledTag = '<span style="color:red">No longer enrolled in Banner</span>'>
		</cfif>
	</cfif>
<div class="row">
	<div class="small-5 medium-6 columns display readonly">#data.lastname#, #data.firstname# <cfif len(data.exitDate) GT 0><span style="color:red">Exit Date: #DateFormat(data.exitDate,'m/d/yy')#</span></cfif> (#data.bannerGNumber#)</div>
	<div class="small-3 medium-3 columns display readonly">#enrolledTag#</div>
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
<div id="addmissingstudent">
</div>
</cfoutput>
<cfset local.inList =  ValueList(data.bannerGNumber,",")>
<cfquery name="bannermissing" dbtype="query">
	select *
	from bannerdata
	where stu_id NOT IN (<cfqueryparam value="#local.inList#" list="yes" cfsqltype="String">)
</cfquery>
<cfif bannermissing.recordcount GT 0>
	<cfset missingHtml = ''>
	<cfoutput query="bannermissing" >
		<cfinvoke component="pcclinks.bill.SetUpBilling" method="getStudents" returnvariable="student">
			<cfinvokeargument name="beginDate" value="2000-01-01">
			<cfinvokeargument name="endDate" value="3000-12-31">
			<cfinvokeargument name="bannerGNumber" value="#stu_id#">
		</cfinvoke>
		<cfif student.exitDate EQ '' OR DateDiff('d', student.exitDate, Now()) LT 45>
			<cfsavecontent variable="missingHtml">
				#missingHtml#
				<li>Student #student.firstname# #student.lastname# (#stu_id#) <cfif student.exitdate NEQ ''>Exit Date: #DateFormat(student.exitDate,'m/d/yyyy')# </cfif>missing from class.  <a href="javascript:addMissingBannerStudent('#stu_id#');">Add Student</a></li>
			</cfsavecontent>
		</cfif>
	</cfoutput>
	<cfif missingHtml NEQ ''>
	<b><span style="color:red">Students Missing from Billing</span></b>
	<ul>
		<cfoutput>#missingHtml#</cfoutput>
	</ul>
	</cfif>
</cfif>

<script>
	<cfoutput>
	var crn = '#url.crn#';
	var billingStartDate = '#url.billingStartDate#';
	</cfoutput>
	function addMissingBannerStudent(bannerGNumber){
		 $.ajax({
            url: "setUpBilling.cfc?method=addBillingStudent",
            type:'post',
            data:{bannerGNumber:bannerGNumber, billingStartDate:billingStartDate, crn: crn},
            dataType: 'json',
            async:false,
            success: function(billingStudentId){
            	window.location = 'attendanceEntry.cfm?crn='+ crn + '&billingStartDate=' + billingStartDate;
            },
            error: function (jqXHR, exception) {
			    handleAjaxError(jqXHR, exception);
            }
        });
	}
</script>
