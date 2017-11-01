<!--- Get Classes to Bill --->
<cfinvoke component="ProgramBilling" method="selectBillingEntries"  returnvariable="data">
	<cfinvokeargument name="billingStudentId" value="#attributes.billingStudentId#">
</cfinvoke>


<cfset Variables.programType = "term">
<cfif data.program CONTAINS "attendance" >
	<cfset Variables.programType = "attendance">
</cfif>

<b>Billed Classes</b>
<table id="dt_billed" name="dt" class="unstriped hover compact" cellspacing="0" width="100%">
	<thead>
    	<tr>
	    	<th style="display:none;" id="BillingStudentItemId"></th>
	    	<th id="term">Term</th>
            <th id="CRN">CRN</th>
            <th id="SUBJ">SUBJ</th>
            <th id="Title">Title</th>
			<th id="TakenPreviousTerm">Taken Prev.</th>
			<th <cfif Variables.programType EQ "attendance">id="Attendace">Attend.<cfelse>id="Credits">CR</cfif></th>
			<th id="IncludeFlag">Incl.</th>
       </tr>
     </thead>
     <tbody>
		<cfoutput query="data">
        <tr>
	    	<td style="display:none;">#BillingStudentItemId#</td>
	    	<td >#term#</td>
            <td>#CRN#</td>
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
<cfif data.BillingStatus NEQ 'BILLED'>
<div class="callout">
	<b>Billing Reviewed:</b> <input type="checkbox" name="billingReviewed" id="billingReviewed" <cfif data.BillingStatus EQ "Complete">checked</cfif> >
</div>
</cfif>

