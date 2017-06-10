<cfinclude template="includes/header.cfm" />

<cfset Variables.BannerGNumber = #Session.bannerGNumber#>
<cfset Variables.Term = #Session.term#>
<cfset Variables.Program = #Session.Program#>
<!---debug code
<cfdump var="#Variables.BannerGNumber#">
<cfdump var="#Variables.Term#">
--->
<cfinvoke component="ProgramBilling" method="yearlybilling"  returnvariable="qryStudent">
	<cfinvokeargument name="bannerGNumber" value="#Variables.BannerGNumber#">
	<cfinvokeargument name="term" value="#Variables.Term#">
</cfinvoke>
<cfinvoke component="ProgramBilling" method="selectBillingEntries"  returnvariable="qryEntries">
	<cfinvokeargument name="bannerGNumber" value="#Variables.BannerGNumber#">
	<cfinvokeargument name="term" value="#Variables.Term#">
</cfinvoke>
<cfset args = {"gnumber"= Variables.bannerGNumber, "term" = Variables.Term, "subj" = ""}>
<cfinvoke component="ProgramBilling" method="selectBannerClasses"  returnvariable="qryPastClasses">
	<cfinvokeargument name="row" value="#args#">
</cfinvoke>
<!--- debug code <cfdump var="#qryStudent#"> --->

<!----------------------------- Data from qryStudent ------------------------------------------------>
<cfoutput query="qryStudent">
	<cfset Variables.BillingStatus = #BillingStatus#>
	<div class=<cfif #BillingStatus# EQ 'COMPLETE'>"callout alert"<cfelse>"callout primary"</cfif> >
		<div class="row">
			<!-- previous button -->
			<div class="small-1 columns"><input id="prevStudent" name="prevStudent" type="button" class="button" value="<<"></div>
			<!-- header data -->
			<div class="small-10 columns">
				<div class="row">
					<div class="small-2 columns"><b>G</b></div>
					<div class="small-2 columns"><b>Name</b></div>
					<div class="small-1 columns"><b>Program</b></div>
					<div class="small-2 columns"><b>Enrolled Date</b></div>
					<div class="small-2 columns"><b>Exit Date </b></div>
					<div class="small-1 columns"><b>Billing Date</b></div>
					<div class="small-2 columns"><b>Review with Coach</b></div>
				</div>
				<div class="row">
					<div class="small-2 columns">#bannerGNumber#</div>
					<div class="small-2 columns">#FIRSTNAME# #LASTNAME#</div>
					<div class="small-1 columns">#PROGRAM#</div>
					<div class="small-2 columns">#DateFormat(ENROLLEDDATE,"m/d/yy")#</div>
					<div class="small-2 columns"><cfif LEN(#EXITDATE#) EQ 0>None<cfelse>#DateFormat(EXITDATE,"m/d/yy")#</cfif></div>
					<div class="small-1 columns"><cfif LEN(#BillingDate#) EQ 0>N/A<cfelse>#DateFormat(BillingDate,"m/d/yy")#</cfif></div>
					<div class="small-2 columns">
						<input type="checkbox"  >
					</div>
				</div>
			</div> <!-- end header data -->
			<!-- next button -->
			<div class="small-1 columns"><input id="nextStudent" name="nextStudent" type="button" class="button" value=">>"></div>
		</div> <!-- end row -->
	</div>
</cfoutput>
<!------------------------ End Data from qryStudent -------------------------------------------->


<div class="row">
	<!---------------------------------------------------------------------------->
	<!--- Billed Classes -------------------------------------------------------->
	<!---------------------------------------------------------------------------->
	<div class="small-5 columns">
		<b>Billed Classes</b>
		<table id="dt_billed" name="dt" class="unstriped hover compact" cellspacing="0" width="100%">
			<thead>
		    	<tr>
			    	<th style="display:none;" id="BillingStudentItemId"></th>
			    	<th id="term">Term</th>
		            <th id="CRSE">CRSE</th>
		            <th id="SUBJ">SUBJ</th>
		            <th id="Title">Title</th>
					<td id="TakenPreviousTerm">Taken Prev.</td>
					<th id="CourseValue">CR</th>
					<th id="IncludeFlag">Incl.</th>
		       </tr>
		     </thead>
		     <tbody>
				<cfoutput query="qryEntries">
		        <tr>
			    	<td style="display:none;">#BillingStudentItemId#</td>
			    	<td >#term#</td>
		            <td>#CRSE#</td>
		            <td>#SUBJ#</td>
		            <td>#Title#</td>
					<td><cfif LEN(#TakenPreviousTerm#) EQ 0 OR #TakenPreviousTerm# EQ 0>No<cfelse><span style="color:red">#TakenPreviousTerm#</span></cfif></td>
		            <td>#NumberFormat(CourseValue,"0")#</td>
		            <td><input type="checkbox" id="IncludeFlag" <cfif #IncludeFlag# EQ 1>checked</cfif>></td>
				</tr>
				</cfoutput>
			</tbody>
		</table>
		<div class="callout">
			<b>Billing Reviewed:</b> <input type="checkbox" <cfif #Variables.BillingStatus# EQ "Complete">checked</cfif> >
		</div>
	</div>
	<div class="small-1 columns"></div>
	<!---------------------------------------------------------------------------->
	<!--- Past Classes -------------------------------------------------------->
	<!---------------------------------------------------------------------------->
	<div class="small-6 columns">
	<b>Past Classes</b>
	<legend>These are the prior classes taken by the student in the selected current class subject area.  Classes that were given a "W" are in red.</legend>
	<table name="dt_classes" id="dt_classes" class="unstriped compact" cellspacing="0" width="100%">
			<thead>
	    	<tr>
				<th id="Term">Term</th>
	            <th id="CRSE">CRSE</th>
	            <th id="SUBJ">SUBJ</th>
	            <th id="Title">Title</th>
				<th id="IncludeFlag">CR</th>
				<th id="CourseValue">Grade</th>
	       </tr>
	     </thead>
	     <tbody>
			<cfoutput query="qryPastClasses">
	        <tr <cfif #grade# EQ 'W'> style="color:red;"</cfif>>
				<td>#Term#</td>
	            <td>#CRSE#</td>
	            <td>#SUBJ#</td>
	            <td>#Title#</td>
	            <td>#Credits#</td>
	            <td>#Grade#</td>
			</tr>
			</cfoutput>
		</tbody>
	</table>
	</div>
</div> <!--- end div row --->


<cfsavecontent variable="pcc_scripts">
<script>
$(document).ready(function() {
	//setup for billing table
    $('#dt_billed').DataTable({
    	searching:false,
    	paging:false,
    	info:false,
    	ordering: false,
    	language: {
      		emptyTable: "No classes for term: <cfoutput>#Variables.Term#</cfoutput> "
    	}
    });

    // grouping for the classes table
	$('#dt_classes').DataTable({
		searching: false,
		paging: false,
		info: false,
		columns:[{data:'Term'},{data:'CRSE'},{data:'SUBJ'},{data:'Title'},{data:'Credits'},{data:'Grade'}],
		orderFixed:([0, 'desc']),
    	rowGroup: {
    		dataSrc: 'Term'
    	}
    });

   // save include checkbox changes
   $('#dt_billed').find('td').click(function(){
		cb = $(this).find('input:checkbox');
 		dt = $('#dt_billed').DataTable();
		var tableRow  = dt.row(this).data();

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

	$('#nextStudent').button().click(function (){
		setNextGNumber(1);
		goToDetailPage();
	});

	$('#prevStudent').button().click(function (){
		setNextGNumber(0);
		goToDetailPage();
	});

	function setNextGNumber(isGetNext){
		var next = isGetNext;
		var prev = isGetNext ? 0 : 1;
		$.ajax({
			url: "programbilling.cfc?method=setNextGNumberInSession",
			type: "POST",
			async: false,
			data: { getNext: next, getPrev: prev},
			error: function (jqXHR, exception) {
		        handleAjaxError(jqXHR, exception);
			}
		});
	}

	function goToDetailPage(bannerGNumber){
			var dt = $('#dt_table').DataTable();
			var gList = dt.columns({search:'applied'}).data()[0];
			var url = 'saveSession.cfm';
			var form = $('<form action="' + url + '" method="post">' +
  				'<input type="text" name="location" value="ProgramStudentDetail.cfm"/>' +
  				'</form>');
			$('body').append(form);
			form.submit();
		}

});


 </script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
