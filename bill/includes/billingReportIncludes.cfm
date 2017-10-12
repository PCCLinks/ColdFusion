<!---<cfdump var="#Session#">--->
<cfset programValue="" >
<cfif isDefined("Session.Program") >
	<cfset programValue="#Session.Program#" >
</cfif>
<cfset schooldistrictValue="" >
<cfif isDefined("Session.schooldistrict") >
	<cfset schooldistrictValue="#Session.schooldistrict#" >
</cfif>
<cfset termValue="" >
<cfif isDefined("Session.term") >
	<cfset termValue="#Session.term#" >
</cfif>
<cfinvoke component="LookUp" method = "getProgramYearTerms" term="#termValue#" returnvariable="terms"></cfinvoke>
<cfinvoke component="ProgramBilling" method="billingReport" returnvariable="qryData">
	<cfinvokeargument name="program" value="#programValue#">
	<cfinvokeargument name="schooldistrict" value="#schooldistrictvalue#">
	<cfinvokeargument name="term" value="#termValue#">
</cfinvoke>


<div class="row">
	<table width="800px"><tr><td class="header">
		<h3>College Quarterly Credit - Equivalent Instructional Days</h3>
		<cfoutput><b>All Students at  #qryData.Program# for #terms.term1# and #terms.currentterm#</b></cfoutput>
	</td></tr></table>
</div>

<div class="row">
<table id="dt_table" cellspacing="0" width="100%">
		<cfoutput>
            <thead class="header-print">
                <tr >
                    <th>
						<table >
							<tr><td colspan="4">Student</td></tr>
							<tr>
								<td></td>
								<td>Entry Date</td>
								<td>Exit Date</td>
								<td></td>
							</tr>
						</table>
					</th>
					<th colspan="2">
						<table>
							<tr><td colspan="2" >SUMMER</td></tr>
							<tr><td>Credits</td>
								<td>Days</td>
							</tr>
						</table>
					</th>
					<th colspan="4">
						<table>
							<tr><td colspan="4">FALL</td></tr>
							<tr><td>Credits</td>
								<td>Over</td>
								<td>Days</td>
								<td>Over</td>
							</tr>
						</table>
					</th>
					<th colspan="4">
						<table>
							<tr><td colspan="4">WINTER</td></tr>
							<tr><td>Credits</td>
								<td>Over</td>
								<td>Days</td>
								<td>Over</td>
							</tr>
						</table>
					</th>
					<th colspan="4">
						<table>
							<tr><td colspan="4">SPRING</td></tr>
							<tr><td>Credits</td>
								<td>Over</td>
								<td>Days</td>
								<td>Over</td>
							</tr>
						</table>
					</th>
					<th>Total Credits</th>
					<th>Max Total Credits</th>
					<th>Total Days</th>
					<th>Max Total Days</th>
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
                        <td ><input type="hidden" id="bannerGNumber" name="bannerGNumber" value="#bannerGNumber#">
						<table >
								<tr><td class="name-column" colspan="4">
									<cfif IsDefined("attributes")>
									 	<cfif StructKeyExists(attributes, "onScreen")>
											<a href="javascript:goToDetail('#bannerGNumber#');">#qryData.LASTNAME#, #qryData.FIRSTNAME#</a>
										</cfif>
									<cfelse>
										#qryData.LASTNAME#, #qryData.FIRSTNAME#
									</cfif>
								</td></tr>
								<tr><td class="no-border">&nbsp;</td><td class="no-border-text-align-left" >#qryData.EnrolledDate#</td><td class="no-border-text-align-left">#qryData.ExitDate#</td><td class="no-border" ></td></tr>
							</table>
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
				<tr>
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
					<!-- Credits -->
					<td class="bold-left-border">#NumberFormat(Variables.winterCredits,'_._')#</td>
					<!-- Credits Over -->
					<td>#NumberFormat(Variables.winterCreditsOver,'_._')#</td>
					<!-- Days -->
					<td>#NumberFormat(Variables.winterCredits/36*175,'_._')#</td>
					<!-- Days Over -->
					<td>#NumberFormat(Variables.winterCreditsOver/36*175,'_._')#</td>
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
				<tr>
					<td>Max Billing</td>
					<td colspan="2" style="text-align:center;"  class="bold-left-border">#NumberFormat(Variables.summerCredits/36*175,'_._')#</td>
					<cfif #termValue# GTE #terms.term2#>
					<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat((Variables.fallCredits-Variables.fallCreditsOver)/36*175,'_._')#</td>
					</cfif>
					<cfif #termValue# GTE #terms.term3#>
					<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat((Variables.winterCredits-Variables.winterCreditsOver)/36*175,'_._')#</td>
					</cfif>
					<cfif #termValue# GTE #terms.term4#>
					<td colspan="4" style="text-align:center;"  class="bold-left-border">#NumberFormat((Variables.springCredits-Variables.springCreditsOver)/36*175,'_._')#</td>
					</cfif>
					<td class="no-border"></td>
					<td class="no-border"></td>
					<td class="no-border"></td>
					<td class="no-border"></td>
				</tr>
			</tfoot>
		</cfoutput>
	</table>
</div>
