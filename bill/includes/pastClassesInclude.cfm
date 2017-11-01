<!--- Get Past Courses --->

<cfinvoke component="ProgramBilling" method="selectBannerClasses"  returnvariable="qryPastClasses">
	<cfinvokeargument name="pidm" value="#attributes.pidm#">
	<cfinvokeargument name="term" value="#attributes.Term#">
	<cfinvokeargument name="contactId" value="#attributes.contactId#">
</cfinvoke>

<cfquery dbtype="query" name="data">
	select *
	from qryPastClasses
	where term != <cfqueryparam value="#attributes.Term#">
</cfquery>

<b>Past Classes</b>
<legend>These are the prior classes taken by the student in the selected current class subject area.  Classes that were given a "W" are in red.</legend>
<table name="dt_classes" id="dt_classes" class="unstriped compact" cellspacing="0" width="100%">
		<thead>
    	<tr>
			<th>Term</th>
            <th>CRN</th>
            <th>SUBJ</th>
            <th>Title</th>
			<th>CR</th>
			<th>Grade</th>
			<th>Taken Prev.</th>
			<th>Incl.</th>
       </tr>
     </thead>
     <tbody>
		<cfoutput query="data">
        <tr <cfif #grade# EQ 'W'> style="color:red;"</cfif>>
			<td>#Term#</td>
            <td>#CRN#</td>
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