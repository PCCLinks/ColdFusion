<cfinclude template="includes/header.cfm" />


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
	where billingStudentId = qryBillingStudentEntries.billingStudentId
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
		where billingStudentId <> #qryStudent.billingStudentId#
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
		<cfmodule template="includes/programStudentCurrentHeaderInclude.cfm"
			qryBillingStudentEntries = #qryBillingStudentEntries#
			billingStudentId = #qryStudent.billingStudentId#>
	</div>


	<!-- Previous Term Content Container -->
	<cfoutput query="qryOtherBilling">
	<div class= "tabs-panel" id="#billingStudentId#H">
		<cfmodule template="includes/programStudentCurrentHeaderInclude.cfm"
			qryBillingStudentEntries = #qryBillingStudentEntries#
			billingStudentId = #qryOtherBilling.billingStudentId#>
	</div> <!-- end tab content -->
	</cfoutput>

</div> <!-- end total tab content -->




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
