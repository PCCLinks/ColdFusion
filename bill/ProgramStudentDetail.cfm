<cfinclude template="includes/header.cfm" />

<!--- Set Page Variables --->
<cfset Variables.BannerGNumber = #Session.bannerGNumber#>
<cfset Variables.Term = #Session.term#>
<!---<cfset Variables.Program = #Session.Program#>--->
<cfset Variables.BillingStatus = "">
<cfparam name="showNext" default=true>
<cfif IsDefined("session.showNext")>
	<cfset showNext = session.showNext>
</cfif>


<!--- Get Page Header Data --->
<!--- Current Status --->
<cfinvoke component="ProgramBilling" method="getProgramStudent"  returnvariable="qryStudent">
	<cfinvokeargument name="bannerGNumber" value="#Variables.BannerGNumber#">
	<cfinvokeargument name="term" value="#Variables.Term#">
</cfinvoke>
<cfset Variables.programType = "term">
<cfif qryStudent.program CONTAINS "attendance" >
	<cfset Variables.programType = "attendance">
</cfif>

<!--- Previous Statuses for Year --->
<cfinvoke component="ProgramBilling" method="getOtherBilling"  returnvariable="qryOtherBilling">
	<cfinvokeargument name="contactid" value="#qryStudent.contactid#">
	<cfinvokeargument name="term" value="#Variables.Term#">
</cfinvoke>



<!--- Set Billing Student Variables --->
<cfset Variables.BillingStudentID = qryStudent.billingStudentID>
<cfset Variables.BillingStudentProgram = qryStudent.Program>

<!--- Get Classes to Bill --->
<cfinvoke component="ProgramBilling" method="selectBillingEntries"  returnvariable="qryEntries">
	<cfinvokeargument name="bannerGNumber" value="#Variables.BannerGNumber#">
	<cfinvokeargument name="term" value="#Variables.Term#">
</cfinvoke>
<!--- Get Past Courses --->
<cfset args = {"pidm"= qryStudent.pidm, "term" = Variables.Term, "subj" = ""}>
<cfinvoke component="ProgramBilling" method="selectBannerClasses"  returnvariable="qryPastClasses">
	<cfinvokeargument name="pidm" value="#qryStudent.pidm#">
	<cfinvokeargument name="term" value="#Variables.Term#">
	<cfinvokeargument name="contactId" value="#qryStudent.contactId#">
</cfinvoke>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>


<!----------------------------- Data from qryStudent Current Status------------------------------------------------>
<cfoutput query="qryStudent">
	<cfset Variables.BillingStatus = #BillingStatus#>
	<div class=<cfif #BillingStatus# EQ 'COMPLETE'>"callout alert"<cfelse>"callout primary"</cfif> >
		<cfif showNext>
		<div class="row">
			<!-- previous button -->
			<div class="small-11 columns"><input id="prevStudent" name="prevStudent" type="button" class="button" value="<<"></div>
			<div class="small-1 columns"><input id="nextStudent" name="nextStudent" type="button" class="button" value=">>"></div>
		</div>
		</cfif>
		<div class="row">
			<div class="small-1 columns"><b>G</b></div>
			<div class="small-1 columns"><b>Name</b></div>
			<div class="small-3 columns"><b>Program</b></div>
			<div class="small-1 columns"><b>Enrolled Date</b></div>
			<div class="small-1 columns"><b>Exit Date </b></div>
			<div class="small-1 columns"><b>Term</b></div>
			<div class="small-1 columns"><b>School</b></div>
			<div class="small-1 columns"><b>Status</b></div>
			<div class="small-1 columns"><b>Review with Coach</b></div>
			<div class="small-1 columns"><b>Include in Billing</b></div>
		</div>
		<div class="row">
			<div class="small-1 columns">#bannerGNumber#</div>
			<div class="small-1 columns">#FIRSTNAME# #LASTNAME#</div>
			<div class="small-3 columns">
				<cfif #billingstatus# EQ 'COMPLETE'>
					#program#
				<cfelse>
				<select name="program" id="program">
					<cfloop query="programs">
						<option value="#programName#" <cfif #qryStudent.program# EQ #programName#> selected </cfif> > #programName# </option>
					</cfloop>
				</select>
				</cfif>
			</div>
			<div class="small-1 columns">#DateFormat(ENROLLEDDATE,"m/d/yy")#</div>
			<div class="small-1 columns"><cfif LEN(#EXITDATE#) EQ 0>None<cfelse>#DateFormat(EXITDATE,"m/d/yy")#</cfif></div>
			<div class="small-1 columns">#term#</div>
			<div class="small-1 columns">#schooldistrict#</div>
			<div class="small-1 columns">#billingstatus#</div>
			<div class="small-1 columns">
				<input type="checkbox" id="reviewWithCoachFlag" <cfif #reviewWithCoachFlag# EQ 1>checked</cfif>>
			</div>
			<div class="small-1 columns">
				<input type="checkbox" id="includeFlag" <cfif #includeFlag# EQ 1>checked</cfif>>
			</div>
		</div>

		<div class="row">
			<div class="small-12 columns" style="color:red">
				#ErrorMessage#
			</div>
		</div>
	</div> <!-- end header data -->
</cfoutput>
<!------------------------ End Data from qryStudent -------------------------------------------->


<!----------------------------- Data from qryOtherBilling Previous Year Status Status------------------------------------------------>
<cfoutput query="qryOtherBilling">
	<div class=<cfif #BillingStatus# EQ 'COMPLETE'>"callout alert"<cfelse>"callout primary"</cfif> >
		<div class="row">
			<div class="small-2 columns"><b>Program</b></div>
			<div class="small-1 columns"><b>Enrolled Date</b></div>
			<div class="small-2 columns"><b>Exit Date </b></div>
			<div class="small-1 columns"><b>Term</b></div>
			<div class="small-1 columns"><b>School</b></div>
			<div class="small-1 columns"><b>Status</b></div>
			<div class="small-3 columns"></div>
		</div>
		<div class="row">
			<div class="small-2 columns">#program#</div>
			<div class="small-1 columns">#DateFormat(ENROLLEDDATE,"m/d/yy")#</div>
			<div class="small-2 columns"><cfif LEN(#EXITDATE#) EQ 0>None<cfelse>#DateFormat(EXITDATE,"m/d/yy")#</cfif></div>
			<div class="small-1 columns">#term#</div>
			<div class="small-1 columns">#schooldistrict#</div>
			<div class="small-1 columns">#billingstatus#</div>
			<div class="small-3 columns" style="color:red">#ErrorMessage#</div>
		</div>
	</div> <!-- end header data -->
</cfoutput>
<!------------------------ End Data from qryOtherBilling -------------------------------------------->


<div class="row">
	<!---------------------------------------------------------------------------->
	<!--- Billed Classes -------------------------------------------------------->
	<!---------------------------------------------------------------------------->
	<div class="small-4 columns">
		<b>Billed Classes</b>
		<table id="dt_billed" name="dt" class="unstriped hover compact" cellspacing="0" width="100%">
			<thead>
		    	<tr>
			    	<th style="display:none;" id="BillingStudentItemId"></th>
			    	<th id="term">Term</th>
		            <th id="CRSE">CRSE</th>
		            <th id="SUBJ">SUBJ</th>
		            <th id="Title">Title</th>
					<th id="TakenPreviousTerm">Taken Prev.</td>
					<th <cfif Variables.programType EQ "attendance">id="Attendace">Attend.<cfelse>id="Credits">CR</cfif></th>
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
		            <td><cfif programType EQ "attendance">
		            		<a href="javascript:getAttendanceDetail(#CRN#)" >#NumberFormat(Attendance,"0.0000")#</a>
		            	<cfelse>
		            		#NumberFormat(Credits,"0")#
		            	</cfif>
					</td>
		            <td><input type="checkbox" id="IncludeFlag"  <cfif #IncludeFlag# EQ 1>checked</cfif>></td>
				</tr>
				</cfoutput>
			</tbody>
		</table>
		<div class="callout">
			<b>Billing Reviewed:</b> <input type="checkbox" name="billingReviewed" id="billingReviewed" <cfif Variables.BillingStatus EQ "Complete" and Variables.term EQ qryStudent.Term>checked</cfif> >
		</div>
	</div>
	<div class="small-1 columns"></div>
	<!---------------------------------------------------------------------------->
	<!--- Past Classes -------------------------------------------------------->
	<!---------------------------------------------------------------------------->
	<div class="small-7 columns">
	<b>Past Classes</b>
	<legend>These are the prior classes taken by the student in the selected current class subject area.  Classes that were given a "W" are in red.</legend>
	<table name="dt_classes" id="dt_classes" class="unstriped compact" cellspacing="0" width="100%">
			<thead>
	    	<tr>
				<th>Term</th>
	            <th>CRSE</th>
	            <th>SUBJ</th>
	            <th>Title</th>
				<th>CR</th>
				<th>Grade</th>
				<th>Taken Prev.</th>
				<th>Incl.</th>
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
	            <td>#TakenPreviousTerm#</td>
	            <td><input type="checkbox" id="IncludeFlag" readonly <cfif #IncludeFlag# EQ 1>checked</cfif>></td>
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
			columns:[{data:'Term'},{data:'CRSE'},{data:'SUBJ'},{data:'Title'},{data:'Credits'},{data:'Grade'},{data:'TakenPreviousTerm'},{data:'IncludeFlag'}],
			orderFixed:([0, 'desc']),
	    	rowGroup: {
	    		dataSrc: 'Term'
	    	}
	    });

	   // save program dropdown changes
	   $('#program').change(function(){
			var program = $(this).val();
			var billingStudentId = <cfoutput>#Variables.BillingStudentID#</cfoutput>;
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

	   // save billing reviewed checkbox changes
	   $('#billingReviewed').click(function(){
			var checked = $(this)[0].checked;
			var billingStudentId = <cfoutput>#Variables.BillingStudentID#</cfoutput>;
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
			var billingStudentId = <cfoutput>#Variables.BillingStudentID#</cfoutput>;
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
			var billingStudentId = <cfoutput>#Variables.BillingStudentID#</cfoutput>;
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
			bannerGNumber = setNextGNumber(1);
			goToDetailPage(bannerGNumber);
		});

		$('#prevStudent').button().click(function (){
			bannerGNumber = setNextGNumber(0);
			goToDetailPage(bannerGNumber);
		});
	});



	function setNextGNumber(isGetNext){
		var next = isGetNext;
		var prev = isGetNext ? 0 : 1;
		var bannerGNumber = "";
		$.ajax({
			url: "programbilling.cfc?method=getNextGNumberInSession",
			type: "POST",
			async: false,
			dataType:"json",
			data: { getNext: next, getPrev: prev, bannerGNumber: '<cfoutput>#Variables.bannerGNumber#</cfoutput>'},
			error: function (jqXHR, exception) {
		        handleAjaxError(jqXHR, exception);
			},
			success: function(data){
				bannerGNumber = data;
			}
		});
		return bannerGNumber;
	}

	function getAttendanceDetail(crn){
		<cfoutput>sessionStorage.setItem("term", #Variables.term#);</cfoutput>
		sessionStorage.setItem("CRN", crn);
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  		$.post("SaveSession.cfm", data, function(){
  			window.open('AttendanceDetail.cfm?crn=' + crn);
  		});
	}

 </script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
