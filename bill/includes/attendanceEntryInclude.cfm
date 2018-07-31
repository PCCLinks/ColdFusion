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
	<cfset enrolledTag = '<span style="color:red">No longer enrolled in Banner</span>' >
	<cfif data.subj EQ url.crn>
		<cfset enrolledTag = '&nbsp;'>
	</cfif>
	<cfif bannerdata.recordcount GT 0>
		<cfquery name="banner" dbtype="query">
			select *
			from bannerdata
			where stu_id = <cfqueryparam value="#data.bannerGNumber#">
		</cfquery>
		<cfif banner.recordcount GT 0>
			<cfset enrolledTag = '&nbsp;'>
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
		<div class="column small-5 large-5">
			Paste Entry: <input id='paste#data.billingStudentItemId#'  >
			<a href="javascript:doPaste(#data.billingStudentItemId#);">Save Paste</a>
		</div>
		<div class="column small-3 large-5">
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

<div id="missingStudents"></div>


<script>
	function loadMissingStudents(){
		$.get('ProgramBilling.cfc?method=getStudentsMissingFromCRN&crn=<cfoutput>#url.crn#&billingStartDate=#url.billingStartDate#</cfoutput>')
			.done(function(data){
				$('#missingStudents').html(data);
			});
	}
	<cfoutput>
	var crn = '#url.crn#';
	var billingStartDate = '#url.billingStartDate#';
	</cfoutput>
	function addMissingBannerStudent(bannerGNumber){
		document.body.style.cursor = 'wait';
		 $.ajax({
            url: "setUpBilling.cfc",
            type:'post',
            data:{method:'addBillingStudent', billingType:'attendance', bannerGNumber:bannerGNumber, billingStartDate:billingStartDate, crn: crn},
            dataType: 'json',
            async:false,
            success: function(billingStudentId){
            	window.location = 'attendanceEntry.cfm?crn='+ crn + '&billingStartDate=' + billingStartDate;
            	document.body.style.cursor = 'default';
            },
            error: function (jqXHR, exception) {
            	document.body.style.cursor = 'default';
			    handleAjaxError(jqXHR, exception);
            }
        });
	}
</script>
