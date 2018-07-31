<!--- Get Past Courses --->
<cfinvoke component="pcclinks.bill.ProgramBilling" method="selectBannerClasses"  returnvariable="qryPastClasses">
	<cfinvokeargument name="pidm" value="#Session.qryStudent.pidm#">
	<cfinvokeargument name="contactId" value="#Session.qryStudent.contactId#">
</cfinvoke>

<cfquery dbtype="query" name="years">
	select ProgramYear
	from qryPastClasses
	group by ProgramYear
	order by ProgramYear desc
</cfquery>
<cfset currentYear = years.ProgramYear>

<b>Past Classes</b>
<!--->  <legend>These are the prior classes taken by the student in the selected current class subject area.</legend>
	Classes that were given a "W" are in red.</legend>--->
<!-- Year Tabs -->
<ul class="tabs" data-tabs id="year-tabs">
	<cfoutput query="years">
		<cfset key = #ProgramYear# >
		<cfset liClass = "tabs-title">
		<cfif ProgramYear EQ currentYear><cfset liClass = liClass & " is-active"></cfif>
  		<li class="#liClass#"><a href="###Replace(ProgramYear,'/','')#C" aria-selected="<cfif ProgramYear EQ '2017/2018'>true<cfelse>false</cfif>">#ProgramYear#</a></li>
	</cfoutput>
</ul>

<!-- year tab content -->
<div class="tabs-content" data-tabs-content="year-tabs">
	<cfoutput query="years">
	<!-- Year tab panel -->
	<div class= "tabs-panel<cfif years.ProgramYear EQ currentYear> is-active</cfif>" id="#Replace(ProgramYear,'/','')#C">
		<table name="dt_classes_#Replace(ProgramYear,'/','')#" id="dt_classes_#Replace(ProgramYear,'/','')#" class="unstriped compact" cellspacing="0" width="100%" style="font-size:14px">
				<thead>
		    	<tr>
			    	<th></th>
					<th>Term</th>
		            <th>CRN</th>
		            <th>CRSE</th>
		            <th>Title</th>
					<th>CR</th>
					<th>Grade</th>
					<th>Prev. Term</th>
					<th>Billed</th>
					<th></th>
					<th></th>
		       </tr>
		     </thead>
		     <tbody>
			</tbody>
		</table>
	</div>
	</cfoutput>
</div>

<script type="text/javascript">
var pastClassData;
function pastClassesInit(){
	$.get("programBilling.cfc?method=selectBannerClassesFromSession", function(data){
		pastClassData = JSON.parse(data).DATA;
	}).done(function(){
		updateTables();
	});
}

function updateTables(){
	var dt;
	var currentYear = <cfoutput>'#currentYear#'</cfoutput>;

	var idx_programYear = 0;
	var idx_term = 1;
	var idx_includeFlag = 8;
	var idx_billingStudentItemId = 9;
	var idx_isTermBilling = 10;
	//debugger;

	<cfoutput query="years">
	var gridData = [];
	$.each(pastClassData, function(key, value) {
      if ( value[0] == "#ProgramYear#" ){
      		gridData.push(value);
      	}
      });
	dt = $('##dt_classes_#Replace(ProgramYear,'/','')#').DataTable({
		searching: false,
		paging: false,
		info: false,
    	data:gridData,
		columnDefs:[{targets:idx_programYear, visible:false },
			{targets:idx_billingStudentItemId, visible:false },
			{targets:idx_isTermBilling, visible:false },
	    	{targets:idx_includeFlag,
	    		render: function ( data, type, row ) {
	    			if((row[idx_programYear] != currentYear) || (row[idx_isTermBilling] == 0) ){
	    				return (data == 1 ? 'Y' : 'N');
	    			}else{
						return '<input type="checkbox" id="IncludeFlag' + row[idx_billingStudentItemId] + '"' + (data == 1 ? ' checked ' : '') + ' onChange="javascript:updateClassIncludeFlag(\'IncludeFlag' + row[idx_billingStudentItemId] + '\',' + row[idx_billingStudentItemId] + ');" >';
	    			}
	    		}
	    	}],
		orderFixed:([idx_term, 'desc']),
    	rowGroup: {
    		dataSrc: idx_term
    	}
    });
    </cfoutput>
}
</script>