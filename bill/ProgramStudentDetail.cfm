<cfinclude template="includes/header.cfm" />


<!---  ---------------- INITIAL SETUP ---------------- --->
<cfparam name="showNext" default=false>
<cfif IsDefined("url.showNext")>
	<cfset showNext = url.showNext>
</cfif>


<cfinvoke component="ProgramBilling" method="getProgramStudent"  returnvariable="qryStudent">
	<cfinvokeargument name="billingStudentId" value="#url.billingStudentId#">
</cfinvoke>

<cfset Variables.isAttendance = false>
<cfif qryStudent.program CONTAINS "attendance" >
	<cfset Variables.isAttendance = true>
</cfif>

<!--- Other Statuses for Year --->
<cfinvoke component="ProgramBilling" method="getOtherBilling"  returnvariable="qryOtherBilling">
	<cfinvokeargument name="contactId" value="#qryStudent.contactId#">
	<cfinvokeargument name="term" value="#qryStudent.term#">
	<cfinvokeargument name="billingStartDate" value="#qryStudent.billingStartDate#">
</cfinvoke>

<!--- Header Tabs for Term/Billing Date  --->
<cfquery dbtype="query" name="qryOtherTabHeaders">
	select term, billingStartDate
	from qryOtherBilling
	group by term, billingStartDate
</cfquery>


<!--   START OF UI  -->

<!--- Next and Previous Buttons --->
<cfif showNext>
<div class="row">
	<div class="large-5 columns">
		<input id="prevStudent" name="prevStudent" type="button" class="button" value="<<">
	</div>
	<div class="large-1 columns">
		<input id="nextStudent" name="nextStudent" type="button" class="button" value=">>">
	</div>
</div>
</cfif>

<!-- Header Tabs -->
<ul class="tabs" data-tabs id="header-tabs" >
	<!--- Attendance shows full date, term programs just show term --->
	<cfset currentKey = DateFormat(qryStudent.billingStartDate,'m-d-yy')>

	<!--- Active tab based on url billingStudentId date --->
	<cfoutput>
		<li class="tabs-title is-active">
			<a href="###currentKey#" aria-selected="true">
				#DateFormat(qryStudent.billingStartDate,'m-d-yy')#<br><span style="color:gray">#qryStudent.Term#</span>
			</a>
		</li>
	</cfoutput>
	<!--- Remaining tabs based on the dates in the other query --->
	<cfoutput query="qryOtherTabHeaders" >
		<li class="tabs-title">
			<a href="###DateFormat(billingStartDate,'m-d-yy')#">
				#DateFormat(billingStartDate,'m-d-yy')#<br><span style="color:gray">#Term#</span>
			</a>
		</li>
	</cfoutput>
</ul>

<!-- start tab-content container -->
<div class="tabs-content" data-tabs-content="header-tabs" style="margin-bottom:25px">
	<!-- current term container -->
	<div class= "tabs-panel is-active" id="<cfoutput>#currentKey#</cfoutput>">
		<cfmodule template="includes/programStudentCurrentHeaderInclude.cfm"
			qryStudent = #qryStudent#>
	</div>

	<!-- Previous Term Content Container -->
	<cfoutput query="qryOtherBilling">
	<div class= "tabs-panel" id="#DateFormat(billingStartDate,'m-d-yy')#">
		<div class=<cfif #BillingStatus# EQ 'COMPLETE'>"callout alert"<cfelse>"callout primary"</cfif> >
			<div class="row">
				<div class="small-2 columns"><b>Program</b></div>
				<div class="small-1 columns"><b>Enrolled Date</b></div>
				<div class="small-2 columns"><b>Exit Date </b></div>
				<div class="small-1 columns"><b>Term</b></div>
				<div class="small-2 columns"><b>Month</b></div>
				<div class="small-2 columns"><b>School</b></div>
				<div class="small-2 columns"><b>Status</b></div>
			</div>
			<div class="row">
				<div class="small-2 columns">#program#</div>
				<div class="small-1 columns">#DateFormat(ENROLLEDDATE,"m/d/yy")#</div>
				<div class="small-2 columns"><cfif LEN(#EXITDATE#) EQ 0>None<cfelse>#DateFormat(EXITDATE,"m/d/yy")#</cfif></div>
				<div class="small-1 columns">#term#</div>
				<div class="small-2 columns">#DateFormat(billingStartDate,"m/d/yy")#</div>
				<div class="small-2 columns">#schooldistrict#</div>
				<div class="small-2 columns">#billingstatus#</div>
			</div>
			<div class="row">
				<div class="small-12 columns" style="color:red">#ErrorMessage#</div>
			</div>
		</div> <!-- end header data -->
	</div> <!-- end tab content -->
	</cfoutput>

</div> <!-- end total tab content -->

<!-- begin class information -->
<div class="row">
	<!-- lefthand column -->
	<div class="small-5 columns">
		<!-- Billed Classes  -->
		<div class="row" style="margin-bottom:50px">
			<cfmodule template="includes/billedClassesInclude.cfm" billingStudentId="#url.billingStudentId#">
		</div> <!-- end billed classes -->

		<!-- Billing Adjustments -->
		<div class="row">
			Billing Adjustments
			<cfmodule template="includes/billingStudentTabInclude.cfm"
				contactid = "#qryStudent.contactid#"
				term="#qryStudent.term#"
				currentKey = "#currentKey#"
				isAttendance = "#isAttendance#">
		</div><!-- end billing adjustments -->

	</div> <!-- end column -->

	<!-- blank column -->
	<div class="small-1 columns"></div>

	<!-- righthand column -->
	<div class="small-6 columns">
	<!-- past classes -->
		<cfmodule template="includes/pastClassesInclude.cfm" pidm="#qryStudent.pidm#" term="#qryStudent.Term#" contactId="#qryStudent.contactId#">
	</div> <!-- end past classes -->

</div> <!-- end class information -->


<cfsavecontent variable="pcc_scripts">
<script>
	var billingStudentId = <cfoutput>#url.BillingStudentID#</cfoutput>;

	$(document).ready(function() {

		// save review with coach checkbox changes


		$('#nextStudent').button().click(function (){
			billingStudentId = setNextBillingStudentId(1);
			window.location.href = 'programStudentDetail.cfm?billingStudentId=' + billingStudentId + '&showNext=true';
		});

		$('#prevStudent').button().click(function (){
			bannerGNumber = setNextBillingStudentId(0);
			window.location.href = 'programStudentDetail.cfm?billingStudentId=' + billingStudentId + '&showNext=true';
		});

	});

	function getAttendanceDetail(crn){
		<cfoutput>window.open('AttendanceDetail.cfm?crn=' + crn + '&billingStartDate=#qryStudent.billingStartDate#');</cfoutput>
	}

	function setNextBillingStudentId(isGetNext){
		var next = isGetNext;
		var prev = isGetNext ? 0 : 1;
		$.ajax({
			url: "programbilling.cfc?method=getNextbillingStudentIdInSession",
			type: "POST",
			async: false,
			dataType:"json",
			data: { getNext: next, getPrev: prev, billingStudentId: billingStudentId},
			error: function (jqXHR, exception) {
		        handleAjaxError(jqXHR, exception);
			},
			success: function(data){
				billingStudentId = data;
			}
		});
		return billingStudentId;
	}


 </script>
</cfsavecontent>


<cfinclude template="includes/footer.cfm" />
