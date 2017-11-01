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
<cfset Session.reportTermPrintTable = qryData>
<cfinvoke component="LookUp" method="getProgramYearTerms" value="terms"></cfinvoke>
<style>

		/*table tbody td, table tfoot td{
			text-align:right;
			padding:4x;
		}
		table thead th, table tbody td, table tfoot td {
			border-color:lightgray;
			border-style:solid solid none none;
			border-width: 0.5px;
		}
		table{
			border-collapse: collapse;
		}
		.no-border{
			border-color:none;
			border-style:none;
			border-width: 0px;
		}
		.bold-left-border{
			border-left-width:2px;
			border-left-style:solid;
			border-left-color:black;
		}
		.bold-right-border{
			border-right-width:1px;
			border-right-style:solid;
			border-right-color:black;
		}
		.border-no-bottom{
			border-bottom-style:none;
		}
		.border-no-top{
			border-top-style:none;
		}

		.dataTables_wrapper .dataTables_processing{
			top: 70% !important;
			height: 50px !important;
			background-color: lightGray;
		}
		.dataTables_info{
			margin-right:10px !important;
		}
		select {
			width:auto !important;
		}
		input{
			display:inline-block !important;
			width:auto !important;
		}
		*/


	</style>

	<div class="row" id="tableheader">
		<table width="100%" style="border-style:none;" >
			<tr>
				<td style="text-align:left; font-size:8px; border-style:none;">
					<cfoutput>#url.schooldistrict#</cfoutput>
				</td>
				<td class="bottom-border" style="text-align:right; font-size:8px; border-style:none;">
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

	<table id="dt_table" class="stripe hover">
			<cfoutput>
	            <thead >
	                <tr>
						<th class="no-border"></th>
						<th class="no-border"></th>
						<th class="no-border"></th>
						<th id="SummerNoOfCredits" colspan="2" class="bold-left-border">SUMMER</th>
						<th colspan="4" id="FallNoOfCredits" class="bold-left-border">FALL</th>
						<th colspan="4" id="WinterNoOfCredits" class="bold-left-border">WINTER</th>
						<th colspan="4" id="SpringNoOfCredits" class="bold-left-border">SPRING</th>
						<th class="bold-left-border border-no-bottom"></th>
						<th class="border-no-bottom" colspan="3"></th>
	                </tr>
	                <tr>
						<th class="border-left-border">Student</th>
	                    <th>G</th>
	                    <th class="border-left-border" >Dates</th>
						<!-- SUMMER -->
						<th class="bold-left-border">Credits</th>
						<th >Days</th>
						<!-- FALL -->
						<th class="bold-left-border">Credits</th>
						<th>Over</th>
						<th>Days</th>
						<th>Over</th>
						<!-- WINTER -->
						<th class="bold-left-border">Credits</th>
						<th>Over</th>
						<th>Days</th>
						<th>Over</th>
						<!-- SPRING -->
						<th class="bold-left-border">Credits</th>
						<th>Over</th>
						<th>Days</th>
						<th>Over</th>
						<!-- ROW TOTALS -->
						<th class="border-no-top bold-left-border">Total Credit</th>
						<th class="border-no-top" >Max&nbsp;Total Credit</th>
						<th class="border-no-top" >Total Days</th>
						<th class="border-no-top" >Max&nbsp;Bill Days</th>
	                </tr>
	            </thead>
	            </cfoutput>
	            <tbody>
					<cfif not isNull(qryData)>
						<cfoutput query="qryData">
	                    <tr>
	                        <td ><b>#LASTNAME#,&nbsp;#FIRSTNAME#</b></td>
							<td>#bannerGNumber#</td>
	                        <td>#EntryDate# <cfif ExitDate NEQ "">-#ExitDate#</cfif></td>
							<!-- SUMMER -->
							<cfif billingStudentIdSummer GT 0><cfset link = true><cfelse><cfset link = false></cfif>
							<td class="bold-left-border"><cfif link><a href='javascript:goToBillingRecord(#billingStudentIdSummer#);'></cfif>#NumberFormat(SummerNoOfCredits,'_._')#<cfif link></a></cfif></td>
							<td>#NumberFormat(SummerNoOfDays,'_._')#</td>
							<!-- FALL -->
							<cfif billingStudentIdFall GT 0><cfset link = true><cfelse><cfset link = false></cfif>
							<td class="bold-left-border"><cfif link><a href='javascript:goToBillingRecord(#billingStudentIdFall#);'></cfif>#NumberFormat(FallNoOfCredits,'_._')#<cfif link></a></cfif></td>
							<td>#NumberFormat(FallNoOfCreditsOver,'_._')#</td>
							<td>#NumberFormat(FallNoOfDays,'_._')#</td>
							<td>#NumberFormat(FallNoOfDaysOver,'_._')#</td>
							<!-- WINTER -->
							<cfif billingStudentIdWinter GT 0><cfset link = true><cfelse><cfset link = false></cfif>
							<td class="bold-left-border"><cfif link><a href='javascript:goToBillingRecord(#billingStudentIdWinter#);'></cfif>#NumberFormat(WinterNoOfCredits,'_._')#<cfif link></a></cfif></td>
							<td>#NumberFormat(WinterNoOfCreditsOver,'_._')#</td>
							<td>#NumberFormat(WinterNoOfDays,'_._')#</td>
							<td>#NumberFormat(WinterNoOfDaysOver,'_._')#</td>
							<!-- SPRING -->
							<cfif billingStudentIdSpring GT 0><cfset link = true><cfelse><cfset link = false></cfif>
							<td class="bold-left-border"><cfif link><a href='javascript:goToBillingRecord(#billingStudentIdSpring#);'></cfif>#NumberFormat(SpringNoOfCredits,'_._')#<cfif link></a></cfif></td>
							<td>#NumberFormat(SpringNoOfCreditsOver,'_._')#</td>
							<td>#NumberFormat(SpringNoOfDays,'_._')#</td>
							<td>#NumberFormat(SpringNoOfDaysOver,'_._')#</td>
							<!-- Total Credits -->
							<td class="bold-left-border">#NumberFormat(FYTotalNoOfCredits,'_._')#</td>
							<!-- Max Total Credits -->
							<td>#NumberFormat(FYMaxTotalNoOfCredits,'_._')#</td>
							<!-- Total Days -->
							<td>#NumberFormat(FYTotalNoOfDays,'_._')#</td>
							<!-- Max Total Days -->
							<td>#NumberFormat(FYMaxTotalNoOfDays,'_._')#</td>
	                    </tr>
	                	</cfoutput>
					</cfif>
	            </tbody>
				<!-- FOOTER -->
				<tfoot>
					<cfquery dbtype="query" name="totals">
						select sum(SummerNoOfCredits) SummerNoOfCredits, sum(SummerNoOfDays) SummerNoOfDays
								,CAST(sum(FallNoOfCredits) as decimal) FallNoOfCredits, CAST(sum(FallNoOfCreditsOver) as decimal) FallNoOfCreditsOver
								,sum(FallNoOfDays) FallNoOfDays, sum(FallNoOfDaysOver) FallNoOfDaysOver
								,sum(WinterNoOfCredits) WinterNoOfCredits, sum(WinterNoOfCreditsOver) WinterNoOfCreditsOver
								,sum(WinterNoOfDays) WinterNoOfDays, sum(WinterNoOfDaysOver) WinterNoOfDaysOver
								,sum(SpringNoOfCredits) SpringNoOfCredits, sum(SpringNoOfCreditsOver) SpringNoOfCreditsOver
								,sum(SpringNoOfDays) SpringNoOfDays, sum(SpringNoOfDaysOver) SpringNoOfDaysOver
								,sum(FYTotalNoOfCredits) FYTotalNoOfCredits, sum(FYMaxTotalNoOfCredits) FYMaxTotalNoOfCredits
								,sum(FYTotalNoOfDays) FYTotalNoOfDays, sum(FYMaxTotalNoOfDays) FYMaxTotalNoOfDays
						from qryData
					</cfquery>
					<cfoutput query="totals">
					<tr id="dt-footer1">
						<td></td>
						<td></td>
						<td>Totals</td>
						<!--- have to use DecimalFormat or does not round properly --->
						<!-- SUMMER -->
						<td class="bold-left-border">#NumberFormat(DecimalFormat(SummerNoOfCredits),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(SummerNoOfDays),'_._')#</td>
						<!-- FALL -->
						<td class="bold-left-border">#NumberFormat(Replace(DecimalFormat(FallNoOfCredits),",",""),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(FallNoOfCreditsOver),'_._')#</td>
						<td>#NumberFormat(Replace(DecimalFormat(FallNoOfDays),',',''),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(FallNoOfDaysOver),'_._')#</td>
						<!-- WINTER -->
						<td class="bold-left-border">#NumberFormat(DecimalFormat(WinterNoOfCredits),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(WinterNoOfCreditsOver),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(WinterNoOfDays),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(WinterNoOfDaysOver),'_._')#</td>
						<!-- SPRING -->
						<td class="bold-left-border">#NumberFormat(DecimalFormat(SpringNoOfCredits),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(SpringNoOfCreditsOver),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(SpringNoOfDays),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(SpringNoOfDaysOver),'_._')#</td>
						<!-- Grand Totals -->
						<td class="bold-left-border">#NumberFormat(Replace(DecimalFormat(FYTotalNoOfCredits),',',''),'_._')#</td>
						<td>#NumberFormat(Replace(DecimalFormat(FYMaxTotalNoOfCredits),',',''),'_._')#</td>
						<td>#NumberFormat(Replace(DecimalFormat(FYTotalNoOfDays),',',''),'_._')#</td>
						<td>#NumberFormat(Replace(DecimalFormat(FYMaxTotalNoOfDays),',',''),'_._')#</td>
					</tr>
					<tr id="dt-footer2">
						<td></td>
						<td colspan="2">Max Billing</td>
						<!-- Summer -->
						<td colspan="2" style="text-align:center;"  class="bold-left-border">#NumberFormat(Replace(DecimalFormat(SummerNoOfDays),',',''),'_._')#</td>
						<!-- Fall -->
						<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat(Replace(DecimalFormat(FallNoOfDays-FallNoOfDaysOver),',',''),'_._')#</td>
						<!-- Winter -->
						<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat(Replace(DecimalFormat(WinterNoOfDays-WinterNoOfDaysOver),',',''),'_._')#</td>
						<!-- Spring -->
						<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat(Replace(DecimalFormat(SpringNoOfDays-SpringNoOfDaysOver),',',''),'_._')#</td>
						<td class="no-border"></td>
						<td class="no-border"></td>
						<td class="no-border"></td>
						<td class="no-border"></td>
					</tr>
				</cfoutput>
				</tfoot>
		</table>

	<cfsavecontent variable="pcc_scripts">
	<script>

		$(document).ready(function() {
		    setUpTable();
		} );

		function setUpTable(){
			$('#dt_table').dataTable( {
		    	dom: '<"top"iBf>rt<"bottom"lp>',
		    	// order by lastname
		    	order:1,
		    	bSort:false,
		        scrollY: "400px",
		        scrollX: true,
		        //scrollCollapse: true,
		        paging: false,
        		fixedColumns:true,
				//print button
		        buttons: [
		         {text:'print',
		         	action: function(){
		         		window.open('ReportTermPrintTable.cfm');
		         	}
		         }
		    ] //end buttons

		    } ); //end data table
		} //end setup table

		function goToBillingRecord(billingStudentId){
			sessionStorage.clear();
			sessionStorage.setItem('returnToReport', '<cfoutput>#cgi.script_name#?#cgi.query_string#</cfoutput>');
			sessionStorage.setItem("showNext", true);
			var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
			$.post("SaveSession.cfm", data, function(){
				window.open('programStudentDetail.cfm?billingStudentId='+billingStudentId);
			});
		}



	</script>
	</cfsavecontent>
	<cfinclude template="includes/footer.cfm">