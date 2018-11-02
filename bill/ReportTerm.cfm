<cfset pcc_title = 'PCC Links Billing' />
<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getMaxTerm"  returnvariable="maxTerm"></cfinvoke>
<cfinvoke component="Report" method="termReport" returnvariable="qryData">
	<cfinvokeargument name="program" value="#url.program#">
	<cfinvokeargument name="schooldistrict" value="#url.schooldistrict#">
	<cfinvokeargument name="programYear" value="#url.programYear#">
	<cfinvokeargument name="term" value="#maxTerm#">
</cfinvoke>


<cfinvoke component="Report" method="getReportList"  returnvariable="reportListData">
	<cfinvokeargument name="programYear" value="#url.programYear#">
	<cfinvokeargument name="billingType" value="#url.type#">
</cfinvoke>

<div class="off-canvas-wrapper">
<div class="off-canvas-wrapper-inner" data-off-canvas-wrapper>
<div class="off-canvas position-left" id="offCanvasLeft" data-off-canvas>
<ul class="menu vertical">
<cfif not isNull(reportListData)>
	<cfoutput query="reportListData">
	<li><a href="ReportTerm.cfm?schooldistrict=#schoolDistrict#&program=#program#&type=#url.type#&programYear=#url.programYear#">#schoolDistrict# - #program#</a></li>
     </cfoutput>
</cfif>
</ul> <!-- end of menu -->
</div> <!-- end of class=off-canvas position-left -->

<!--MAIN REPORT -->
<div class="off-canvas-content" data-off-canvas-content>
	<table width="100%" style="border-style:none;" >
		<tr>
			<td style="text-align:left; font-size:12px; border-style:none;margin-left:10px">
				<cfoutput>#url.schooldistrict#</cfoutput>
			</td>
			<td class="bottom-border" style="text-align:right; font-size:12px; border-style:none;">
				Alternative Education Program
			</td>
		</tr>
		<tr>
			<td colspan="2" class="no-border" style="text-align:center; font-size:12px; border-style:none;">
				<h4>College Quarterly Credit - Equivalent Instructional Days</h4>
				<cfoutput><b>All Students at #Program# between #DateFormat(qryData.billingStartDate,'m/d/yyyy')# and #DateFormat(qryData.billingEndDate,'m/d/yyyy')#</b></cfoutput>
			</td>
		</tr>
	</table>
</div> <!-- end of class=off-canvas-content -->
</div> <!-- end of class=off-canvas-wrapper-inner -->
</div> <!-- end of class=off-canvas-wrapper -->

<!-- Fire Off-canvas -->
<button type="button" class="button alert" data-toggle="offCanvasLeft">Show Report List</button>

<input class="button" id="print" value="Print Friendly Version" onClick="javascript: print();">
<div id="displayTable">
<cfinclude template="includes/reportTermDisplayTableInclude.cfm">
</div>

<cfsavecontent variable="pcc_scripts">
<script>

	$(document).ready(function() {
	    setUpTable();
	} );

	function setUpTable(){
		$('#dt_table').dataTable( {
	    	dom: '<"top"if>rt<"bottom"lp>',
	    	// order by lastname
	    	order:1,
	    	bSort:false,
	        scrollY: "400px",
	        scrollX: true,
	        //scrollCollapse: true,
	        paging: false,
       		fixedColumns:true
	    } ); //end data table
	} //end setup table

	function print(){
		window.open('ReportTermPrintTable.cfm');
	}

</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">