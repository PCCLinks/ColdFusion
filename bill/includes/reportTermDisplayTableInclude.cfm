<cfset data = Session.reportTermData>
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
			<cfif not isNull(data)>
				<cfoutput query="data">
                   <tr>
                    <td><a href='javascript:goToBillingRecord(#BillingStudentIdMostCurrent#);'>#LASTNAME#,&nbsp;#FIRSTNAME#</a></td>
					<td>#bannerGNumber#</td>
                    <td>#EntryDate# <cfif ExitDate NEQ "">-#ExitDate#</cfif></td>
					<!-- SUMMER -->
					<td class="bold-left-border">#NumberFormat(SummerNoOfCredits,'_._')#</td>
					<td>#NumberFormat(SummerNoOfDays,'_._')#</td>
					<!-- FALL -->
					<td class="bold-left-border">#NumberFormat(FallNoOfCredits,'_._')#</td>
					<td>#NumberFormat(FallNoOfCreditsOver,'_._')#</td>
					<td>#NumberFormat(FallNoOfDays,'_._')#</td>
					<td>#NumberFormat(FallNoOfDaysOver,'_._')#</td>
					<!-- WINTER -->
					<td class="bold-left-border">#NumberFormat(WinterNoOfCredits,'_._')#</td>
					<td>#NumberFormat(WinterNoOfCreditsOver,'_._')#</td>
					<td>#NumberFormat(WinterNoOfDays,'_._')#</td>
					<td>#NumberFormat(WinterNoOfDaysOver,'_._')#</td>
					<!-- SPRING -->
					<td class="bold-left-border">#NumberFormat(SpringNoOfCredits,'_._')#</td>
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
				from data
			</cfquery>
			<cfoutput query="totals">
			<tr id="dt-footer1">
				<td></td>
				<td></td>
				<td>Totals</td>
				<!--- have to use DecimalFormat or does not round properly --->
				<!-- SUMMER -->
				<td class="bold-left-border">#NumberFormat(Replace(DecimalFormat(SummerNoOfCredits),",",""),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(SummerNoOfDays),",",""),'_._')#</td>
				<!-- FALL -->
				<td class="bold-left-border">#NumberFormat(Replace(DecimalFormat(FallNoOfCredits),",",""),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(FallNoOfCreditsOver),",",""),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(FallNoOfDays),',',''),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(FallNoOfDaysOver),",",""),'_._')#</td>
				<!-- WINTER -->
				<td class="bold-left-border">#NumberFormat(Replace(DecimalFormat(WinterNoOfCredits),",",""),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(WinterNoOfCreditsOver),",",""),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(WinterNoOfDays),",",""),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(WinterNoOfDaysOver),",",""),'_._')#</td>
				<!-- SPRING -->
				<td class="bold-left-border">#NumberFormat(Replace(DecimalFormat(SpringNoOfCredits),",",""),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(SpringNoOfCreditsOver),",",""),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(SpringNoOfDays),",",""),'_._')#</td>
				<td>#NumberFormat(Replace(DecimalFormat(SpringNoOfDaysOver),",",""),'_._')#</td>
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


