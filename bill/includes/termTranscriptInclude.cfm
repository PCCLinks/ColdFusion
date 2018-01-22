<!--- Get Classes to Bill --->
<cfinvoke component="pcclinks.bill.ProgramBilling" method="getBannerClassesForTerm"  returnvariable="data">
	<cfinvokeargument name="pidm" value="#attributes.pidm#">
	<cfinvokeargument name="term" value="#attributes.term#">
	<cfinvokeargument name="contactId" value="#attributes.contactId#">
</cfinvoke>

<table id="dt" name="dt" class="unstriped hover compact" cellspacing="0" width="100%">
	<thead>
    	<tr>
            <th id="SUBJ">Class</th>
            <th id="Title">Title</th>
			<th id="Credits">CR</th>
			<th id="Grade">GR</th>
			<th id="TakenPreviousTerm">Taken Prev.</th>
			<th>Billled</th>
       </tr>
     </thead>
     <tbody>
		<cfif data.recordcount EQ 0>
		<tr>
			<td colspan="6">No classes for term</td>
		</tr>
		<cfelse>
		<cfoutput query="data">
        <tr>
            <td width="5px">#SUBJ#:#CRSE#</td>
            <td>#Title#</td>
			<td>#NumberFormat(Credits,"0")#</td>
			<td>#Grade#</td>
			<td><cfif LEN(#TakenPreviousTerm#) EQ 0 OR #TakenPreviousTerm# EQ 0>No<cfelse><span style="color:red">#TakenPreviousTerm#</span></cfif></td>
			<td><cfif #billed# EQ 'No'><span style="color:red">No</span><cfelse>#billed#</cfif>
		</tr>
		</cfoutput>
		</cfif>
	</tbody>
</table>


