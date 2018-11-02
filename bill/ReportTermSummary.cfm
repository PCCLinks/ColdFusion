<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getOpenTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method = "getProgramYearTerms" returnvariable="terms"></cfinvoke>

<cfparam name="term" default="#qryTerms.Term#">

<cfinvoke component="Report" method="termSummary" returnvariable="data">
	<cfinvokeargument name="term" value="#Variables.term#">
</cfinvoke>


<style>

	.dataTables_info{
		margin-right:10px !important;
	}
	.dataTables_filter input{
		width:75%;
		display: inline-block;
	}
	.dataTables_length select {
		width:auto;
	}
</style>
<cfset title = "Term Summary for #term#">
<!---><cfset Session.attendanceEntryTitle = title>--->
<form action="ReportTermSummary.cfm" method="post">
<div class="callout primary">
	<label for="term">Term Summary for:&nbsp;&nbsp;
		<select name="term" id="term" onChange="javascript:this.form.submit()" style="width:200px">
			<option disabled selected value="" > --Select Term -- </option>
			<cfoutput query="terms">
				<option value="#term#" <cfif term EQ Variables.term> selected </cfif>  > #Term# </option>
			</cfoutput>
		</select>
	</label>
</div>
<div class="callout"><div class="row">
	<div class="large-2 columns"><a class="group-by" data-column="0" data-src="crn">Group by CRN</a></div>
	<div class="large-3 columns"><a class="group-by" data-column="3" data-src="schooldistrict">Group by School District</a></div>
	<div class="large-3 columns"><a class="group-by" data-column="4" data-src="program">Group by Program</a></div>
	<div class="large-4 columns"><a class="group-by" data-column="5" data-src="bannerGNumber">Group by Student</a></div>
</div></div>
</form>
<table id="dt_table">
	<thead>
		<tr>
			<th>CRN</th>
			<th>Crse</th>
			<th>Subj</th>
			<th>District</th>
			<th>Program</th>
			<th>G</th>
			<th>First Name</th>
			<th>Last Name</th>
			<th>Program Exit</th>
			<th>Current Exit</th>
			<th>Credits</th>
			<th>Exclude Student</th>
			<th>Exclude Class</th>
		</tr>
	</thead>
	<tbody>
		<cfoutput query="data">
		<tr>
			<td>#crn#</td>
			<td>#crse#</td>
			<td>#subj#</td>
			<td>#schooldistrict#</td>
			<td>#program#</td>
			<td><a href='javascript:getBillingStudent(#billingStudentId#, true);'>#bannerGNumber#</a></td>
			<td>#firstname#</td>
			<td>#lastname#</td>
			<td>#DateFormat(exitDate,'m/d/yyyy')#</td>
			<td>#DateFormat(sidnyExitDate,'m/d/yyyy')#</td>
			<td>#NumberFormat(Credits,'99')#</td>
			<td>#includestudent#</td>
			<td>#includeclass#</td>
		</tr>
		</cfoutput>
	</tbody>
</table>


<cfsavecontent variable="pcc_scripts">
	<script>
		$(document).ready(function() {
		    var table = $('#dt_table').DataTable({
		    	dom: '<"top"if>rt<"bottom"lp>',
            	columns:[{data:'crn'},{data:'crse'},{data:'subj'}
            			,{data:'schooldistrict'}, {data:'program'},{data:'bannerGNumber'}
            			,{data:'firstname'},{data:'lastname'},{data:'credits'}
            			,{data:'includestudent'},{data:'includeclass'}, {data:'exitDate'}
            			,{data:'sidnyExitDate'}],
            	rowGroup: {
    				dataSrc: 'crn'
    			},
    			columDefs:[{target:3, visible:false}]
		    });

		    $('a.group-by').on( 'click', function (e) {
				e.preventDefault();
				table.column($(this).data('column')).order('asc');
				table.rowGroup().dataSrc( $(this).data('src') );
				table.order.fixed( {pre: [[ $(this).data('column')*1, 'asc' ]]} ).draw();
			});
		} );


	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">