


<style>
 .backgroundAlert{
	background-color: #f7e4e1;
 }
</style>

<!---  ---------------- INITIAL SETUP ---------------- --->
<cfparam name="showNext" default=false>
<cfif IsDefined("url.showNext")>
	<cfset showNext = url.showNext>
</cfif>


<cfinvoke component="ProgramBilling" method="getBillingStudentForYear"  returnvariable="qryBillingStudentEntries">
	<cfinvokeargument name="billingStudentId" value="#url.billingStudentId#">
</cfinvoke>

<!--- assuming sorted by billingDate desc --->
<cfquery dbtype="query" name="qryStudent">
	select *
	from qryBillingStudentEntries
	where billingStudentId = <cfqueryparam value=#qryBillingStudentEntries.billingStudentId#>
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
	<cfset selectedBillingStudentId = qryStudent.billingStudentId >
	<cfset currentKey = selectedBillingStudentId & "H" >

	<!--- Active tab based on url billingStudentId date --->
	<cfoutput>
		<li class="tabs-title is-active">
			<a href="###currentKey#" aria-selected="true">
				#DateFormat(qryStudent.billingStartDate,'m-d-yy')#<br><span style="color:gray">#qryStudent.Term#</span>
			</a>
		</li>
	</cfoutput>

	<!--- Remaining tabs --->
	<cfquery dbtype="query" name="qryOtherBilling">
		select *
		from qryBillingStudentEntries
		where billingStudentId <> <cfqueryparam value=#qryStudent.billingStudentId# >
		order by billingStartDate desc
	</cfquery>

	<cfoutput query="qryOtherBilling" >
		<li class="tabs-title">
			<a href="###billingStudentId#H">
				#DateFormat(billingStartDate,'m-d-yy')#<br><span style="color:gray">#Term#</span>
			</a>
		</li>
	</cfoutput>
</ul>

<!-- start tab-content container -->
<div class="tabs-content" data-tabs-content="header-tabs" style="margin-bottom:25px">
	<!-- current term container -->
	<div class= "tabs-panel is-active" id="<cfoutput>#currentKey#</cfoutput>">
		<cfmodule template="includes/programStudentHeaderInclude.cfm"
			qryBillingStudentEntries = #qryBillingStudentEntries#
			billingStudentId = #qryStudent.billingStudentId#>
	</div>


	<!-- Previous Term Content Container -->
	<cfoutput query="qryOtherBilling">
	<div class= "tabs-panel" id="#billingStudentId#H">
		<cfmodule template="includes/programStudentHeaderInclude.cfm"
			qryBillingStudentEntries = #qryBillingStudentEntries#
			billingStudentId = #qryOtherBilling.billingStudentId#>
	</div> <!-- end tab content -->
	</cfoutput>

</div> <!-- end total tab content -->


<!-- Class vs Billing Header Tabs -->
<ul class="tabs" data-tabs id="billingclassheader-tabs" data-deep-link="true">
	<li class="tabs-title is-active">
		<a href="#Classes" aria-selected="true">CLASSES</a>
	</li>
	<li class="tabs-title">
		<a href="#Billing">BILLING</a>
	</li>
</ul>

<!-- Class vs Billing Header Content Container -->
<div class="tabs-content" data-tabs-content="billingclassheader-tabs" >
	<!-- class content container -->
	<div class= "tabs-panel is-active" id="Classes">
		<!-- begin class information -->
		<div class="row">
			<!-- lefthand column -->
			<div class="small-6 columns">
				<!-- Billed Classes  -->
				<div class="row" style="margin-bottom:50px">
					<cfmodule template="includes/billedClassesInclude.cfm" billingStudentId="#url.billingStudentId#">
				</div> <!-- end billed classes -->
			</div> <!-- end column -->

			<!-- blank column -->
			<div class="small-1 columns"></div>

			<!-- righthand column -->
			<div class="small-5 columns">
			<!-- past classes -->
			<div class="row">
				<cfmodule template="includes/pastClassesInclude.cfm" pidm="#qryStudent.pidm#" term="#qryStudent.Term#" contactId="#qryStudent.contactId#">
			</div>
			</div> <!-- end past classes -->

		</div> <!-- end class information -->
	</div> <!-- end class content container -->

	<!-- billing content container -->
	<div class= "tabs-panel" id="Billing">
		<!-- Billing Adjustments -->
		<cfmodule template="includes/billingStudentTabInclude.cfm"
			data = "#qryBillingStudentEntries#"
			selectedBillingStudentId = "#selectedBillingStudentId#">
	</div> <!-- end billing content container -->
</div> <!-- End Class vs Billing Header Content Container -->



<script>
	var billingStudentId = <cfoutput>#url.BillingStudentID#</cfoutput>;

	//$(document).ready(function() {

		// save review with coach checkbox changes


		$('#nextStudent').button().click(function (){
			billingStudentId = setNextBillingStudentId(1);
			window.location.href = 'programStudentDetail.cfm?billingStudentId=' + billingStudentId + '&showNext=true';
		});

		$('#prevStudent').button().click(function (){
			bannerGNumber = setNextBillingStudentId(0);
			window.location.href = 'programStudentDetail.cfm?billingStudentId=' + billingStudentId + '&showNext=true';
		});

		 $('#header-tabs').on('change.zf.tabs', function() {
		      var tabId = $('div[data-tabs-content="'+$(this).attr('id')+'"]').find('.tabs-panel.is-active').attr('id');
      		  $('#billing-tabs').foundation('selectTab', $('#'+tabId.replace('H','B')), false);
  		 });
  		  $('#billing-tabs').on('change.zf.tabs', function() {
		      var tabId = $('div[data-tabs-content="'+$(this).attr('id')+'"]').find('.tabs-panel.is-active').attr('id');
    		  $('#header-tabs').foundation('selectTab', $('#'+tabId.replace('B','H')), false);
  		 });

	//});

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




