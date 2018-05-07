<!--- Get Classes to Bill --->
<cfinvoke component="pcclinks.bill.ProgramBilling" method="selectBillingEntries"  returnvariable="data">
	<cfinvokeargument name="billingStudentId" value="#attributes.billingStudentId#">
</cfinvoke>

<cfset Variables.programType = "term">
<cfif data.program CONTAINS "attendance" >
	<cfset Variables.programType = "attendance">
</cfif>

<b>Current Classes</b>
<table id="dt_billed" name="dt" class="unstriped hover compact" cellspacing="0" width="100%" style="font-size:14px">
	<thead>
    	<tr>
	    	<th style="display:none;" id="BillingStudentItemId"></th>
	    	<th id="term">Term</th>
            <th id="CRN">CRN</th>
            <th id="SUBJ">CRSE</th>
            <th id="Title">Title</th>
			<th id="TakenPreviousTerm">Taken Prev.</th>
			<th><cfif Variables.programType EQ "attendance">Attend. To Date
					<cfelse>Credits
				</cfif>
			</th>
			<th id="IncludeFlag">Bill</th>
       </tr>
     </thead>
     <tbody>
		<cfoutput query="data">
        <tr>
	    	<td style="display:none;">#BillingStudentItemId#</td>
	    	<td >#term#</td>
            <td>#CRN#</td>
            <td>#SUBJ# #CRSE#</td>
            <td>#Title#</td>
			<td><cfif LEN(#TakenPreviousTerm#) EQ 0 OR #TakenPreviousTerm# EQ 0>No<cfelse><span style="color:red">#TakenPreviousTerm#</span></cfif></td>
			<td><cfif programType EQ "attendance">#NumberFormat(AttendanceToDate,"0.0000")#
					<cfelse>#NumberFormat(Credits,"0")#
				</cfif>
			</td>
            <td>
				<cfif inBilling EQ 0>
					<span style="color:red">#billingStatus#</span>
				<cfelse>
					<cfif billingStatus EQ 'BILLED'>
						<cfif IncludeFlag EQ 1>TRUE<cfelse>FALSE</cfif>
					<cfelse>
						<input type="checkbox" id="IncludeFlag"  <cfif #IncludeFlag# EQ 1>checked</cfif>>
					</cfif>
				</cfif>
			</td>
		</tr>
		<cfif inBanner EQ 0>
			<tr><td colspan="7"><span style="color:red; line-height:50%">CRN #crn# billed but has been dropped in Banner</span></small></td></tr>
		</cfif>
		</cfoutput>
	</tbody>
</table>
<cfif data.BillingStatus NEQ 'BILLED'>
<div class="callout">
	<b>Billing Reviewed:</b> <input type="checkbox" name="billingReviewed" id="billingReviewed" <cfif data.BillingStatus EQ "Reviewed">checked</cfif> >
</div>
</cfif>

<script type="text/javascript">

//source page: billedClassesInlude.cfm
$(document).ready(function() {
	//setup for billing table
    $('#dt_billed').DataTable({
    	searching:false,
    	paging:false,
    	info:false,
    	ordering: false,
    	language: {
      		emptyTable: "No classes for term: <cfoutput>#data.Term#</cfoutput> "
    	}
    });

     // save billing reviewed checkbox changes
	 $('#billingReviewed').click(function(){
		var checked = $(this)[0].checked;
		$.ajax({
			url: "programbilling.cfc?method=updatestudentbillingstatus",
			type: "POST",
			async: false,
			data: { billingstudentid: billingStudentId, billingReviewed: checked },
			error: function (jqXHR, exception) {
		        handleAjaxError(jqXHR, exception);
			}
		});
		}); //end save checkbox changes

		 // save include course checkbox changes
	   	$('#dt_billed').find('input:checkbox').click(function(){
			//cb = $(this).find('input:checkbox');
			cb = $(this);
	 		dt = $('#dt_billed').DataTable();
			var tableRow  = dt.row(this.parentNode).data();

			var billingStudentItemId = tableRow[0];
			var includeFlag = (cb[0].checked ? 1 : 0);
			$.ajax({
				url: "programbilling.cfc?method=updatestudentbillingiteminclude",
				type: "POST",
				async: false,
				data: { billingstudentitemid: billingStudentItemId, includeflag:includeFlag },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
		}); //end save checkbox changes
});
</script>