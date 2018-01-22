<cfset pcc_title = 'PCC Links Billing' />
<cfinclude template="includes/header.cfm">

<cfset Variables.program="#url.program#" >
<cfset Variables.schooldistrict="#url.schooldistrict#" >
<cfset Variables.term="#url.term#" >

<cfinvoke component="LookUp" method = "getProgramYearTerms" term="#Variables.term#" returnvariable="terms"></cfinvoke>
<cfinvoke component="Report" method="termReport" returnvariable="qryData">
	<cfinvokeargument name="program" value="#Variables.program#">
	<cfinvokeargument name="schooldistrict" value="#Variables.schooldistrict#">
	<cfinvokeargument name="term" value="#Variables.term#">
</cfinvoke>

<cfinvoke component="LookUp" method="getProgramYearTerms" value="terms"></cfinvoke>

<div class="row" id="tableheader">
	<table width="100%" style="border-style:none;" >
		<tr>
			<td style="text-align:left; font-size:12px; border-style:none;">
				<cfoutput>#url.schooldistrict#</cfoutput>
			</td>
			<td class="bottom-border" style="text-align:right; font-size:12px; border-style:none;">
				Alternative Education Program
			</td>
		</tr>
		<tr>
			<td colspan="2" class="no-border" style="text-align:center; font-size:12px; border-style:none;">
				<h4>College Quarterly Credit - Equivalent Instructional Days</h4>
				<cfoutput><b>All Students at #Program# between #qryData.BillingStartDate# and #qryData.BillingEndDate#</b></cfoutput>
			</td>
		</tr>
	</table>
</div>

<input class="button" id="recalculate" value="Recalculate" onClick="javascript: reCalculate();">
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

	function goToBillingRecord(billingStudentId){
		window.open('programStudentDetail.cfm?billingStudentId='+billingStudentId+'&showNext=true#Billing');
	}

	function print(){
		window.open('ReportTermPrintTable.cfm');
	}

	function reCalculate(){
     	$.ajax({
			url: "report.cfc?method=reCalculateBilling",
			data: <cfoutput>{term: #Variables.term#, billingType: 'term', program: '#Variables.program#', schooldistrict: '#Variables.schooldistrict#'},</cfoutput>
			type: "POST",
     		success: function(){
			$.ajax({
	        	url: 'includes/reportTermDisplayTableInclude.cfm?',
	       		cache: false
		    	}).done(function(data) {
		        	$("#displayTable").html(data);
		        	setUpTable();
		    	}); //end done
     				}, //end function success
			error: function (jqXHR, exception) {
	        	handleAjaxError(jqXHR, exception);
			} //end error
      	})//end ajax
     } //end recalculate button

</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">