<!---<cfdump var="#Session#">--->
<cfset varBannerGNumber = #Session.bannerGNumber#>
<cfset varTerm = #Session.term#>
<cfset varGList = #Session.gList#>
<cfset varProgram = #Session.Program#>
<cfinvoke component="ProgramBilling" method="yearlybilling"  returnvariable="qryStudent">
	<cfinvokeargument name="bannerGNumber" value="#varBannerGNumber#">
	<cfinvokeargument name="term" value="#varTerm#">
</cfinvoke>
<cfinvoke component="ProgramBilling" method="selectBillingEntries"  returnvariable="qryEntries">
	<cfinvokeargument name="bannerGNumber" value="#varBannerGNumber#">
	<cfinvokeargument name="term" value="#varTerm#">
</cfinvoke>
<cfset args = {"gnumber"= varbannerGNumber, "term" = varTerm, "subj" = ""}>
<cfinvoke component="ProgramBilling" method="selectBannerClasses"  returnvariable="qryPastClasses">
	<cfinvokeargument name="row" value="#args#">
</cfinvoke>
<html>
<head>
 <link rel="stylesheet" href="css/foundation.css">
  <script src="js/vendor/jquery.js"></script>
 <script src="https://code.jquery.com/jquery-1.12.4.js"></script>

<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.css"/>


</head>

<body>
<nav class="top-bar">
    <ul class="menu">
     	 <li><a href="Billing.cfm">Home</a></li>
     	 <li><a href="SetUpBilling.cfm">Generate</a></li>
     	 <li><a href="ProgramStudent.cfm">Submit Billing</a></li>
     	 <li><a href="Reconcile.cfm">Reconcile Previous Billing</a></li>
     	 <li><a href="BillingSummary.cfm">Reports</a></li>
	  </ul>
</nav>


<cfoutput query="qryStudent">
	<cfset varBillingStatus = #BillingStatus#>
	<div class=<cfif #BillingStatus# EQ 'COMPLETE'>"callout alert"<cfelse>"callout primary"</cfif> >
	<form name="billingStatus">
		<input type="hidden" name="StudentBillingID" value='#CurrentStudentBillingID#'>
		<input  type="hidden" name="BillingStatus" value='#BillingStatus#'>
	</form>
		<div class="row">
			<div class="small-12 columns"><p><b>Program Student Billing Review</b></p></div>
		</div>
		<div class="row">
			<div class="small-1 columns">Previous</div>
			<div class="small-2 columns"><b>G</b></div>
			<div class="small-2 columns"><b>Name</b></div>
			<div class="small-1 columns"><b>Program</b></div>
			<div class="small-1 columns"><b>Enrolled Date</b></div>
			<div class="small-1 columns"><b>Exit Date </b></div>
			<div class="small-1 columns"><b>Billing Date</b></div>
			<div class="small-2 columns"><b>Review with Coach</b></div>
			<div class="small-1 columns">Next</div>
		</div>
		<div class="row">
			<div class="small-1 columns"><input id="prevStudent" name="prevStudent" type="button" class="button" value="<<<"></div>
			<div class="small-2 columns">#bannerGNumber#</div>
			<div class="small-2 columns">#FIRSTNAME# #LASTNAME#</div>
			<div class="small-1 columns">#PROGRAM#</div>
			<div class="small-1 columns">#DateFormat(ENROLLEDDATE,"m/d/yy")#</div>
			<div class="small-1 columns"><cfif LEN(#EXITDATE#) EQ 0>None<cfelse>#DateFormat(EXITDATE,"m/d/yy")#</cfif></div>
			<div class="small-1 columns"><cfif LEN(#BillingDate#) EQ 0>N/A<cfelse>#DateFormat(BillingDate,"m/d/yy")#</cfif></div>
			<div class="small-2 columns">
				<input type="checkbox"  >
			</div>
			<div class="small-1 columns"><input id="nextStudent" name="nextStudent" type="button" class="button" value=">>>"></div>
		</div>
	</div>
</cfoutput>

<div class="row">
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
					<td><cfif LEN(#TakenPreviousTerm#) EQ 0 OR #TakenPreviousTerm# EQ 0>No<cfelse><span style="color:red">Yes</span></cfif></td>
		            <td>#NumberFormat(CourseValue,"0")#</td>
		            <td><input type="checkbox" id="IncludeFlag" <cfif #IncludeFlag# EQ 1>checked</cfif>></td>
				</tr>
				</cfoutput>
			</tbody>
		</table>
		<div class="callout">
			<b>Billing Reviewed:</b> <input type="checkbox" <cfif #varBillingStatus# EQ "Complete">checked</cfif> >
		</div>
	</div>
	<div class="small-1 columns"></div>
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
</div>

</body>
<footer>
<script type="text/javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
<script type="text/javascript" src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/v/dt/dt-1.10.15/b-1.3.1/b-html5-1.3.1/kt-2.2.1/r-2.1.1/rg-1.0.0/datatables.min.js"></script>
<script type="text/javascript" charset="utf8" src="js/jquery.blockUI.js"></script>

<cfoutput>

<script>
	var term = #varTerm#;
	var program = '#varProgram#';
</script>
</cfoutput>

<script>
$(document).ready(function() {
	$('#dt_classes').DataTable({
		searching: false,
		paging: false,
		info: false,
		columns:[{data:'Term'},{data:'CRSE'},{data:'SUBJ'},{data:'Title'},{data:'Credits'},{data:'Grade'}],
    	rowGroup: {
    		dataSrc: 'Term'
    	}
    });
    $('#dt_billed').DataTable({
    	searching:false,
    	paging:false,
    	info:false,
    	ordering: false,
    	language: {
      		emptyTable: "No classes for term: <cfoutput>#varTerm#</cfoutput> "
    	}
    });

   $('#dt_billed').find('td').click(function(){
		cb = $(this).find('input:checkbox');
 		dt = $('#dt_billed').DataTable();
		var tableRow  = dt.row(this).data();
		id = tableRow[0];

		var rowData ={};
		rowData["BillingStudentItemID"] = id;
		rowData["IncludeFlag"] = (cb[0].checked?1:0);
		$.blockUI({ message: '<h1>Just a moment...</h1>' });
		$.ajax({
			url: "programbilling.cfc?method=editstudentbillingiteminclude",
			dataType: "json",
			type: "POST",
			async: false,
			data: { row: JSON.stringify(rowData) },
			success: function(data) {
				// process the results, 200 is good, anything else give them the error
				if (data['ResultCode'] == 200){
				}
				 else {
					$("#resultBox").html('');

					$.each(data['ResultMessages'], function(index, value) {
						$("#resultBox").append("<div>" + value + "</div>");
					});

					$("#resultBox").removeClass("results").addClass("error").show().focus();

				}
			}
		});
		$.unblockUI();
	});



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
			url: "programbilling.cfc?method=getGNumber",
			dataType: "json",
			type: "POST",
			async: false,
			data: { getNext: next, getPrev: prev}
		});
	}


});

	function goToDetailPage(){
		window.location = 'ProgramStudentDetail.cfm';
			//var url = 'ProgramStudentDetail.cfm';
			//var form = $('<form action="' + url + '" method="post">' +
  			//	'<input type="text" name="bannerGNumber" value="' + bannerGNumber + '" />' +
  			//	'<input type="text" name="term" value="' + term + '" />' +
  			//	'<input type="text" name="program" value="' +  program + '" />' +
  			//	'<input type="text" name="gList" value=' +  JSON.stringify(gList) + '/>' +
  			//	'</form>');
			//$('body').append(form);
			//form.submit();
	}

 </script>

</footer>
</html>