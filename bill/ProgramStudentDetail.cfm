<cfinclude template="includes/header.cfm" />

<cfparam name="showNext" default=true>
<cfif IsDefined("session.showNext")>
	<cfset showNext = session.showNext>
</cfif>

<cfinvoke component="ProgramBilling" method="getProgramStudent"  returnvariable="qryStudent">
	<cfinvokeargument name="billingStudentId" value="#url.billingStudentId#">
</cfinvoke>


<!--- Get Page Header Data --->
<!--- Current Status --->

<cfset Variables.isAttendance = false>
<cfif qryStudent.program CONTAINS "attendance" >
	<cfset Variables.isAttendance = true>
	<cfinvoke component="Lookup" method="getMaxBillingStartDateForTerm" returnvariable="maxDate">
		<cfinvokeargument name="term" value="#qryStudent.Term#">
	</cfinvoke>
</cfif>

<!--- Previous Statuses for Year --->
<cfinvoke component="ProgramBilling" method="getOtherBilling"  returnvariable="qryOtherBilling">
	<cfinvokeargument name="contactId" value="#qryStudent.contactId#">
	<cfinvokeargument name="term" value="#qryStudent.term#">
	<cfinvokeargument name="billingStartDate" value="#qryStudent.billingStartDate#">
</cfinvoke>

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

<!-- Header Tabs for Term/Billing Date  -->
<cfquery dbtype="query" name="otherTerms">
	select term, billingStartDate
	from qryOtherBilling
	group by term, billingStartDate
</cfquery>
<ul class="tabs" data-tabs id="header-tabs" >
	<cfif isAttendance><cfset currentKey =#DateFormat(qryStudent.billingStartDate,'m-d-yy')#><cfelse><cfset currentKey = qryStudent.Term></cfif>
	<cfoutput><li class="tabs-title is-active"><a href="###currentKey#" aria-selected="true">#currentKey#</a></li></cfoutput>
	<cfoutput query="otherTerms" >
	<cfif isAttendance><cfset key = DateFormat(billingStartDate,'m-d-yy')><cfelse><cfset key = Term></cfif>
	<li class="tabs-title"><a href="###key#">#key#</a></li>
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
	<cfif isAttendance><cfset key = DateFormat(billingStartDate,'m-d-yy')><cfelse><cfset key = Term></cfif>
	<div class= "tabs-panel" id="#key#">
		<div class=<cfif #BillingStatus# EQ 'COMPLETE'>"callout alert"<cfelse>"callout primary"</cfif> >
			<div class="row">
				<div class="small-2 columns"><b>Program</b></div>
				<div class="small-1 columns"><b>Enrolled Date</b></div>
				<div class="small-2 columns"><b>Exit Date </b></div>
				<div class="small-1 columns"><b>Term</b></div>
				<div class="small-2 columns"><b>Month</b></div>
				<div class="small-2 columns"><b>School</b></div>
				<div class="small-1 columns"><b>Status</b></div>
				<div class="small-1 columns"></div>
			</div>
			<div class="row">
				<div class="small-2 columns">#program#</div>
				<div class="small-1 columns">#DateFormat(ENROLLEDDATE,"m/d/yy")#</div>
				<div class="small-2 columns"><cfif LEN(#EXITDATE#) EQ 0>None<cfelse>#DateFormat(EXITDATE,"m/d/yy")#</cfif></div>
				<div class="small-1 columns">#term#</div>
				<div class="small-2 columns">#DateFormat(billingStartDate,"m/d/yy")#</div>
				<div class="small-2 columns">#schooldistrict#</div>
				<div class="small-1 columns">#billingstatus#</div>
				<div class="small-1 columns" style="color:red">#ErrorMessage#</div>
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
				term="#qryStudent.term#">
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
		$('#exitDate').fdatepicker({ format: 'mm/dd/yy',
			disableDblClickSelection: true,
			leftArrow:'<<',
			rightArrow:'>>',
			closeIcon:'X',
			closeButton: true });


		//setup for billing table
	    $('#dt_billed').DataTable({
	    	searching:false,
	    	paging:false,
	    	info:false,
	    	ordering: false,
	    	language: {
	      		emptyTable: "No classes for term: <cfoutput>#qryStudent.Term#</cfoutput> "
	    	}
	    });

	    // grouping for the classes table
		$('#dt_classes').DataTable({
			searching: false,
			paging: false,
			info: false,
			columns:[{data:'Term'},{data:'CRSE'},{data:'SUBJ'},{data:'Title'},{data:'Credits'},{data:'Grade'},{data:'TakenPreviousTerm'},{data:'IncludeFlag'}],
			orderFixed:([0, 'desc']),
	    	rowGroup: {
	    		dataSrc: 'Term'
	    	}
	    });

	   // save program dropdown changes
	   $('#program').change(function(){
			var program = $(this).val();
			$.blockUI({ message: 'Just a moment...' });
			$.ajax({
				url: "programbilling.cfc?method=updatestudentbillingprogram",
				type: "POST",
				async: false,
				data: { billingstudentid: billingStudentId, program: program },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
			$.unblockUI();
		}); //end save checkbox changes

		// save exit date changes
	   $('#exitDate').change(function(){
			var exitDate = $(this).val();
			$.blockUI({ message: 'Just a moment...' });
			$.ajax({
				url: "programbilling.cfc?method=updatestudentbillingexitdate",
				type: "POST",
				async: false,
				data: { billingstudentid: billingStudentId, exitDate: exitDate },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
			$.unblockUI();
		}); //end save checkbox changes

	   // save billing reviewed checkbox changes
	   $('#billingReviewed').click(function(){
			var checked = $(this)[0].checked;
			$.blockUI({ message: 'Just a moment...' });
			$.ajax({
				url: "programbilling.cfc?method=updatestudentbillingstatus",
				type: "POST",
				async: false,
				data: { billingstudentid: billingStudentId, billingReviewed: checked },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
			$.unblockUI();
		}); //end save checkbox changes

	   // save include course checkbox changes
	   	$('#dt_billed').find('input:checkbox').click(function(){
			//cb = $(this).find('input:checkbox');
			cb = $(this);
	 		dt = $('#dt_billed').DataTable();
			var tableRow  = dt.row(this.parentNode).data();

			var billingStudentItemId = tableRow[0];
			var includeFlag = (cb[0].checked ? 1 : 0);
			$.blockUI({ message: 'Just a moment...' });
			$.ajax({
				url: "programbilling.cfc?method=updatestudentbillingiteminclude",
				type: "POST",
				async: false,
				data: { billingstudentitemid: billingStudentItemId, includeflag:includeFlag },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
			$.unblockUI();
		}); //end save checkbox changes

		// save review with coach checkbox changes
	   	 $('#reviewWithCoachFlag').click(function(){
			var reviewWithCoachFlag = $(this)[0].checked ? 1 : 0;
			$.blockUI({ message: 'Just a moment...' });
			$.ajax({
				url: "programbilling.cfc?method=updateStudentReviewWithCoachFlag",
				type: "POST",
				async: false,
				data: { billingStudentId: billingStudentId, reviewWithCoachFlag:reviewWithCoachFlag },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
			$.unblockUI();
		}); //end save checkbox changes


		// save include in billing checkbox changes
	   	 $('#includeFlag').click(function(){
			var includeFlag = $(this)[0].checked ? 1 : 0;
			$.blockUI({ message: 'Just a moment...' });
			$.ajax({
				url: "programbilling.cfc?method=updateStudentIncludeFlag",
				type: "POST",
				async: false,
				data: { billingStudentId: billingStudentId, includeFlag:includeFlag },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
			$.unblockUI();
		}); //end save checkbox changes

		$('#nextStudent').button().click(function (){
			billingStudentId = setNextBillingStudentId(1);
			window.location.href = 'programStudentDetail.cfm?billingStudentId=' + billingStudentId;
		});

		$('#prevStudent').button().click(function (){
			bannerGNumber = setNextBillingStudentId(0);
			window.location.href = 'programStudentDetail.cfm?billingStudentId=' + billingStudentId;
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
