<!--- Get Past Courses --->

<cfinvoke component="pcclinks.bill.ProgramBilling" method="selectBannerClasses"  returnvariable="qryPastClasses">
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
<!--->  <legend>These are the prior classes taken by the student in the selected current class subject area.</legend>
	Classes that were given a "W" are in red.</legend>--->
<table name="dt_classes" id="dt_classes" class="unstriped compact" cellspacing="0" width="100%" style="font-size:14px">
		<thead>
    	<tr>
			<th>Term</th>
            <th>CRN</th>
            <th>CRSE</th>
            <th>Title</th>
			<th>CR</th>
			<th>Grade</th>
			<th>Prev. Term</th>
			<th>Billed</th>
       </tr>
     </thead>
     <tbody>
		<cfoutput query="data">
        <!---><tr <cfif #grade# EQ 'W'> style="color:red;"</cfif>>--->
		<tr>
			<td>#Term#</td>
            <td>#CRN#</td>
            <td>#SUBJ# #CRSE#</td>
            <td>#Title#</td>
            <td>#Credits#</td>
            <td>#Grade#</td>
            <td>#TakenPreviousTerm#</td>
            <td><cfif term GT 201702> <!--- billing system not in place prior do n/a --->
					<cfif #IncludeFlag# EQ 1>Y<cfelse>N</cfif>
				</cfif>
			</td>
		</tr>
		</cfoutput>
	</tbody>
</table>

<script type="text/javascript">

//source page: pastClassesInclude.cfm
$(document).ready(function() {
    // grouping for the classes table
	$('#dt_classes').DataTable({
		searching: false,
		paging: false,
		info: false,
		columns:[{data:'Term'},{data:'CRSE'},{data:'SUBJ'},{data:'Title'},{data:'Credits'},{data:'Grade'},{data:'TakenPreviousTerm'},{data:'IncludeFlag'}],
		//columns:[{data:'Term'},{data:'CRSE'},{data:'SUBJ'},{data:'Title'},{data:'Credits'},{data:'Grade'}],
		orderFixed:([0, 'desc']),
    	rowGroup: {
    		dataSrc: 'Term'
    	}
    });

});

</script>