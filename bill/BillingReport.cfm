<cfset pcc_title = 'PCC Links Billing' />
<cfinclude template="includes/header.cfm">

<cfset Variables.program="#Session.program#" >
<cfset Variables.schooldistrict="#Session.schooldistrict#" >
<cfset Variables.term="#Session.term#" >
<!---<cfif isDefined("Session.Program") >
	<cfset programValue="#Session.Program#" >
</cfif>
<cfset schooldistrictValue="" >
<cfif isDefined("Session.schooldistrict") >
	<cfset schooldistrictValue="#Session.schooldistrict#" >
</cfif>
<cfset termValue="" >
<cfif isDefined("Session.term") >
	<cfset termValue="#Session.term#" >
</cfif>--->
<cfinvoke component="LookUp" method = "getProgramYearTerms" term="#Variables.term#" returnvariable="terms"></cfinvoke>
<cfinvoke component="ProgramBilling" method="billingReport" returnvariable="qryData">
	<cfinvokeargument name="program" value="#Variables.program#">
	<cfinvokeargument name="schooldistrict" value="#Variables.schooldistrict#">
	<cfinvokeargument name="term" value="#Variables.term#">
</cfinvoke>
<cfinvoke component="LookUp" method="getProgramYearTerms" value="terms"></cfinvoke>
<style>

		table tbody td, table tfoot td{
			text-align:right;
		}
		table thead th, table tbody td, table tfoot td {
			border-color:black;
			border-style:solid solid none none;
			border-width: 0.5px;
			background-color:white;
		}
		.no-border{
			border-color:none;
			border-style:none;
			border-width: 0px;
		}
		.bold-left-border{
			border-left-width:1px;
			border-left-style:solid;
		}
		.bold-right-border{
			border-right-width:1px;
			border-right-style:solid;
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
	</style>


	<div class="row" id="tableheader">
		<table width="100%" style="border-style:none;">
			<tr>
				<td class="bottom-border" style="text-align:left; font-size:x-small">
					<cfoutput>#Variables.schooldistrict#</cfoutput>
				</td>
				<td class="bottom-border" style="text-align:right; font-size:x-small">
					Alternative Education Program
				</td>
			</tr>
			<tr>
				<td class="no-border" style="text-align:center">
					<h3>College Quarterly Credit - Equivalent Instructional Days</h3>
					<cfoutput><b>All Students at <cfif qryData.Program EQ "gtc">PCC/HSC<cfelse>#qryData.Program#</cfif> for #qryData.reportingStartDate# and #qryData.reportingEndDate#</b></cfoutput>
				</td>
			</tr>
		</table>
	</div>


	<table id="dt_table" class="hover compact">
		<!---<div class="row">--->
			<cfoutput>
	            <thead >
	                <tr id="dt-header">
	                    <th>G</th>
						<th class="name-column">Student</th>
						<th id="SummerNoOfCredits" colspan="2" class="bold-left-border">SUMMER</th>
						<th colspan="4" id="FallNoOfCredits" class="bold-left-border">FALL</th>
						<th colspan="4" id="WinterNoOfCredits" class="bold-left-border">WINTER</th>
						<th colspan="4" id="SpringNoOfCredits" class="bold-left-border">SPRING</th>
						<th class="bold-left-border border-no-bottom"></th>
						<th class="border-no-bottom"></th>
						<th class="border-no-bottom"></th>
						<th class="border-no-bottom"></th>
	                </tr>
	                <tr>
						<th></th>
	                    <th class="border-left-none name-column" style="white-space:nowrap">Entry Date - Exit Date</th>
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
						<th class="border-no-top" >Max Total Credit</th>
						<th class="border-no-top" >Total Days</th>
						<th class="border-no-top" >Max Bill Days</th>
	                </tr>
	            </thead>
	            </cfoutput>
	            <tbody>
					<cfif not isNull(qryData)>
						<cfoutput query="qryData">
	                    <tr>
							<td>#qryData.bannerGNumber#</td>
	                        <td id="namecol" class="name-column" style="white-space:nowrap"><b>#qryData.LASTNAME#, #qryData.FIRSTNAME#</b><br/>
									#qryData.EnrolledDate# <cfif qryData.ExitDate NEQ "">-#qryData.ExitDate#</cfif>
							</td>
							<!-- SUMMER -->
							<td class="bold-left-border">#NumberFormat(qryData.SummerNoOfCredits,'_._')#</td>
							<td>#NumberFormat(qryData.SummerNoOfDays,'_._')#</td>
							<!-- FALL -->
							<td class="bold-left-border">#NumberFormat(qryData.FallNoOfCredits,'_._')#</td>
							<td>#NumberFormat(qryData.FallNoOfCreditsOver,'_._')#</td>
							<td>#NumberFormat(qryData.FallNoOfDays,'_._')#</td>
							<td>#NumberFormat(qryData.FallNoOfDaysOver,'_._')#</td>
							<!-- WINTER -->
							<td class="bold-left-border">#NumberFormat(qryData.WinterNoOfCredits,'_._')#</td>
							<td>#NumberFormat(qryData.WinterNoOfCreditsOver,'_._')#</td>
							<td>#NumberFormat(qryData.WinterNoOfDays,'_._')#</td>
							<td>#NumberFormat(qryData.WinterNoOfDaysOver,'_._')#</td>
							<!-- SPRING -->
							<td class="bold-left-border">#NumberFormat(qryData.SpringNoOfCredits,'_._')#</td>
							<td>#NumberFormat(qryData.SpringNoOfCreditsOver,'_._')#</td>
							<td>#NumberFormat(qryData.SpringNoOfDays,'_._')#</td>
							<td>#NumberFormat(qryData.SpringNoOfDaysOver,'_._')#</td>
							<!-- Total Credits -->
							<td class="bold-left-border">#NumberFormat(qryData.FYTotalNoOfCredits,'_._')#</td>
							<!-- Max Total Credits -->
							<td>#NumberFormat(qryData.FYMaxTotalNoOfCredits,'_._')#</td>
							<!-- Total Days -->
							<td>#NumberFormat(qryData.FYTotalNoOfDays,'_._')#</td>
							<!-- Max Total Days -->
							<td>#NumberFormat(qryData.FYMaxTotalNoOfDays,'_._')#</td>
	                    </tr>
	                	</cfoutput>
					</cfif>
	            </tbody>
				<!-- FOOTER -->
				<tfoot>
					<cfquery dbtype="query" name="totals">
						select sum(SummerNoOfCredits) SummerNoOfCredits, sum(SummerNoOfDays) SummerNoOfDays
								,sum(FallNoOfCredits) FallNoOfCredits, sum(FallNoOfCreditsOver) FallNoOfCreditsOver
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
						<td>Totals</td>
						<!--- have to use DecimalFormat or does not round properly --->
						<!-- SUMMER -->
						<td class="bold-left-border">#NumberFormat(DecimalFormat(SummerNoOfCredits),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(SummerNoOfDays),'_._')#</td>
						<!-- FALL -->
						<td class="bold-left-border">#NumberFormat(DecimalFormat(FallNoOfCredits),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(FallNoOfCreditsOver),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(FallNoOfDays),'_._')#</td>
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
						<td class="bold-left-border">#NumberFormat(DecimalFormat(FYTotalNoOfCredits),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(FYMaxTotalNoOfCredits),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(FYTotalNoOfDays),'_._')#</td>
						<td>#NumberFormat(DecimalFormat(FYMaxTotalNoOfDays),'_._')#</td>
					</tr>
					<tr id="dt-footer2">
						<td></td>
						<td>Max Billing</td>
						<!-- Summer -->
						<td colspan="2" style="text-align:center;"  class="bold-left-border">#NumberFormat(DecimalFormat(SummerNoOfDays),'_._')#</td>
						<!-- Fall -->
						<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat(DecimalFormat(FallNoOfDays-FallNoOfDaysOver),'_._')#</td>
						<!-- Winter -->
						<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat(DecimalFormat(WinterNoOfDays-WinterNoOfDaysOver),'_._')#</td>
						<!-- Spring -->
						<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat(DecimalFormat(SpringNoOfDays-SpringNoOfDaysOver),'_._')#</td>
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
			$('#dt_table').DataTable( {
		    	dom: '<"top"iBf>rt<"bottom"lp>',
		    	// order by lastname
		    	order:1,
		    	bSort:false,
		    	//set up hyperlinks for each cell of data
		    	columnDefs: [
		    			//summer
						{targets:2,
						 	sortable:false,
						 	render: function ( data, type, row ) {
		                  				return '<a href="javascript:goToDetail(\'<cfoutput>#terms.term1#</cfoutput>\', \'' + row[0] +'\')">' + data + '</a>';
		             				}
						 	},
						 //fall
						{targets:4,
						 	sortable:false,
						 	render: function ( data, type, row ) {
		                  				return '<a href="javascript:goToDetail(\'<cfoutput>#terms.term2#</cfoutput>\', \'' + row[0] +'\')">' + data + '</a>';
		             				}
						 	},
						 //winter
						{targets:8,
						 	sortable:false,
						 	render: function ( data, type, row ) {
		                  				return '<a href="javascript:goToDetail(\'<cfoutput>#terms.term3#</cfoutput>\', \'' + row[0] +'\')">' + data + '</a>';
		             				}
						 	},
						 //spring
						{targets:12,
						 	sortable:false,
						 	render: function ( data, type, row ) {
		                  				return '<a href="javascript:goToDetail(\'<cfoutput>#terms.term4#</cfoutput>\', \'' + row[0] +'\')">' + data + '</a>';
		             				}
						 	}


						],
				//print button
		        buttons: [
		          {	extend:'print',
		            autoPrint:false,
		            header:true,
		            footer:true,
		            //all columns but first GNumber column
		            exportOptions: { columns: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]},
		            orientation:'landscape',

		            // Set up some custom HTML for printing
		            customize: function ( win ) {
		            	//set body font size and type
		            	$(win.document.body)
		                        .css( 'font-size', '8pt' )
		                        .css('font-family', 'Times New Roman');

						//sets same fonts for the table
		                $(win.document.body).find( 'table' )
		                        .css( 'font-size', 'inherit' );

						//reset the name column so that the breaks are put in properly - does not format right
						//automatically
						$(win.document.body).find('td').each(function(){
																if(this.cellIndex == 0){
																	this.style.textAlign='left';
																	this.style.columnWidth = '150px';
																	this.innerHTML = this.innerHTML.replace('\t\t\t','<br>');
																}
															});

						 //default is only the last row of the table header - adding back in first row
						 var firstHeader = $('#dt-header').html();
						 var firstCol = '<th rowspan=\"1\" colspan=\"1\">G</th>';
						 firstHeader = firstHeader.substring(firstCol.length, firstHeader.length);
		     			 $(win.document.body).find( 'thead' ).prepend('<tr>' + firstHeader + '</tr>');

						//default is only the first row of the table footer - adding back in the last row
						var footer1 =  $('#dt-footer1').html();
						footer1 = footer1.substring(firstCol.length-1, footer1.length);
						var footer2 = $('#dt-footer2').html();
						footer2 = footer2.substring(firstCol.length-1, footer2.length);
		     			 $(win.document.body).find( 'tfoot' ).replaceWith('<tfoot><tr>' + footer1 + '</tr><tr>' + footer2 + '</tr></tfoot>');

						//adding in the document header
		     			 $(win.document.body).find('h1').replaceWith('<style> .no-border{border-style:none !important} .bottom-border{ 	border-top-style:none;	border-left-style:none; border-right-style:none; border-bottom-style:solid; } </style><div class="row">' + $('#tableheader').html() + '</div><br><br>');
		            } //end customize
		        } //end print button definition
		    ] //end buttons

		    } ); //end data table
		} //end setup table

		function goToDetail(term, bannerGNumber){
			sessionStorage.setItem('bannerGNumber', bannerGNumber);
			sessionStorage.setItem('term', term);
			sessionStorage.setItem('showNext', false);
			var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
	 			$.post("SaveSession.cfm", data, function(){
	 				window.open('programStudentDetail.cfm','_blank');
	 			});
			}

	</script>
	</cfsavecontent>
	<cfinclude template="includes/footer.cfm">