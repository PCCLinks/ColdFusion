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
					<cfoutput><b>All Students at  #qryData.Program# for #terms.term1# and #terms.currentterm#</b></cfoutput>
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
	            <tbody>
					<cfif not isNull(qryData)>
						<cfset Variables.summerCredits = 0>
						<cfset Variables.fallCredits = 0>
						<cfset Variables.winterCredits = 0>
						<cfset Variables.springCredits = 0>
						<cfset Variables.fallCreditsOver = 0>
						<cfset Variables.winterCreditsOver = 0>
						<cfset Variables.springCreditsOver = 0>
						<cfset Variables.totalCredits = 0>

						<cfloop query="qryData">
						<cfset Variables.personOverage = 0>
	                    <tr>
							<td>#qryData.bannerGNumber#</td>
	                        <td id="namecol" class="name-column" style="white-space:nowrap"><b>#qryData.LASTNAME#, #qryData.FIRSTNAME#</b><br/>
									#qryData.EnrolledDate#-#qryData.ExitDate#
							</td>
							<!-- SUMMER -->
							<!-- Number of Credits -->
							<td class="bold-left-border">
								<cfif LEN(qryData.SummerNoOfCredits) EQ 0>0
								<cfelse>#NumberFormat(qryData.SummerNoOfCredits,'_._')#
								</cfif>
							</td>
							<!-- Number of Days -->
							<td>
								<cfif LEN(qryData.SummerNoOfCredits) EQ 0>0
								<cfelse>#NumberFormat(qryData.SummerNoOfCredits/36*175,'_._')#
								</cfif>
							</td>
							<!-- FALL -->
							<!-- Determine Overage -->
							<cfset Variables.overage = qryData.SummerNoOfCredits+qryData.FallNoOfCredits>
							<cfif Variables.overage GT 36>
								<cfset Variables.overage = Variables.overage -36>
								<cfset Variables.fallCreditsOver = Variables.fallCreditsOver + Variables.overage>
								<cfset Variables.personOverage = Variables.fallCreditsOver>
							<cfelse>
								<cfset Variables.overage = 0>
							</cfif>
							<!-- Number of Credits -->
							<td class="bold-left-border">
								<cfif LEN(qryData.FallNoOfCredits) EQ 0>0
								<cfelse>#NumberFormat(qryData.FallNoOfCredits,'_._')#</cfif>
							</td>
							<!-- Overage Credits -->
							<td>
								<cfif Variables.overage GT 0>#NumberFormat(Variables.overage,'_._')#</cfif>
							</td>
							<!-- Number of Days -->
							<td>
								<cfif LEN(qryData.FallNoOfCredits) EQ 0>0
								<cfelse>#NumberFormat(qryData.FallNoOfCredits/36*175,'_._')#</cfif>
							</td>
							<!-- Overage Days -->
							<td>
								<cfif Variables.overage GT 0>#NumberFormat(Variables.overage/36*175,'_._')#</cfif>
							</td>
							<!-- WINTER -->
							<!-- Determine Overage -->
							<cfset Variables.overage = qryData.SummerNoOfCredits+qryData.FallNoOfCredits+qryData.WinterNoOfCredits-Variables.overage>
							<cfif Variables.overage GT 36>
								<cfset Variables.overage = Variables.overage -36>
								<cfset Variables.winterCreditsOver = Variables.winterCreditsOver + Variables.overage>
								<cfset Variables.personOverage = Variables.personOverage + Variables.winterCreditsOver>
							<cfelse>
								<cfset Variables.overage = 0>
							</cfif>
							<!-- Number of Credits -->
							<td class="bold-left-border">
								<cfif LEN(qryData.WinterNoOfCredits) EQ 0>0
								<cfelse>#NumberFormat(qryData.WinterNoOfCredits,'_._')#</cfif>
							</td>
							<!-- Overage Credits -->
							<td>
								<cfif Variables.overage GT 0>#NumberFormat(Variables.overage,'_._')#</cfif>
							</td>
							<!-- Number of Days -->
							<td>
								<cfif LEN(qryData.WinterNoOfCredits) EQ 0>0
								<cfelse>#NumberFormat(qryData.WinterNoOfCredits/36*175,'_._')#</cfif>
							</td>
							<!-- Overage Days -->
							<td>
								<cfif Variables.overage GT 0>#NumberFormat(Variables.overage/36*175,'_._')#</cfif>
							</td>
							<!-- SPRING -->
							<!-- Determine Overage -->
							<cfset Variables.overage = qryData.SummerNoOfCredits+qryData.FallNoOfCredits+qryData.WinterNoOfCredits+qryData.SpringNoOfCredits-Variables.overage>
							<cfif Variables.overage GT 36>
								<cfset Variables.overage = Variables.overage -36>
								<cfset Variables.springCreditsOver = Variables.springCreditsOver + Variables.overage>
								<cfset Variables.personOverage = Variables.personOverage + Variables.springCreditsOver>
							<cfelse>
								<cfset Variables.overage = 0>
							</cfif>
							<!-- Number of Credits -->
							<td class="bold-left-border">
								<cfif LEN(qryData.SpringNoOfCredits) EQ 0>0
								<cfelse>#NumberFormat(qryData.SpringNoOfCredits,'_._')#</cfif>
							</td>
							<!-- Overage Credits -->
							<td>
								<cfif Variables.overage GT 0>#NumberFormat(Variables.overage,'_._')#</cfif>
							</td>
							<!-- Number of Days -->
							<td>
								<cfif LEN(qryData.SpringNoOfCredits) EQ 0>0
								<cfelse>#NumberFormat(qryData.SpringNoOfCredits/36*175,'_._')#</cfif>
							</td>
							<!-- Overage Days -->
							<td>
								<cfif Variables.overage GT 0>#NumberFormat(Variables.overage/36*175,'_._')#</cfif>
							</td>
							<!-- Total Credits -->
							<td class="bold-left-border">#NumberFormat(qryData.FYTotalNoOfCredits,'_._')#</td>
							<!-- Max Total Credits -->
							<td>#NumberFormat(qryData.FYTotalNoOfCredits-Variables.personOverage,'_._')#</td>
							<!-- Total Days -->
							<td>#NumberFormat(qryData.FYTotalNoOfCredits/36*175,'_._')#</td>
							<!-- Max Total Days -->
							<td>#NumberFormat((qryData.FYTotalNoOfCredits-Variables.personOverage)/36*175,'_._')#</td>
	                    </tr>
							<!-- Totals for Footer -->
							<cfset Variables.summerCredits = Variables.summerCredits + qryData.SummerNoOfCredits>
							<cfset Variables.fallCredits = Variables.fallCredits + qryData.fallNoOfCredits>
							<cfset Variables.winterCredits = Variables.winterCredits + qryData.winterNoOfCredits>
							<cfset Variables.springCredits = Variables.springCredits + qryData.springNoOfCredits>
							<cfset Variables.totalCredits = Variables.totalCredits + qryData.FYTotalNoOfCredits>
	                	</cfloop>
					</cfif>
	            </tbody>
				<!-- FOOTER -->
				<tfoot>
					<tr id="dt-footer1">
						<td></td>
						<td>Totals</td>
						<!-- SUMMER -->
						<!-- Credits -->
						<td class="bold-left-border">#NumberFormat(Variables.summerCredits,'_._')#</td>
						<!-- Days -->
						<td>#NumberFormat(Variables.summerCredits/36*175,'_._')#</td>
						<!-- FALL -->
						<!-- Credits -->
						<td class="bold-left-border">#NumberFormat(Variables.fallCredits,'_._')#</td>
						<!-- Credits Over -->
						<td>#NumberFormat(Variables.fallCreditsOver,'_._')#</td>
						<!-- Days -->
						<td>#NumberFormat(Variables.fallCredits/36*175,'_._')#</td>
						<!-- Days Over -->
						<td>#NumberFormat(Variables.fallCreditsOver/36*175,'_._')#</td>
						<!-- WINTER -->
						<!-- Credits -->
						<td class="bold-left-border">#NumberFormat(Variables.winterCredits,'_._')#</td>
						<!-- Credits Over -->
						<td>#NumberFormat(Variables.winterCreditsOver,'_._')#</td>
						<!-- Days -->
						<td>#NumberFormat(Variables.winterCredits/36*175,'_._')#</td>
						<!-- Days Over -->
						<td>#NumberFormat(Variables.winterCreditsOver/36*175,'_._')#</td>
						<!-- SPRING -->
						<!-- Credits -->
						<td class="bold-left-border">#NumberFormat(Variables.springCredits,'_._')#</td>
						<!-- Credits Over -->
						<td>#NumberFormat(Variables.springCreditsOver,'_._')#</td>
						<!-- Days -->
						<td>#NumberFormat(Variables.springCredits/36*175,'_._')#</td>
						<!-- Days Over -->
						<td>#NumberFormat(Variables.springCreditsOver/36*175,'_._')#</td>
						<!-- Grand Totals -->
						<cfset Variables.totalOverage = Variables.fallCreditsOver+Variables.winterCreditsOver+Variables.springCreditsOver>
						<!-- Total Credit -->
						<td class="bold-left-border">#NumberFormat(Variables.totalCredits,'_._')#</td>
						<!-- Max Total Credit -->
						<td>#NumberFormat(Variables.totalCredits-Variables.totalOverage,'_._')#</td>
						<!-- Total Days -->
						<td>#NumberFormat(Variables.totalCredits/36*175,'_._')#</td>
						<!-- Max Bill Days -->
						<td>#NumberFormat((Variables.totalCredits-Variables.totalOverage)/36*175,'_._')#</td>
					</tr>
					<tr id="dt-footer2">
						<td></td>
						<td>Max Billing</td>
						<!-- Summer -->
						<td colspan="2" style="text-align:center;"  class="bold-left-border">#NumberFormat(Variables.summerCredits/36*175,'_._')#</td>
						<!-- Fall -->
						<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat((Variables.fallCredits-Variables.fallCreditsOver)/36*175,'_._')#</td>
						<!-- Winter -->
						<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat((Variables.winterCredits-Variables.winterCreditsOver)/36*175,'_._')#</td>
						<!-- Spring -->
						<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat((Variables.springCredits-Variables.springCreditsOver)/36*175,'_._')#</td>
						<td class="no-border"></td>
						<td class="no-border"></td>
						<td class="no-border"></td>
						<td class="no-border"></td>
					</tr>
				</tfoot>
			</cfoutput>
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